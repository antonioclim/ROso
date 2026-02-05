# Sisteme de Operare - Săptămâna 14 (Suplimentar): Conectarea la Rețea

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026  
> **Conformitate fișă disciplină**: Săptămâna 14 — „Conectarea la rețea. Comenzi Linux"

---

## Obiectivele Săptămânii

1. **Identifici** rolul sistemului de operare în gestionarea comunicațiilor de rețea
2. **Explici** arhitectura stivei TCP/IP din perspectiva kernel-ului
3. **Configurezi** interfețe de rețea și tabele de rutare folosind utilitare Linux
4. **Utilizezi** instrumente de diagnostic pentru analiza traficului și depanarea conectivității
5. **Implementezi** un model client-server elementar folosind API-ul de socket-uri BSD
6. **Aplici** reguli de filtrare a pachetelor prin subsistemul netfilter

---

## Context Aplicativ: De ce rețeaua este responsabilitate a SO?

Când o aplicație invocă o cerere HTTP, parcursul datelor traversează multiple straturi software, iar sistemul de operare mediază fiecare tranziție critică. Nucleul Linux gestionează interfețele fizice și virtuale, menține tabelele de rutare, implementează protocoalele de transport (TCP/UDP), administrează bufferele de socket și aplică politicile de securitate prin netfilter. Fără această infrastructură, aplicațiile ar trebui să reimplementeze întreaga stivă de protocoale — o situație analogă cu absența sistemului de fișiere, când fiecare program ar gestiona direct blocurile pe disc.

Contextul contemporan amplifică această responsabilitate: containerele Docker partajează stiva de rețea a gazdei prin namespace-uri, Kubernetes orchestrează mii de endpoint-uri virtuale, iar eBPF permite injectarea de logică personalizată direct în calea de procesare a pachetelor. Înțelegerea fundamentelor networking-ului la nivel de kernel constituie, așadar, premisa obligatorie pentru arhitecturile cloud-native.

---

## Conținut Curs (14 Suplimentar / 14)

### 1. Arhitectura Stivei de Rețea în Linux

Sistemul de operare implementează modelul TCP/IP printr-o arhitectură stratificată, fiecare nivel expunând interfețe bine definite către nivelul adiacent.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPAȚIUL UTILIZATOR                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Browser   │  │   curl      │  │    ssh      │  │   Aplicație │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │           │
│         └────────────────┼────────────────┼────────────────┘           │
│                          │                │                            │
│ ═══════════════════════════ APELURI SISTEM ═══════════════════════════ │
│          socket(), bind(), listen(), accept(), connect(),              │
│          send(), recv(), sendto(), recvfrom(), close()                 │
├─────────────────────────────────────────────────────────────────────────┤
│                         SPAȚIUL KERNEL                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    STRATUL SOCKET (BSD API)                      │   │
│  │        struct socket, struct sock, protocol families            │   │
│  └──────────────────────────────┬──────────────────────────────────┘   │
│                                 │                                       │
│  ┌─────────────────────────────┴──────────────────────────────────┐   │
│  │               STRATUL TRANSPORT (L4)                            │   │
│  │  ┌───────────────────┐    ┌───────────────────┐                │   │
│  │  │        TCP        │    │        UDP        │                │   │
│  │  │ • Control flux    │    │ • Fără conexiune  │                │   │
│  │  │ • Retransmisie    │    │ • Overhead minim  │                │   │
│  │  │ • Ordonare        │    │ • Multicast       │                │   │
│  │  └─────────┬─────────┘    └─────────┬─────────┘                │   │
│  └────────────┼──────────────────────────┼────────────────────────┘   │
│               └──────────────┬───────────┘                             │
│  ┌───────────────────────────┴─────────────────────────────────────┐   │
│  │                   STRATUL REȚEA (L3)                             │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │                      IPv4 / IPv6                         │    │   │
│  │  │  • Rutare (FIB - Forwarding Information Base)           │    │   │
│  │  │  • Fragmentare/Reasamblare                              │    │   │
│  │  │  • ICMP (diagnostic)                                     │    │   │
│  │  │  • ARP/NDP (rezolvare adrese L2)                        │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  │                                                                  │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │                     NETFILTER                            │    │   │
│  │  │  hook-uri: PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTE│    │   │
│  │  │  module: iptables, nftables, conntrack                  │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────┬───────────────────────────────┘   │
│  ┌─────────────────────────────────┴───────────────────────────────┐   │
│  │               STRATUL LEGĂTURĂ DE DATE (L2)                      │   │
│  │  • Device drivers (e1000, virtio-net, veth)                     │   │
│  │  • Traffic control (tc - qdisc, class, filter)                  │   │
│  │  • Bridging, bonding, VLAN                                       │   │
│  └─────────────────────────────────┬───────────────────────────────┘   │
│                                    │                                    │
├────────────────────────────────────┼────────────────────────────────────┤
│                         HARDWARE / NIC                                  │
│  ┌─────────────────────────────────┴───────────────────────────────┐   │
│  │  Ring buffers, DMA, IRQ coalescing, RSS (Receive Side Scaling)  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1.1. Parcursul unui Pachet la Recepție

