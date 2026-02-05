#!/usr/bin/env python3
"""
cgroup_monitor.py - Monitor cgroups v2 în timp real
Sisteme de Operare | ASE București - CSIE | 2025-2026

Concepte ilustrate:
- Structura ierarhiei cgroups v2
- Citirea metricilor de resurse (CPU, memorie, I/O, PID-uri)
- Vizualizare consum în timp real

Utilizare:
    python3 cgroup_monitor.py                    # Monitorizare toate grupurile
    python3 cgroup_monitor.py <cgroup_path>      # Monitorizare grup specific
    python3 cgroup_monitor.py --docker <id>      # Monitorizare container Docker
"""

import os
import sys
import time
import argparse
from pathlib import Path
from typing import Dict, Optional, NamedTuple
from dataclasses import dataclass

# Calea de bază pentru cgroups v2
CGROUP_BASE = Path("/sys/fs/cgroup")


@dataclass
class CgroupStats:
    """Structură pentru statisticile unui cgroup."""
    path: str
    cpu_usage_usec: int = 0
    cpu_user_usec: int = 0
    cpu_system_usec: int = 0
    memory_current: int = 0
    memory_max: int = 0
    memory_swap: int = 0
    pids_current: int = 0
    pids_max: int = 0
    io_read_bytes: int = 0
    io_write_bytes: int = 0


class CgroupMonitor:
    """Monitor pentru cgroups v2."""
    
    def __init__(self, cgroup_path: Path):
        """
        Inițializare monitor.
        
        Args:
            cgroup_path: Calea către directorul cgroup de monitorizat
        """
        self.cgroup_path = cgroup_path
        self.prev_cpu_usage = 0
        self.prev_time = time.time()
        
        # Verificare existență
        if not self.cgroup_path.exists():
            raise FileNotFoundError(f"Cgroup nu există: {cgroup_path}")
        
        # Verificare cgroups v2
        if not (CGROUP_BASE / "cgroup.controllers").exists():
            raise RuntimeError("Sistemul nu folosește cgroups v2 (unified hierarchy)")
    
    def read_file(self, filename: str) -> str:
        """Citește conținutul unui fișier din cgroup."""
        filepath = self.cgroup_path / filename
        try:
            return filepath.read_text().strip()
        except (FileNotFoundError, PermissionError):
            return ""
    
    def read_int(self, filename: str, default: int = 0) -> int:
        """Citește un întreg din fișier."""
        content = self.read_file(filename)
        if not content or content == "max":
            return default
        try:
            return int(content)
        except ValueError:
            return default
    
    def parse_stat_file(self, filename: str) -> Dict[str, int]:
        """Parsează un fișier de statistici (cheie valoare)."""
        result = {}
        content = self.read_file(filename)
        for line in content.split('\n'):
            if line:
                parts = line.split()
                if len(parts) >= 2:
                    try:
                        result[parts[0]] = int(parts[1])
                    except ValueError:
                        pass
        return result
    
    def get_stats(self) -> CgroupStats:
        """Colectează toate statisticile cgroup-ului."""
        stats = CgroupStats(path=str(self.cgroup_path))
        
        # CPU statistici
        cpu_stat = self.parse_stat_file("cpu.stat")
        stats.cpu_usage_usec = cpu_stat.get("usage_usec", 0)
        stats.cpu_user_usec = cpu_stat.get("user_usec", 0)
        stats.cpu_system_usec = cpu_stat.get("system_usec", 0)
        
        # Memorie
        stats.memory_current = self.read_int("memory.current")
        stats.memory_max = self.read_int("memory.max", default=-1)
        stats.memory_swap = self.read_int("memory.swap.current")
        
        # PIDs
        stats.pids_current = self.read_int("pids.current")
        stats.pids_max = self.read_int("pids.max", default=-1)
        
        # I/O (agregate din io.stat)
        io_stat = self.read_file("io.stat")
        for line in io_stat.split('\n'):
            if line:
                # Format: "8:0 rbytes=X wbytes=Y ..."
                parts = line.split()
                for part in parts:
                    if part.startswith("rbytes="):
                        stats.io_read_bytes += int(part.split('=')[1])
                    elif part.startswith("wbytes="):
                        stats.io_write_bytes += int(part.split('=')[1])
        
        return stats
    
    def get_cpu_percent(self, stats: CgroupStats) -> float:
        """Calculează procentul CPU folosit."""
        current_time = time.time()
        time_delta = current_time - self.prev_time
        
        if time_delta > 0 and self.prev_cpu_usage > 0:
            cpu_delta = stats.cpu_usage_usec - self.prev_cpu_usage
            # Convertire din microsecunde în procent
            cpu_percent = (cpu_delta / (time_delta * 1_000_000)) * 100
        else:
            cpu_percent = 0.0
        
        self.prev_cpu_usage = stats.cpu_usage_usec
        self.prev_time = current_time
        
        return min(cpu_percent, 100.0 * os.cpu_count())


def format_bytes(bytes_value: int) -> str:
    """Formatează bytes în unități citibile."""
    if bytes_value < 0:
        return "unlimited"
    
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024:
            return f"{bytes_value:.1f} {unit}"
        bytes_value /= 1024
    return f"{bytes_value:.1f} PB"


def format_percent(value: float, max_value: int) -> str:
    """Formatează valoare ca procent din maxim."""
    if max_value <= 0:
        return "N/A"
    percent = (value / max_value) * 100
    return f"{percent:.1f}%"


