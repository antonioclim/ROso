# Scripturi Demo — Curs 15 Suplimentar: Conectarea la Rețea

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> by Revolvix

---

## Cuprins Scripturi

| Script | Limbaj | Scop | Complexitate |
|--------|--------|------|--------------|
| `echo_server.py` | Python | Server TCP simplu cu echo | Medie |
| `echo_client.py` | Python | Client TCP pentru testare server | Medie |
| `network_diag.sh` | Bash | Diagnosticare rețea (IP, rute, porturi) | Simplă |
| `firewall_basic.sh` | Bash | Configurare reguli iptables de bază | Avansată |

---

## Utilizare Rapidă

### Echo Server/Client

```bash
# Terminal 1: Pornire server (ascultă pe port 9999)
python3 echo_server.py --port 9999

# Terminal 2: Conectare client
python3 echo_client.py --host localhost --port 9999

# Server cu logging verbose
python3 echo_server.py --port 9999 --verbose

# Client cu timeout personalizat
python3 echo_client.py --host 192.168.1.100 --port 9999 --timeout 10
```

### Diagnosticare Rețea

```bash
# Raport complet
./network_diag.sh

# Mod verbose cu detalii extinse
./network_diag.sh -v

# Verificare doar conectivitate
./network_diag.sh --connectivity-only
```

### Firewall (necesită sudo)

```bash
# Listare reguli curente
sudo ./firewall_basic.sh --list

# Permite trafic pe portul 80
sudo ./firewall_basic.sh --allow-port 80

# Blochează IP specific
sudo ./firewall_basic.sh --block-ip 10.0.0.100

# Reset la configurația implicită
sudo ./firewall_basic.sh --reset
```

---

## Legătura cu Conceptele din Curs

### Socket API (echo_server.py & echo_client.py)

Scripturile demonstrează ciclul complet al comunicării TCP:

```
Server:                          Client:
socket() → creează socket        socket() → creează socket
   ↓                                ↓
bind() → asociază IP:port           │
   ↓                                │
listen() → marchează pasiv          │
   ↓                                ↓
accept() ←─────────────────────── connect()
   ↓                                ↓
recv() ←───────────────────────── send()
   ↓                                ↓
send() ────────────────────────→ recv()
   ↓                                ↓
close()                           close()
```

### Modelul Client-Server

- **Server**: Ascultă pasiv, acceptă conexiuni multiple (opțional cu threading)
- **Client**: Inițiază conexiunea, trimite cereri, primește răspunsuri
- **Protocol**: TCP garantează livrare ordonată și fiabilă

### Diagnosticare Rețea (network_diag.sh)

Utilitare demonstrate:
- `ip addr` / `ifconfig` — Configurație interfețe
- `ip route` / `route` — Tabel de rutare
- `ss` / `netstat` — Conexiuni active și porturi deschise
- `ping` — Testare conectivitate ICMP
- `dig` / `nslookup` — Rezoluție DNS

### Securitate Rețea (firewall_basic.sh)

Concepte iptables:
- **Chains**: INPUT, OUTPUT, FORWARD
- **Targets**: ACCEPT, DROP, REJECT
- **Matching**: port, protocol, IP sursă/destinație

---

## Exemple Output

### echo_server.py

```
$ python3 echo_server.py --port 9999
[SERVER] Pornit pe 0.0.0.0:9999
[SERVER] Aștept conexiuni...
[CONN] Client conectat: 127.0.0.1:54321
[RECV] "Hello, server!"
[SEND] Echo: "Hello, server!"
[CONN] Client deconectat: 127.0.0.1:54321
```

### network_diag.sh

```
$ ./network_diag.sh
═══════════════════════════════════════════════════════════════
                    RAPORT DIAGNOSTIC REȚEA
═══════════════════════════════════════════════════════════════

[1/5] Interfețe de rețea:
  eth0: 192.168.1.50/24 (UP)
  lo: 127.0.0.1/8 (UP)

[2/5] Gateway implicit:
  192.168.1.1 via eth0

[3/5] Servere DNS:
  8.8.8.8, 8.8.4.4

[4/5] Porturi în ascultare:
  tcp 0.0.0.0:22 (sshd)
  tcp 0.0.0.0:80 (nginx)

[5/5] Test conectivitate:
  google.com: OK (23ms)
  8.8.8.8: OK (15ms)

═══════════════════════════════════════════════════════════════
```

---

## Cerințe Sistem

- Python 3.8+ (pentru echo_server.py și echo_client.py)
- Ubuntu 24.04 (WSL2 sau nativ)
- Pachete: `iproute2`, `dnsutils`, `iputils-ping`
- Pentru firewall: drepturi root/sudo, pachet `iptables`

### Instalare dependențe

```bash
sudo apt update
sudo apt install iproute2 dnsutils iputils-ping iptables
```

---

## Troubleshooting

| Problemă | Cauză | Soluție |
|----------|-------|---------|
| "Address already in use" | Portul e ocupat | `ss -tlnp \| grep <port>` și oprește procesul |
| "Connection refused" | Server nu rulează | Pornește serverul mai întâi |
| "Permission denied" (firewall) | Nu ai root | Rulează cu `sudo` |
| "Network unreachable" | Problemă rutare | Verifică `ip route` |

---

## Note Didactice

1. **Testare locală**: Folosește `localhost` sau `127.0.0.1` pentru teste inițiale
2. **Porturi**: Evită porturile < 1024 (necesită root); folosește 8000-65535
3. **Firewall**: Salvează regulile înainte de modificări (`iptables-save`)
4. **Debugging**: Folosește `tcpdump` sau Wireshark pentru analiză trafic

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*