Când un cadru Ethernet ajunge la interfața de rețea, secvența de procesare urmează calea:

1. **NIC → DMA**: Controlerul de rețea transferă cadrul în memoria principală prin DMA (Direct Memory Access), populând un descriptor în ring buffer-ul de recepție.

2. **Întrerupere → NAPI**: Kernel-ul primește întreruperea hardware, dar în loc să proceseze fiecare pachet individual (overhead prohibitiv la rate gigabit), activează NAPI (New API) care comută în modul polling.

3. **Stratul L2**: Driver-ul decodifică antetul Ethernet, verifică adresa MAC destinație și determină protocolul încapsulat (IPv4: 0x0800, IPv6: 0x86DD, ARP: 0x0806).

4. **Stratul L3**: Subsistemul IP validează antetul, consultă tabela de rutare și decide: pachetul este destinat local (INPUT) sau necesită forwarding (FORWARD)?

5. **Netfilter hooks**: În fiecare punct de decizie, hook-urile netfilter permit inspecție și modificare (NAT, filtrare, marcare).

6. **Stratul L4**: TCP sau UDP demultiplexează pe baza portului destinație, identificând socket-ul asociat.

7. **Socket buffer**: Datele sunt copiate în coada de recepție a socket-ului, iar aplicația este notificată (prin select/poll/epoll sau deblocare read).

---

### 2. Configurarea Interfețelor de Rețea

Linux expune configurația de rețea prin două mecanisme: utilitarele tradiționale (ifconfig, route, netstat) și suita modernă iproute2 (ip, ss). Recomandarea oficială favorizează iproute2 datorită funcționalității extinse și sintaxei consistente.

#### 2.1. Comanda `ip` — Instrument Universal

```bash
# Afișare interfețe și adrese
ip addr show                      # sau: ip a
ip link show                      # doar starea legăturilor

# Activare/dezactivare interfață
ip link set eth0 up
ip link set eth0 down

# Configurare adresă IPv4
ip addr add 192.168.1.100/24 dev eth0
ip addr del 192.168.1.100/24 dev eth0

# Configurare adresă IPv6
ip -6 addr add 2001:db8::1/64 dev eth0

# Configurare MTU (Maximum Transmission Unit)
ip link set eth0 mtu 9000         # Jumbo frames

# Afișare statistici detaliate
ip -s link show eth0
```

#### 2.2. Tabele de Rutare

Tabela de rutare determină calea pe care pachetele o urmează pentru a ajunge la destinație. Kernel-ul menține structura FIB (Forwarding Information Base) optimizată pentru căutări rapide.

```bash
# Afișare tabel de rutare
ip route show                     # sau: ip r

# Structura tipică:
# default via 192.168.1.1 dev eth0 proto dhcp metric 100
# 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
# 172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1

# Adăugare rută statică
ip route add 10.0.0.0/8 via 192.168.1.254

# Adăugare rută pentru o gazdă specifică
ip route add 8.8.8.8/32 via 192.168.1.1

# Ștergere rută
ip route del 10.0.0.0/8

# Afișare rută pentru o destinație specifică
ip route get 8.8.8.8
```

**Concepte esențiale:**
- **Gateway implicit (default gateway)**: Ruta utilizată când nicio altă regulă nu se potrivește
- **Metric**: Prioritatea rutei; valori mai mici indică preferință mai mare
- **Scope**: link (destinație direct conectată), global (accesibilă prin rutare)
- **Proto**: Sursa informației de rutare (kernel, static, dhcp, bgp)

