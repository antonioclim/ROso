# C01_04_GHID_STUDIU.md
# Ghid de Studiu — Introducere în Sisteme de Operare

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 1 | by Revolvix

---

## Rezumat Executiv

Acest curs introduce conceptele fundamentale ale sistemelor de operare: definiție, roluri, arhitecturi și funcționare de bază. Este fundația pentru toate cursurile următoare.

**Timp de studiu recomandat**: 2-3 ore  
**Dificultate**: Introductiv

---

## Concepte Esențiale de Reținut

### 1. Definiția Sistemului de Operare

```
SO = Software care gestionează hardware-ul și oferă
     servicii pentru aplicații
```

**Două roluri principale**:
- **Gestionar de resurse**: Alocă CPU, memorie, I/O între procese
- **Mașină extinsă**: Oferă abstracții convenabile (fișiere, procese)

---

### 2. Dual Mode Operation

| Caracteristică | User Mode | Kernel Mode |
|---------------|-----------|-------------|
| Privilegii | Restricționate | Complete |
| Acces hardware | Indirect (prin syscalls) | Direct |
| Erori | Crash aplicație | Crash sistem |
| Exemple cod | Aplicații, libraries | Kernel, drivers |

**Mecanism de tranziție**: System call (trap)

---

### 3. System Calls

**Definiție**: Interfață controlată între aplicații și kernel.

**Categorii principale**:
- Procese: `fork()`, `exec()`, `exit()`
- Fișiere: `open()`, `read()`, `write()`, `close()`
- Memorie: `mmap()`, `brk()`
- Dispozitive: `ioctl()`

---

### 4. Arhitecturi de Kernel

| Tip | Caracteristici | Exemple |
|-----|---------------|---------|
| **Monolithic** | Tot în kernel, rapid, complex | Linux, BSD |
| **Microkernel** | Minim în kernel, modular, overhead IPC | MINIX, QNX |
| **Hybrid** | Combinație | Windows NT, macOS |

---

### 5. Procesul de Boot

```
POWER ON → BIOS/UEFI → BOOTLOADER → KERNEL → INIT → LOGIN
```

**Etape cheie**:
1. POST (hardware test)
2. Găsire boot device
3. Încărcare kernel în RAM
4. Kernel init + root mount
5. Pornire servicii sistem

---

## Termeni Cheie (Glosar)

| Termen | Definiție |
|--------|-----------|
| **Kernel** | Nucleul SO, rulează în mod privilegiat |
| **Shell** | Interfață (CLI sau GUI) pentru interacțiune cu SO |
| **Process** | Program în execuție |
| **Interrupt** | Semnal hardware/software care solicită atenția CPU |
| **Trap** | Întrerupere software (ex: system call) |
| **Bootstrap** | Procesul de pornire a sistemului |
| **Firmware** | Software permanent în hardware (BIOS/UEFI) |

---

## Întrebări de Auto-Evaluare

### Nivel 1: Cunoștințe
1. Ce este un sistem de operare?
2. Care sunt cele două roluri principale ale unui SO?
3. Ce reprezintă acronimul BIOS?

### Nivel 2: Înțelegere
4. De ce avem nevoie de dual mode operation?
5. Ce se întâmplă când o aplicație face un system call?
6. Care este diferența între interrupt și trap?

### Nivel 3: Aplicare
7. Explică procesul de boot al unui PC.
8. Compară kernel monolitic cu microkernel.
9. De ce aplicațiile nu pot accesa direct hardware-ul?

---

## Greșeli Frecvente de Evitat

❌ **Greșit**: "Kernel-ul este un program care rulează mereu"
✅ **Corect**: Kernel-ul este cod care se execută când este apelat (syscalls, interrupts)

❌ **Greșit**: "User mode înseamnă utilizator uman"
✅ **Corect**: User mode = nivel de privilegii CPU, nu despre cine folosește PC-ul

❌ **Greșit**: "Linux este un sistem de operare"
✅ **Corect**: Linux este un kernel; distribuțiile (Ubuntu, Fedora) sunt sisteme de operare complete

---

## Exerciții Practice

### Exercițiul 1: Explorare System Calls
```bash
# Pe Linux, listează system calls folosite de un program
strace ls -la 2>&1 | head -20

# Numără câte syscalls face un program simplu
strace -c ./program_simplu
```

### Exercițiul 2: Informații Sistem
```bash
# Versiune kernel
uname -r

# Informații despre CPU
cat /proc/cpuinfo | head -20

# Memorie disponibilă
free -h
```

### Exercițiul 3: Proces de Boot
```bash
# Vezi mesajele de boot
dmesg | head -50

# Servicii pornite de systemd
systemctl list-units --type=service --state=running
```

---

## Plan de Studiu Recomandat

### Ziua 1 (1 oră)
- [ ] Citește README.md din directorul cursului
- [ ] Revizuiește slide-urile/notițele de curs
- [ ] Completează glosarul cu definiții proprii

### Ziua 2 (1 oră)
- [ ] Studiază diagramele (concept map)
- [ ] Răspunde la întrebările de auto-evaluare
- [ ] Fă exercițiile practice pe Linux

### Ziua 3 (30 min)
- [ ] Recapitulare rapidă
- [ ] Completează quiz-ul formativ
- [ ] Notează întrebările pentru curs

---

## Resurse Suplimentare

### Lecturi Recomandate
- [OSTEP - Intro](https://pages.cs.wisc.edu/~remzi/OSTEP/intro.pdf) (gratuit, excelent)
- Silberschatz, Cap. 1-2

### Video
- [Crash Course: Operating Systems](https://www.youtube.com/watch?v=26QPDBe-NB8)

### Practice
- [Linux Journey](https://linuxjourney.com/) - Tutorial interactiv

---

## Pregătire pentru Cursul Următor

Cursul 2 va acoperi **Concepte de Bază ale SO** (întreruperi, I/O, DMA).

**Pre-cerințe de revizuit**:
- Ce este un interrupt?
- Diferența între polling și interrupts
- Ce face DMA?

---

*Ghid actualizat: Ianuarie 2026 | Feedback: issues@revolvix.dev*
