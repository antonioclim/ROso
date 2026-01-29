# Sisteme de Operare - Săptămâna 1: Introducere în Sisteme de Operare

> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Obiectivele Săptămânii

După parcurgerea materialelor din această săptămână, vei putea să:

1. Definești conceptul de sistem de operare și funcțiile sale principale
2. Explici rolul SO ca intermediar între hardware și aplicații și să clasifici SO-urile după diverse criterii
3. Identifici componentele principale ale unui sistem de calcul și interacțiunea lor cu SO
4. Descrii evoluția istorică a sistemelor de operare și tendințele moderne

---

## Context aplicativ (scenariu didactic): De ce telefonul tău poate rula 50 de aplicații simultan fără să explodeze?

Deschide telefonul și numără aplicațiile care rulează în fundal: Spotify, WhatsApp, Gmail, Maps, Camera... Poate 20, 30, chiar 50 de aplicații. Toate "simultan". Pe un procesor cu 8 nuclee. Cum e posibil? 

Răspunsul stă în sistemul de operare - acel strat invizibil de software care jonglează cu resursele tale limitate (procesor, memorie, baterie) și creează iluzia că totul merge perfect în paralel. Fără SO, fiecare aplicație ar trebui să știe exact cum să vorbească cu fiecare componentă hardware - un coșmar pentru dezvoltatori și utilizatori deopotrivă.

> 💡 Gândește-te: Ce s-ar întâmpla dacă două aplicații ar încerca să scrie simultan în același loc din memorie?

Răspuns scurt: haos. Răspuns lung: vom discuta despre race conditions și sincronizare peste câteva săptămâni. E unul din cele mai interesante (și frustante!) subiecte din SO — haosul e surprinzător de subtil și greu de debugat.

---

## Conținut Curs (1/14)

### 1. Ce este un Sistem de Operare?

#### Definiție Formală (Academică)

> Sistemul de operare este un program (sau o colecție de programe) care acționează ca intermediar între utilizator și hardware-ul calculatorului, gestionând resursele hardware și oferind servicii comune pentru programele de aplicație. (Silberschatz, Galvin & Gagne, 2018)

Din perspectiva teoretică, SO-ul îndeplinește două roluri fundamentale:
- Mașină virtuală extinsă (extended machine): Abstractizează complexitatea hardware-ului
- Manager de resurse (resource manager): Alocă eficient CPU, memorie, dispozitive I/O

#### Explicație intuitivă (nivel introductiv)

Imaginează-ți că ai o orchestră cu 100 de muzicieni (aplicațiile) și doar 8 instrumente (nucleele procesorului). Fiecare muzician vrea să cânte, dar nu pot cânta toți odată pe aceleași instrumente!

> 💡 Am avut studenți care au învățat Bash în două săptămâni pornind de la zero — deci se poate, cu practică consistentă. Ușor, nu?


Sistemul de operare este dirijorul care:
- Decide cine cântă acum și cine așteaptă
- Se asigură că nimeni nu "fură" instrumentul altuia
- Coordonează totul să sune armonios
- Împiedică haosul și certurile

Fără dirijor, fiecare muzician ar încerca să smulgă instrumentul din mâna altuia → dezastru! Fără SO, fiecare aplicație ar încerca să acceseze direct hardware-ul → crash!

#### Context Istoric

| An | Eveniment | Semnificație |
|----|-----------|--------------|
| 1950s | Fără SO | Programatorii foloseau cartele perforate, un program pe rând |
| 1956 | GM-NAA I/O | Primul SO! General Motors + North American Aviation pentru IBM 704 |
| 1964 | OS/360 (IBM) | Primul SO "universal" pentru o familie de calculatoare |
| 1969 | UNIX (Bell Labs) | Ken Thompson & Dennis Ritchie; baza SO-urilor moderne |
| 1981 | MS-DOS | Microsoft; dominația PC-urilor personale |
| 1991 | Linux 0.01 | Linus Torvalds; revoluția open-source |
| 2007 | iOS / Android | SO-urile mobile domină |
| 2010s | Containere (Docker) | "SO-uri" pentru aplicații cloud |

> 💡 Fun fact: UNIX a fost scris inițial pentru a rula un joc - "Space Travel"! Thompson a vrut un calculator mai ieftin pe care să ruleze jocul său.