---

### 3. Rezolvarea Numelor și DNS

Sistemul de operare abstractizează rezolvarea numelor prin biblioteca C standard (glibc sau musl), care consultă configurația din `/etc/nsswitch.conf` pentru a determina ordinea surselor.

```bash
# Rezolvare manuală
host google.com
dig google.com
nslookup google.com

# Interogare specifică pentru înregistrări MX
dig google.com MX

# Interogare cu server DNS specific
dig @8.8.8.8 google.com

# Verificare configurație DNS locală
cat /etc/resolv.conf

# Cache DNS local (systemd-resolved)
resolvectl status
resolvectl query google.com
```

**Fișiere de configurare critice:**

| Fișier | Scop |
|--------|------|
| `/etc/resolv.conf` | Serverele DNS utilizate |
| `/etc/hosts` | Mapări statice nume ↔ IP |
| `/etc/nsswitch.conf` | Ordinea surselor de rezolvare |
| `/etc/hostname` | Numele gazdei locale |

---

### 4. Instrumente de Diagnostic

Diagnosticarea problemelor de rețea necesită instrumente specializate pentru fiecare strat al modelului TCP/IP.

#### 4.1. Verificare Conectivitate (L3)

```bash
# Test ICMP echo
ping -c 4 8.8.8.8                 # IPv4
ping6 -c 4 2001:4860:4860::8888   # IPv6

# Opțiuni avansate
ping -i 0.2 -c 100 192.168.1.1   # Interval 200ms, 100 pachete
ping -s 1400 -M do 192.168.1.1   # Verificare MTU (nu fragmenta)
```

#### 4.2. Trasare Rută (L3)

```bash
# Identificare hop-uri intermediare
traceroute 8.8.8.8
traceroute -I 8.8.8.8             # Folosește ICMP în loc de UDP
traceroute -T -p 443 google.com  # TCP pe portul 443

# Varianta modernă (mai rapidă)
mtr -r -c 10 8.8.8.8
```

#### 4.3. Investigare Socket-uri și Conexiuni (L4)

Comanda `ss` (socket statistics) înlocuiește `netstat` cu performanță superioară.

```bash
# Toate conexiunile TCP
ss -t -a

# Socket-uri în ascultare (listening)
ss -l -t -n                       # -n evită rezolvarea DNS

# Conexiuni TCP stabilite
ss -t state established

# Afișare proces asociat
ss -t -p                          # necesită privilegii root

# Statistici sumar
ss -s

# Filtrare după port
ss -t '( dport = :443 or sport = :443 )'

# Filtrare după adresă
ss -t dst 8.8.8.8
```

**Coloane critice în output:**
- **State**: ESTABLISHED, LISTEN, TIME-WAIT, CLOSE-WAIT, SYN-SENT
- **Recv-Q**: Bytes în coada de recepție (nebuferate de aplicație)
- **Send-Q**: Bytes în coada de transmisie (neconfirmați)
- **Local Address:Port**: Endpoint local
- **Peer Address:Port**: Endpoint remote

#### 4.4. Capturare și Analiză Trafic

```bash
# Capturare pe interfață specifică
tcpdump -i eth0

# Filtrare după port
tcpdump -i eth0 port 80

# Filtrare după gazdă
tcpdump -i eth0 host 192.168.1.100

# Salvare în fișier pentru analiză ulterioară
tcpdump -i eth0 -w capture.pcap

# Afișare conținut ASCII
tcpdump -i eth0 -A port 80

# Expresii complexe
tcpdump -i eth0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
```

#### 4.5. Testare Conectivitate Arbitrară cu Netcat

Netcat (nc) funcționează ca un „cuțit elvețian" pentru rețea, permițând conexiuni TCP/UDP ad-hoc.

```bash
# Client TCP
nc -v google.com 80
GET / HTTP/1.1
Host: google.com

# Server TCP simplu (ascultă pe port)
nc -l -p 8080

# Transfer fișier
# Pe receptor: nc -l -p 9999 > fisier_primit
# Pe emițător: nc receptor 9999 < fisier_de_trimis

# Scanare porturi (bază)
nc -z -v 192.168.1.1 20-25

# Conexiune UDP
nc -u -v 8.8.8.8 53
```

---

### 5. Modelul Socket BSD