def print_header():
    """Afișează header-ul tabelului."""
    print("\033[2J\033[H", end="")  # Clear screen
    print("=" * 80)
    print(" CGROUP MONITOR - Monitorizare resurse în timp real")
    print("=" * 80)
    print()


def print_stats(stats: CgroupStats, cpu_percent: float):
    """Afișează statisticile formatat."""
    print(f"\033[4;0H", end="")  # Poziționare cursor
    
    print(f" Cgroup: {stats.path}")
    print("-" * 80)
    print()
    
    # CPU
    print(" CPU:")
    print(f"   Utilizare curentă:  {cpu_percent:6.1f}%")
    print(f"   Timp user:          {stats.cpu_user_usec / 1_000_000:,.2f}s")
    print(f"   Timp system:        {stats.cpu_system_usec / 1_000_000:,.2f}s")
    print(f"   Timp total:         {stats.cpu_usage_usec / 1_000_000:,.2f}s")
    print()
    
    # Memorie
    print(" MEMORIE:")
    mem_usage = format_bytes(stats.memory_current)
    mem_limit = format_bytes(stats.memory_max)
    mem_percent = format_percent(stats.memory_current, stats.memory_max) if stats.memory_max > 0 else "N/A"
    print(f"   Utilizare curentă:  {mem_usage:>12} ({mem_percent})")
    print(f"   Limită:             {mem_limit:>12}")
    print(f"   Swap:               {format_bytes(stats.memory_swap):>12}")
    print()
    
    # PIDs
    print(" PROCESE:")
    pids_limit = str(stats.pids_max) if stats.pids_max > 0 else "unlimited"
    print(f"   Procese active:     {stats.pids_current:>12}")
    print(f"   Limită:             {pids_limit:>12}")
    print()
    
    # I/O
    print(" I/O:")
    print(f"   Bytes citiți:       {format_bytes(stats.io_read_bytes):>12}")
    print(f"   Bytes scriși:       {format_bytes(stats.io_write_bytes):>12}")
    print()
    
    print("-" * 80)
    print(" Apăsați Ctrl+C pentru oprire")


def find_docker_cgroup(container_id: str) -> Path:
    """Găsește cgroup-ul pentru un container Docker."""
    # Docker folosește structuri diferite în funcție de configurare
    patterns = [
        # systemd driver (implicit în versiunile recente)
        CGROUP_BASE / "system.slice" / f"docker-{container_id}.scope",
        # cgroupfs driver
        CGROUP_BASE / "docker" / container_id,
        # Variante cu ID scurt
        CGROUP_BASE / "system.slice" / f"docker-{container_id[:12]}.scope",
    ]
    
    for pattern in patterns:
        if pattern.exists():
            return pattern
    
    # Căutare recursivă pentru ID parțial
    for path in CGROUP_BASE.rglob(f"*{container_id[:12]}*"):
        if path.is_dir():
            return path
    
    raise FileNotFoundError(f"Nu s-a găsit cgroup pentru container: {container_id}")


def list_cgroups():
    """Listează toate cgroup-urile active."""
    print("Cgroup-uri disponibile:")
    print("-" * 60)
    
    for cgroup_dir in sorted(CGROUP_BASE.rglob("*")):
        if cgroup_dir.is_dir():
            # Verifică dacă are procese
            procs_file = cgroup_dir / "cgroup.procs"
            if procs_file.exists():
                try:
                    procs = procs_file.read_text().strip()
                    if procs:
                        relative_path = cgroup_dir.relative_to(CGROUP_BASE)
                        num_procs = len(procs.split('\n'))
                        print(f"  {relative_path} ({num_procs} procese)")
                except PermissionError:
                    pass


def main():
    """Punct de intrare principal."""
    parser = argparse.ArgumentParser(
        description="Monitor cgroups v2 în timp real",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  %(prog)s                           # Monitorizare cgroup root
  %(prog)s /sys/fs/cgroup/user.slice # Monitorizare utilizatori
  %(prog)s --docker abc123           # Monitorizare container Docker
  %(prog)s --list                    # Listare cgroup-uri disponibile
        """
    )
    
    parser.add_argument(
        "cgroup_path",
        nargs="?",
        default=str(CGROUP_BASE),
        help="Calea către cgroup-ul de monitorizat"
    )
    
    parser.add_argument(
        "--docker", "-d",
        metavar="CONTAINER_ID",
        help="ID-ul containerului Docker de monitorizat"
    )
    
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="Listează cgroup-urile disponibile"
    )
    
    parser.add_argument(
        "--interval", "-i",
        type=float,
        default=1.0,
        help="Interval de actualizare în secunde (implicit: 1.0)"
    )
    
    args = parser.parse_args()
    
    # Listare cgroups
    if args.list:
        list_cgroups()
        return
    
    # Determinare cale cgroup
    if args.docker:
        try:
            cgroup_path = find_docker_cgroup(args.docker)
            print(f"Container găsit: {cgroup_path}")
        except FileNotFoundError as e:
            print(f"Eroare: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        cgroup_path = Path(args.cgroup_path)
    
    # Creare monitor
    try:
        monitor = CgroupMonitor(cgroup_path)
    except (FileNotFoundError, RuntimeError) as e:
        print(f"Eroare: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Bucla de monitorizare
    try:
        print_header()
        
        while True:
            stats = monitor.get_stats()
            cpu_percent = monitor.get_cpu_percent(stats)
            print_stats(stats, cpu_percent)
            time.sleep(args.interval)
            
    except KeyboardInterrupt:
        print("\n\nMonitor oprit.")
    except PermissionError:
        print("\nEroare: Permisiuni insuficiente. Încercați cu sudo.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()