#### Structura unui Sistem de Calcul

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICAȚII (User Space)                    │
│           Browser, Editor, Spotify, VS Code, etc.            │
├─────────────────────────────────────────────────────────────┤
│                     SYSTEM CALLS                             │
│              (Interfața cu Kernel-ul)                        │
├─────────────────────────────────────────────────────────────┤
│                    KERNEL (SO)                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Procese  │ │ Memorie  │ │ Fișiere  │ │   I/O    │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
├─────────────────────────────────────────────────────────────┤
│                    HARDWARE                                  │
│           CPU, RAM, Disk, Network, GPU, etc.                │
└─────────────────────────────────────────────────────────────┘
```

---

### 2. Funcțiile Principale ale SO

| Funcție | Descriere | Exemplu Linux | Metaforă |
|---------|-----------|---------------|----------|
| Gestiunea proceselor | Crearea, planificarea, terminarea proceselor | `fork()`, `exec()`, scheduler | Dirijorul care decide cine cântă |
| Gestiunea memoriei | Alocarea și protecția memoriei | Paginare, memorie virtuală | Bibliotecarul care împarte cărțile |
| Gestiunea fișierelor | Organizarea și accesul la date persistente | ext4, permisiuni, directoare | Arhivistul care organizează dosare |
| Gestiunea I/O | Comunicarea cu dispozitivele | Drivere, buffering | Traducătorul între limbi diferite |
| Securitate | Protecția resurselor și utilizatorilor | Autentificare, autorizare | Paznicul care verifică legitimații |

---

### 3. Tipuri de Sisteme de Operare

#### Clasificare după scop

```
                    ┌─────────────────────────────────────────┐
                    │       SISTEME DE OPERARE                │
                    └───────────────┬─────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌───────▼───────┐          ┌───────▼───────┐          ┌───────▼───────┐
│   DESKTOP     │          │    SERVER     │          │   EMBEDDED    │
├───────────────┤          ├───────────────┤          ├───────────────┤
│ Windows 11   │          │ Ubuntu Server │          │ FreeRTOS      │
│ macOS        │          │ RHEL          │          │ Zephyr        │
│ Ubuntu       │          │ Windows Server│          │ VxWorks       │
│ Fedora       │          │ FreeBSD       │          │ Android (IoT) │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
   Interactivitate             Throughput               Timp Real
   Response Time              Disponibilitate           Consum mic