API-ul de socket-uri BSD, standardizat prin POSIX, oferă interfața programatică pentru comunicații de rețea. Abstractizează detaliile protocolului, expunând operații intuitive: creare socket, asociere adresă, conectare, transmisie, recepție.

#### 5.1. Anatomia unui Socket

```
┌─────────────────────────────────────────────────────────────────┐
│                      DESCRIPTOR SOCKET                          │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Familie   │    │     Tip     │    │  Protocol   │         │
│  │  AF_INET    │    │ SOCK_STREAM │    │  IPPROTO_TCP│         │
│  │  AF_INET6   │    │ SOCK_DGRAM  │    │  IPPROTO_UDP│         │
│  │  AF_UNIX    │    │ SOCK_RAW    │    │      0      │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   STRUCTURI ADRESĂ                       │   │
│  │                                                          │   │
│  │  struct sockaddr_in {                                    │   │
│  │      sa_family_t    sin_family;   // AF_INET             │   │
│  │      in_port_t      sin_port;     // Port (network order)│   │
│  │      struct in_addr sin_addr;     // Adresă IPv4         │   │
│  │  };                                                      │   │
│  │                                                          │   │
│  │  struct sockaddr_in6 {                                   │   │
│  │      sa_family_t     sin6_family; // AF_INET6            │   │
│  │      in_port_t       sin6_port;   // Port                │   │
│  │      uint32_t        sin6_flowinfo;                      │   │
│  │      struct in6_addr sin6_addr;   // Adresă IPv6         │   │
│  │      uint32_t        sin6_scope_id;                      │   │
│  │  };                                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.2. Fluxul de Operații TCP

```
        SERVER                              CLIENT
           │                                   │
    socket()                            socket()
           │                                   │
      bind()                                   │
           │                                   │
    listen()                                   │
           │                                   │
           │◄──────── TCP 3-way ──────────connect()
           │          handshake                │
    accept()                                   │
           │                                   │
           │◄─────────────────────────────write()
      read()                                   │
           │                                   │
     write()─────────────────────────────►     │
           │                                  read()
           │                                   │
     close()◄──────── TCP 4-way ──────────close()
           │          termination              │
```

#### 5.3. Exemplu: Server Echo în Python

```python
#!/usr/bin/env python3
"""
Server TCP echo - demonstrează modelul socket BSD.
Primește mesaje de la clienți și le returnează identic.
"""

import socket
import sys

def echo_server(host: str = '0.0.0.0', port: int = 9000) -> None:
    """
    Implementare server TCP cu tratare secvențială a conexiunilor.
    
    Args:
        host: Adresa de ascultare (0.0.0.0 = toate interfețele)
        port: Portul de ascultare
    """
    # Creare socket TCP (SOCK_STREAM)
    # AF_INET specifică familia de adrese IPv4
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
        # SO_REUSEADDR permite reutilizarea imediată a portului după închidere
        # Evită eroarea "Address already in use" în timpul dezvoltării
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        # Asociere socket cu adresă și port
        server_socket.bind((host, port))
        
        # Activare mod ascultare; backlog=5 specifică lungimea cozii
        # de conexiuni în așteptarea accept()
        server_socket.listen(5)
        
        print(f"[INFO] Server activ pe {host}:{port}")
        print(f"[INFO] Apăsați Ctrl+C pentru oprire")
        
        while True:
            try:
                # accept() blochează până la sosirea unei conexiuni
                # Returnează un nou socket pentru comunicare și adresa clientului
                client_socket, client_addr = server_socket.accept()
                
                with client_socket:
                    print(f"[CONN] Conexiune de la {client_addr[0]}:{client_addr[1]}")
                    
                    while True:
                        # Recepție date; dimensiunea buffer = 4096 bytes
                        data = client_socket.recv(4096)
                        
                        if not data:
                            # Conexiune închisă de client
                            print(f"[DISC] {client_addr[0]}:{client_addr[1]} deconectat")
                            break
                        
                        # Decodificare și afișare
                        message = data.decode('utf-8', errors='replace')
                        print(f"[RECV] {client_addr[0]}: {message.strip()}")
                        
                        # Echo: retransmitere date primite
                        client_socket.sendall(data)
                        print(f"[SEND] Echo trimis")
                        
            except KeyboardInterrupt:
                print("\n[INFO] Server oprit de utilizator")
                sys.exit(0)

