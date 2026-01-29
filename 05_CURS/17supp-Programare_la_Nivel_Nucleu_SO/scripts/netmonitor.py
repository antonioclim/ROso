#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
netmonitor.py - Monitorizare conexiuni rețea cu BCC/eBPF

Descriere:
    Script de monitorizare a conexiunilor de rețea TCP/UDP utilizând
    tehnologia eBPF. Afișează în timp real conexiunile noi, conexiunile
    închise, retransmisii și statistici agregate.

Caracteristici:
    • Monitorizare conexiuni TCP outbound (connect)
    • Monitorizare conexiuni TCP inbound (accept)
    • Detectare retransmisii TCP
    • Statistici agregate per proces
    • Export opțional în format JSON

Utilizare:
    sudo python3 netmonitor.py              # Monitorizare toate procesele
    sudo python3 netmonitor.py -p 1234      # Filtrare după PID
    sudo python3 netmonitor.py -d 60        # Rulare 60 secunde
    sudo python3 netmonitor.py --json       # Export statistici JSON la final

Cerințe:
    • Python 3.6+
    • BCC (apt install bpfcc-tools python3-bcc)
    • Linux kernel 4.9+ (recomandat 5.x+)
    • Privilegii root

Autor: Curs SO - ASE București CSIE
Versiune: 1.0
"""

from __future__ import print_function
from bcc import BPF
from time import sleep, strftime
from socket import inet_ntop, AF_INET, AF_INET6
from struct import pack
import argparse
import signal
import sys
import json
from collections import defaultdict

# ═══════════════════════════════════════════════════════════════════════════
# PROGRAM eBPF (C RESTRICȚIONAT)
# ═══════════════════════════════════════════════════════════════════════════

bpf_program = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>
#include <linux/tcp.h>

// Structură pentru evenimente trimise în user space
struct event_t {
    u64 ts_ns;          // Timestamp nanosecunde
    u32 pid;            // Process ID
    u32 tid;            // Thread ID
    u32 uid;            // User ID
    u32 saddr;          // Source address (IPv4)
    u32 daddr;          // Destination address (IPv4)
    u16 sport;          // Source port
    u16 dport;          // Destination port
    u8 event_type;      // 1=connect, 2=accept, 3=close, 4=retrans
    char comm[16];      // Process name
};

// Tipuri de evenimente
#define EVENT_CONNECT   1
#define EVENT_ACCEPT    2
#define EVENT_CLOSE     3
#define EVENT_RETRANS   4

// Buffer pentru evenimente către user space
BPF_PERF_OUTPUT(events);

// Hartă pentru a urmări socket-urile în curs de conectare
BPF_HASH(currsock, u32, struct sock *);

// Hartă pentru statistici per proces
BPF_HASH(connect_count, u32, u64);
BPF_HASH(accept_count, u32, u64);
BPF_HASH(bytes_sent, u32, u64);
BPF_HASH(bytes_recv, u32, u64);

// ════════════════════════════════════════════════════════════════════════
// TRASARE TCP CONNECT
// ════════════════════════════════════════════════════════════════════════

// Intrare în tcp_v4_connect
int trace_connect_entry(struct pt_regs *ctx, struct sock *sk) {
    u32 tid = bpf_get_current_pid_tgid();
    
    // Filtrare PID (înlocuit la runtime)
    FILTER_PID
    
    // Salvare socket pentru lookup la return
    currsock.update(&tid, &sk);
    return 0;
}

// Ieșire din tcp_v4_connect
int trace_connect_return(struct pt_regs *ctx) {
    int ret = PT_REGS_RC(ctx);
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 tid = (u32)pid_tgid;
    u32 pid = pid_tgid >> 32;
    
    // Lookup socket salvat
    struct sock **skpp = currsock.lookup(&tid);
    if (!skpp) return 0;
    
    // Ignorare dacă connect a eșuat (altul decât EINPROGRESS)
    if (ret != 0 && ret != -EINPROGRESS) {
        currsock.delete(&tid);
        return 0;
    }
    
    struct sock *sk = *skpp;
    currsock.delete(&tid);
    
    // Extragere informații conexiune
    u16 sport = 0;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    // Creare eveniment
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.tid = tid;
    event.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    event.event_type = EVENT_CONNECT;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    // Trimitere eveniment
    events.perf_submit(ctx, &event, sizeof(event));
    
    // Actualizare statistici
    u64 *count = connect_count.lookup(&pid);
    if (count) {
        (*count)++;
    } else {
        u64 init = 1;
        connect_count.update(&pid, &init);
    }
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TRASARE TCP ACCEPT
// ════════════════════════════════════════════════════════════════════════

int trace_accept_return(struct pt_regs *ctx) {
    struct sock *sk = (struct sock *)PT_REGS_RC(ctx);
    if (!sk) return 0;
    
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // Filtrare PID
    FILTER_PID
    
    // Extragere informații
    u16 sport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    // Creare eveniment
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.tid = (u32)pid_tgid;
    event.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    event.event_type = EVENT_ACCEPT;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(ctx, &event, sizeof(event));
    
    // Actualizare statistici
    u64 *count = accept_count.lookup(&pid);
    if (count) {
        (*count)++;
    } else {
        u64 init = 1;
        accept_count.update(&pid, &init);
    }
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TRASARE TCP RETRANSMIT
// ════════════════════════════════════════════════════════════════════════

TRACEPOINT_PROBE(tcp, tcp_retransmit_skb) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // Filtrare PID
    FILTER_PID
    
    // Extragere din argumentele tracepoint
    // args->saddr, args->daddr, etc. disponibile în tracepoints moderne
    struct sock *sk = (struct sock *)args->skaddr;
    
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.event_type = EVENT_RETRANS;
    event.sport = args->sport;
    event.dport = args->dport;
    event.saddr = args->saddr;
    event.daddr = args->daddr;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(args, &event, sizeof(event));
    
    return 0;
}

// ════════════════════════════════════════════════════════════════════════
// TRASARE TCP CLOSE
// ════════════════════════════════════════════════════════════════════════

int trace_tcp_close(struct pt_regs *ctx, struct sock *sk) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // Filtrare PID
    FILTER_PID
    
    // Verificare socket valid
    u8 state = sk->__sk_common.skc_state;
    if (state == TCP_TIME_WAIT) return 0;
    
    // Extragere informații
    u16 sport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    u32 saddr = sk->__sk_common.skc_rcv_saddr;
    u32 daddr = sk->__sk_common.skc_daddr;
    
    dport = ntohs(dport);
    
    struct event_t event = {};
    event.ts_ns = bpf_ktime_get_ns();
    event.pid = pid;
    event.event_type = EVENT_CLOSE;
    event.saddr = saddr;
    event.daddr = daddr;
    event.sport = sport;
    event.dport = dport;
    bpf_get_current_comm(&event.comm, sizeof(event.comm));
    
    events.perf_submit(ctx, &event, sizeof(event));
    
    return 0;
}
"""

