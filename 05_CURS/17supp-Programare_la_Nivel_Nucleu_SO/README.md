# SO_curs16suppl: eBPF — Observabilitate și Programabilitate la Nivel de Nucleu

> **Modul Suplimentar Avansat** | Sisteme de Operare  
> by Revolvix | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026

---

## Cuprins

1. [Obiective și Competențe](#1-obiective-și-competențe)
2. [Motivație: De ce eBPF?](#2-motivație-de-ce-ebpf)
3. [Fundamentele Arhitecturale eBPF](#3-fundamentele-arhitecturale-ebpf)
4. [Modelul de Execuție și Verificarea Siguranței](#4-modelul-de-execuție-și-verificarea-siguranței)
5. [Tipuri de Programe și Puncte de Ancorare](#5-tipuri-de-programe-și-puncte-de-ancorare)
6. [Structuri de Date: Hărțile eBPF](#6-structuri-de-date-hărțile-ebpf)
7. [Instrumentarul de Dezvoltare](#7-instrumentarul-de-dezvoltare)
8. [bpftrace: Trasare Dinamică de Înaltă Performanță](#8-bpftrace-trasare-dinamică-de-înaltă-performanță)
9. [BCC: Colecția de Compilatoare BPF](#9-bcc-colecția-de-compilatoare-bpf)
10. [Cazuri de Utilizare în Producție](#10-cazuri-de-utilizare-în-producție)
11. [Securitate și Considerații Operaționale](#11-securitate-și-considerații-operaționale)
12. [Demonstrații Practice](#12-demonstrații-practice)
13. [Exerciții și Provocări](#13-exerciții-și-provocări)
14. [Referințe și Lectură Suplimentară](#14-referințe-și-lectură-suplimentară)

---

## 1. Obiective și Competențe

### 1.1. Obiective de Învățare

La finalizarea acestui modul, studentul va fi capabil să:

1. **Explice arhitectura eBPF** la nivel conceptual și tehnic, identificând componentele fundamentale (mașina virtuală, verificator, compilator JIT, hărți, funcții auxiliare)

2. **Analizeze diferențele** dintre metodele tradiționale de observabilitate (strace, perf, SystemTap) și paradigma eBPF, argumentând avantajele de performanță și siguranță

3. **Clasifice tipurile de programe eBPF** în funcție de punctele de ancorare în nucleu (kprobes, tracepoints, XDP, tc, cgroup hooks) și domeniile de aplicabilitate

4. **Utilizeze uneltele bpftrace și BCC** pentru diagnosticarea problemelor de performanță în sisteme de producție

5. **Implementeze scenarii practice** de monitorizare: latență I/O, conexiuni de rețea, apeluri de sistem, scurgeri de memorie

6. **Evalueze implicațiile de securitate** ale programelor eBPF și mecanismele de protecție implementate în nucleu

### 1.2. Competențe Transversale

- **Gândire sistemică**: înțelegerea interacțiunilor între spațiul utilizator, nucleu și hardware
- **Diagnosticare metodică**: abordare structurată a problemelor de performanță
- **Adaptabilitate tehnologică**: familiarizare cu tehnologii emergente în infrastructura cloud-native

---

## 2. Motivație: De ce eBPF?

### 2.1. Problema Observabilității în Sisteme Moderne

Sistemele contemporane prezintă o complexitate exponențială: microservicii distribuite, containerizare, orchestrare Kubernetes, comunicații inter-proces frecvente. Întrebările fundamentale devin dificil de răspuns:

- *De ce acest proces consumă 100% CPU?*
- *Ce cauzează latența de 500ms la accesul disc?*
- *Ce conexiuni de rețea deschide acest container?*
- *De ce memoria crește continuu până la OOM?*

**Instrumentele tradiționale** suferă de limitări semnificative:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPARAȚIE: TRASARE TRADIȚIONALĂ vs eBPF                 │
├─────────────────────┬─────────────────────────┬─────────────────────────────┤
│     Instrument      │       Overhead          │        Limitări             │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ strace              │ 100-1000x încetinire    │ Doar apeluri sistem         │
│                     │ (ptrace syscall)        │ Un singur proces            │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ ltrace              │ ~500x încetinire        │ Doar apeluri biblioteci     │
│                     │                         │ Incompatibil cu PIE/ASLR    │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ perf                │ Moderat (sampling)      │ Date statistice, nu cauzale │
│                     │                         │ Dificil de corelat          │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ SystemTap           │ Variabil                │ Module kernel necesare      │
│                     │                         │ Risc de kernel panic        │
│                     │                         │ Nepotrivit pentru producție │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ Module kernel       │ Minim                   │ Dezvoltare complexă         │
│ personalizate       │                         │ Risc maxim securitate       │
│                     │                         │ Ciclu lung compilare        │
├─────────────────────┼─────────────────────────┼─────────────────────────────┤
│ eBPF                │ ~1-5% (verificat safe)  │ Verificator strict          │
│                     │ Overhead neglijabil     │ Limite bucle/memorie        │
│                     │                         │ Curba de învățare           │
└─────────────────────┴─────────────────────────┴─────────────────────────────┘
```

### 2.2. Revoluția eBPF

**eBPF** (extended Berkeley Packet Filter) reprezintă o tehnologie de programare a nucleului care permite executarea de cod verificat și sigur în contextul nucleului, fără a modifica codul sursă al acestuia sau a încărca module kernel.

**Analogia conceptuală**: Dacă nucleul Linux este un sistem de operare, eBPF este echivalentul JavaScript pentru browser — permite extensii dinamice, verificate, într-un mediu sandboxed.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           PARADIGMA eBPF                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Cod Tradițional                      Cod eBPF                              │
│   ─────────────                        ────────                              │
│                                                                              │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  Aplicație      │                  │  Aplicație      │                   │
│   │  (user space)   │                  │  + Program eBPF │                   │
│   └────────┬────────┘                  └────────┬────────┘                   │
│            │                                    │                            │
│            ▼                                    ▼                            │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  System Call    │                  │  bpf() syscall  │                   │
│   │  Interface      │                  │  încărcare prog │                   │
│   └────────┬────────┘                  └────────┬────────┘                   │
│            │                                    │                            │
│   ─────────┼────────────────          ─────────┼─────────────────            │
│            │    KERNEL                         │    KERNEL                   │
│   ─────────┼────────────────          ─────────┼─────────────────            │
│            │                                    │                            │
│            ▼                                    ▼                            │
│   ┌─────────────────┐                  ┌─────────────────┐                   │
│   │  Cod kernel     │                  │  Verificator    │──► Respins?       │
│   │  (fix, static)  │                  │  eBPF           │    STOP           │
│   └─────────────────┘                  └────────┬────────┘                   │
│                                                 │ Acceptat                   │
│                                                 ▼                            │
│                                        ┌─────────────────┐                   │
│                                        │  JIT Compiler   │                   │
│                                        │  → cod nativ    │                   │
│                                        └────────┬────────┘                   │
│                                                 │                            │
│                                                 ▼                            │
│                                        ┌─────────────────┐                   │
│                                        │  Atașare la     │                   │
│                                        │  hook (kprobe,  │                   │
│                                        │  tracepoint,    │                   │
│                                        │  XDP, etc.)     │                   │
│                                        └─────────────────┘                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 2.3. Adopția în Industrie

eBPF a devenit fundamentul observabilității moderne:

| Companie/Proiect | Utilizare eBPF |
|------------------|----------------|
| **Netflix** | Analiza performanței aplicațiilor, profilare CPU/memorie |
| **Facebook/Meta** | Bilanțare încărcare L4 (Katran), firewall la scară |
| **Google** | Monitorizare Kubernetes (GKE), securitate runtime |
| **Cloudflare** | Protecție DDoS (XDP), procesare pachete la 10M+ pps |
| **Cilium** | CNI pentru Kubernetes, politici rețea fără iptables |
| **Falco** | Detectarea intruziunilor runtime în containere |
| **Datadog/Dynatrace** | APM (Application Performance Monitoring) |

---

## 3. Fundamentele Arhitecturale eBPF

### 3.1. Evoluția Istorică

**BPF clasic** (1992, Steven McCanne și Van Jacobson) a fost conceput inițial pentru filtrarea pachetelor în tcpdump. Arhitectura originală era o mașină virtuală simplă cu registre limitate și operații aritmetice de bază.

**eBPF** (2014, Alexei Starovoitov) extinde radical această arhitectură:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              EVOLUȚIA BPF → eBPF                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   BPF Clasic (cBPF)                    eBPF (extended BPF)                  │
│   ─────────────────                    ───────────────────                  │
│                                                                             │
│   • 2 registre (A, X)                  • 11 registre (R0-R10)               │
│   • 32 biți                            • 64 biți                            │
│   • ~50 instrucțiuni                   • ~100+ instrucțiuni                 │
│   • Doar filtrare pachete              • Evenimente arbitrare nucleu        │
│   • Fără apeluri funcții               • Helper functions (>150)           │
│   • Fără stare persistentă             • Maps (hash, array, stack, etc.)   │
│   • Interpretor doar                   • JIT compilation (x86, ARM, etc.)  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Componente Arhitecturale

Arhitectura eBPF constă din cinci componente fundamentale:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ARHITECTURA eBPF                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   SPAȚIUL UTILIZATOR                                                        │
│   ══════════════════                                                        │
│                                                                             │
│   ┌───────────────┐     ┌───────────────┐     ┌───────────────┐            │
│   │  Aplicație    │     │  bpftrace     │     │  BCC Tools    │            │
│   │  custom       │     │  (limbaj DSL) │     │  (Python+C)   │            │
│   └───────┬───────┘     └───────┬───────┘     └───────┬───────┘            │
│           │                     │                     │                     │
│           └─────────────────────┼─────────────────────┘                     │
│                                 │                                           │
│                                 ▼                                           │
│                    ┌────────────────────────┐                               │
│                    │   libbpf / libebpf     │                               │
│                    │   (bibliotecă user)    │                               │
│                    └───────────┬────────────┘                               │
│                                │                                           │
│                                ▼                                           │
│                    ┌────────────────────────┐                               │
│                    │   bpf() system call    │                               │
│                    │   (BPF_PROG_LOAD, etc.)│                               │
│                    └───────────┬────────────┘                               │
│                                │                                           │
│   ══════════════════════════════╪═══════════════════════════════════════    │
│   SPAȚIUL NUCLEU                │                                           │
│   ══════════════════════════════│═══════════════════════════════════════    │
│                                │                                           │
│                                ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                       1. VERIFICATOR (Verifier)                     │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Analiză statică a bytecode-ului                            │  │   │
│   │  │ • Verifică terminare garantată (no infinite loops)           │  │   │
│   │  │ • Verifică accese memorie (bounds checking)                  │  │   │
│   │  │ • Verifică tipuri registre și operații legale                │  │   │
│   │  │ • Verifică utilizare helpers permise pentru tipul program    │  │   │
│   │  │ • Max 1 milion instrucțiuni verificate                       │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │ Acceptat                                  │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                  2. COMPILATOR JIT (Just-In-Time)                   │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Transformă bytecode eBPF în cod mașină nativ                │  │   │
│   │  │ • Suport: x86_64, ARM64, RISC-V, s390x, PowerPC              │  │   │
│   │  │ • Performanță comparabilă cu cod C compilat                   │  │   │
│   │  │ • Activare: /proc/sys/net/core/bpf_jit_enable                │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                   3. SISTEM DE HĂRȚI (Maps)                         │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • Structuri date kernel ↔ user space                         │  │   │
│   │  │ • Tipuri: hash, array, per-CPU, ring buffer, stack, queue    │  │   │
│   │  │ • Persistență între execuții program                          │  │   │
│   │  │ • Comunicare între programe eBPF diferite                     │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                  4. FUNCȚII AUXILIARE (Helpers)                     │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • API-uri kernel expuse programelor eBPF                      │  │   │
│   │  │ • bpf_map_lookup_elem(), bpf_probe_read()                    │  │   │
│   │  │ • bpf_get_current_pid_tgid(), bpf_ktime_get_ns()            │  │   │
│   │  │ • bpf_perf_event_output(), bpf_trace_printk()               │  │   │
│   │  │ • >150 helpers disponibile                                    │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                5. PUNCTE DE ANCORARE (Hooks/Attach Points)          │   │
│   │  ┌──────────────────────────────────────────────────────────────┐  │   │
│   │  │ • kprobes/kretprobes: orice funcție kernel                   │  │   │
│   │  │ • uprobes/uretprobes: funcții user space                     │  │   │
│   │  │ • tracepoints: puncte statice în kernel                       │  │   │
│   │  │ • XDP: procesare pachete ultra-rapidă                         │  │   │
│   │  │ • tc (traffic control): clasificare trafic                    │  │   │
│   │  │ • cgroup hooks: control per container                         │  │   │
│   │  │ • LSM hooks: securitate Linux                                 │  │   │
│   │  └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3. Setul de Instrucțiuni eBPF

Mașina virtuală eBPF definește un set de instrucțiuni RISC-like cu următoarele caracteristici:

**Registre**:
- `R0`: valoare de retur din program și helpers
- `R1-R5`: argumente funcții (caller-saved)
- `R6-R9`: registre callee-saved (persistă peste apeluri)
- `R10`: frame pointer (read-only, stack)

**Clase de instrucțiuni**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CATEGORII INSTRUCȚIUNI eBPF                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ARITMETICE (ALU64/ALU32)                                                   │
│  ─────────────────────────                                                  │
│  add, sub, mul, div, mod    │  Operații matematice pe 64/32 biți           │
│  and, or, xor, lsh, rsh     │  Operații logice și deplasări                │
│  neg, mov                   │  Negare, mutare                               │
│                                                                             │
│  SALT (JMP)                                                                 │
│  ──────────                                                                 │
│  ja                         │  Salt necondiționat                           │
│  jeq, jne, jgt, jlt, jge    │  Salturi condiționate (signed/unsigned)      │
│  jset                       │  Salt dacă biți setați                        │
│  call                       │  Apel helper function                         │
│  exit                       │  Terminare program                            │
│                                                                             │
│  MEMORIE (LD/ST)                                                            │
│  ───────────────                                                            │
│  ldx, stx                   │  Încărcare/stocare din/în memorie             │
│  lddw                       │  Încărcare constantă 64 biți                  │
│  Dimensiuni: B(8), H(16), W(32), DW(64) biți                               │
│                                                                             │
│  ATOMICE                                                                    │
│  ────────                                                                   │
│  lock xadd                  │  Adunare atomică                              │
│  lock cmpxchg               │  Compare-and-exchange atomic                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Exemplu bytecode eBPF** (afișare PID curent):

```
; Obține PID curent și afișează via trace_printk
r1 = 0                      ; Inițializare
call bpf_get_current_pid_tgid  ; R0 = (tgid << 32) | pid
r1 = r0                     ; Salvare rezultat
rsh r1, 32                  ; Extrage TGID (>>32)
; ... formatare și afișare ...
exit                        ; Terminare program
```

---

## 4. Modelul de Execuție și Verificarea Siguranței

### 4.1. Verificatorul eBPF

Verificatorul reprezintă componenta critică de securitate a sistemului eBPF. Funcția sa este de a garanta că programul încărcat nu poate compromite stabilitatea sau securitatea nucleului.

**Algoritm de verificare** (simplificat):

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROCESUL DE VERIFICARE eBPF                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   PASUL 1: CONSTRUCȚIE CFG (Control Flow Graph)                             │
│   ─────────────────────────────────────────────                             │
│   • Identifică toate căile de execuție posibile                             │
│   • Detectează bucle și salturi                                             │
│   • Verifică că toate căile se termină (exit)                               │
│                                                                             │
│   PASUL 2: SIMULARE SIMBOLICĂ                                               │
│   ─────────────────────────────                                             │
│   • Parcurge FIECARE cale de execuție                                       │
│   • Urmărește starea registrelor la fiecare instrucțiune                    │
│   • Menține informații de tip pentru fiecare registru:                      │
│     - SCALAR_VALUE: valoare numerică cu bounds cunoscute                    │
│     - PTR_TO_MAP_VALUE: pointer în hartă                                    │
│     - PTR_TO_CTX: pointer la context program                                │
│     - PTR_TO_STACK: pointer la stivă locală                                 │
│     - PTR_TO_PACKET: pointer la date pachet                                 │
│                                                                             │
│   PASUL 3: VERIFICĂRI DE SIGURANȚĂ                                          │
│   ────────────────────────────────                                          │
│   □ Bounds checking: toate accesele memorie în limite                       │
│   □ Null checking: pointerii pot fi NULL? verificat înainte de acces        │
│   □ Type safety: operații permise pentru tipul registrului                  │
│   □ Privilegii: helpers permise pentru tipul de program                     │
│   □ Complexitate: max ~1M instrucțiuni (previne DoS la verificare)          │
│                                                                             │
│   REZULTAT                                                                  │
│   ────────                                                                  │
│   ✓ ACCEPTAT: program încărcat, JIT compilat                                │
│   ✗ RESPINS: eroare detaliată returnată                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Exemple de Respingeri

**Caz 1: Acces memorie posibil în afara limitelor**

```c
// COD RESPINS
int *value = bpf_map_lookup_elem(&my_map, &key);
// Lipsește verificarea NULL!
*value += 1;  // EROARE: value poate fi NULL

// COD CORECT
int *value = bpf_map_lookup_elem(&my_map, &key);
if (value) {
    *value += 1;  // OK: verificat non-NULL
}
```

**Caz 2: Buclă potențial infinită**

```c
// COD RESPINS (înainte de bounded loops)
for (int i = 0; i < n; i++) {  // EROARE: n necunoscut la verificare
    // ...
}

// COD CORECT
#pragma unroll
for (int i = 0; i < 16; i++) {  // OK: limită cunoscută
    if (i >= n) break;
    // ...
}
```

**Caz 3: Citire din memorie kernel arbitrară**

```c
// COD RESPINS
char *ptr = (char *)0xffffffff81000000;  // Adresă kernel arbitrară
char c = *ptr;  // EROARE: acces la memorie kernel nepermisă

// COD CORECT (cu helper)
char buf[64];
bpf_probe_read_kernel(&buf, sizeof(buf), ptr);  // Helper verificat
```

### 4.3. Garanțiile de Siguranță

Verificatorul garantează următoarele proprietăți pentru orice program acceptat:

1. **Terminare**: Programul se va termina în timp finit (no infinite loops)
2. **Siguranță memorie**: Nu există accese în afara limitelor
3. **Siguranță tip**: Operațiile sunt valide pentru tipurile de date
4. **Izolare**: Nu poate citi/scrie memorie kernel arbitrară
5. **Stabilitate**: Nu poate provoca kernel panic

---

## 5. Tipuri de Programe și Puncte de Ancorare

### 5.1. Taxonomia Programelor eBPF

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TIPURI DE PROGRAME eBPF                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    TRASARE ȘI OBSERVABILITATE                       │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  KPROBE/KRETPROBE                                                   │    │
│  │  ─────────────────                                                  │    │
│  │  • Ancorare la ORICE funcție kernel                                 │    │
│  │  • kprobe: la intrarea în funcție                                   │    │
│  │  • kretprobe: la ieșirea din funcție                                │    │
│  │  • Acces la argumente funcției și valoare retur                     │    │
│  │  • Utilizare: profilare, debugging, audit                           │    │
│  │  • Exemplu: kprobe:vfs_read pentru monitorizare citiri fișiere      │    │
│  │                                                                     │    │
│  │  UPROBE/URETPROBE                                                   │    │
│  │  ─────────────────                                                  │    │
│  │  • Ancorare la funcții în binare USER SPACE                         │    │
│  │  • Funcționează cu executabile și biblioteci (.so)                  │    │
│  │  • Acces la argumente (necesită cunoaștere ABI)                     │    │
│  │  • Exemplu: uprobe:/lib/x86_64-linux-gnu/libc.so.6:malloc          │    │
│  │                                                                     │    │
│  │  TRACEPOINT                                                         │    │
│  │  ──────────                                                         │    │
│  │  • Puncte STATICE definite în codul kernel                          │    │
│  │  • ABI stabil (spre deosebire de kprobes)                           │    │
│  │  • Format argumente documentat                                       │    │
│  │  • Categorii: syscalls, sched, net, block, etc.                     │    │
│  │  • Exemplu: tracepoint:syscalls:sys_enter_openat                    │    │
│  │                                                                     │    │
│  │  RAW_TRACEPOINT                                                     │    │
│  │  ──────────────                                                     │    │
│  │  • Versiune high-performance a tracepoints                          │    │
│  │  • Acces la argumente brute (fără conversie)                        │    │
│  │  • Overhead mai mic, dar mai complex de utilizat                    │    │
│  │                                                                     │    │
│  │  PERF_EVENT                                                         │    │
│  │  ──────────                                                         │    │
│  │  • Integrare cu subsistemul perf                                    │    │
│  │  • Evenimente hardware (cache misses, branch mispredictions)        │    │
│  │  • Sampling periodic bazat pe frecvență                              │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    REȚEA ȘI PROCESARE PACHETE                       │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  XDP (eXpress Data Path)                                            │    │
│  │  ───────────────────────                                            │    │
│  │  • Cel mai timpuriu punct de procesare pachete                      │    │
│  │  • ÎNAINTE de alocarea sk_buff                                      │    │
│  │  • Performanță: 10-20M pachete/secundă per core                     │    │
│  │  • Acțiuni: XDP_DROP, XDP_PASS, XDP_TX, XDP_REDIRECT               │    │
│  │  • Cazuri: DDoS mitigation, load balancing L4                       │    │
│  │                                                                     │    │
│  │        Ordinea procesare pachete:                                   │    │
│  │        ─────────────────────────                                    │    │
│  │        NIC → [XDP] → Driver → sk_buff → [TC] → Netfilter → Socket   │    │
│  │              ▲                           ▲                          │    │
│  │              │                           │                          │    │
│  │         Cel mai rapid              După alocare buffer              │    │
│  │                                                                     │    │
│  │  TC (Traffic Control)                                               │    │
│  │  ────────────────────                                               │    │
│  │  • La nivel tc ingress/egress                                       │    │
│  │  • Acces la sk_buff complet                                         │    │
│  │  • Modificare pachete, marcare, redirecționare                      │    │
│  │  • Mai flexibil decât XDP, dar mai lent                             │    │
│  │                                                                     │    │
│  │  SOCKET_FILTER                                                      │    │
│  │  ─────────────                                                      │    │
│  │  • BPF clasic pentru filtrare pachete (tcpdump)                     │    │
│  │  • Acum implementat ca eBPF intern                                  │    │
│  │                                                                     │    │
│  │  SK_SKB, SK_MSG                                                     │    │
│  │  ─────────────                                                      │    │
│  │  • Procesare la nivel socket                                        │    │
│  │  • Redirecționare mesaje între socketi                              │    │
│  │  • Utilizat pentru service mesh (Cilium)                            │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    CONTROL ȘI SECURITATE                            │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │                                                                     │    │
│  │  CGROUP_*                                                           │    │
│  │  ────────                                                           │    │
│  │  • Asociate cu control groups                                       │    │
│  │  • Per-container/per-pod în Kubernetes                              │    │
│  │  • Tipuri: CGROUP_SKB, CGROUP_SOCK, CGROUP_DEVICE                  │    │
│  │  • Control: permisiuni dispozitive, conectivitate rețea             │    │
│  │                                                                     │    │
│  │  LSM (Linux Security Module)                                        │    │
│  │  ───────────────────────────                                        │    │
│  │  • Hooks în subsistemul de securitate                               │    │
│  │  • Augmentează/înlocuiește politici SELinux/AppArmor               │    │
│  │  • Control granular: operații fișiere, IPC, rețea                   │    │
│  │  • Exemplu: blocarea execuției dintr-un director specific           │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2. Selectarea Tipului de Program

| Scenariu | Tip Program Recomandat | Justificare |
|----------|------------------------|-------------|
| Monitorizare apeluri sistem | tracepoint:syscalls | ABI stabil, overhead minim |
| Profilare funcție kernel specifică | kprobe | Flexibilitate maximă |
| Trasare funcții biblioteca C | uprobe | Acces user space |
| DDoS mitigation | XDP | Performanță maximă |
| Politici rețea Kubernetes | tc, sk_skb | Acces complet la pachet |
| Monitorizare containere | CGROUP_* | Izolare per-container |
| Audit securitate runtime | LSM | Integrare cu security framework |

---

## 6. Structuri de Date: Hărțile eBPF

### 6.1. Conceptul de Hartă

Hărțile eBPF (Maps) sunt structuri de date rezidente în memoria nucleului care permit:
- Persistența datelor între invocări ale programului eBPF
- Comunicarea între programe eBPF diferite
- Comunicarea bidirecțională între spațiul nucleu și spațiul utilizator

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMUNICARE VIA HĂRȚI eBPF                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   SPAȚIUL UTILIZATOR                                                        │
│   ══════════════════                                                        │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Aplicație Python/Go/C                                              │   │
│   │                                                                     │   │
│   │  map_fd = bpf_obj_get("/sys/fs/bpf/my_map")                        │   │
│   │  value = bpf_map_lookup_elem(map_fd, &key)   // Citire             │   │
│   │  bpf_map_update_elem(map_fd, &key, &value)   // Scriere            │   │
│   └──────────────────────────────┬──────────────────────────────────────┘   │
│                                  │                                          │
│                                  │  bpf() syscall                           │
│                                  ▼                                          │
│   ════════════════════════════════════════════════════════════════════════  │
│                                                                             │
│   NUCLEU                                                                    │
│   ══════                                                                    │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                          HARTĂ eBPF                                 │   │
│   │  ┌─────────┬─────────┐                                              │   │
│   │  │   Key   │  Value  │     Tip: BPF_MAP_TYPE_HASH                  │   │
│   │  ├─────────┼─────────┤     Max entries: 10000                       │   │
│   │  │ PID=123 │ count=5 │     Key size: 4 bytes                        │   │
│   │  │ PID=456 │ count=2 │     Value size: 8 bytes                      │   │
│   │  │ PID=789 │ count=8 │                                              │   │
│   │  └─────────┴─────────┘                                              │   │
│   └──────────────────────────────▲──────────────────────────────────────┘   │
│                                  │                                          │
│                                  │  bpf_map_lookup_elem()                   │
│                                  │  bpf_map_update_elem()                   │
│                                  │                                          │
│   ┌──────────────────────────────┴──────────────────────────────────────┐   │
│   │  Program eBPF (rulează la fiecare eveniment)                        │   │
│   │                                                                     │   │
│   │  SEC("kprobe/vfs_read")                                             │   │
│   │  int count_reads(struct pt_regs *ctx) {                             │   │
│   │      u32 pid = bpf_get_current_pid_tgid() >> 32;                    │   │
│   │      u64 *count = bpf_map_lookup_elem(&my_map, &pid);               │   │
│   │      if (count) {                                                   │   │
│   │          (*count)++;                                                │   │
│   │      } else {                                                       │   │
│   │          u64 init = 1;                                              │   │
│   │          bpf_map_update_elem(&my_map, &pid, &init, BPF_ANY);        │   │
│   │      }                                                              │   │
│   │      return 0;                                                      │   │
│   │  }                                                                  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2. Tipuri de Hărți

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TIPURI DE HĂRȚI eBPF                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  HĂRȚI GENERICE                                                             │
│  ──────────────                                                             │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_HASH  │ Tabel hash clasic                               │   │
│  │                    │ Lookup O(1), inserare/ștergere dinamică         │   │
│  │                    │ Utilizare: contorizare per-cheie                │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_ARRAY │ Array cu index numeric                          │   │
│  │                    │ Lookup O(1), dimensiune fixă                    │   │
│  │                    │ Utilizare: histograme, configurații             │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Variante per-CPU                                │   │
│  │ PERCPU_HASH/ARRAY  │ Evită lock contention                           │   │
│  │                    │ Fiecare CPU are copie separată                  │   │
│  │                    │ Utilizare: statistici high-throughput           │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
│  HĂRȚI PENTRU COMUNICARE                                                    │
│  ────────────────────────                                                   │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_      │ Buffer circular                                 │   │
│  │ RINGBUF            │ Producător (kernel) → Consumator (user)         │   │
│  │                    │ Zero-copy, foarte eficient                      │   │
│  │                    │ Înlocuiește perf buffer (mai vechi)             │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Legacy: buffer evenimente perf                  │   │
│  │ PERF_EVENT_ARRAY   │ Per-CPU, overhead mai mare decât ringbuf       │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
│  HĂRȚI SPECIALE                                                             │
│  ──────────────                                                             │
│                                                                             │
│  ┌────────────────────┬─────────────────────────────────────────────────┐   │
│  │ BPF_MAP_TYPE_      │ Referințe la alte programe eBPF                 │   │
│  │ PROG_ARRAY         │ Permite tail calls (înlănțuire programe)        │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Stivă LIFO                                      │   │
│  │ STACK              │ Utilizare: salvare stack traces                 │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Coadă FIFO                                      │   │
│  │ QUEUE              │ Utilizare: buffering evenimente                 │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_LRU_  │ Hash cu evicție LRU                             │   │
│  │ HASH               │ Nu necesită gestiune manuală dimensiune         │   │
│  ├────────────────────┼─────────────────────────────────────────────────┤   │
│  │ BPF_MAP_TYPE_      │ Longest Prefix Match                            │   │
│  │ LPM_TRIE           │ Utilizare: routing tables, CIDR matching        │   │
│  └────────────────────┴─────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3. Operații pe Hărți

**Din programul eBPF (în nucleu)**:
```c
void *bpf_map_lookup_elem(map, key)     // Caută valoare după cheie
int bpf_map_update_elem(map, key, val)  // Inserează/actualizează
int bpf_map_delete_elem(map, key)       // Șterge intrare
```

**Din spațiul utilizator**:
```c
// Via syscall bpf() sau librării (libbpf)
bpf_map_lookup_elem(fd, key, value)
bpf_map_update_elem(fd, key, value, flags)
bpf_map_delete_elem(fd, key)
bpf_map_get_next_key(fd, key, next_key)  // Iterare
```

---

## 7. Instrumentarul de Dezvoltare

### 7.1. Suita de Unelte

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NIVELURI DE ABSTRACTIZARE eBPF                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  NIVEL ÎNALT (Utilizatori finali, SRE, DevOps)                              │
│  ══════════════════════════════════════════════                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  bpftrace           BCC tools           kubectl-trace               │    │
│  │  (one-liners)       (pre-built)         (Kubernetes)                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  NIVEL MEDIU (Dezvoltatori de instrumente)                                  │
│  ═════════════════════════════════════════                                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  BCC (Python+C)     libbpf-rs (Rust)    cilium/ebpf (Go)           │    │
│  │  Framework          Framework            Framework                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  NIVEL SCĂZUT (Dezvoltare programe eBPF)                                    │
│  ═══════════════════════════════════════                                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  libbpf (C)         BTF (type info)     CO-RE (Compile Once -       │    │
│  │  Biblioteca core    Formate             Run Everywhere)             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                  │                                          │
│                                  ▼                                          │
│  NUCLEU                                                                     │
│  ══════                                                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Verificator        JIT Compiler        Maps           Helpers      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2. Verificarea Suportului Sistem

```bash
# Verificare versiune kernel (minim 4.x, recomandat 5.x+)
uname -r

# Verificare CONFIG_BPF activat
grep CONFIG_BPF /boot/config-$(uname -r)
# CONFIG_BPF=y
# CONFIG_BPF_SYSCALL=y
# CONFIG_BPF_JIT=y

# Verificare JIT activat
cat /proc/sys/net/core/bpf_jit_enable
# 1 = activat, 0 = dezactivat

# Listare programe eBPF încărcate
sudo bpftool prog list

# Listare hărți eBPF
sudo bpftool map list

# Verificare BTF disponibil (pentru CO-RE)
ls /sys/kernel/btf/vmlinux
```

---

## 8. bpftrace: Trasare Dinamică de Înaltă Performanță

### 8.1. Introducere în bpftrace

**bpftrace** este un limbaj de nivel înalt pentru trasare eBPF, inspirat de DTrace și AWK. Permite scrierea de one-liners și scripturi scurte pentru diagnosticare rapidă.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       STRUCTURA PROGRAM bpftrace                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   probe_type:probe_name /filter/ { action }                                 │
│                                                                             │
│   Exemple:                                                                  │
│   ─────────                                                                 │
│                                                                             │
│   kprobe:vfs_read { @[comm] = count(); }                                   │
│   │       │         │           │                                          │
│   │       │         │           └─ Acțiune: incrementează contor           │
│   │       │         └─ Agregare pe numele procesului                       │
│   │       └─ Funcția kernel de monitorizat                                 │
│   └─ Tipul probei                                                          │
│                                                                             │
│   tracepoint:syscalls:sys_enter_openat /comm == "nginx"/ { ... }          │
│                                         │                                  │
│                                         └─ Filtru: doar procesul nginx     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2. Tipuri de Probe bpftrace

| Sintaxă | Descriere | Exemplu |
|---------|-----------|---------|
| `kprobe:func` | Intrare funcție kernel | `kprobe:do_sys_open` |
| `kretprobe:func` | Ieșire funcție kernel | `kretprobe:do_sys_open` |
| `uprobe:binary:func` | Intrare funcție user | `uprobe:/bin/bash:readline` |
| `uretprobe:binary:func` | Ieșire funcție user | `uretprobe:/lib/libc.so.6:malloc` |
| `tracepoint:cat:name` | Tracepoint static | `tracepoint:syscalls:sys_enter_read` |
| `software:event:count` | Eveniment software | `software:cpu-clock:1000000` |
| `hardware:event:count` | Eveniment hardware | `hardware:cache-misses:1000` |
| `profile:hz:freq` | Sampling periodic | `profile:hz:99` |
| `interval:s:sec` | Timer periodic | `interval:s:1` |
| `BEGIN`, `END` | Start/stop trasare | `BEGIN { print("Start"); }` |

### 8.3. Variabile și Funcții Built-in

**Variabile built-in**:
```
pid          - Process ID
tid          - Thread ID
uid          - User ID
gid          - Group ID
comm         - Nume proces (16 caractere)
nsecs        - Timestamp nanosecunde
kstack       - Stack trace kernel
ustack       - Stack trace user
arg0-argN    - Argumente funcție
retval       - Valoare retur (în kretprobe/uretprobe)
curtask      - Pointer la task_struct curent
cgroup       - ID cgroup curent
```

**Funcții built-in**:
```
printf()     - Afișare formatată
print()      - Afișare simplă
count()      - Numărare evenimente
sum(x)       - Sumă valori
avg(x)       - Medie
min(x), max(x) - Minim, maxim
hist(x)      - Histogramă log2
lhist(x,min,max,step) - Histogramă liniară
str(ptr)     - Citire string din memorie
kstack(n)    - Stack kernel cu n frame-uri
ustack(n)    - Stack user cu n frame-uri
time(fmt)    - Timestamp formatat
```

### 8.4. Colecție de One-Liners Esențiale

Următoarele comenzi reprezintă un arsenal de diagnosticare pentru orice inginer de sistem:

```bash
# ═══════════════════════════════════════════════════════════════════════════
# MONITORIZARE PROCESE
# ═══════════════════════════════════════════════════════════════════════════

# 1. Listare procese noi create (fork/exec)
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_execve { 
    printf("%s -> %s\n", comm, str(args->filename)); 
}'

# 2. Contorizare apeluri sistem per proces
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }'

# 3. Top 10 procese după număr de apeluri sistem (rulează 5 secunde)
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); } 
    interval:s:5 { exit(); }'

# 4. Monitorizare semnale trimise
sudo bpftrace -e 'tracepoint:signal:signal_generate { 
    printf("%s (pid %d) -> sig %d -> pid %d\n", 
           comm, pid, args->sig, args->pid); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# OPERAȚII FIȘIERE
# ═══════════════════════════════════════════════════════════════════════════

# 5. Monitorizare fișiere deschise
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat { 
    printf("%s: %s\n", comm, str(args->filename)); 
}'

# 6. Contorizare operații read/write per proces
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_read { @reads[comm] = count(); }
    tracepoint:syscalls:sys_enter_write { @writes[comm] = count(); }
'

# 7. Distribuție dimensiuni citiri (histogramă)
sudo bpftrace -e 'tracepoint:syscalls:sys_exit_read /args->ret > 0/ { 
    @bytes = hist(args->ret); 
}'

# 8. Latență operații VFS read (timp în funcție)
sudo bpftrace -e '
    kprobe:vfs_read { @start[tid] = nsecs; }
    kretprobe:vfs_read /@start[tid]/ { 
        @latency_ns = hist(nsecs - @start[tid]); 
        delete(@start[tid]); 
    }
'

# ═══════════════════════════════════════════════════════════════════════════
# REȚEA
# ═══════════════════════════════════════════════════════════════════════════

# 9. Conexiuni TCP noi (connect)
sudo bpftrace -e 'kprobe:tcp_v4_connect { 
    printf("%s[%d] connecting...\n", comm, pid); 
}'

# 10. Conexiuni TCP acceptate (server)
sudo bpftrace -e 'kretprobe:inet_csk_accept { 
    printf("%s[%d] accepted connection\n", comm, pid); 
}'

# 11. Pachete trimise per proces
sudo bpftrace -e 'kprobe:tcp_sendmsg { @[comm] = count(); }'

# 12. Distribuție dimensiuni pachete TCP trimise
sudo bpftrace -e 'kprobe:tcp_sendmsg { @size = hist(arg2); }'

# ═══════════════════════════════════════════════════════════════════════════
# MEMORIE
# ═══════════════════════════════════════════════════════════════════════════

# 13. Apeluri brk() pentru extindere heap
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_brk { 
    printf("%s: brk(%p)\n", comm, args->brk); 
}'

# 14. Page faults per proces
sudo bpftrace -e 'software:page-faults:1 { @[comm] = count(); }'

# 15. Alocări de pagini kernel (kmalloc)
sudo bpftrace -e 'tracepoint:kmem:kmalloc { @bytes[comm] = sum(args->bytes_alloc); }'

# ═══════════════════════════════════════════════════════════════════════════
# PLANIFICATOR (SCHEDULER)
# ═══════════════════════════════════════════════════════════════════════════

# 16. Comutări de context per secundă
sudo bpftrace -e 'tracepoint:sched:sched_switch { @switches = count(); } 
    interval:s:1 { print(@switches); clear(@switches); }'

# 17. Latență run queue (timp de așteptare înainte de rulare)
sudo bpftrace -e '
    tracepoint:sched:sched_wakeup { @qtime[args->pid] = nsecs; }
    tracepoint:sched:sched_switch /@qtime[args->next_pid]/ {
        @latency_us = hist((nsecs - @qtime[args->next_pid]) / 1000);
        delete(@qtime[args->next_pid]);
    }
'

# 18. Migrări între CPU-uri
sudo bpftrace -e 'tracepoint:sched:sched_migrate_task { 
    printf("%s migrated from CPU %d to CPU %d\n", 
           args->comm, args->orig_cpu, args->dest_cpu); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# BLOC I/O (DISC)
# ═══════════════════════════════════════════════════════════════════════════

# 19. Latență I/O bloc (histogramă)
sudo bpftrace -e '
    tracepoint:block:block_rq_issue { @start[args->dev, args->sector] = nsecs; }
    tracepoint:block:block_rq_complete /@start[args->dev, args->sector]/ {
        @latency_us = hist((nsecs - @start[args->dev, args->sector]) / 1000);
        delete(@start[args->dev, args->sector]);
    }
'

# 20. I/O per dispozitiv și tip operație
sudo bpftrace -e 'tracepoint:block:block_rq_issue { 
    @io[args->dev, args->rwbs] = count(); 
}'

# ═══════════════════════════════════════════════════════════════════════════
# PROFILARE CPU
# ═══════════════════════════════════════════════════════════════════════════

# 21. Sampling stack-uri la 99 Hz (flame graph input)
sudo bpftrace -e 'profile:hz:99 { @[kstack] = count(); }'

# 22. Funcții kernel cele mai frecvent apelate
sudo bpftrace -e 'profile:hz:99 { @[func] = count(); }'

# 23. Off-CPU analysis (unde așteaptă procesele)
sudo bpftrace -e '
    tracepoint:sched:sched_switch { 
        @off[args->prev_comm, args->prev_pid] = nsecs; 
    }
    tracepoint:sched:sched_switch /@off[args->next_comm, args->next_pid]/ {
        @blocked_us[args->next_comm] = 
            hist((nsecs - @off[args->next_comm, args->next_pid]) / 1000);
        delete(@off[args->next_comm, args->next_pid]);
    }
'
```

### 8.5. Script bpftrace Complet: Monitorizare Proces Specific

```bash
#!/usr/bin/env bpftrace
/*
 * process_monitor.bt - Monitorizare detaliată a unui proces
 * Utilizare: sudo bpftrace process_monitor.bt -c "program_to_trace"
 *            sudo bpftrace process_monitor.bt -p PID
 */

BEGIN {
    printf("Monitoring process... Ctrl+C to stop.\n");
    printf("%-20s %-10s %-40s\n", "EVENT", "LATENCY", "DETAILS");
    printf("─────────────────────────────────────────────────────────────────────\n");
}

// Apeluri sistem - intrare
tracepoint:raw_syscalls:sys_enter /pid == $target/ {
    @syscall_start[tid] = nsecs;
    @syscall_id[tid] = args->id;
}

// Apeluri sistem - ieșire cu durată
tracepoint:raw_syscalls:sys_exit /pid == $target && @syscall_start[tid]/ {
    $latency = (nsecs - @syscall_start[tid]) / 1000; // microsecunde
    @syscall_latency[@syscall_id[tid]] = hist($latency);
    
    // Afișează doar apelurile lente (>1ms)
    if ($latency > 1000) {
        printf("%-20s %-10d syscall_id=%d ret=%d\n", 
               "SLOW_SYSCALL", $latency, @syscall_id[tid], args->ret);
    }
    
    delete(@syscall_start[tid]);
    delete(@syscall_id[tid]);
}

// Deschidere fișiere
tracepoint:syscalls:sys_enter_openat /pid == $target/ {
    printf("%-20s %-10s %s\n", "OPEN", "-", str(args->filename));
}

// Operații read/write
tracepoint:syscalls:sys_exit_read /pid == $target && args->ret > 0/ {
    @read_bytes = sum(args->ret);
}

tracepoint:syscalls:sys_exit_write /pid == $target && args->ret > 0/ {
    @write_bytes = sum(args->ret);
}

// Conexiuni rețea
kprobe:tcp_v4_connect /pid == $target/ {
    printf("%-20s %-10s TCP connect initiated\n", "NET_CONNECT", "-");
}

// Page faults
software:page-faults:1 /pid == $target/ {
    @page_faults = count();
}

// Context switches
tracepoint:sched:sched_switch /args->prev_pid == $target/ {
    @voluntary_switches = count();
}

interval:s:5 {
    printf("\n═══ 5 SECOND SUMMARY ═══\n");
    printf("Read bytes:  %d\n", @read_bytes);
    printf("Write bytes: %d\n", @write_bytes);
    printf("Page faults: %d\n", @page_faults);
    printf("Context switches: %d\n", @voluntary_switches);
    
    clear(@read_bytes);
    clear(@write_bytes);
    clear(@page_faults);
    clear(@voluntary_switches);
}

END {
    printf("\n═══ SYSCALL LATENCY HISTOGRAMS (μs) ═══\n");
    print(@syscall_latency);
    
    clear(@syscall_start);
    clear(@syscall_id);
    clear(@syscall_latency);
}
```

---

## 9. BCC: Colecția de Compilatoare BPF

### 9.1. Arhitectura BCC

**BCC** (BPF Compiler Collection) este un framework care combină programe eBPF scrise în C restricționat cu aplicații Python/Lua pentru orchestrare. Include o bibliotecă bogată de unelte pre-construite.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       ARHITECTURA BCC                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Script Python (orchestrare, afișare, procesare date)               │   │
│   │  ┌───────────────────────────────────────────────────────────────┐  │   │
│   │  │  from bcc import BPF                                          │  │   │
│   │  │  b = BPF(text=bpf_program)                                    │  │   │
│   │  │  b.attach_kprobe(event="vfs_read", fn_name="trace_read")      │  │   │
│   │  │  while True:                                                  │  │   │
│   │  │      print(b["counts"].items())                               │  │   │
│   │  └───────────────────────────────────────────────────────────────┘  │   │
│   └──────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Program eBPF (C restricționat, compilat la runtime)                │   │
│   │  ┌───────────────────────────────────────────────────────────────┐  │   │
│   │  │  BPF_HASH(counts, u32, u64);                                  │  │   │
│   │  │                                                               │  │   │
│   │  │  int trace_read(struct pt_regs *ctx) {                        │  │   │
│   │  │      u32 pid = bpf_get_current_pid_tgid() >> 32;              │  │   │
│   │  │      counts.increment(pid);                                   │  │   │
│   │  │      return 0;                                                │  │   │
│   │  │  }                                                            │  │   │
│   │  └───────────────────────────────────────────────────────────────┘  │   │
│   └──────────────────────────────────┬──────────────────────────────────┘   │
│                                      │                                      │
│                                      │ LLVM/Clang                           │
│                                      │ compilare                            │
│                                      ▼                                      │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  Bytecode eBPF → Verificator → JIT → Atașare la hook               │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2. Instalare BCC

```bash
# Ubuntu/Debian
sudo apt-get install bpfcc-tools linux-headers-$(uname -r)

# Fedora
sudo dnf install bcc-tools

# Arch Linux
sudo pacman -S bcc bcc-tools python-bcc

# Verificare instalare
sudo /usr/share/bcc/tools/execsnoop
```

### 9.3. Unelte BCC Esențiale

BCC include peste 100 de unelte de diagnostic. Următorul tabel prezintă cele mai utilizate:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      UNELTE BCC ESENȚIALE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PROCESE ȘI APELURI SISTEM                                                  │
│  ═════════════════════════                                                  │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ execsnoop      │ Trasare exec() - procese noi create                │    │
│  │                │ $ sudo execsnoop                                   │    │
│  │                │ PCOMM  PID   PPID  RET ARGS                        │    │
│  │                │ bash   1234  1000  0   /bin/ls -la                 │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ opensnoop      │ Trasare open() - fișiere deschise                  │    │
│  │                │ $ sudo opensnoop -p 1234                           │    │
│  │                │ PID    COMM  FD  PATH                              │    │
│  │                │ 1234   cat   3   /etc/passwd                       │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ syscount       │ Contorizare apeluri sistem                         │    │
│  │                │ $ sudo syscount -p 1234 -i 1                       │    │
│  │                │ SYSCALL    COUNT                                   │    │
│  │                │ read       15234                                   │    │
│  │                │ write      8432                                    │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ killsnoop      │ Monitorizare semnale kill()                        │    │
│  │                │ $ sudo killsnoop                                   │    │
│  │                │ PID    COMM      SIG  TPID   RES                   │    │
│  │                │ 1234   bash      9    5678   0                     │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  REȚEA                                                                      │
│  ═════                                                                      │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ tcpconnect     │ Conexiuni TCP active (outbound)                    │    │
│  │                │ $ sudo tcpconnect                                  │    │
│  │                │ PID    COMM      SADDR        DADDR        DPORT   │    │
│  │                │ 1234   curl      10.0.0.1     93.184.216.34 80     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcpaccept      │ Conexiuni TCP pasive (inbound)                     │    │
│  │                │ $ sudo tcpaccept                                   │    │
│  │                │ PID    COMM      RADDR        LPORT                │    │
│  │                │ 5678   nginx     192.168.1.5  80                   │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcpretrans     │ Retransmisii TCP (indicator probleme rețea)        │    │
│  │                │ $ sudo tcpretrans                                  │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ tcplife        │ Durata de viață conexiuni TCP                      │    │
│  │                │ $ sudo tcplife                                     │    │
│  │                │ PID   COMM      LADDR  RADDR   TX_KB RX_KB MS      │    │
│  │                │ 1234  curl      :0     :80     1     25    150     │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  DISC I/O                                                                   │
│  ════════                                                                   │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ biolatency     │ Histogramă latență block I/O                       │    │
│  │                │ $ sudo biolatency                                  │    │
│  │                │      usecs      : count    distribution            │    │
│  │                │        0 -> 1   : 0       |                        │    │
│  │                │        2 -> 3   : 12      |**                      │    │
│  │                │        4 -> 7   : 156     |*************           │    │
│  │                │       ...                                          │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ biosnoop       │ Trasare fiecare operație I/O                       │    │
│  │                │ $ sudo biosnoop                                    │    │
│  │                │ TIME     COMM   PID  DISK  T  SECTOR  BYTES  LAT   │    │
│  │                │ 12:00:01 mysqld 123  sda   R  1234    4096   0.5   │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ ext4slower     │ Operații ext4 lente (sau xfs/btrfs/zfs)            │    │
│  │                │ $ sudo ext4slower 10                               │    │
│  │                │ (afișează operații >10ms)                          │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ filelife       │ Durata de viață fișiere (create → delete)          │    │
│  │                │ $ sudo filelife                                    │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  MEMORIE                                                                    │
│  ═══════                                                                    │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ memleak        │ Detectare memory leaks (fără modificare cod)       │    │
│  │                │ $ sudo memleak -p 1234                             │    │
│  │                │ [top outstanding allocations]                      │    │
│  │                │ 1024 bytes in 16 allocations from stack:           │    │
│  │                │   malloc+0x00                                      │    │
│  │                │   process_request+0x42                             │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ oomkill        │ Monitorizare OOM killer events                     │    │
│  │                │ $ sudo oomkill                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ cachestat      │ Statistici page cache (hits/misses)                │    │
│  │                │ $ sudo cachestat                                   │    │
│  │                │ HITS   MISSES  DIRTIES  RATIO  BUFFERS_MB          │    │
│  │                │ 12345  234     45       98.1%  512                 │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
│  CPU ȘI PLANIFICATOR                                                        │
│  ═══════════════════                                                        │
│                                                                             │
│  ┌────────────────┬────────────────────────────────────────────────────┐    │
│  │ runqlat        │ Latență run queue (cât așteaptă înainte de CPU)    │    │
│  │                │ $ sudo runqlat                                     │    │
│  │                │      usecs      : count    distribution            │    │
│  │                │        0 -> 1   : 3245    |*****                   │    │
│  │                │        2 -> 3   : 12456   |*******************     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ runqlen        │ Lungime run queue în timp                          │    │
│  │                │ $ sudo runqlen                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ cpudist        │ Distribuție timp on-CPU per task                   │    │
│  │                │ $ sudo cpudist                                     │    │
│  ├────────────────┼────────────────────────────────────────────────────┤    │
│  │ offcputime     │ Analiza blocaje (off-CPU stacks)                   │    │
│  │                │ $ sudo offcputime -p 1234 5                        │    │
│  │                │ (stack traces cu timp petrecut blocat)             │    │
│  └────────────────┴────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.4. Exemplu Complet: Script BCC Personalizat

```python
#!/usr/bin/env python3
"""
slow_syscalls.py - Monitorizare apeluri sistem lente
Afișează apelurile sistem care depășesc un prag de latență
"""

from bcc import BPF
from time import strftime
import argparse

# Argumentele liniei de comandă
parser = argparse.ArgumentParser(
    description="Monitorizare apeluri sistem lente")
parser.add_argument("-p", "--pid", type=int, 
    help="Filtrare după PID")
parser.add_argument("-t", "--threshold", type=int, default=1000,
    help="Prag latență în microsecunde (implicit: 1000)")
args = parser.parse_args()

# Programul eBPF (C restricționat)
bpf_program = """
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>

struct data_t {
    u64 ts;           // Timestamp start
    u64 lat_us;       // Latența în microsecunde
    u32 pid;
    u32 tid;
    u64 syscall_id;
    char comm[16];
};

BPF_HASH(start, u64, u64);           // tid -> timestamp
BPF_HASH(syscalls, u64, u64);        // tid -> syscall_id
BPF_PERF_OUTPUT(events);             // Buffer pentru user space

TRACEPOINT_PROBE(raw_syscalls, sys_enter) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    
    // Filtru PID opțional
    FILTER_PID
    
    u64 tid = pid_tgid;
    u64 ts = bpf_ktime_get_ns();
    
    start.update(&tid, &ts);
    syscalls.update(&tid, &args->id);
    
    return 0;
}

TRACEPOINT_PROBE(raw_syscalls, sys_exit) {
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u64 tid = pid_tgid;
    
    u64 *tsp = start.lookup(&tid);
    if (!tsp) return 0;
    
    u64 lat_ns = bpf_ktime_get_ns() - *tsp;
    u64 lat_us = lat_ns / 1000;
    
    // Prag de latență
    if (lat_us < THRESHOLD_US) {
        start.delete(&tid);
        syscalls.delete(&tid);
        return 0;
    }
    
    struct data_t data = {};
    data.ts = *tsp;
    data.lat_us = lat_us;
    data.pid = pid_tgid >> 32;
    data.tid = tid;
    
    u64 *sid = syscalls.lookup(&tid);
    if (sid) data.syscall_id = *sid;
    
    bpf_get_current_comm(&data.comm, sizeof(data.comm));
    
    events.perf_submit(args, &data, sizeof(data));
    
    start.delete(&tid);
    syscalls.delete(&tid);
    
    return 0;
}
"""

# Substituții în cod
bpf_program = bpf_program.replace("THRESHOLD_US", str(args.threshold))
if args.pid:
    bpf_program = bpf_program.replace("FILTER_PID",
        f"if (pid != {args.pid}) return 0;")
else:
    bpf_program = bpf_program.replace("FILTER_PID", "")

# Mapare syscall ID -> nume
from bcc import syscall_name

# Încărcare și atașare
b = BPF(text=bpf_program)

# Callback pentru evenimente
def print_event(cpu, data, size):
    event = b["events"].event(data)
    syscall = syscall_name(event.syscall_id).decode('utf-8', 'replace')
    print(f"{strftime('%H:%M:%S')} {event.comm.decode('utf-8'):<16} "
          f"{event.pid:<7} {syscall:<20} {event.lat_us:>10} μs")

# Header
print(f"{'TIME':<8} {'COMM':<16} {'PID':<7} {'SYSCALL':<20} {'LATENCY':>10}")
print("─" * 70)

# Polling evenimente
b["events"].open_perf_buffer(print_event)
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        print("\nÎncheiere monitorizare.")
        exit()
```

---

## 10. Cazuri de Utilizare în Producție

### 10.1. Metodologia de Diagnosticare cu eBPF

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              FLUX DE DIAGNOSTICARE PERFORMANȚĂ                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   1. SIMPTOM OBSERVAT                                                       │
│      │                                                                      │
│      ├─► Latență ridicată aplicație                                         │
│      ├─► CPU 100% utilizare                                                 │
│      ├─► Memorie în creștere                                                │
│      └─► I/O lent                                                           │
│            │                                                                │
│            ▼                                                                │
│   2. IDENTIFICARE RESURSĂ SATURATĂ (USE Method)                             │
│      │                                                                      │
│      │   ┌──────────┬──────────────────────┬─────────────────┐              │
│      │   │ Resursă  │ Utilizare            │ Unealtă eBPF    │              │
│      │   ├──────────┼──────────────────────┼─────────────────┤              │
│      │   │ CPU      │ runqlat, cpudist     │ bpftrace/BCC    │              │
│      │   │ Memorie  │ memleak, cachestat   │ BCC tools       │              │
│      │   │ I/O      │ biolatency, biosnoop │ BCC tools       │              │
│      │   │ Rețea    │ tcplife, tcpretrans  │ BCC tools       │              │
│      │   └──────────┴──────────────────────┴─────────────────┘              │
│            │                                                                │
│            ▼                                                                │
│   3. ANALIZĂ DETALIATĂ                                                      │
│      │                                                                      │
│      ├─► Stack traces (profilare)                                           │
│      ├─► Latență per operație                                               │
│      └─► Corelație evenimente                                               │
│            │                                                                │
│            ▼                                                                │
│   4. IDENTIFICARE CAUZĂ RĂDĂCINĂ                                            │
│      │                                                                      │
│      ├─► Cod aplicație (funcție specifică)                                  │
│      ├─► Configurație sistem                                                │
│      └─► Problemă hardware                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2. Scenarii Practice

**Scenariu 1: Latență aplicație web**

```bash
# Pas 1: Verificare latență run queue (CPU overloaded?)
sudo runqlat 10 1
# Dacă vedem latențe >100μs, CPU-ul este saturat

# Pas 2: Verificare I/O disc (blocking reads?)
sudo biolatency 10 1
# Latențe >10ms indică probleme I/O

# Pas 3: Identificare operații specifice
sudo opensnoop -p $(pgrep nginx) -d 10
# Vedem fișierele accesate

# Pas 4: Stack traces pentru funcții lente
sudo offcputime -p $(pgrep nginx) -f 5 > stacks.out
# Analiza cu flame graph
```

**Scenariu 2: Memory leak**

```bash
# Monitorizare alocări neeliberate
sudo memleak -p $(pgrep myapp) -a

# Rezultat exemplu:
# [10:00:00] 1048576 bytes in 1024 allocations from stack:
#         malloc+0x00
#         process_request+0x42 [myapp]
#         handle_connection+0x1f [myapp]
```

**Scenariu 3: Probleme conexiune rețea**

```bash
# Retransmisii TCP (indică pierderi pachete/congestie)
sudo tcpretrans

# Conexiuni refuzate
sudo tcpconnect | grep -v "^0$"

# Latență conexiuni
sudo tcplife
```

### 10.3. Integrare cu Sisteme de Monitorizare

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              STACK OBSERVABILITATE MODERN                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      VIZUALIZARE ȘI ALERTARE                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │  │
│  │  │  Grafana    │  │  Kibana     │  │  Datadog    │  │  Pagerduty  │   │  │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │  │
│  └─────────┼────────────────┼────────────────┼────────────────┼──────────┘  │
│            │                │                │                │             │
│            └────────────────┴────────────────┴────────────────┘             │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      STOCARE ȘI AGREGARE                              │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐    │  │
│  │  │ Prometheus  │  │ Elasticsearch│ │ Jaeger (tracing distribuit) │    │  │
│  │  └──────┬──────┘  └──────┬──────┘  └─────────────┬───────────────┘    │  │
│  └─────────┼────────────────┼───────────────────────┼────────────────────┘  │
│            │                │                       │                       │
│            └────────────────┴───────────────────────┘                       │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      COLECTARE (AGENT eBPF)                           │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │  Pixie / Cilium Hubble / Datadog Agent / Parca / ...            │  │  │
│  │  │                                                                 │  │  │
│  │  │  • Metrici kernel (CPU, memorie, I/O)                           │  │  │
│  │  │  • Trasare apeluri sistem                                       │  │  │
│  │  │  • Observabilitate rețea (fără sidecar)                         │  │  │
│  │  │  • Profilare continuă                                           │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      NUCLEU LINUX (eBPF hooks)                        │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │  │
│  │  │kprobes  │ │uprobes  │ │tracepoint│ │ XDP    │ │ tc     │         │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘         │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 11. Securitate și Considerații Operaționale

### 11.1. Modelul de Securitate eBPF

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STRATURI DE SECURITATE eBPF                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STRATUL 1: PRIVILEGII NECESARE                                             │
│  ═════════════════════════════════                                          │
│                                                                             │
│  • CAP_BPF (kernel 5.8+) sau CAP_SYS_ADMIN (kernel mai vechi)              │
│  • CAP_PERFMON pentru probe de performanță                                  │
│  • CAP_NET_ADMIN pentru XDP/tc                                              │
│                                                                             │
│  Verificare:                                                                │
│  $ cat /proc/sys/kernel/unprivileged_bpf_disabled                          │
│  1 = dezactivat pentru utilizatori neprivilegiați (recomandat)             │
│                                                                             │
│  STRATUL 2: VERIFICATOR                                                     │
│  ═════════════════════════                                                  │
│                                                                             │
│  • Analiza statică OBLIGATORIE înainte de încărcare                        │
│  • Garantează: terminare, siguranță memorie, operații legale               │
│  • NU poate fi ocolit                                                       │
│                                                                             │
│  STRATUL 3: IZOLARE HELPER FUNCTIONS                                        │
│  ═══════════════════════════════════                                        │
│                                                                             │
│  • Fiecare tip de program are acces doar la helpers specifice              │
│  • XDP nu poate citi memorie kernel arbitrară                              │
│  • Tracing nu poate modifica pachete                                        │
│                                                                             │
│  STRATUL 4: SIGNED BPF (kernel 5.16+)                                       │
│  ═════════════════════════════════════                                      │
│                                                                             │
│  • Programe eBPF pot fi semnate criptografic                               │
│  • Kernel verifică semnătura înainte de încărcare                          │
│  • Previne încărcarea de programe neautorizate                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 11.2. Riscuri și Mitigări

| Risc | Descriere | Mitigare |
|------|-----------|----------|
| **DoS prin verificator** | Program complex poate încetini verificarea | Limite complexitate verificator |
| **Information leakage** | Citire date sensibile din kernel | Helpers restricționate, Spectre mitigations |
| **Side-channel attacks** | Timing attacks prin măsurători | bpf_jit_harden=2 |
| **Escape din sandbox** | Exploatare vulnerabilități verificator | Actualizări kernel, audturi cod |
| **Overhead performanță** | Programe ineficiente | Profiling, limits resurse |

### 11.3. Configurări de Securitate Recomandate

```bash
# Dezactivare eBPF pentru utilizatori neprivilegiați
echo 1 > /proc/sys/kernel/unprivileged_bpf_disabled

# Întărire JIT (mitigare side-channels)
echo 2 > /proc/sys/net/core/bpf_jit_harden

# Activare logging încărcare programe
echo 1 > /proc/sys/kernel/bpf_stats_enabled

# Verificare programe încărcate
sudo bpftool prog list
```

---

## 12. Demonstrații Practice

### 12.1. Laborator 1: Monitorizare Sistem cu bpftrace

**Obiectiv**: Diagnosticarea problemelor de performanță pe un server web simulat

```bash
#!/bin/bash
# lab1_system_monitor.sh - Setup și demonstrație

# Pas 1: Generare încărcare (într-un terminal separat)
echo "Terminal 1: Generare încărcare..."
# stress --cpu 2 --io 2 --vm 1 --vm-bytes 128M --timeout 60s &

# Pas 2: Monitorizare cu bpftrace
echo "Terminal 2: Monitorizare activitate sistem..."

# 2a. Procese noi create
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_execve { 
        printf("EXEC: %s -> %s\n", comm, str(args->filename)); 
    }
' &

# 2b. Fișiere deschise
sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_openat { 
        printf("OPEN: %s: %s\n", comm, str(args->filename)); 
    }
' &

# 2c. Histogramă latență I/O
sudo bpftrace -e '
    kprobe:blk_account_io_start { @start[arg0] = nsecs; }
    kprobe:blk_account_io_done /@start[arg0]/ { 
        @io_lat = hist((nsecs - @start[arg0]) / 1000);
        delete(@start[arg0]);
    }
    interval:s:10 { print(@io_lat); clear(@io_lat); }
'
```

### 12.2. Laborator 2: Detectare Memory Leak

```python
#!/usr/bin/env python3
"""
lab2_memleak_demo.py - Demonstrație detectare memory leak
"""

import ctypes
import time
import os

def leaky_function():
    """Funcție care alocă memorie fără să o elibereze"""
    # Alocare directă prin libc malloc
    libc = ctypes.CDLL("libc.so.6")
    ptr = libc.malloc(1024)  # 1KB per apel
    # Nu apelăm free(ptr) - memory leak!
    return ptr

def main():
    print(f"PID: {os.getpid()}")
    print("Starting allocation loop... (run 'sudo memleak -p PID' in another terminal)")
    
    allocations = []
    while True:
        ptr = leaky_function()
        allocations.append(ptr)
        if len(allocations) % 100 == 0:
            print(f"Allocations: {len(allocations)}, ~{len(allocations)}KB leaked")
        time.sleep(0.01)

if __name__ == "__main__":
    main()
```

**Detectare cu BCC:**

```bash
# Terminal 1: Rulare aplicație
python3 lab2_memleak_demo.py

# Terminal 2: Detectare leak-uri
sudo /usr/share/bcc/tools/memleak -p $(pgrep -f lab2_memleak) -a

# Rezultat așteptat:
# Attaching to pid XXXX, Ctrl+C to quit.
# [15:00:00] Top 10 stacks with outstanding allocations:
# 	1048576 bytes in 1024 allocations from stack
# 		malloc+0x00 [libc.so.6]
# 		leaky_function+0x1a [python3]
# 		...
```

### 12.3. Laborator 3: Analiza Conexiuni Rețea

```bash
#!/bin/bash
# lab3_network_analysis.sh - Monitorizare conexiuni

echo "=== MONITORIZARE CONEXIUNI TCP ==="

# Conexiuni outbound
echo "Conexiuni inițiate (outbound):"
sudo timeout 30 /usr/share/bcc/tools/tcpconnect &

# Conexiuni inbound
echo "Conexiuni acceptate (inbound):"
sudo timeout 30 /usr/share/bcc/tools/tcpaccept &

# Retransmisii (indicator probleme)
echo "Retransmisii TCP (probleme rețea):"
sudo timeout 30 /usr/share/bcc/tools/tcpretrans &

# Generare trafic test
echo "Generare trafic..."
for i in {1..10}; do
    curl -s http://example.com > /dev/null
    sleep 1
done

wait
echo "=== ANALIZA COMPLETĂ ==="
```

---

## 13. Exerciții și Provocări

### 13.1. Exerciții de Bază

**Exercițiul 1**: Modificați one-liner-ul pentru monitorizare fișiere deschise astfel încât să afișeze doar fișierele din `/etc/`:

```bash
# Soluție de pornire:
sudo bpftrace -e 'tracepoint:syscalls:sys_enter_openat 
    /str(args->filename) == "/etc/*"/ { ... }'
```

**Exercițiul 2**: Creați un script bpftrace care numără câte bytes citește fiecare proces, afișând top 5 la fiecare 10 secunde.

**Exercițiul 3**: Utilizați `biolatency` pentru a compara latența I/O între un HDD și un SSD (dacă disponibile).

### 13.2. Exerciții Avansate

**Exercițiul 4**: Scrieți un program BCC Python care monitorizează toate apelurile `connect()` și afișează adresa IP destinație în format human-readable.

**Exercițiul 5**: Implementați un "container-aware" tracer care filtrează evenimentele după cgroup namespace.

**Exercițiul 6**: Creați un script de profilare care generează output compatibil cu flame graphs (folded stacks).

### 13.3. Proiect: Sistem de Alertare Performanță

Implementați un sistem care:
1. Monitorizează continuu latența operațiilor critice (I/O, rețea, apeluri sistem)
2. Detectează anomalii (latențe > 2x media)
3. Capturează stack traces când detectează anomalii
4. Exportă metrici către Prometheus

---

## 14. Referințe și Lectură Suplimentară

### 14.1. Documentație Oficială

- [Kernel BPF Documentation](https://www.kernel.org/doc/html/latest/bpf/index.html)
- [bpftrace Reference Guide](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)
- [BCC Tools Tutorial](https://github.com/iovisor/bcc/blob/master/docs/tutorial.md)
- [libbpf Documentation](https://libbpf.readthedocs.io/)

### 14.2. Cărți Recomandate

1. **Gregg, B.** (2019). *BPF Performance Tools: Linux System and Application Observability*. Addison-Wesley. — Referința fundamentală pentru eBPF în practică
2. **Gregg, B.** (2020). *Systems Performance: Enterprise and the Cloud* (2nd ed.). Prentice Hall. — Context mai larg despre metodologii de performanță
3. **Rice, L.** (2023). *Learning eBPF*. O'Reilly Media. — Introducere modernă și accesibilă

### 14.3. Resurse Online

- [Brendan Gregg's eBPF Page](https://www.brendangregg.com/ebpf.html) — Colecție completă de materiale
- [ebpf.io](https://ebpf.io/) — Site-ul comunității eBPF
- [Cilium eBPF Documentation](https://docs.cilium.io/en/stable/bpf/) — Perspectiva Kubernetes/networking

### 14.4. Articole Academice

- McCanne, S., & Jacobson, V. (1993). *The BSD Packet Filter: A New Architecture for User-level Packet Capture*. USENIX Winter Conference.
- Starovoitov, A., & Borkmann, D. (2014). *Extending extended BPF*. Linux Plumbers Conference.

---

## Sumar

eBPF reprezintă o schimbare de paradigmă în observabilitatea sistemelor Linux, oferind capabilități anterior imposibile fără modificarea nucleului sau risc de instabilitate. Acest modul a acoperit:

1. **Arhitectura fundamentală**: verificator, JIT, hărți, helpers
2. **Tipuri de programe**: kprobes, tracepoints, XDP, tc, cgroup hooks
3. **Instrumentar practic**: bpftrace pentru diagnosticare rapidă, BCC pentru unelte pre-construite
4. **Scenarii de producție**: metodologii USE, debugging latență, memory leaks, probleme rețea
5. **Considerații de securitate**: privilegii, verificator, signed BPF

Pentru studenții care doresc să exceleze în roluri de Site Reliability Engineering, Cloud Infrastructure sau Performance Engineering, stăpânirea eBPF devine o competență diferențiatoare pe piața muncii.

---

*Acest material a fost pregătit pentru cursul de Sisteme de Operare, ASE București - CSIE, 2025-2026.*

---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce este un modul kernel? Care sunt funcțiile obligatorii (`init` și `exit`) și cum se încarcă/descarcă un modul?
2. **[UNDERSTAND]** Explică ce este eBPF și de ce este considerat revoluționar pentru observabilitate și securitate în Linux.
3. **[ANALYSE]** Compară dezvoltarea unui modul kernel clasic cu scrierea unui program eBPF. Care sunt avantajele și limitările eBPF?

### Mini-provocare (opțional)

Listează modulele kernel încărcate cu `lsmod` și identifică 3 module, explicând rolul fiecăruia.

---


---


---


---

## Lectură Recomandată

### Resurse Obligatorii

**Documentație oficială**
- [eBPF.io](https://ebpf.io/) — Site-ul oficial al comunității eBPF
- [BCC Reference Guide](https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md) — Referință completă BCC
- [bpftrace Reference](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)

**Brendan Gregg Resources**
- [BPF Performance Tools](https://www.brendangregg.com/bpf-performance-tools-book.html) — Cartea de referință
- [eBPF Tracing Tools](https://www.brendangregg.com/ebpf.html) — Colecție completă de materiale

### Resurse Recomandate

**Articole Clasice**
- McCanne & Jacobson (1993): "The BSD Packet Filter" — Articolul original BPF
- Gregg (2019): "BPF Performance Tools" — Capitolele 1-3 pentru fundamente

**Linux man pages**
```bash
man 2 bpf           # Syscall-ul bpf()
man 7 bpf-helpers   # Funcții helper disponibile în programe eBPF
```

### Resurse Video

- **Brendan Gregg - eBPF Superpowers** (Performance Summit)
- **Liz Rice - eBPF Deep Dive** (KubeCon talks)
- **Kernel Recipes** — Multiple prezentări despre eBPF internals

### Proiecte pentru Studiu

- [libbpf-bootstrap](https://github.com/libbpf/libbpf-bootstrap) — Template pentru programe eBPF moderne
- [Cilium](https://github.com/cilium/cilium) — Networking Kubernetes bazat pe eBPF

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **BTF (BPF Type Format)**: Informații de tip pentru CO-RE (Compile Once, Run Everywhere).
- **BPF LSM**: Linux Security Module bazat pe eBPF pentru politici de securitate custom.
- **BPF iterators**: Iterare eficientă peste structuri kernel (procese, fișiere, connections).

### Greșeli frecvente de evitat

1. **Loops infinite în eBPF**: Verificatorul le va respinge; folosește bounded loops.
2. **Accesarea directă a memoriei kernel**: Necesită helper functions (`bpf_probe_read`).
3. **Presupunerea stabilității kprobes**: Funcțiile interne se pot schimba între versiuni kernel.

### Întrebări rămase deschise

- Va deveni eBPF standardul pentru extensibilitate kernel pe toate SO-urile (Windows eBPF)?
- Pot programele eBPF să ruleze safe pe acceleratoare (SmartNICs, DPU-uri)?

## Privire înainte

**Continuare Opțională: C18supp — Integrarea NPU în Sistemele de Operare**

Acesta este ultimul modul suplimentar. Dacă eBPF ți-a deschis apetitul pentru programarea la nivel de kernel, C18 explorează cum sistemele de operare moderne gestionează procesoarele specializate AI/ML (NPU, Neural Engine, TPU).

**Pregătire recomandată:**
- Cercetează ce accelerator AI are dispozitivul tău (dacă are)
- Citește despre Apple Neural Engine, Intel NPU, sau Google TPU

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 17: KERNEL DEV — RECAP             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  MODULE KERNEL                                                  │
│  ├── Cod care se încarcă dinamic în kernel                     │
│  ├── init_module(): la încărcare (insmod)                      │
│  ├── cleanup_module(): la descărcare (rmmod)                   │
│  └── Compilare: Makefile special cu KBUILD                     │
│                                                                 │
│  eBPF (Extended Berkeley Packet Filter)                         │
│  ├── Cod sigur care rulează în kernel                          │
│  ├── Verificator: garantează terminare și siguranță            │
│  ├── Use cases: networking, tracing, security                  │
│  └── Tools: bpftrace, bcc, libbpf                              │
│                                                                 │
│  TRACING & OBSERVABILITY                                        │
│  ├── ftrace: tracing built-in kernel                           │
│  ├── perf: performance counters                                │
│  └── bpftrace: scriptare eBPF one-liners                       │
│                                                                 │
│  DEBUGGING KERNEL                                               │
│  ├── printk(): printf pentru kernel                            │
│  ├── dmesg: buffer mesaje kernel                               │
│  └── /proc, /sys: interfață cu kernel                          │
│                                                                 │
│  💡 TAKEAWAY: eBPF = viitorul observabilității în Linux        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