if __name__ == '__main__':
    echo_server()
```

#### 5.4. Exemplu: Client în Python

```python
#!/usr/bin/env python3
"""
Client TCP pentru testare server echo.
"""

import socket

def echo_client(host: str = '127.0.0.1', port: int = 9000) -> None:
    """Conectare la server și trimitere mesaje interactive."""
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.connect((host, port))
            print(f"[INFO] Conectat la {host}:{port}")
            
            while True:
                message = input("Mesaj (quit pentru ieșire): ")
                
                if message.lower() == 'quit':
                    break
                
                sock.sendall(message.encode('utf-8'))
                response = sock.recv(4096)
                print(f"[ECHO] {response.decode('utf-8')}")
                
        except ConnectionRefusedError:
            print(f"[ERR] Nu s-a putut conecta la {host}:{port}")
        except KeyboardInterrupt:
            print("\n[INFO] Client oprit")

if __name__ == '__main__':
    echo_client()
```

---

### 6. Filtrare Pachete cu Netfilter

Netfilter constituie framework-ul kernel-ului Linux pentru inspecție și manipulare a pachetelor. Oferă hook-uri în calea de procesare, permițând modulelor (iptables, nftables, conntrack) să intercepteze traficul.

#### 6.1. Arhitectura Hook-urilor

```
                                    REȚEA EXTERNĂ
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            PREROUTING                                    │
│                   (NAT destinație, mangle)                               │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │      DECIZIE RUTARE       │
                    │   Pachet pentru mine?      │
                    └─────────────┬─────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │ DA                │                   │ NU
              ▼                   │                   ▼
┌─────────────────────┐          │          ┌─────────────────────┐
│       INPUT         │          │          │      FORWARD        │
│  (filtrare intrare) │          │          │ (filtrare tranzit)  │
└──────────┬──────────┘          │          └──────────┬──────────┘
           │                     │                     │
           ▼                     │                     │
┌─────────────────────┐          │                     │
│  PROCESE LOCALE     │          │                     │
│  (aplicații)        │          │                     │
└──────────┬──────────┘          │                     │
           │                     │                     │
           ▼                     │                     │
┌─────────────────────┐          │                     │
│      OUTPUT         │          │                     │
│ (filtrare ieșire    │          │                     │
│  trafic generat     │          │                     │
│  local)             │          │                     │
└──────────┬──────────┘          │                     │
           │                     │                     │
           └─────────────────────┴─────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           POSTROUTING                                    │
│                    (NAT sursă, masquerade)                               │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
                            REȚEA EXTERNĂ
```

#### 6.2. Comenzi iptables Fundamentale

```bash
# Afișare reguli cu numere de linie
iptables -L -n -v --line-numbers

# Politică implicită (DROP toate pachetele neacceptate explicit)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitere trafic pe interfața loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitere conexiuni deja stabilite
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitere SSH (port 22) doar din subnet specific
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Permitere HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Blocare adresă specifică
iptables -A INPUT -s 10.20.30.40 -j DROP

# Logging pentru pachete blocate (pentru depanare)
iptables -A INPUT -j LOG --log-prefix "IPT_DROP: " --log-level 4
iptables -A INPUT -j DROP

# Ștergere regulă după număr
iptables -D INPUT 3

# Golire toate regulile
iptables -F

# Salvare reguli (Debian/Ubuntu)
iptables-save > /etc/iptables/rules.v4

# Restaurare reguli
iptables-restore < /etc/iptables/rules.v4
```

#### 6.3. Migrare către nftables

nftables reprezintă succesorul modern al iptables, oferind sintaxă unificată și performanță îmbunătățită.

```bash
# Listare seturi de reguli
nft list ruleset

# Creare tabel și lanț
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }

# Adăugare reguli
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport { 80, 443 } accept

# Afișare formatat
nft list chain inet filter input
```

---

### 7. Network Namespaces — Izolare de Rețea

Network namespaces permit crearea de stive de rețea izolate, fiecare cu propriile interfețe, tabele de rutare și reguli de firewall. Acest mecanism stă la baza containerizării.

```bash
# Creare namespace
ip netns add ns_test

# Listare namespaces
ip netns list

# Execuție comandă în namespace
ip netns exec ns_test ip addr show

