# Pornire Rapidă — Verificare în 5 Minute

> Folosește această listă pentru a verifica că instalarea este completă.  
> Dacă orice verificare eșuează, revino la ghidul complet pentru acel pas.

---

## Înainte de SEM01, verifică că totul funcționează

### Pasul 1: Poți porni Ubuntu?

**Utilizatori WSL2 (Windows):**
- Deschide meniul Start → tastează „Ubuntu" → click pentru a deschide
- Ar trebui să apară o fereastră terminal cu numele tău de utilizator

**Utilizatori VirtualBox:**
- Deschide VirtualBox → selectează VM-ul tău → click Start
- Conectează-te prin SSH: `ssh numeletau@ADRESA_IP_VM`

✅ **Trecut:** Vezi un prompt de comandă de genul `popescu@AP_1001_A:~$`

---

### Pasul 2: Rulează verificări rapide

Copiază și lipește aceste comenzi în Ubuntu:

```bash
# Verifică versiunea Ubuntu (ar trebui să arate 24.04)
lsb_release -d

# Verifică hostname-ul (ar trebui să fie în formatul INITIALA_GRUPA_SERIA)
hostname

# Verifică numele de utilizator (ar trebui să fie numele tău de familie)
whoami

# Verifică conectivitatea la internet
ping -c 2 google.com
```

✅ **Trecut:** Toate comenzile funcționează și arată valorile corecte

---

### Pasul 3: Rulează scriptul complet de verificare

```bash
bash ~/verify_installation.sh
```

Sau descarcă-l mai întâi dacă nu îl ai:

```bash
# Dacă verify_installation.sh nu este în directorul home
curl -O https://raw.githubusercontent.com/antonioclim/ROso/main/01_INIT_SETUP/verify_installation.sh
bash verify_installation.sh
```

✅ **Trecut:** Toate elementele arată `[OK]` în verde

---

### Pasul 4: Testează conexiunea SSH (din Windows/gazdă)

**Utilizatori Windows:**
1. Deschide PuTTY
2. Introdu adresa IP a Ubuntu (găsește-o cu `hostname -I` în Ubuntu)
3. Click Open
4. Autentifică-te cu credențialele tale

**Utilizatori macOS/Linux:**
```bash
ssh numeletau@ADRESA_IP
```

✅ **Trecut:** Te poți conecta remote la Ubuntu

---

## Card de Referință Rapidă

| Ce verifici | Comandă | Rezultat așteptat |
|-------------|---------|-------------------|
| Versiune Ubuntu | `lsb_release -d` | Ubuntu 24.04.x LTS |
| Hostname | `hostname` | AP_1001_A (formatul tău) |
| Nume utilizator | `whoami` | popescu (numele tău de familie) |
| Adresă IP | `hostname -I` | 172.x.x.x sau 192.168.x.x |
| Pornește SSH | `sudo systemctl start ssh` | Fără output = succes |
| Verifică SSH | `sudo systemctl status ssh` | „active (running)" |

---

## Toate verificările au trecut?

🎉 **Ești pregătit pentru SEM01!**

Adu laptopul încărcat. Începem să scriem cod din primul minut.

---

## Ceva a eșuat?

| Problemă | Soluție |
|----------|---------|
| Ubuntu nu pornește | Verifică virtualizarea în BIOS |
| Hostname greșit | Rulează din nou configurarea hostname (Secțiunea 6) |
| SSH nu funcționează | Rulează `sudo systemctl start ssh` |
| Fără internet | Verifică setările adaptorului de rețea |
| Am uitat parola | Vezi „Am uitat parola" în secțiunea de depanare |

Pentru ajutor detaliat, revino la ghidul complet:
- WSL2: `GHID_WSL2_Ubuntu2404_RO.md`
- VirtualBox: `GHID_VirtualBox_Ubuntu2404_RO.md`

---

*Versiune 2.1 | Ianuarie 2025 | ASE București - CSIE*