# ═══════════════════════════════════════════════════════════════════════════
# FUNCȚII HELPER
# ═══════════════════════════════════════════════════════════════════════════

def ip_to_str(addr):
    """Convertește adresă IP din format numeric în string."""
    return inet_ntop(AF_INET, pack("I", addr))

def event_type_str(event_type):
    """Returnează numele tipului de eveniment."""
    types = {
        1: "CONNECT",
        2: "ACCEPT",
        3: "CLOSE",
        4: "RETRANS"
    }
    return types.get(event_type, "UNKNOWN")

def event_type_color(event_type):
    """Returnează codul de culoare ANSI pentru tipul de eveniment."""
    colors = {
        1: "\033[92m",   # Verde - CONNECT
        2: "\033[94m",   # Albastru - ACCEPT
        3: "\033[93m",   # Galben - CLOSE
        4: "\033[91m"    # Roșu - RETRANS
    }
    return colors.get(event_type, "\033[0m")

# ═══════════════════════════════════════════════════════════════════════════
# CLASA PRINCIPALĂ DE MONITORIZARE
# ═══════════════════════════════════════════════════════════════════════════

class NetworkMonitor:
    """
    Clasă pentru monitorizarea traficului de rețea utilizând eBPF.
    """
    
    def __init__(self, pid=None, json_output=False):
        """
        Inițializare monitor.
        
        Args:
            pid: Optional, PID-ul procesului de monitorizat
            json_output: Dacă True, exportă statistici JSON la final
        """
        self.pid = pid
        self.json_output = json_output
        self.running = True
        self.events = []
        self.stats = defaultdict(lambda: defaultdict(int))
        
        # Pregătire program BPF
        program = bpf_program
        if pid:
            program = program.replace("FILTER_PID", 
                f"if (pid != {pid}) return 0;")
        else:
            program = program.replace("FILTER_PID", "")
        
        # Compilare și încărcare
        print("[*] Compilare program eBPF...")
        self.bpf = BPF(text=program)
        
        # Atașare la probe
        print("[*] Atașare probe...")
        self.bpf.attach_kprobe(event="tcp_v4_connect", 
                               fn_name="trace_connect_entry")
        self.bpf.attach_kretprobe(event="tcp_v4_connect", 
                                  fn_name="trace_connect_return")
        self.bpf.attach_kretprobe(event="inet_csk_accept", 
                                  fn_name="trace_accept_return")
        self.bpf.attach_kprobe(event="tcp_close", 
                               fn_name="trace_tcp_close")
        
        print("[*] Monitorizare activă. Ctrl+C pentru a opri.\n")
    
    def print_event(self, cpu, data, size):
        """Callback pentru procesarea evenimentelor."""
        event = self.bpf["events"].event(data)
        
        timestamp = strftime("%H:%M:%S")
        event_type = event_type_str(event.event_type)
        color = event_type_color(event.event_type)
        reset = "\033[0m"
        
        comm = event.comm.decode('utf-8', 'replace')
        saddr = ip_to_str(event.saddr)
        daddr = ip_to_str(event.daddr)
        
        # Afișare formatată
        print(f"{timestamp} {color}{event_type:8s}{reset} "
              f"{comm:16s} {event.pid:<7d} "
              f"{saddr}:{event.sport} -> {daddr}:{event.dport}")
        
        # Salvare pentru statistici
        self.stats[comm]["connects"] += 1 if event.event_type == 1 else 0
        self.stats[comm]["accepts"] += 1 if event.event_type == 2 else 0
        self.stats[comm]["closes"] += 1 if event.event_type == 3 else 0
        self.stats[comm]["retrans"] += 1 if event.event_type == 4 else 0
        
        if self.json_output:
            self.events.append({
                "timestamp": timestamp,
                "type": event_type,
                "process": comm,
                "pid": event.pid,
                "src": f"{saddr}:{event.sport}",
                "dst": f"{daddr}:{event.dport}"
            })
    
    def run(self, duration=None):
        """
        Rulează monitorizarea.
        
        Args:
            duration: Optional, durata în secunde (None = infinit)
        """
        # Header
        print(f"{'TIME':8s} {'TYPE':8s} {'PROCESS':16s} {'PID':7s} "
              f"{'CONNECTION':40s}")
        print("─" * 80)
        
        # Deschidere buffer perf
        self.bpf["events"].open_perf_buffer(self.print_event)
        
        elapsed = 0
        try:
            while self.running:
                self.bpf.perf_buffer_poll(timeout=1000)  # 1 secundă
                elapsed += 1
                if duration and elapsed >= duration:
                    break
        except KeyboardInterrupt:
            pass
        
        self.print_summary()
    
    def print_summary(self):
        """Afișează sumarul la final."""
        print("\n")
        print("═" * 80)
        print(" " * 30 + "SUMAR FINAL")
        print("═" * 80)
        
        # Tabel statistici
        print(f"\n{'PROCES':<20s} {'CONNECT':>10s} {'ACCEPT':>10s} "
              f"{'CLOSE':>10s} {'RETRANS':>10s}")
        print("─" * 60)
        
        for proc, data in sorted(self.stats.items(), 
                                 key=lambda x: sum(x[1].values()), 
                                 reverse=True):
            print(f"{proc:<20s} {data['connects']:>10d} {data['accepts']:>10d} "
                  f"{data['closes']:>10d} {data['retrans']:>10d}")
        
        # Totale
        total_conn = sum(d["connects"] for d in self.stats.values())
        total_acc = sum(d["accepts"] for d in self.stats.values())
        total_close = sum(d["closes"] for d in self.stats.values())
        total_retr = sum(d["retrans"] for d in self.stats.values())
        
        print("─" * 60)
        print(f"{'TOTAL':<20s} {total_conn:>10d} {total_acc:>10d} "
              f"{total_close:>10d} {total_retr:>10d}")
        
        # Export JSON dacă solicitat
        if self.json_output:
            output = {
                "summary": dict(self.stats),
                "events": self.events
            }
            filename = f"netmonitor_{strftime('%Y%m%d_%H%M%S')}.json"
            with open(filename, 'w') as f:
                json.dump(output, f, indent=2)
            print(f"\n[*] Statistici exportate în: {filename}")
        
        print("\n" + "═" * 80)
        print("Monitorizare încheiată.")
    
    def stop(self):
        """Oprește monitorizarea."""
        self.running = False


# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

def main():
    """Punctul de intrare principal."""
    
    # Argumente linie de comandă
    parser = argparse.ArgumentParser(
        description="Monitorizare conexiuni rețea cu eBPF/BCC",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  sudo python3 netmonitor.py                 # Toate procesele
  sudo python3 netmonitor.py -p $(pgrep nginx)  # Doar nginx
  sudo python3 netmonitor.py -d 60 --json    # 60 secunde, export JSON
        """
    )
    parser.add_argument("-p", "--pid", type=int, default=None,
                        help="Filtrare după PID proces")
    parser.add_argument("-d", "--duration", type=int, default=None,
                        help="Durata monitorizării în secunde")
    parser.add_argument("--json", action="store_true",
                        help="Export statistici în format JSON")
    
    args = parser.parse_args()
    
    # Banner
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║          NETWORK MONITOR - Monitorizare rețea cu eBPF/BCC                    ║
║                                                                              ║
║   Trasează conexiuni TCP: connect, accept, close, retransmit                 ║
║   Cerințe: root, BCC instalat, kernel 4.9+                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)
    
    # Verificare root
    import os
    if os.geteuid() != 0:
        print("[!] EROARE: Acest script necesită privilegii root.")
        print("    Rulați cu: sudo python3 netmonitor.py")
        sys.exit(1)
    
    # Afișare configurație
    if args.pid:
        print(f"[*] Filtrare activă pentru PID: {args.pid}")
    if args.duration:
        print(f"[*] Durată monitorizare: {args.duration} secunde")
    
    # Creare și rulare monitor
    monitor = NetworkMonitor(pid=args.pid, json_output=args.json)
    
    # Handler pentru SIGINT
    def signal_handler(sig, frame):
        monitor.stop()
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Rulare
    monitor.run(duration=args.duration)


if __name__ == "__main__":
    main()