# Creare pereche veth (virtual ethernet)
ip link add veth0 type veth peer name veth1

# Mutare un capăt în namespace
ip link set veth1 netns ns_test

# Configurare în namespace-ul implicit
ip addr add 192.168.100.1/24 dev veth0
ip link set veth0 up

# Configurare în namespace-ul izolat
ip netns exec ns_test ip addr add 192.168.100.2/24 dev veth1
ip netns exec ns_test ip link set veth1 up
ip netns exec ns_test ip link set lo up

# Test conectivitate
ping -c 2 192.168.100.2
ip netns exec ns_test ping -c 2 192.168.100.1

# Ștergere namespace
ip netns delete ns_test
```

---

## Laborator/Seminar — Exerciții Practice

### Exercițiul 1: Diagnostic Complet

Investigați conectivitatea către un server extern folosind instrumentele prezentate:

```bash
# 1. Verificare rezolvare DNS
dig google.com +short

# 2. Test conectivitate ICMP
ping -c 4 google.com

# 3. Trasare rută
traceroute -I google.com

# 4. Verificare conexiuni active
ss -t state established

# 5. Capturare trafic DNS
sudo tcpdump -i any port 53 -c 10
```

### Exercițiul 2: Server și Client

1. Rulați serverul echo din directorul `scripts/`
2. Într-un alt terminal, conectați-vă cu clientul sau cu netcat
3. Observați socket-urile create: `ss -t -p | grep 9000`

### Exercițiul 3: Configurare Firewall Bazic

Implementați un set minim de reguli iptables care să permită doar:
- Trafic loopback
- Conexiuni SSH de la rețeaua locală
- Răspunsuri la conexiuni inițiate local
- Blocarea cu logging a restului

---

## Recapitulare Vizuală

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    REȚEAUA ÎN SISTEME DE OPERARE                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  CONFIGURARE              DIAGNOSTIC              PROGRAMARE            │
│  ───────────              ──────────              ──────────            │
│  ip addr/link             ping/traceroute         socket()              │
│  ip route                 ss/netstat              bind()/listen()       │
│  /etc/resolv.conf        tcpdump                 accept()/connect()    │
│  /etc/hosts              dig/host                send()/recv()         │
│                                                                         │
│  FILTRARE                 IZOLARE                                       │
│  ────────                 ───────                                       │
│  iptables/nftables        ip netns (namespaces)                        │
│  netfilter hooks          veth pairs                                    │
│  conntrack                bază pentru containere                        │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│  Lecturi recomandate:                                                   │
│  • OSTEP, Capitolul „Distributed Systems" (introducere)                │
│  • Tanenbaum, „Computer Networks", Capitolele 1-5                      │
│  • Stevens, „Unix Network Programming", Volume 1                        │
│  • Linux man pages: ip(8), ss(8), iptables(8), socket(7)               │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Sumar Comenzi

| Categorie | Comandă | Scop |
|-----------|---------|------|
| Interfețe | `ip addr show` | Listare adrese IP |
| | `ip link set eth0 up/down` | Activare/dezactivare |
| Rutare | `ip route show` | Afișare tabel rutare |
| | `ip route add` | Adăugare rută statică |
| DNS | `dig`, `host`, `nslookup` | Rezolvare nume |
| Diagnostic | `ping`, `traceroute`, `mtr` | Test conectivitate |
| | `ss -t`, `ss -l` | Stare socket-uri |
| | `tcpdump -i eth0` | Capturare trafic |
| | `nc -v host port` | Conexiune ad-hoc |
| Firewall | `iptables -L` | Listare reguli |
| | `nft list ruleset` | Reguli nftables |
| Namespaces | `ip netns add/exec/del` | Izolare rețea |

---

## Scripturi Incluse

| Fișier | Limbaj | Descriere |
|--------|--------|-----------|
| `scripts/echo_server.py` | Python | Server TCP echo demonstrativ |
| `scripts/echo_client.py` | Python | Client TCP pentru testare |
| `scripts/network_diag.sh` | Bash | Script diagnostic complet |
| `scripts/firewall_basic.sh` | Bash | Template configurare iptables |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este un socket? Enumeră cei 5 pași pentru crearea unei conexiuni TCP (server-side).
2. **[UNDERSTAND]** Explică diferența dintre TCP și UDP. În ce situații ai alege fiecare protocol?
3. **[ANALYSE]** Analizează modelul client-server. Ce se întâmplă dacă serverul nu face `accept()` și coada de conexiuni se umple?

### Mini-provocare (opțional)

Modifică echo_server.py pentru a gestiona conexiuni multiple simultan folosind thread-uri sau `select()`.

---


---


---

## Lectură Recomandată

### Resurse Obligatorii

**Beej's Guide to Network Programming**
- [Secțiunile 1-6](https://beej.us/guide/bgnet/) — Ghidul complet al socket API
- Cel mai bun tutorial practic pentru programarea socket în C

**OSTEP (dacă disponibil)**
- Capitolul 48: Distributed Systems — context pentru comunicarea în rețea

### Resurse Recomandate

**Stevens - UNIX Network Programming, Vol. 1**
- Capitolul 4: Elementary TCP Sockets (pag. 85-120)
- Capitolul 5: TCP Client/Server Example
- Referința clasică pentru network programming

**Linux man pages** (disponibile local cu `man`)
```bash
man 2 socket      # System call pentru creare socket
man 2 bind        # Asociere socket cu adresă
man 2 listen      # Marcare socket ca pasiv
man 2 accept      # Acceptare conexiune
man 2 connect     # Inițiere conexiune (client)
man 7 tcp         # Protocolul TCP în Linux
man 7 ip          # Protocolul IP
man 7 socket      # Interfața generală socket
```

### Resurse Video

- **MIT 6.033** - Computer System Engineering (secțiunea Networking)
- **Brian "Beej" Hall** - Network Programming Tutorials (YouTube)

### Articole Tehnice

- [The C10K Problem](http://www.kegel.com/c10k.html) — De ce threadurile per conexiune nu scalează
- [Epoll Tutorial](https://copyconstruct.medium.com/the-method-to-epolls-madness-d9d2d6378642) — I/O multiplexing modern


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **io_uring pentru networking**: Alternativă modernă la epoll cu performanțe superioare.
- **QUIC protocol**: UDP-based transport layer (HTTP/3) care evită head-of-line blocking.
- **eBPF XDP (eXpress Data Path)**: Procesarea pachetelor în kernel bypass pentru performanță extremă.

### Greșeli frecvente de evitat

1. **Blocking I/O cu mulți clienți**: Folosește select/poll/epoll sau threads pentru scalabilitate.
2. **Ignorarea partial writes/reads**: `send()` și `recv()` pot transfera mai puțin decât cerut.
3. **Hardcodarea IP-urilor**: Folosește DNS și configurări pentru portabilitate.

### Întrebări rămase deschise

- Va înlocui QUIC complet TCP pentru aplicații interactive?
- Cum vor evolua API-urile de networking pentru 100Gbps+ și RDMA?

## Privire înainte

**Continuare Opțională: C16supp — Containerizare Avansată**

Dacă ai înțeles socket API și comunicarea în rețea, următorul pas natural este containerizarea avansată. Vei vedea cum Docker folosește namespaces pentru izolarea rețelei și cgroups pentru limitarea resurselor.

**Pregătire recomandată:**
- Instalează Docker și rulează primul container: `docker run hello-world`
- Experimentează cu `docker network ls` și `docker network inspect`

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 15: REȚELISTICĂ — RECAP            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SOCKET = Endpoint pentru comunicare în rețea                  │
│                                                                 │
│  MODELUL CLIENT-SERVER                                          │
│  ├── SERVER: socket() → bind() → listen() → accept() → r/w    │
│  └── CLIENT: socket() → connect() → read/write                 │
│                                                                 │
│  TCP vs UDP                                                     │
│  ├── TCP: connection-oriented, reliable, ordered               │
│  └── UDP: connectionless, best-effort, fast                    │
│                                                                 │
│  ADRESARE                                                       │
│  ├── IP Address: identifică host-ul în rețea                   │
│  ├── Port: identifică aplicația pe host                        │
│  └── Socket = (IP, Port, Protocol)                             │
│                                                                 │
│  COMENZI UTILE                                                  │
│  ├── netstat/ss: conexiuni active                              │
│  ├── ping: testare conectivitate                               │
│  └── tcpdump/wireshark: captură pachete                        │
│                                                                 │
│  💡 TAKEAWAY: Totul e socket — web, email, streaming           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---