```

#### Clasificare după arhitectură

##### a) Kernel Monolitic

```
┌─────────────────────────────────────────┐
│            User Applications            │
├─────────────────────────────────────────┤
│              System Call Interface       │
├─────────────────────────────────────────┤
│   ┌─────────────────────────────────┐   │
│   │          MONOLITHIC KERNEL       │   │
│   │  ┌───────┐ ┌───────┐ ┌───────┐  │   │
│   │  │Process│ │Memory │ │  FS   │  │   │
│   │  │ Mgmt  │ │ Mgmt  │ │ Mgmt  │  │   │
│   │  └───────┘ └───────┘ └───────┘  │   │
│   │  ┌───────┐ ┌───────┐ ┌───────┐  │   │
│   │  │  I/O  │ │Network│ │Security│ │   │
│   │  └───────┘ └───────┘ └───────┘  │   │
│   └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│              Hardware                    │
└─────────────────────────────────────────┘
```

Exemple: Linux, FreeBSD, tradițional UNIX

Puncte forte: 
- Performanță excelentă (apeluri directe între module)
- Toate componentele în același spațiu de adrese

Puncte slabe:
- Un bug poate crăpa tot sistemul
- Greu de întreținut (milioane de linii de cod)

##### b) Microkernel

```
┌─────────────────────────────────────────┐
│            User Applications            │
├───────┬───────┬───────┬───────┬─────────┤
│  FS   │ Net   │ Driver│ Driver│  ...    │  ← User Space
│Server │Server │   1   │   2   │         │    Servers
├───────┴───────┴───────┴───────┴─────────┤
│           MICROKERNEL                    │
│    (doar: scheduling, IPC, basic MM)    │
├─────────────────────────────────────────┤
│              Hardware                    │
└─────────────────────────────────────────┘
```

Exemple: Minix, QNX, L4, seL4

Puncte forte:

- Izolare între componente (un server crapă → restul funcționează)
- Kernel mic, ușor de verificat formal
- Flexibilitate (servicii pot fi reîncărcate)


Puncte slabe:
- Overhead pentru comunicare inter-procese (IPC)
- Complexitate în design

##### c) Kernel Hibrid

Combină elemente din ambele abordări.

Exemple: Windows NT, macOS (XNU), BeOS

---

### 4. Primul Algoritm SO: Batch Processing

#### Definiție Formală

> Batch Processing (procesare pe loturi) este o tehnică de execuție în care job-urile sunt colectate, grupate și procesate secvențial fără intervenție manuală între ele. Utilizatorul nu interacționează cu sistemul în timpul execuției.

#### Explicație Intuitivă

Imaginează-ți o spălătorie automată pentru mașini:
- Mașinile (job-urile) se încolonează
- Fiecare mașină intră pe rând în tunel
- Se spală complet, apoi iese, și totodată următoarea mașină intră automat
- Tu nu intervii în proces - doar pui mașina la coadă și aștepți rezultatul

Fără batch processing (anii 1950): Trebuia să stai lângă calculator, să încarci manual cartelele perforate, să aștepți, să colectezi rezultatele, să încarci următorul program. Calculatorul sta nefolosit între job-uri!

Cu batch processing: Operatorul încarcă un teanc de job-uri seara. Calculatorul le procesează noaptea. Dimineața găsești toate rezultatele.

#### Istoric

| Când | Ce | Cine |
|------|-----|------|
| 1956 | Primul sistem batch: GM-NAA I/O | General Motors + North American Aviation |
| 1959 | SHARE Operating System | Consorțiu utilizatori IBM |
| 1961 | IBSYS pentru IBM 7090 | IBM |
| 1964 | OS/360 | IBM - cel mai influent SO batch |

Problema rezolvată: Utilizarea CPU era ~30% (restul = timp mort între job-uri). Cu batch processing: ~90%+

#### Costuri și Trade-off-uri

| Avantaj | Dezavantaj |
|---------|------------|
| Utilizare CPU ridicată | Fără interactivitate |
| Procesare eficientă volume mari | Timp lung de răspuns |
| Simplu de implementat | Eroare la job 5? Afli după job 100 |
| Bun pentru calcule lungi | Nu potrivit pentru aplicații interactive |

#### Implementare Comparativă

| Aspect | Mainframe clasic | Linux modern | Windows |
|--------|------------------|--------------|---------|
| Implementare | Job Control Language (JCL) | `cron`, `at`, `systemd` | Task Scheduler |
| Nivel | Kernel + utilități | Userspace daemons | Serviciu Windows |
| Limbaj | Assembler, JCL | C, Bash, Python | C++, PowerShell |

#### Reproducere în Python

```python
#!/usr/bin/env python3
"""
Simulare simplificată a unui sistem Batch Processing.
Demonstrează conceptul de job queue și execuție secvențială.
"""

import time
from collections import deque
from dataclasses import dataclass
from typing import Callable

@dataclass
class Job:
    """Reprezintă un job în sistemul batch."""
    id: int
    name: str
    duration: float  # secunde
    task: Callable[[], str]  # funcția de executat

