# SO_curs18suppl: Integrarea NPU în Sistemele de Operare — Scheduling Heterogen și Gestiunea Memoriei pentru Inferență AI

> **Modul Suplimentar Avansat** | Sisteme de Operare  
> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Cuprins

1. [Obiective și Competențe](#1-obiective-și-competențe)
2. [Motivație: De ce NPU în 2025-2026?](#2-motivație-de-ce-npu-în-2025-2026)
3. [Arhitectura Sistemelor Heterogene CPU+GPU+NPU](#3-arhitectura-sistemelor-heterogene-cpugpunpu)
4. [Scheduling Heterogen: De la Big.LITTLE la Thread Director](#4-scheduling-heterogen-de-la-biglittle-la-thread-director)
5. [Gestiunea Memoriei pentru Inferență AI](#5-gestiunea-memoriei-pentru-inferență-ai)
6. [Comparație Arhitecturală: Apple vs Intel vs AMD vs Qualcomm](#6-comparație-arhitecturală-apple-vs-intel-vs-amd-vs-qualcomm)
7. [Integrarea la Nivel de Sistem de Operare](#7-integrarea-la-nivel-de-sistem-de-operare)
8. [Modelul de Drivere pentru NPU](#8-modelul-de-drivere-pentru-npu)
9. [Izolarea și Securitatea pentru Workload-uri AI](#9-izolarea-și-securitatea-pentru-workload-uri-ai)
10. [Demonstrații Practice](#10-demonstrații-practice)
11. [Trade-off-uri Arhitecturale](#11-trade-off-uri-arhitecturale)
12. [Exerciții și Provocări](#12-exerciții-și-provocări)
13. [Referințe și Lectură Suplimentară](#13-referințe-și-lectură-suplimentară)

---

## 1. Obiective și Competențe

### 1.1. Obiective de Învățare

La finalizarea acestui modul, studentul va fi capabil să:

1. **Explice arhitectura sistemelor heterogene** cu CPU, GPU și NPU, identificând rolul fiecărei componente și modul în care cooperează

2. **Analizeze mecanismele de scheduling heterogen** implementate în procesoarele moderne (Intel Thread Director, Apple AMX scheduling, AMD XDNA)

3. **Compare strategiile de gestiune a memoriei** pentru inferență AI: unified memory vs discrete memory, DMA pentru NPU, zero-copy buffers

4. **Evalueze trade-off-urile arhitecturale** între diferitele abordări (Apple, Intel, AMD, Qualcomm) din perspectiva performanței, eficienței energetice și programabilității

5. **Înțeleagă modelul de drivere** pentru NPU în Linux (subsistemul accel) și Windows (MCDM - Microsoft Compute Driver Model)

6. **Identifice implicațiile pentru izolare și securitate** când workload-uri AI accesează resurse partajate

### 1.2. Competențe Transversale

- **Gândire sistemică**: înțelegerea interacțiunilor complexe între CPU, GPU, NPU și memorie
- **Analiză comparativă**: evaluarea critică a diferitelor abordări arhitecturale
- **Perspectivă evolutivă**: înțelegerea cum conceptele tradiționale de SO se adaptează la noi paradigme

### 1.3. Prerequisite

- Scheduling (Cursul 4) — algoritmi de planificare, preemption, priorități
- Gestiunea Memoriei (Cursurile 9-10) — paginare, TLB, DMA
- Drivere și Module Kernel (Cursul 17) — interacțiunea user space/kernel space

---

## 2. Motivație: De ce NPU în 2025-2026?

### 2.1. Contextul: AI on the Edge

Începând cu 2024, **toate procesoarele mainstream** includ unități dedicate pentru inferență AI:

- **Intel Core Ultra** (Meteor Lake, Lunar Lake, Arrow Lake) — NPU bazat pe tehnologie Movidius
- **Apple M-series** (M1-M4) — Neural Engine integrat
- **AMD Ryzen AI** (Phoenix, Hawk Point, Strix Point) — XDNA NPU
- **Qualcomm Snapdragon X** — Hexagon NPU

Această convergență nu este întâmplătoare — reflectă o schimbare fundamentală în cerințele aplicațiilor:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              EVOLUȚIA CERINȚELOR COMPUTAȚIONALE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1980-2000: CPU Single-Core                                                 │
│  └── Workload-uri secvențiale, creștere frecvență                          │
│                                                                             │
│  2000-2010: CPU Multi-Core                                                  │
│  └── Paralelism explicit, threading, SMP                                   │
│                                                                             │
│  2010-2020: CPU + GPU                                                       │
│  └── GPGPU pentru grafică și compute intensiv                              │
│                                                                             │
│  2020-prezent: CPU + GPU + NPU                                              │
│  └── Inferență AI on-device, modele de limbaj locale                       │
│      Copilot, Apple Intelligence, Windows Recall                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2. Problema pentru Sistemele de Operare

Introducerea NPU-urilor ridică întrebări fundamentale pentru proiectarea SO:

1. **Scheduling**: Cum decidem ce rulează pe CPU vs GPU vs NPU?
2. **Memoria**: Cum gestionăm transferul de date între unitățile de procesare?
3. **Izolarea**: Cum prevenim ca un proces să acceseze modelul AI al altui proces?
4. **Drivere**: Ce model de driver este potrivit pentru acceleratoare AI?
5. **Energia**: Cum optimizăm consumul când avem 3 tipuri de procesoare?

### 2.3. Definiția "AI PC" / "Copilot+ PC"

Microsoft a definit **Copilot+ PC** ca un sistem care îndeplinește:

- **NPU cu ≥40 TOPS** (Tera Operations Per Second)
- **≥16 GB RAM**
- **≥256 GB stocare SSD**
- Suport pentru Windows AI Foundry APIs

Această definiție hardware are implicații directe pentru SO — Windows 11 24H2 include funcționalități care *necesită* NPU:

- **Windows Recall** — captură și indexare semantică continuă
- **Live Captions** — transcriere în timp real
- **Cocreator în Paint** — generare imagine locală
- **Windows Studio Effects** — procesare video în timp real

---

## 3. Arhitectura Sistemelor Heterogene CPU+GPU+NPU

### 3.1. Topologia Fizică

Sistemele moderne integrează multiple unități de procesare pe același die sau package:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TOPOLOGIA UNUI SoC MODERN (exemplu: Intel Lunar Lake)    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         COMPUTE TILE                                 │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   P-Core 1   │  │   P-Core 2   │  │   P-Core 3   │  ...         │   │
│  │  │   (Lion)     │  │   (Lion)     │  │   (Lion)     │              │   │
│  │  │  + Thread    │  │  + Thread    │  │  + Thread    │              │   │
│  │  │   Director   │  │   Director   │  │   Director   │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  │                                                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   E-Core 1   │  │   E-Core 2   │  │   E-Core 3   │  ...         │   │
│  │  │ (Skymont LP) │  │ (Skymont LP) │  │ (Skymont LP) │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                              Ring Interconnect                              │
│                                    │                                        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │   GPU TILE      │    │   NPU TILE      │    │   SOC TILE      │        │
│  │   (Xe2-LPG)     │    │   (NPU 4)       │    │   (I/O, Media)  │        │
│  │   8 Xe cores    │    │   6 NCE units   │    │   USB, PCIe     │        │
│  │   67 TOPS       │    │   48 TOPS       │    │   Display       │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│                                    │                                        │
│                           Memory Controller                                 │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         LPDDR5X (On-Package)                         │   │
│  │                         32GB @ 8533 MT/s                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Caracteristicile Fiecărei Unități de Procesare

```
┌───────────────────────────────────────────────────────────────────────────────┐
│           COMPARAȚIE: CPU vs GPU vs NPU                                        │
├──────────────┬──────────────────┬──────────────────┬──────────────────────────┤
│   Aspect     │       CPU        │       GPU        │          NPU             │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Paradigmă    │ Secvențială      │ SIMT (Single     │ Dataflow /               │
│              │ (pipelining)     │ Instruction,     │ Systolic Array           │
│              │                  │ Multiple Thread) │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Optimizat    │ Control flow     │ Throughput       │ Înmulțire matrice        │
│ pentru       │ complex,         │ masiv, SIMD      │ (GEMM), convoluții       │
│              │ latență mică     │ larg             │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Precizie     │ FP64, FP32       │ FP32, FP16,      │ INT8, INT4, FP16         │
│ tipică       │                  │ BF16, TF32       │ (cuantizat)              │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Memorie      │ Cache ierarhic   │ VRAM dedicat     │ Scratchpad software-     │
│              │ (L1/L2/L3)       │ sau unified      │ managed + DMA            │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Eficiență    │ ~0.1 TOPS/W      │ ~1 TOPS/W        │ ~5-10 TOPS/W             │
│ energetică   │                  │                  │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Use case     │ Logică aplicație │ Training ML,     │ Inferență on-device,     │
│ tipic        │ OS, I/O          │ rendering        │ always-on AI             │
└──────────────┴──────────────────┴──────────────────┴──────────────────────────┘
```

### 3.3. Modelul de Programare

Diferența fundamentală între CPU, GPU și NPU din perspectiva programatorului:

```python
# === CPU: Control explicit, instrucțiuni secvențiale ===
def matmul_cpu(A, B):
    C = np.zeros((A.shape[0], B.shape[1]))
    for i in range(A.shape[0]):
        for j in range(B.shape[1]):
            for k in range(A.shape[1]):
                C[i,j] += A[i,k] * B[k,j]
    return C

# === GPU: Paralelism SIMT, kernel launch ===
# (CUDA pseudocod)
@cuda.jit
def matmul_gpu(A, B, C):
    i, j = cuda.grid(2)
    if i < C.shape[0] and j < C.shape[1]:
        tmp = 0.0
        for k in range(A.shape[1]):
            tmp += A[i, k] * B[k, j]
        C[i, j] = tmp

# === NPU: Graph-based, runtime dispatch ===
# (ONNX Runtime / CoreML / OpenVINO)
model = onnxruntime.InferenceSession("model.onnx", 
                                      providers=['NPUExecutionProvider'])
output = model.run(None, {"input": input_tensor})
# Runtime-ul decide cum să mapeze operațiile pe NPU
```

**Observație critică**: NPU-urile nu se programează direct — se specifică un *graf de calcul* (ONNX, CoreML, TensorFlow) iar runtime-ul (OpenVINO, CoreML, DirectML) compilează și optimizează pentru hardware-ul specific.

---

## 4. Scheduling Heterogen: De la Big.LITTLE la Thread Director

### 4.1. Evoluția Scheduling-ului Asimetric

Scheduler-ele tradiționale presupuneau core-uri identice. Introducerea arhitecturilor asimetrice a forțat schimbări fundamentale:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EVOLUȚIA SCHEDULING-ULUI ASIMETRIC                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  2011: ARM big.LITTLE                                                       │
│  ├── Prima arhitectură comercială asimetrică                               │
│  ├── Scheduler în firmware (IKS - In-Kernel Switcher)                      │
│  └── Migrare la nivel de cluster, nu per-thread                            │
│                                                                             │
│  2014: ARM GTS (Global Task Scheduling)                                     │
│  ├── Toate core-urile vizibile pentru OS                                   │
│  ├── Scheduler-ul decide pe ce core rulează fiecare thread                 │
│  └── Linux EAS (Energy Aware Scheduling) — kernel 4.10+                    │
│                                                                             │
│  2021: Intel Alder Lake + Thread Director                                   │
│  ├── Hardware monitorizează caracteristicile workload-ului                 │
│  ├── Furnizează hints către OS prin HFI (Hardware Feedback Interface)      │
│  └── Scheduling rămâne decizia OS-ului, dar cu informații precise          │
│                                                                             │
│  2024: Intel Lunar Lake + Containment Zones                                 │
│  ├── Colaborare Microsoft pentru "zone de contenție"                       │
│  ├── Workload-uri lightweight rămân pe E-cores implicit                    │
│  └── 35% reducere consum pentru aplicații tipice                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Intel Thread Director în Detaliu

Thread Director este o unitate hardware care monitorizează continuu execuția thread-urilor și clasifică workload-urile:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ARHITECTURA THREAD DIRECTOR                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MONITORIZARE HARDWARE                             │   │
│  │                                                                      │   │
│  │   Pentru fiecare thread activ, se analizează:                       │   │
│  │   • Mix de instrucțiuni (INT, FP, vector, branch)                   │   │
│  │   • Rata de cache miss (L1, L2, L3)                                 │   │
│  │   • Dependențe de memorie (memory-bound vs compute-bound)           │   │
│  │   • Utilizare unități vectoriale (AVX-512, AMX)                     │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    CLASIFICARE WORKLOAD                              │   │
│  │                                                                      │   │
│  │   Clase detectate:                                                  │   │
│  │   • Background/Idle — E-core optimal                                │   │
│  │   • I/O intensive — E-core optimal                                  │   │
│  │   • Integer compute — E-core eficient                               │   │
│  │   • FP/Vector — P-core necesar                                      │   │
│  │   • AI/Matrix (AMX) — P-core cu AMX                                 │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                 HARDWARE FEEDBACK INTERFACE (HFI)                    │   │
│  │                                                                      │   │
│  │   Tabel per-core expus către OS:                                    │   │
│  │   ┌───────────┬────────────────────┬─────────────────────┐          │   │
│  │   │  Core ID  │  Performance Score │  Efficiency Score   │          │   │
│  │   ├───────────┼────────────────────┼─────────────────────┤          │   │
│  │   │  P-core 0 │        100         │         45          │          │   │
│  │   │  P-core 1 │        100         │         45          │          │   │
│  │   │  E-core 0 │         36         │        100          │          │   │
│  │   │  E-core 1 │         36         │        100          │          │   │
│  │   └───────────┴────────────────────┴─────────────────────┘          │   │
│  │                                                                      │   │
│  │   Scorurile se actualizează dinamic (throttling termic, etc.)       │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    SCHEDULER OS (Windows/Linux)                      │   │
│  │                                                                      │   │
│  │   Folosește HFI pentru a decide plasarea thread-urilor:             │   │
│  │   • Priorități high + FP-heavy → P-core                             │   │
│  │   • Background tasks → E-core                                       │   │
│  │   • Thermal throttling → migrare la E-cores                         │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3. Scheduling pentru NPU — O Paradigmă Diferită

**NPU-urile nu sunt programate direct de scheduler-ul OS!** Aceasta este o diferență fundamentală față de CPU:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                CPU SCHEDULING vs NPU SCHEDULING                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CPU SCHEDULING (tradițional)                                               │
│  ────────────────────────────                                               │
│                                                                             │
│   [Thread A] [Thread B] [Thread C]                                         │
│        │          │          │                                              │
│        └──────────┼──────────┘                                              │
│                   ▼                                                         │
│        ┌─────────────────────┐                                              │
│        │   OS Scheduler      │ ◄── Context switch ~1-10μs                  │
│        │   (preemptiv)       │                                              │
│        └─────────────────────┘                                              │
│                   │                                                         │
│     ┌─────────────┼─────────────┐                                           │
│     ▼             ▼             ▼                                           │
│  [Core 0]     [Core 1]     [Core 2]                                        │
│                                                                             │
│                                                                             │
│  NPU SCHEDULING (queue-based)                                               │
│  ────────────────────────────                                               │
│                                                                             │
│   [App A]         [App B]         [App C]                                  │
│      │               │               │                                      │
│      │   ┌───────────┼───────────┐   │                                      │
│      │   │           │           │   │                                      │
│      ▼   ▼           ▼           ▼   ▼                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │     User-space Runtime                   │                               │
│   │     (OpenVINO, CoreML, DirectML)         │                               │
│   │     - Compilare graf → NPU instructions  │                               │
│   │     - Memory management                  │                               │
│   │     - Queue management                   │                               │
│   └─────────────────────────────────────────┘                               │
│                      │                                                      │
│                      ▼                                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │     Kernel Driver (intel_vpu, amdxdna)  │                               │
│   │     - Submit comenzi la hardware        │                               │
│   │     - Alocare memorie DMA               │                               │
│   │     - Izolare între contexte            │                               │
│   └─────────────────────────────────────────┘                               │
│                      │                                                      │
│                      ▼                                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │            NPU Hardware                  │                               │
│   │     - Command queue (FIFO/prioritizat)  │                               │
│   │     - Execuție non-preemptivă           │ ◄── Întrerupere grosieră     │
│   │       (terminare layer sau checkpoint)  │     sau deloc                │
│   └─────────────────────────────────────────┘                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.4. Priority Inversion în Sisteme Heterogene

Problema clasică de priority inversion capătă forme noi când NPU-ul este implicat:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                PRIORITY INVERSION CU NPU                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Scenariul:                                                                 │
│  • Task L (low priority) — pornește inferență pe NPU (durată 100ms)        │
│  • Task M (medium priority) — CPU intensive                                │
│  • Task H (high priority) — necesită NPU pentru inferență urgentă          │
│                                                                             │
│  Problema:                                                                  │
│                                                                             │
│  t=0ms    [L] submit job NPU ─────────────────────────────────────►        │
│  t=10ms   [M] preempts L pe CPU                                            │
│  t=20ms   [H] needs NPU, dar NPU ocupat de L!                              │
│           │                                                                 │
│           ▼                                                                 │
│           H așteaptă... (inversion!)                                       │
│           Deși H > M > L, H nu poate rula                                  │
│                                                                             │
│  t=100ms  NPU termină job-ul lui L                                         │
│  t=100ms  H poate în sfârșit să folosească NPU                             │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Soluții propuse:                                                          │
│                                                                             │
│  1. Preemption la nivel de layer (checkpoint după GEMM)                    │
│     - Implementare: PREMA scheduler (cercetare)                            │
│     - Overhead: salvare/restaurare stare (~1-5% din timp execuție)         │
│                                                                             │
│  2. Priority inheritance pentru resurse NPU                                │
│     - L moștenește prioritatea H cât ține NPU-ul                           │
│     - Implementare limitată în drivere actuale                             │
│                                                                             │
│  3. Time-slicing cu quantum mic                                            │
│     - Job-uri mari se fragmentează în sub-grafuri                          │
│     - Overhead de context switch NPU semnificativ                          │
│                                                                             │
│  4. Separate queues per priority                                           │
│     - Implementare Intel NPU: multiple contexte cu priorități              │
│     - Limit: ~6-16 contexte concurente                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Gestiunea Memoriei pentru Inferență AI

### 5.1. Provocările Memoriei pentru AI

Workload-urile AI au caracteristici de memorie distincte:

| Caracteristică | Workload Tradițional | Workload AI Inference |
|----------------|---------------------|----------------------|
| Pattern acces | Random / secvențial mixt | Streaming predictibil |
| Dimensiune working set | KB - MB | MB - GB (modele) |
| Reutilizare date | Variabilă | Înaltă (weights reused) |
| Latență critică | Variabil | Da (real-time) |
| Bandwidth cerut | Moderat | Foarte mare |

### 5.2. Unified Memory vs Discrete Memory

```
┌─────────────────────────────────────────────────────────────────────────────┐
│             UNIFIED MEMORY vs DISCRETE MEMORY                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  UNIFIED MEMORY (Apple M-series, Qualcomm, Intel on-package LPDDR)         │
│  ══════════════════════════════════════════════════════════════            │
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐                                    │
│   │   CPU   │  │   GPU   │  │   NPU   │                                    │
│   └────┬────┘  └────┬────┘  └────┬────┘                                    │
│        │            │            │                                          │
│        └────────────┼────────────┘                                          │
│                     │                                                       │
│              Memory Controller                                              │
│                     │                                                       │
│        ┌────────────┴────────────┐                                          │
│        │     UNIFIED DRAM        │  ← Același pool fizic                   │
│        │  (LPDDR5X, 128GB max)   │                                          │
│        └─────────────────────────┘                                          │
│                                                                             │
│   Avantaje:                                                                │
│   ✓ Zero-copy: CPU pregătește tensor, NPU îl citește direct               │
│   ✓ Latență mică: fără transfer PCIe                                       │
│   ✓ Eficiență energetică: un singur controller                             │
│   ✓ Programare simplificată: pointeri valizi peste tot                     │
│                                                                             │
│   Dezavantaje:                                                             │
│   ✗ Bandwidth limitat (max ~500 GB/s LPDDR5X)                              │
│   ✗ Capacitate limitată de package size                                    │
│   ✗ Contention între CPU/GPU/NPU                                           │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  DISCRETE MEMORY (NVIDIA datacenter, AMD dGPU)                             │
│  ═══════════════════════════════════════════                               │
│                                                                             │
│   ┌─────────┐                    ┌─────────────────────┐                   │
│   │   CPU   │                    │       GPU           │                   │
│   └────┬────┘                    │  ┌──────────────┐   │                   │
│        │                         │  │   HBM/GDDR   │   │                   │
│   ┌────┴────┐                    │  │   (VRAM)     │   │                   │
│   │ System  │◄═══ PCIe 5.0 ═════►│  │   96GB HBM3  │   │                   │
│   │  DRAM   │     64 GB/s        │  │   ~3 TB/s    │   │                   │
│   └─────────┘                    │  └──────────────┘   │                   │
│                                  └─────────────────────┘                   │
│                                                                             │
│   Avantaje:                                                                │
│   ✓ Bandwidth foarte mare (HBM3: 3+ TB/s)                                  │
│   ✓ Capacitate mare, scalabilă                                             │
│   ✓ Izolare naturală                                                       │
│                                                                             │
│   Dezavantaje:                                                             │
│   ✗ Transfer explicit CPU↔GPU necesar                                      │
│   ✗ Latență PCIe ~1-2μs                                                    │
│   ✗ Consum energetic mai mare                                              │
│   ✗ Programare complexă (memory management explicit)                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3. Zero-Copy și DMA pentru NPU

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ZERO-COPY BUFFER FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  FĂRĂ Zero-Copy (overhead ridicat):                                        │
│  ═══════════════════════════════════                                        │
│                                                                             │
│  [User Buffer]  ──copy──►  [Kernel Buffer]  ──DMA──►  [NPU Scratchpad]    │
│       ↑                          ↑                           ↑             │
│   malloc()              kmalloc(GFP_DMA)               SRAM intern        │
│   user space              kernel space                  hardware           │
│                                                                             │
│  Overhead: 2 copii + syscall overhead                                      │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  CU Zero-Copy (optimal):                                                   │
│  ═══════════════════════                                                    │
│                                                                             │
│  [User Buffer]  ────────── DMA direct ──────────►  [NPU Scratchpad]       │
│       ↑                                                    ↑               │
│   mmap() pe                                         SRAM intern           │
│   memorie fizică                                    hardware              │
│   contiguă                                                                 │
│                                                                             │
│  Implementare (Linux):                                                     │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │  // Alocare buffer DMA-capable                                      │   │
│  │  dma_addr_t dma_handle;                                             │   │
│  │  void *buf = dma_alloc_coherent(dev, size, &dma_handle, GFP_KERNEL);│   │
│  │                                                                      │   │
│  │  // Map în user space pentru zero-copy                              │   │
│  │  vm_area->vm_page_prot = pgprot_noncached(vm_area->vm_page_prot);   │   │
│  │  remap_pfn_range(vm_area, vaddr, PFN(dma_handle), size, prot);      │   │
│  │                                                                      │   │
│  │  // User space scrie direct → NPU citește via DMA                   │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4. Scratchpad Memory vs Cache Ierarhic

NPU-urile folosesc preponderent **scratchpad memory** (SPM) în loc de cache tradițional:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              CACHE vs SCRATCHPAD MEMORY                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CACHE (CPU/GPU tradițional)                                               │
│  ═══════════════════════════                                                │
│                                                                             │
│   • Hardware-managed: CPU decide ce rămâne în cache                        │
│   • Transparent pentru programator                                          │
│   • Replacement policy: LRU, pseudo-LRU                                    │
│   • Bun pentru pattern-uri impredictibile                                  │
│                                                                             │
│   Problema pentru AI: eviction nedorită a weights în timpul inferenței    │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  SCRATCHPAD (NPU, DSP)                                                     │
│  ═════════════════════                                                      │
│                                                                             │
│   • Software-managed: programatorul controlează ce date sunt prezente     │
│   • Explicit DMA: load_tile(addr, size, scratchpad_offset)                │
│   • Nu există "miss" — eroare de programare dacă datele nu sunt acolo     │
│   • Predictibilitate perfectă pentru scheduling                            │
│                                                                             │
│   Exemplu AMD XDNA:                                                        │
│   ┌────────────────────────────────────────────────────────────────────┐  │
│   │                                                                    │  │
│   │    AI Engine Tile                                                  │  │
│   │    ┌──────────────────┐                                            │  │
│   │    │  Vector Unit     │                                            │  │
│   │    │  128 MACs/cycle  │                                            │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │                                                      │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │  Local Memory    │ ◄── 64KB scratchpad per tile              │  │
│   │    │  (Scratchpad)    │                                            │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │ DMA                                                  │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │  Memory Tile     │ ◄── 512KB shared L2                       │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │                                                      │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │   System DRAM    │ ◄── LPDDR5X                               │  │
│   │    └──────────────────┘                                            │  │
│   │                                                                    │  │
│   └────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.5. PagedAttention: Memorie Virtuală pentru KV-Cache

O inovație recentă aplică concepte de memorie virtuală la gestiunea memoriei pentru LLM:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PagedAttention (vLLM)                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Problema: KV-Cache pentru LLM crește cu lungimea contextului              │
│  ═════════════════════════════════════════════════════════════              │
│                                                                             │
│  Model 7B, context 4K tokens:                                              │
│  KV-Cache = 32 layers × 32 heads × 4096 tokens × 128 dims × 2 (K+V)       │
│           ≈ 4GB per request!                                               │
│                                                                             │
│  Alocare tradițională: pre-alocă pentru max_tokens → 60-80% memorie       │
│  risipită când requesturile au lungimi variabile                           │
│                                                                             │
│  Soluția PagedAttention (analogie cu paging OS):                           │
│  ════════════════════════════════════════════════                           │
│                                                                             │
│   OS Paging              │    PagedAttention                               │
│   ──────────────────────────────────────────────────                       │
│   Page = 4KB             │    Block = 16 tokens                            │
│   Page Table             │    Block Table                                  │
│   Virtual Address        │    Logical Block Index                          │
│   Physical Frame         │    Physical GPU Memory Block                    │
│   Demand Paging          │    Allocate on Generate                         │
│   COW (fork)             │    Shared KV for Beam Search                    │
│                                                                             │
│   ┌──────────────────────────────────────────────────────────────────┐    │
│   │                                                                  │    │
│   │   Request 1 Block Table:     Physical Memory:                    │    │
│   │   ┌───┬───┬───┬───┐         ┌─────────────────────────┐         │    │
│   │   │ 0 │ 1 │ 2 │ 3 │         │ Block 7 │ [Request 1]   │         │    │
│   │   └─┬─┴─┬─┴─┬─┴─┬─┘         │ Block 2 │ [Request 2]   │         │    │
│   │     │   │   │   │           │ Block 9 │ [Request 1]   │         │    │
│   │     │   │   │   └──────────►│ Block 4 │ [FREE]        │         │    │
│   │     │   │   └──────────────►│ Block 1 │ [Request 1]   │         │    │
│   │     │   └──────────────────►│ Block 6 │ [Request 2]   │         │    │
│   │     └──────────────────────►│ Block 3 │ [Request 1]   │         │    │
│   │                             └─────────────────────────┘         │    │
│   │                                                                  │    │
│   │   Rezultat: memorie risipită < 4% (vs 60-80% tradițional)       │    │
│   │   Throughput: 2-4x mai mare pentru serving LLM                   │    │
│   │                                                                  │    │
│   └──────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Comparație Arhitecturală: Apple vs Intel vs AMD vs Qualcomm

### 6.1. Tabel Comparativ Detaliat

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                    COMPARAȚIE NPU: APPLE vs INTEL vs AMD vs QUALCOMM              │
├─────────────┬──────────────┬──────────────┬──────────────┬────────────────────────┤
│   Aspect    │  Apple M4    │ Intel Lunar  │ AMD Strix    │ Qualcomm Snapdragon   │
│             │  Neural Eng  │  Lake NPU    │  Point XDNA  │  X Elite Hexagon      │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ TOPS        │ 38           │ 48           │ 50           │ 45                     │
│ (INT8)      │              │              │              │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Arhitectură │ 16 Neural    │ 2×Movidius   │ 4×8 AI      │ 4-wide VLIW +          │
│             │ Engine cores │ cores + 6    │ Engine tile │ 6-way SMT +            │
│             │              │ NCE units    │ array       │ Tensor coprocessor     │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Memorie     │ Unified      │ Unified      │ Unified     │ Unified LPDDR5X        │
│             │ (până la     │ LPDDR5X      │ LPDDR5X     │ (până la 64GB)         │
│             │ 128GB)       │ (32GB max)   │             │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Precizie    │ FP16, INT8   │ FP16, INT8   │ BF16, INT8, │ FP16, INT8, INT4       │
│             │              │              │ INT4        │ INT2 (experimental)    │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ API/        │ CoreML       │ OpenVINO,    │ ROCm,       │ Qualcomm AI Engine     │
│ Framework   │ (exclusiv)   │ DirectML     │ DirectML    │ (QNN), DirectML        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ OS Support  │ macOS only   │ Windows,     │ Windows,    │ Windows on ARM         │
│             │              │ Linux        │ Linux       │ (nativ necesar)        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Programare  │ Walled       │ Semi-open    │ Open        │ Semi-open              │
│             │ garden       │ (OpenVINO)   │ (ROCm/XRT)  │ (SDK necesar)          │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Concurrency │ Nedocumentat │ ~6 contexte  │ 6-16        │ Multiple queues        │
│             │              │              │ contexte    │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Eficiență   │ ~2.5         │ ~2.8         │ ~1.9        │ ~1.9-2.0               │
│ (TOPS/W)    │              │              │             │                        │
└─────────────┴──────────────┴──────────────┴──────────────┴────────────────────────┘
```

### 6.2. Analiza Arhitecturii Apple

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    APPLE NEURAL ENGINE (M4)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Filozofie: "It just works" — integrare strânsă, control complet           │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │      Developer                                                      │   │
│  │         │                                                           │   │
│  │         ▼                                                           │   │
│  │   ┌──────────────┐                                                  │   │
│  │   │   CoreML     │ ◄── Model format proprietar (.mlmodel)          │   │
│  │   │   Framework  │                                                  │   │
│  │   └──────┬───────┘                                                  │   │
│  │          │                                                           │   │
│  │          ▼                                                           │   │
│  │   ┌──────────────┐                                                  │   │
│  │   │   Compiler   │ ◄── Optimizare automată pentru hardware         │   │
│  │   │   (privat)   │     Graph partitioning, fusion                   │   │
│  │   └──────┬───────┘                                                  │   │
│  │          │                                                           │   │
│  │     ┌────┼────┬────────────┐                                        │   │
│  │     ▼    ▼    ▼            ▼                                        │   │
│  │   [ANE] [GPU] [CPU]    [AMX]                                        │   │
│  │                                                                     │   │
│  │   Runtime decide automat unde rulează fiecare operație             │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Avantaje:                                                                 │
│  ✓ Zero-copy între toate unitățile (unified memory)                        │
│  ✓ Optimizare end-to-end de către Apple                                    │
│  ✓ Eficiență energetică excelentă                                          │
│  ✓ Experiență developer simplificată                                       │
│                                                                             │
│  Dezavantaje:                                                              │
│  ✗ Nicio programabilitate directă a Neural Engine                          │
│  ✗ Lock-in în ecosistem Apple                                              │
│  ✗ Operații nesuportate → fallback GPU/CPU                                 │
│  ✗ Debugging limitat                                                       │
│                                                                             │
│  Apple Intelligence (2024):                                                │
│  • Model ~3B parametri, cuantizat 2-4 biți                                 │
│  • 30 tokens/s pe iPhone 15 Pro                                            │
│  • Private Cloud Compute pentru queries complexe                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3. Analiza Arhitecturii Intel

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INTEL NPU (Lunar Lake - NPU 4)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Filozofie: Standard industry, compatibilitate largă                       │
│                                                                             │
│  Arhitectură internă:                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │    ┌──────────────────────────────────────────────────────────┐    │   │
│  │    │              Command & Scheduling Unit                   │    │   │
│  │    │    2× Movidius LEON cores (SPARC-based)                  │    │   │
│  │    └──────────────────────────┬───────────────────────────────┘    │   │
│  │                               │                                     │   │
│  │    ┌──────────────────────────┴───────────────────────────────┐    │   │
│  │    │              Neural Compute Engine (NCE)                 │    │   │
│  │    │    • 6 NCE units în Lunar Lake                           │    │   │
│  │    │    • 4096 MAC units per NCE                              │    │   │
│  │    │    • 1.4 GHz max frequency                               │    │   │
│  │    │    • INT8: 2 ops/cycle, FP16: 1 op/cycle                 │    │   │
│  │    └──────────────────────────────────────────────────────────┘    │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Stack Software:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   [Application]                                                     │   │
│  │        │                                                            │   │
│  │        ▼                                                            │   │
│  │   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐        │   │
│  │   │   OpenVINO    │   │   DirectML    │   │   ONNX RT     │        │   │
│  │   │   (Intel)     │   │   (Microsoft) │   │   (Cross)     │        │   │
│  │   └───────┬───────┘   └───────┬───────┘   └───────┬───────┘        │   │
│  │           │                   │                   │                 │   │
│  │           └───────────────────┼───────────────────┘                 │   │
│  │                               ▼                                     │   │
│  │                    ┌───────────────────┐                            │   │
│  │                    │   Level Zero API  │                            │   │
│  │                    └─────────┬─────────┘                            │   │
│  │                              │                                      │   │
│  │           ┌──────────────────┼──────────────────┐                   │   │
│  │           ▼                  ▼                  ▼                   │   │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐           │   │
│  │   │ Linux Driver │   │  Windows     │   │  Chrome OS   │           │   │
│  │   │  (intel_vpu) │   │  MCDM Driver │   │   Driver     │           │   │
│  │   └──────────────┘   └──────────────┘   └──────────────┘           │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Linux Driver details:                                                     │
│  • Mainline since kernel 6.2                                               │
│  • Device: /dev/accel/accel0                                               │
│  • Firmware: /lib/firmware/intel/vpu/                                      │
│  • Cache: ~/.cache/ze_intel_npu_cache/                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.4. Analiza Arhitecturii AMD XDNA

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AMD XDNA (Strix Point)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Filozofie: Spatial dataflow — calcul ca flux prin array de tile-uri       │
│  Origine: Xilinx AI Engine (achiziție 2022)                                │
│                                                                             │
│  Arhitectura Tile Array (4×8 = 32 tiles pe Strix Point):                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │   │
│  │   │ AIE │ │ AIE │ │ AIE │ │ AIE │ │ MEM │ │ MEM │ │ MEM │ │ MEM │ │   │
│  │   └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ │   │
│  │      │       │       │       │       │       │       │       │    │   │
│  │   ┌──┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴──┐ │   │
│  │   │              Configurable Switch Network                    │ │   │
│  │   └──┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬──┘ │   │
│  │      │       │       │       │       │       │       │       │    │   │
│  │   ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ │   │
│  │   │ AIE │ │ AIE │ │ AIE │ │ AIE │ │ MEM │ │ MEM │ │ MEM │ │ MEM │ │   │
│  │   └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ │   │
│  │     ...     ...     ...     ...     ...     ...     ...     ...   │   │
│  │                                                                     │   │
│  │   AIE = AI Engine (VLIW + SIMD vector unit)                        │   │
│  │   MEM = Memory Tile (L2 shared)                                    │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Caracteristici unice:                                                     │
│  • Spatial partitioning: array-ul poate fi împărțit între workloads       │
│  • Determinism: DMA programatic, nu cache → latență predictibilă          │
│  • Scalabilitate: design-ul scalează cu numărul de tile-uri               │
│                                                                             │
│  Linux Driver (amdxdna):                                                   │
│  • Mainline Linux 6.14                                                     │
│  • Spatial partitioning la granularitate de coloană                       │
│  • PASID (Process Address Space ID) pentru izolare hardware               │
│  • XRT (Xilinx Runtime) pentru management                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.5. Analiza Arhitecturii Qualcomm Hexagon

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    QUALCOMM HEXAGON NPU (Snapdragon X Elite)                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Filozofie: Mobile-first, eficiență energetică extremă                     │
│  Heritage: 15+ ani de DSP în smartphones                                   │
│                                                                             │
│  Arhitectura Hexagon:                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  Hexagon Scalar Core                        │  │   │
│  │   │    • 4-wide VLIW (4 instrucțiuni/ciclu)                    │  │   │
│  │   │    • 6-way SMT (simultaneous multithreading)               │  │   │
│  │   │    • Control flow, gather/scatter                          │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  HVX (Hexagon Vector Extensions)            │  │   │
│  │   │    • 32 × 1024-bit vector registers                        │  │   │
│  │   │    • Predicated execution                                  │  │   │
│  │   │    • Sliding window operations                             │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  Tensor Coprocessor (HTP)                   │  │   │
│  │   │    • 16K MAC ops/cycle                                     │  │   │
│  │   │    • INT8, INT4, INT2 precision                            │  │   │
│  │   │    • Fused depthwise convolutions                          │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  8MB TCM (Tightly Coupled Memory)           │  │   │
│  │   │    • Software-managed scratchpad                           │  │   │
│  │   │    • DMA scatter-gather                                    │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Eficiență remarcabilă:                                                    │
│  • AI tasks: 1/28 power vs CPU equivalent                                  │
│  • Battery life: 21-27 ore pentru laptops                                  │
│                                                                             │
│  Limitare critică pentru Windows:                                          │
│  • NPU accelerație DOAR pentru aplicații ARM64 native                      │
│  • x86 emulation (Prism) NU poate accesa NPU                               │
│  • Implicație: necesită recompilare aplicații                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Integrarea la Nivel de Sistem de Operare

### 7.1. Windows AI Foundry

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WINDOWS AI STACK (2025)                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        Applications                                  │  │
│   │    Paint Cocreator │ Windows Recall │ Live Captions │ Copilot      │  │
│   └───────────────────────────────┬─────────────────────────────────────┘  │
│                                   │                                        │
│   ┌───────────────────────────────┴─────────────────────────────────────┐  │
│   │                    Windows AI Foundry APIs                           │  │
│   │                                                                      │  │
│   │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │  │
│   │   │  Windows ML  │  │    Phi       │  │  Semantic    │             │  │
│   │   │  (ONNX RT)   │  │  Silica SLM  │  │   Index      │             │  │
│   │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │  │
│   │          │                 │                 │                      │  │
│   └──────────┼─────────────────┼─────────────────┼──────────────────────┘  │
│              │                 │                 │                        │
│   ┌──────────┴─────────────────┴─────────────────┴──────────────────────┐  │
│   │                    ONNX Runtime                                      │  │
│   │    Execution Provider auto-discovery                                │  │
│   └───────────────────────────────┬─────────────────────────────────────┘  │
│                                   │                                        │
│              ┌────────────────────┼────────────────────┐                   │
│              ▼                    ▼                    ▼                   │
│   ┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐       │
│   │   QNN EP          │ │   OpenVINO EP     │ │   DirectML EP     │       │
│   │   (Qualcomm)      │ │   (Intel)         │ │   (Generic)       │       │
│   │   ↓               │ │   ↓               │ │   ↓               │       │
│   │   Qualcomm NPU    │ │   Intel NPU       │ │   GPU fallback    │       │
│   └───────────────────┘ └───────────────────┘ └───────────────────┘       │
│                                   │                                        │
│   ┌───────────────────────────────┴─────────────────────────────────────┐  │
│   │                    MCDM (Microsoft Compute Driver Model)             │  │
│   │                                                                      │  │
│   │    • Derivat din WDDM (display driver model)                        │  │
│   │    • Memory management pentru compute devices                       │  │
│   │    • Multi-tasking cu securitate între contexte                     │  │
│   │    • ETW events pentru performance monitoring                        │  │
│   │    • Task Manager NPU utilization                                   │  │
│   │                                                                      │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2. Linux Compute Acceleration Subsystem

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LINUX ACCEL SUBSYSTEM                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Istoric:                                                                  │
│  • Pre-2022: NPU drivers → DRM subsystem (impropriu)                      │
│  • 2022: Propunere subsistem dedicat pentru accelerators                   │
│  • Linux 6.2+: /dev/accel/* cu major number 261                           │
│                                                                             │
│  Structura în kernel:                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   drivers/accel/                                                    │   │
│  │   ├── accel_drv.c          # Core accel framework                  │   │
│  │   ├── ivpu/                # Intel VPU/NPU driver                  │   │
│  │   │   ├── ivpu_drv.c                                               │   │
│  │   │   ├── ivpu_gem.c       # Memory management                     │   │
│  │   │   ├── ivpu_job.c       # Job submission                        │   │
│  │   │   └── ivpu_mmu.c       # IOMMU integration                     │   │
│  │   ├── habanalabs/          # Intel Gaudi (datacenter)              │   │
│  │   └── amdxdna/             # AMD XDNA driver (6.14+)               │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Device nodes:                                                             │
│  • /dev/accel/accel0      (primul accelerator)                            │
│  • /dev/accel/accel1      (al doilea, etc.)                               │
│                                                                             │
│  Diferențe față de DRM GPU:                                                │
│  • DRIVER_COMPUTE_ACCEL flag (mutual exclusiv cu DRIVER_RENDER)           │
│  • Nu expune KMS (display) interfaces                                      │
│  • Focus pe compute workloads                                              │
│                                                                             │
│  User-space stack:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │   Application (Python ML, C++ inference)                            │   │
│  │        │                                                            │   │
│  │        ▼                                                            │   │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │   │
│  │   │   OpenVINO   │  │   PyTorch    │  │  TensorFlow  │             │   │
│  │   │              │  │   (ONNX)     │  │   Lite       │             │   │
│  │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │   │
│  │          │                 │                 │                      │   │
│  │          └─────────────────┼─────────────────┘                      │   │
│  │                            ▼                                        │   │
│  │                 ┌───────────────────┐                               │   │
│  │                 │   Level Zero API  │ ◄── Intel oneAPI              │   │
│  │                 └─────────┬─────────┘                               │   │
│  │                           │                                         │   │
│  │                           ▼                                         │   │
│  │                 ┌───────────────────┐                               │   │
│  │                 │  /dev/accel/accel0│                               │   │
│  │                 │  (ioctl interface)│                               │   │
│  │                 └───────────────────┘                               │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Modelul de Drivere pentru NPU

### 8.1. Componente Driver NPU

Un driver NPU complet trebuie să gestioneze:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPONENTE DRIVER NPU                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DEVICE INITIALIZATION                                                  │
│     • PCI/ACPI enumeration                                                 │
│     • Firmware loading                                                     │
│     • Hardware reset și power-up sequence                                  │
│                                                                             │
│  2. MEMORY MANAGEMENT                                                      │
│     • GEM (Graphics Execution Manager) objects                             │
│     • DMA buffer allocation (contiguous physical memory)                   │
│     • IOMMU/SMMU mapping pentru izolare                                    │
│     • mmap() pentru user-space access                                      │
│                                                                             │
│  3. COMMAND SUBMISSION                                                     │
│     • Command buffer parsing și validare                                   │
│     • Job queue management                                                 │
│     • Dependency tracking între jobs                                       │
│     • Fence/sync objects pentru completion notification                    │
│                                                                             │
│  4. CONTEXT MANAGEMENT                                                     │
│     • Per-process context isolation                                        │
│     • PASID (Process Address Space ID) support                            │
│     • Resource limits per context                                          │
│                                                                             │
│  5. POWER MANAGEMENT                                                       │
│     • Runtime PM (suspend/resume)                                          │
│     • DVFS (Dynamic Voltage Frequency Scaling)                            │
│     • Thermal throttling response                                          │
│                                                                             │
│  6. ERROR HANDLING                                                         │
│     • Hardware error detection                                             │
│     • Context recovery                                                     │
│     • Fault reporting la user-space                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2. Exemplu: Intel NPU Driver (ivpu)

```c
/* Simplificat din drivers/accel/ivpu/ivpu_drv.c */

static int ivpu_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
    struct ivpu_device *vdev;
    int ret;

    /* 1. Alocă structura device */
    vdev = devm_kzalloc(&pdev->dev, sizeof(*vdev), GFP_KERNEL);
    
    /* 2. Mapează BAR-urile PCI */
    vdev->regb = pcim_iomap(pdev, 0, 0);  /* Control registers */
    vdev->regv = pcim_iomap(pdev, 2, 0);  /* VPU registers */
    
    /* 3. Configurează IOMMU */
    ret = ivpu_mmu_init(vdev);
    
    /* 4. Încarcă firmware */
    ret = ivpu_fw_load(vdev);
    
    /* 5. Inițializează job scheduler */
    ret = ivpu_job_init(vdev);
    
    /* 6. Înregistrează în accel subsystem */
    ret = drm_dev_register(&vdev->drm, 0);
    /* Creează /dev/accel/accel0 */
    
    return 0;
}

/* Job submission flow */
static int ivpu_job_submit(struct ivpu_context *ctx, 
                           struct ivpu_job *job)
{
    /* Validare comenzi */
    ret = ivpu_cmdq_validate(job->cmdq);
    
    /* Pinning memory buffers */
    ret = ivpu_gem_pin_pages(job->buffers);
    
    /* Map în IOMMU pentru NPU access */
    ret = ivpu_mmu_map(ctx, job->buffers);
    
    /* Submit la hardware queue */
    ivpu_cmdq_submit(ctx->hw_queue, job);
    
    /* Creează fence pentru completion */
    job->fence = ivpu_fence_create(ctx);
    
    return 0;
}
```

---

## 9. Izolarea și Securitatea pentru Workload-uri AI

### 9.1. Vectori de Atac Specifici NPU

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VECTORI DE ATAC NPU                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. MODEL EXTRACTION                                                       │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Atacator: Proces malițios pe același sistem                   │     │
│     │  Țintă: Weights-urile modelului AI al victimei                │     │
│     │  Metodă:                                                       │     │
│     │  • Side-channel pe shared cache/memory bus                     │     │
│     │  • Timing analysis pe NPU shared                               │     │
│     │  • Memory snooping dacă izolarea e slabă                       │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. INPUT/OUTPUT INFERENCE                                                 │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Atacator: Alt proces                                          │     │
│     │  Țintă: Datele de intrare/ieșire ale inferenței               │     │
│     │  Metodă:                                                       │     │
│     │  • DMA buffer snooping                                         │     │
│     │  • Memory remanence după deallocate                            │     │
│     │  • Shared memory timing                                        │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3. DENIAL OF SERVICE                                                      │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Atacator: Proces cu acces la NPU                              │     │
│     │  Țintă: Disponibilitatea NPU pentru alți utilizatori          │     │
│     │  Metodă:                                                       │     │
│     │  • Ocupare permanentă a NPU cu jobs mari                       │     │
│     │  • Memory exhaustion pentru DMA buffers                        │     │
│     │  • Firmware crash prin input malformat                         │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  4. PRIVILEGE ESCALATION                                                   │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Atacator: User cu acces limitat                               │     │
│     │  Țintă: Acces kernel sau alte procese                         │     │
│     │  Metodă:                                                       │     │
│     │  • Bug în firmware NPU → arbitrary code exec                   │     │
│     │  • IOMMU bypass                                                │     │
│     │  • Driver vulnerability (ioctl parsing)                        │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2. Mecanisme de Protecție

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MECANISME DE IZOLARE NPU                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. IOMMU (Input-Output Memory Management Unit)                            │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │   Process A          Process B          NPU                    │     │
│     │   VA space           VA space           DMA                    │     │
│     │      │                  │                 │                    │     │
│     │      ▼                  ▼                 ▼                    │     │
│     │   ┌──────┐          ┌──────┐         ┌──────┐                 │     │
│     │   │ PT A │          │ PT B │         │IOMMU │                 │     │
│     │   │(CPU) │          │(CPU) │         │  PT  │                 │     │
│     │   └──┬───┘          └──┬───┘         └──┬───┘                 │     │
│     │      │                 │                │                     │     │
│     │      └─────────────────┼────────────────┘                     │     │
│     │                        ▼                                      │     │
│     │              ┌─────────────────┐                              │     │
│     │              │  Physical RAM   │                              │     │
│     │              │                 │                              │     │
│     │              │ ┌─────┐ ┌─────┐ │                              │     │
│     │              │ │ A's │ │ B's │ │                              │     │
│     │              │ │data │ │data │ │                              │     │
│     │              │ └─────┘ └─────┘ │                              │     │
│     │              └─────────────────┘                              │     │
│     │                                                                │     │
│     │   NPU poate accesa DOAR paginile mapate în IOMMU PT           │     │
│     │   pentru contextul curent                                     │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. PASID (Process Address Space ID) — AMD XDNA                            │
│     • Fiecare proces primește un ID unic                                   │
│     • NPU hardware verifică PASID la fiecare acces                         │
│     • Izolare fără context switch complet                                  │
│                                                                             │
│  3. SPATIAL PARTITIONING — AMD XDNA                                        │
│     • Array-ul de tile-uri poate fi partiționat fizic                     │
│     • Process A: coloanele 0-3, Process B: coloanele 4-7                  │
│     • Izolare hardware completă                                            │
│                                                                             │
│  4. MEMORY ZEROING                                                         │
│     • DMA buffers se șterg (zero) la dealocare                            │
│     • Previne memory remanence attacks                                     │
│     • Overhead de performanță (acceptabil pentru securitate)               │
│                                                                             │
│  5. FIRMWARE VERIFICATION                                                  │
│     • Secure boot pentru firmware NPU                                      │
│     • Signature verification înainte de load                               │
│     • Rollback protection                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Demonstrații Practice

### 10.1. Verificare NPU pe Linux

```bash
#!/bin/bash
# npu_check.sh - Verificare prezență și status NPU

echo "=== NPU Detection Script ==="
echo ""

# 1. Verificare accel devices
echo "[1] Accel devices:"
if ls /dev/accel/accel* 2>/dev/null; then
    ls -la /dev/accel/
else
    echo "    Nu există /dev/accel/* - NPU driver neîncărcat sau absent"
fi
echo ""

# 2. Verificare Intel NPU
echo "[2] Intel NPU (ivpu):"
if lsmod | grep -q ivpu; then
    echo "    ✓ ivpu driver loaded"
    lspci | grep -i "VPU\|NPU" || echo "    (device not in lspci output)"
else
    echo "    ✗ ivpu driver not loaded"
    # Încercare încărcare
    # sudo modprobe intel_vpu
fi
echo ""

# 3. Verificare AMD XDNA
echo "[3] AMD XDNA (amdxdna):"
if lsmod | grep -q amdxdna; then
    echo "    ✓ amdxdna driver loaded"
else
    echo "    ✗ amdxdna driver not loaded"
fi
echo ""

# 4. OpenVINO device query
echo "[4] OpenVINO devices (dacă instalat):"
if command -v benchmark_app &> /dev/null; then
    benchmark_app -d AVAILABLE | head -20
else
    echo "    OpenVINO nu este instalat"
    echo "    Instalare: pip install openvino"
fi
echo ""

# 5. Firmware check
echo "[5] NPU Firmware:"
if ls /lib/firmware/intel/vpu/*.bin 2>/dev/null; then
    echo "    Intel VPU firmware present:"
    ls /lib/firmware/intel/vpu/*.bin
else
    echo "    Intel VPU firmware not found"
fi
```

### 10.2. Benchmark NPU vs CPU vs GPU

```python
#!/usr/bin/env python3
"""
npu_benchmark.py - Comparație inferență NPU vs CPU vs GPU
Requires: pip install openvino onnxruntime torch torchvision
"""

import time
import numpy as np

def benchmark_inference(provider_name, session, input_data, iterations=100):
    """Benchmark inference latency"""
    # Warmup
    for _ in range(10):
        session.run(None, input_data)
    
    # Measure
    latencies = []
    for _ in range(iterations):
        start = time.perf_counter()
        session.run(None, input_data)
        latencies.append((time.perf_counter() - start) * 1000)  # ms
    
    return {
        'provider': provider_name,
        'mean_ms': np.mean(latencies),
        'std_ms': np.std(latencies),
        'p50_ms': np.percentile(latencies, 50),
        'p99_ms': np.percentile(latencies, 99),
    }

def main():
    import onnxruntime as ort
    
    print("=== NPU vs CPU vs GPU Benchmark ===\n")
    
    # Descarcă model de test (MobileNetV2)
    model_path = "mobilenetv2-7.onnx"
    
    # Verifică provideri disponibili
    print("Available Execution Providers:")
    for ep in ort.get_available_providers():
        print(f"  - {ep}")
    print()
    
    # Input de test
    input_data = {"input": np.random.randn(1, 3, 224, 224).astype(np.float32)}
    
    results = []
    
    # CPU Benchmark
    print("Testing CPU...")
    sess_cpu = ort.InferenceSession(model_path, providers=['CPUExecutionProvider'])
    results.append(benchmark_inference("CPU", sess_cpu, input_data))
    
    # GPU Benchmark (CUDA dacă disponibil)
    if 'CUDAExecutionProvider' in ort.get_available_providers():
        print("Testing GPU (CUDA)...")
        sess_gpu = ort.InferenceSession(model_path, providers=['CUDAExecutionProvider'])
        results.append(benchmark_inference("GPU (CUDA)", sess_gpu, input_data))
    
    # NPU Benchmark (OpenVINO)
    if 'OpenVINOExecutionProvider' in ort.get_available_providers():
        print("Testing NPU (OpenVINO)...")
        sess_npu = ort.InferenceSession(model_path, 
            providers=['OpenVINOExecutionProvider'],
            provider_options=[{'device_type': 'NPU'}])
        results.append(benchmark_inference("NPU (OpenVINO)", sess_npu, input_data))
    
    # DirectML (Windows)
    if 'DmlExecutionProvider' in ort.get_available_providers():
        print("Testing DirectML...")
        sess_dml = ort.InferenceSession(model_path, providers=['DmlExecutionProvider'])
        results.append(benchmark_inference("DirectML", sess_dml, input_data))
    
    # Afișare rezultate
    print("\n" + "=" * 60)
    print(f"{'Provider':<20} {'Mean (ms)':<12} {'P50 (ms)':<12} {'P99 (ms)':<12}")
    print("=" * 60)
    for r in results:
        print(f"{r['provider']:<20} {r['mean_ms']:<12.2f} {r['p50_ms']:<12.2f} {r['p99_ms']:<12.2f}")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### 10.3. Monitorizare NPU Utilization

```bash
#!/bin/bash
# npu_monitor.sh - Monitorizare NPU în timp real (Intel)

# Verificare prezență intel_gpu_top (din intel-gpu-tools)
if ! command -v intel_gpu_top &> /dev/null; then
    echo "Instalează: sudo apt install intel-gpu-tools"
    exit 1
fi

# Pentru NPU, folosim sysfs (dacă expus de driver)
NPU_SYSFS="/sys/class/accel/accel0"

if [ -d "$NPU_SYSFS" ]; then
    echo "=== NPU Status ==="
    
    while true; do
        clear
        echo "$(date)"
        echo ""
        
        # Device info
        if [ -f "$NPU_SYSFS/device/power/runtime_status" ]; then
            echo "Power state: $(cat $NPU_SYSFS/device/power/runtime_status)"
        fi
        
        # Memory usage (dacă disponibil)
        if [ -f "$NPU_SYSFS/device/mem_info" ]; then
            echo "Memory: $(cat $NPU_SYSFS/device/mem_info)"
        fi
        
        # Jobs in flight
        if [ -f "$NPU_SYSFS/device/job_count" ]; then
            echo "Active jobs: $(cat $NPU_SYSFS/device/job_count)"
        fi
        
        echo ""
        echo "Press Ctrl+C to exit"
        sleep 1
    done
else
    echo "NPU sysfs not available at $NPU_SYSFS"
    echo "Trying dmesg for NPU activity..."
    dmesg | grep -i "ivpu\|vpu\|npu" | tail -20
fi
```

---

## 11. Trade-off-uri Arhitecturale

### 11.1. Sumar Trade-off-uri

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TRADE-OFF-URI FUNDAMENTALE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. PERFORMANȚĂ vs EFICIENȚĂ ENERGETICĂ                                    │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Performanță maximă (datacenter):                             │     │
│     │  • NPU la frecvență maximă, TDP nelimitat                     │     │
│     │  • TOPS/W scăzut (~1-2)                                       │     │
│     │                                                                │     │
│     │  Eficiență maximă (mobile/laptop):                            │     │
│     │  • DVFS agresiv, power gating                                 │     │
│     │  • TOPS/W ridicat (~5-10)                                     │     │
│     │  • Latență mai mare (wake-up delay)                           │     │
│     │                                                                │     │
│     │  Apple M-series: optimizat pentru laptop, compromis bun       │     │
│     │  Intel Lunar Lake: containment zones pentru eficiență         │     │
│     │  Qualcomm: cel mai eficient, dar ARM-only                     │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. PROGRAMABILITATE vs PERFORMANȚĂ                                        │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Programabilitate maximă (GPU):                               │     │
│     │  • CUDA/OpenCL permite orice algoritm                         │     │
│     │  • Overhead: scheduling, memory management                    │     │
│     │                                                                │     │
│     │  Performanță maximă (NPU fixed-function):                     │     │
│     │  • Hardware optimizat pentru GEMM, convoluții                 │     │
│     │  • Limited: doar operații suportate                           │     │
│     │  • Fallback la GPU/CPU pentru rest                            │     │
│     │                                                                │     │
│     │  AMD XDNA: echilibru (spatial dataflow programmable)          │     │
│     │  Apple ANE: cel mai restrictiv, dar cel mai optimizat         │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3. UNIFIED MEMORY vs DISCRETE MEMORY                                      │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Unified (Apple, Qualcomm):                                   │     │
│     │  ✓ Zero-copy, programare simplă                               │     │
│     │  ✓ Eficiență energetică                                        │     │
│     │  ✗ Bandwidth limitat (~500 GB/s LPDDR5X)                      │     │
│     │  ✗ Capacitate limitată                                         │     │
│     │                                                                │     │
│     │  Discrete (NVIDIA datacenter):                                │     │
│     │  ✓ Bandwidth enorm (HBM: 3+ TB/s)                             │     │
│     │  ✓ Capacitate scalabilă                                        │     │
│     │  ✗ Transfer overhead                                           │     │
│     │  ✗ Programare complexă                                         │     │
│     │                                                                │     │
│     │  Intel Lunar Lake: on-package LPDDR (compromise)              │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  4. LATENȚĂ vs THROUGHPUT                                                  │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Latență minimă (real-time inference):                        │     │
│     │  • NPU always-on, no wake-up delay                            │     │
│     │  • Modele mici, batch size 1                                  │     │
│     │  • Use case: voice assistant, camera effects                  │     │
│     │                                                                │     │
│     │  Throughput maxim (batch processing):                         │     │
│     │  • Batching multiple requests                                 │     │
│     │  • Amortizare overhead kernel launch                          │     │
│     │  • Use case: image processing pipeline, server inference      │     │
│     │                                                                │     │
│     │  Tensiunea: NPU optimizat pentru throughput, dar use case     │     │
│     │  principal pe laptop/phone este latency-sensitive             │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Exerciții și Provocări

### 12.1. Exerciții de Înțelegere

**E1. [REMEMBER]** Enumeră cele 3 tipuri principale de unități de procesare dintr-un SoC modern și caracteristica principală a fiecăreia.

**E2. [UNDERSTAND]** Explică de ce Thread Director furnizează *hints* către OS în loc să facă scheduling direct. Care sunt avantajele acestei abordări?

**E3. [UNDERSTAND]** Compară modelul de memorie "unified" (Apple) cu "discrete" (NVIDIA datacenter). Pentru ce tipuri de workloads este fiecare mai potrivit?

**E4. [ANALYSE]** Un proces cu prioritate înaltă trebuie să execute inferență pe NPU, dar un proces cu prioritate scăzută a început deja un job mare. Analizează problema și propune 2 soluții posibile.

### 12.2. Exerciții Practice

**P1. [LAB]** Folosind scriptul `npu_check.sh`, verifică dacă sistemul tău are NPU și ce driver este încărcat. Documentează output-ul.

**P2. [LAB]** Modifică scriptul `npu_benchmark.py` pentru a testa un model diferit (de exemplu, ResNet-50). Compară rezultatele cu MobileNetV2.

**P3. [PROJECT]** Implementează un script care monitorizează utilizarea NPU în timp real și generează un grafic (folosind matplotlib) cu latența inferenței pe parcursul a 1 minut.

### 12.3. Întrebări de Reflecție

**R1.** De ce crezi că Apple a ales să nu expună Neural Engine pentru programare directă, în timp ce Intel și AMD permit acces prin API-uri standard?

**R2.** Cum ar trebui să evolueze scheduler-ul Linux pentru a gestiona optim workloads pe CPU+GPU+NPU? Ce informații ar trebui să aibă scheduler-ul?

**R3.** Care sunt implicațiile de securitate ale faptului că modelele AI rulează local pe device-ul utilizatorului vs în cloud?

---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este un NPU și prin ce se diferențiază de un CPU și un GPU? Care sunt unitățile de măsură pentru performanța NPU?

2. **[UNDERSTAND]** Explică mecanismul Intel Thread Director. De ce este nevoie de colaborare hardware-software pentru scheduling heterogen?

3. **[ANALYSE]** Compară abordările Apple (unified memory + CoreML exclusiv) și Intel (OpenVINO + multiple backends). Care sunt trade-off-urile fiecărei abordări din perspectiva unui dezvoltator de aplicații AI?

### Mini-provocare (opțional)

Folosind `lspci`, `lsmod` și documentația Intel/AMD, identifică dacă sistemul tău are NPU. Dacă da, verifică versiunea firmware-ului și starea driver-ului. Documentează pașii și rezultatele.

---


---


---


---

## Lectură Recomandată

### Resurse Obligatorii

**Documentație Framework-uri**
- [Apple Core ML Documentation](https://developer.apple.com/documentation/coreml) — Neural Engine pe Apple Silicon
- [ONNX Runtime](https://onnxruntime.ai/docs/) — Runtime cross-platform pentru inferență
- [OpenVINO](https://docs.openvino.ai/) — Intel NPU support

**Documentație Vendor**
- [Intel NPU Plugin](https://docs.openvino.ai/latest/openvino_docs_OV_UG_supported_plugins_NPU.html)
- [Qualcomm AI Engine Direct SDK](https://developer.qualcomm.com/software/ai-engine-direct-sdk)

### Resurse Recomandate

**Articole și Rapoarte**
- Jouppi et al. (2017): "In-Datacenter Performance Analysis of a Tensor Processing Unit" — Paper-ul Google TPU
- Reuther et al. (2022): "AI and ML Accelerator Survey and Trends" — Survei actualizat

**Cursuri și Tutoriale**
- MIT 6.5940: "TinyML and Efficient Deep Learning" — Hardware-aware ML
- Stanford CS231n: Secțiunea despre deployment pe edge devices

### Resurse Video

- **Hot Chips Conference** — Prezentări anuale despre NPU-uri și acceleratoare
- **Apple WWDC** — Sesiuni despre Neural Engine și Core ML
- **tinyML Summit** — Conferință dedicată ML pe edge

### Proiecte pentru Studiu

- [ONNX Model Zoo](https://github.com/onnx/models) — Modele pre-antrenate pentru testare
- [MLPerf Inference](https://mlcommons.org/en/inference-datacenter-10/) — Benchmark-uri standard pentru acceleratoare

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **NPU memory management**: Unified memory vs dedicated memory, DMA transfers.
- **Model compilation**: Cum transformă compilatoarele (XLA, TVM) grafuri ML în instrucțiuni NPU.
- **Power management pentru NPU**: Dynamic frequency scaling, power states.

### Greșeli frecvente de evitat

1. **Presupunerea că NPU e întotdeauna mai rapid**: Pentru modele mici, overhead-ul transferului anulează beneficiile.
2. **Ignorarea latenței de warmup**: Prima inferență e mai lentă din cauza încărcării modelului.
3. **Quantizare fără validare**: Cuantizarea poate degrada acuratețea semnificativ pentru unele modele.

### Întrebări rămase deschise

- Va exista un standard universal pentru programarea NPU-urilor (precum CUDA pentru GPU)?
- Cum vor gestiona SO-urile scheduling-ul pentru workloads hibride CPU+GPU+NPU?

## Privire înainte

**Finalul Seriei de Cursuri Suplimentare**

Acesta este ultimul modul din seria de cursuri Sisteme de Operare. Ai parcurs de la fundamentele SO până la tehnologii de vârf precum eBPF și procesoare neuronale.

**Recomandări pentru continuare:**
- Recapitulează conceptele din cursurile 1-14 pentru examen
- Explorează proiecte open-source: Linux kernel, Docker, containerd
- Contribuie la documentație sau bug fixes în proiecte SO-related

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│           SĂPTĂMÂNA 18: INTEGRAREA NPU ÎN SO — RECAP                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  SISTEME HETEROGENE (2025)                                                  │
│  ├── CPU: Control flow, latență mică, code general                         │
│  ├── GPU: Throughput masiv, SIMT, training + rendering                     │
│  └── NPU: Inferență AI, INT8/INT4, eficiență energetică maximă            │
│                                                                             │
│  SCHEDULING HETEROGEN                                                       │
│  ├── Intel Thread Director: HFI hints + containment zones                  │
│  ├── NPU scheduling: Queue-based, non-preemptiv (vs CPU preemptiv)        │
│  └── Priority inversion: Soluții prin checkpointing sau partitioning      │
│                                                                             │
│  MEMORY PENTRU AI                                                           │
│  ├── Unified memory: Zero-copy, eficient, bandwidth limitat               │
│  ├── Scratchpad: Software-managed, predictibil, DMA explicit               │
│  └── PagedAttention: Concepte VM aplicate la KV-cache LLM                  │
│                                                                             │
│  COMPARAȚIE VENDOR                                                          │
│  ├── Apple: Tight integration, walled garden, ~38 TOPS                     │
│  ├── Intel: Standard APIs, OpenVINO, ~48 TOPS                              │
│  ├── AMD: Spatial dataflow (XDNA), open source, ~50 TOPS                   │
│  └── Qualcomm: Mobile heritage, eficiență max, ~45 TOPS (ARM only!)        │
│                                                                             │
│  INTEGRARE OS                                                               │
│  ├── Windows: AI Foundry + MCDM driver model                               │
│  ├── Linux: /dev/accel/* subsystem (kernel 6.2+)                           │
│  └── macOS: CoreML exclusiv, no direct NPU access                          │
│                                                                             │
│  💡 TAKEAWAY: NPU transformă conceptele clasice de SO (scheduling,          │
│     memory management, drivers) pentru era AI on-device                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 13. Referințe și Lectură Suplimentară

### 13.1. Documentație Oficială

1. **Intel NPU**
   - [Intel NPU Driver (Linux)](https://github.com/intel/linux-npu-driver)
   - [OpenVINO Documentation](https://docs.openvino.ai/)
   - [Thread Director Technical Brief](https://www.intel.com/content/www/us/en/gaming/resources/how-hybrid-design-works.html)

2. **AMD XDNA**
   - [AMD XDNA Driver](https://github.com/amd/xdna-driver)
   - [Xilinx AI Engine Architecture](https://docs.xilinx.com/r/en-US/am020-versal-aie-ml)

3. **Qualcomm**
   - [Qualcomm AI Engine Direct SDK](https://developer.qualcomm.com/software/qualcomm-ai-engine-direct-sdk)

4. **Microsoft**
   - [Copilot+ PC Developer Guide](https://learn.microsoft.com/en-us/windows/ai/npu-devices/)
   - [DirectML Documentation](https://learn.microsoft.com/en-us/windows/ai/directml/dml)

### 13.2. Articole Academice și Tehnice

1. Lam, C. "Qualcomm's Hexagon DSP, and now, NPU" - Chips and Cheese, 2024
2. "PREMA: Predictive Multi-task NPU Scheduler" - arXiv, 2023
3. "PagedAttention: Efficient Memory Management for LLM Serving" - vLLM, 2023

### 13.3. Resurse Video

1. Intel Tech Tour 2024: "Lunar Lake Power Management and Thread Director Innovations"
2. Hot Chips 2023: "Qualcomm Hexagon Tensor Processor"

---

*Materiale dezvoltate pentru cursul de Sisteme de Operare — by Revolvix*  
*ASE București, CSIE — Anul I, Semestrul 2, 2025-2026*