class BatchProcessor:
    """
    Procesor batch simplu.
    
    Concepte demonstrate:

Trei lucruri contează aici: job queue (coadă fifo), execuție secvențială fără intervenție, și logging/accounting.


# Exemplu de utilizare
if __name__ == "__main__":
    processor = BatchProcessor()
    
    # Definim câteva job-uri
    def calculate_pi():
        time.sleep(0.5)  # Simulează calcul
        return "3.14159..."
    
    def sort_data():
        time.sleep(0.3)
        return "Data sorted"
    
    def generate_report():
        time.sleep(0.7)
        return "Report generated"
    
    # Submitem job-urile (ca în anii '50, fără interacțiune ulterioară)
    processor.submit_job(Job(1, "Calculate Pi", 0.5, calculate_pi))
    processor.submit_job(Job(2, "Sort Data", 0.3, sort_data))
    processor.submit_job(Job(3, "Generate Report", 0.7, generate_report))
    
    # Rulăm batch-ul
    processor.run()
```

Output:
```
[SUBMIT] Job #1 'Calculate Pi' added to queue
[SUBMIT] Job #2 'Sort Data' added to queue
[SUBMIT] Job #3 'Generate Report' added to queue

==================================================
BATCH PROCESSING STARTED
==================================================

[RUNNING] Job #1 'Calculate Pi'...
[DONE] Job #1 completed in 0.50s

[RUNNING] Job #2 'Sort Data'...
[DONE] Job #2 completed in 0.30s

[RUNNING] Job #3 'Generate Report'...
[DONE] Job #3 completed in 0.70s

==================================================
BATCH COMPLETE: 3 jobs in 1.50s
==================================================
```

#### Tendințe Moderne

| Evoluție | Descriere |
|----------|-----------|
| Cloud Batch | AWS Batch, Azure Batch, Google Cloud Batch |
| Container-based | Kubernetes Jobs, Argo Workflows |
| Serverless | AWS Lambda (triggered batch) |
| ML/AI Pipelines | Apache Airflow, Kubeflow, MLflow |
| Big Data | Apache Spark batch jobs, Hadoop MapReduce |

Batch processing nu a dispărut - s-a **transformat**! Astăzi:
- ETL jobs rulează noaptea
- Training ML pe GPU clusters
- Rapoarte financiare generate batch
- Video encoding în cloud

---

### 5. Brainstorm: Primul SO din istorie

Situația: În anii 1950, calculatoarele nu aveau sisteme de operare. Programatorii trebuiau să-și încarce manual programele pe cartele perforate, să aștepte execuția, să colecteze rezultatele. Un calculator IBM 704 costa milioane de dolari și stătea nefolosit ore întregi între job-uri.

Întrebări pentru reflecție:
1. Ce problemă principală trebuia rezolvată?
2. Ce funcție ar fi prioritară pentru primul SO?
3. Cum ai automatiza trecerea de la un program la altul?

Cum a fost rezolvat în practică: 

General Motors a creat în 1956 GM-NAA I/O pentru IBM 704 - primul SO! 

Funcția principală: batch processing - citirea automată a unui job de pe cartele, execuția, și trecerea la următorul job fără intervenție umană. 

Rezultat: Utilizarea CPU-ului a crescut de la ~30% la peste 90%.

---

## Demonstrații Practice

### Demo 1: Explorarea sistemului cu `neofetch`

```bash
# Instalare (dacă nu există)
sudo apt install neofetch -y

# Rulare
neofetch
```

Vei vedea informații complete: SO, kernel, uptime, shell, rezoluție, CPU, GPU, memorie.

### Demo 2: Vizualizare procese cu `htop`

```bash
# Instalare
sudo apt install htop -y

# Rulare
htop
```

Ce observi:
- Lista proceselor cu PID, utilizator, CPU%, MEM%
- Numărul de core-uri și utilizarea lor
- Memoria totală vs. utilizată
- Load average

### Demo 3: Explorarea `/proc`

```bash
# Versiunea kernel-ului
cat /proc/version

# Timpul de când rulează sistemul (în secunde)
cat /proc/uptime

# Informații despre CPU
cat /proc/cpuinfo | grep "model name" | head -1

# Statistici memorie
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# Procesul curent (shell-ul nostru)
echo $$  # PID-ul shell-ului
ls /proc/$$/
cat /proc/$$/status | head -20
```

### Demo 4: System calls cu `strace`

```bash
# Instalare
sudo apt install strace -y

# Urmărește ce system calls face comanda 'ls'
strace ls 2>&1 | head -30

# Numără system calls
strace -c ls 2>&1
```

---

## Lectură Recomandată

### OSTEP (Operating Systems: Three Easy Pieces)
- Obligatoriu: [Capitolul 2 - Introduction to Operating Systems](https://pages.cs.wisc.edu/~remzi/OSTEP/intro.pdf)
- Opțional: Prefața și Dialogul introductiv

### Tanenbaum - Modern Operating Systems
- Capitolul 1: Introduction (pag. 1-61)

### Resurse suplimentare
- [The Evolution of Operating Systems](https://www.computerhistory.org/revolution/mainframe-computers/7)
- [Linux Journey - Getting Started](https://linuxjourney.com/lesson/linux-history)
- [OSDev Wiki - Introduction](https://wiki.osdev.org/Introduction)

---

## Auto-evaluare

### Întrebări de verificare
1. Care sunt cele patru funcții principale ale unui sistem de operare?
2. Ce diferență există între kernel space și user space?
3. De ce aplicațiile nu pot accesa direct hardware-ul?
4. Care sunt avantajele și dezavantajele unui kernel monolitic vs microkernel?
5. Ce problemă a rezolvat batch processing în anii 1950?

> 💡 Am observat că studenții care desenează diagrama pe hârtie înainte de a scrie codul au rezultate mult mai bune.


### Mini-provocare
Deschide un terminal și răspunde la următoarele întrebări folosind comenzi:
1. Ce versiune de kernel rulează pe sistemul tău?
2. Câte procese rulează în acest moment?
3. Cât RAM are sistemul și cât e utilizat?
4. Ce tip de arhitectură are procesorul tău?

```bash
# Sugestii de comenzi
uname -r                          # versiune kernel
ps aux | wc -l                    # număr procese
free -h                           # RAM
cat /proc/cpuinfo | grep "model name" | head -1
```

---

## Privire înainte

Săptămâna 2: Concepte de Bază ale SO - Analizăm serviciile oferite de SO, apelurile de sistem, și vom vedea cum aplicațiile "vorbesc" cu kernel-ul.

Pregătire: 
- Asigură-te că ai acces la un sistem Ubuntu 24.04 (nativ, WSL2, sau VirtualBox)
- Familiarizează-te cu terminalul și comenzile de bază (`ls`, `cd`, `pwd`, `cat`)

---

## Sumar Comenzi Noi

| Comandă | Descriere | Exemplu |
|---------|-----------|---------|
| `uname -a` | Afișează informații despre sistem | `uname -a` |
| `cat /etc/os-release` | Detalii despre distribuția Linux | `cat /etc/os-release` |
| `htop` | Monitor interactiv procese | `htop` |
| `neofetch` | Informații sistem în format vizual | `neofetch` |
| `cat /proc/...` | Citire informații din proc filesystem | `cat /proc/cpuinfo` |
| `free -h` | Afișează utilizarea memoriei | `free -h` |
| `ps aux` | Listează toate procesele | `ps aux \| head` |
| `strace` | Urmărește system calls | `strace ls` |

---

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 1: RECAP                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CE ESTE SO?                                                    │
│  ├── Intermediar utilizator ↔ hardware                         │
│  ├── Manager de resurse (CPU, RAM, I/O, Files)                 │
│  └── Mașină virtuală extinsă                                   │
│                                                                 │
│  FUNCȚII PRINCIPALE                                             │
│  ├── Gestiune procese (scheduling, creare, terminare)          │
│  ├── Gestiune memorie (alocare, protecție, virtualizare)       │
│  ├── Gestiune fișiere (organizare, acces, persistență)         │
│  ├── Gestiune I/O (drivere, buffering)                         │
│  └── Securitate (autentificare, autorizare)                    │
│                                                                 │
│  TIPURI SO                                                      │
│  ├── După scop: Desktop, Server, Embedded, Mobile              │
│  ├── După kernel: Monolitic, Microkernel, Hibrid               │
│  └── După timp real: RTOS vs General Purpose                   │
│                                                                 │
│  ALGORITM: BATCH PROCESSING                                     │
│  ├── Definiție: Execuție secvențială fără intervenție          │
│  ├── Problemă rezolvată: Utilizare CPU de la 30% la 90%+       │
│  ├── Istoric: 1956 - GM-NAA I/O (primul SO!)                   │
│  └── Modern: Cloud Batch, Kubernetes Jobs, ML Pipelines        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate by Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

## Scripting în context (Bash + Python): Inventariere de sistem și simulare Batch

### Fișiere incluse

- Bash: `scripts/so_diag.sh` — Colectează un raport de sistem (kernel/CPU/memorie/procese).
- Python: `scripts/batch_sim.py` — Simulare FCFS pentru Batch Processing (timpi de așteptare/turnaround).

### Rulare rapidă

```bash
./scripts/so_diag.sh -v
./scripts/batch_sim.py 2 1 3.5 0.5
```

### Legătura cu conceptele din această săptămână

- Într-un sistem *batch*, scheduling-ul este, în forma sa cea mai simplă, o coadă FCFS: job-urile se execută pe rând.
- Un raport de sistem este primul pas în observabilitate: înainte de a explica „de ce e lent”, trebuie să măsori.

### Practică recomandată

- rulează întâi scripturile pe un director de test (nu pe date critice);
- salvează output-ul într-un fișier și atașează-l la raport/temă, dacă este cerut;
- notează versiunea de kernel (`uname -r`) și versiunea Python (`python3 --version`) când compari rezultate.

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*
