# C01_01_PLAN_CURS.md
# Plan de Curs — Introducere în Sisteme de Operare

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 1 | by Revolvix

---

## Obiective de Învățare

La finalul acestui curs, studentul va fi capabil să:

1. **Definească** conceptul de sistem de operare și rolurile sale fundamentale
2. **Explice** diferența între kernel mode și user mode
3. **Descrie** procesul de boot al unui calculator
4. **Compare** tipurile principale de sisteme de operare
5. **Analizeze** avantajele și dezavantajele diferitelor arhitecturi de kernel

---

## Structura Cursului (100 minute)

### Partea I: Fundamente (30 min)

| Timp | Subiect | Metodă |
|------|---------|--------|
| 0-10 | Ce este un SO? Definiție și exemple | Prezentare + Discuție |
| 10-20 | Rolurile SO: gestionar resurse, mașină extinsă | Diagramă + Exemple |
| 20-30 | Evoluția istorică: batch → multiprogramare → time-sharing | Timeline interactiv |

### Partea II: Concepte Cheie (40 min)

| Timp | Subiect | Metodă |
|------|---------|--------|
| 30-45 | Dual mode: kernel vs user mode | Demo + Diagramă |
| 45-55 | System calls: interfața cu kernel-ul | Cod exemplu |
| 55-70 | Procesul de boot: BIOS/UEFI → Bootloader → Kernel | Animație |

### Partea III: Arhitecturi (30 min)

| Timp | Subiect | Metodă |
|------|---------|--------|
| 70-85 | Monolithic vs Microkernel vs Hybrid | Comparație tabelară |
| 85-95 | Tipuri de SO: desktop, server, embedded, real-time | Studii de caz |
| 95-100 | Recapitulare și întrebări | Q&A |

---

## Resurse Necesare

### Pentru Instructor
- Slide-uri prezentare (PDF/PPTX)
- Diagramă arhitectură SO
- Timeline evoluție SO
- Demo VirtualBox (opțional)

### Pentru Studenți
- README.md din directorul cursului
- Acces la VM Ubuntu (pentru laboratoare ulterioare)

---

## Evaluare

### Formativă (în timpul cursului)
- Întrebări de verificare la fiecare secțiune
- Quiz rapid (5 întrebări) la final

### Sumativă (examen)
- Concepte din acest curs: ~8% din nota finală
- Focus pe: definiții, dual mode, tipuri SO

---

## Pregătire pentru Laboratorul 1

Studenții trebuie să:
1. Instaleze VirtualBox sau VMware
2. Descarce imaginea Ubuntu 24.04 LTS
3. Citească secțiunea "Comenzi de bază Linux" din ghidul de laborator

---

## Întrebări Frecvente

**Q: De ce studiem sisteme de operare?**
A: SO-ul este fundația pe care rulează tot software-ul. Înțelegerea lui este esențială pentru programare eficientă, debugging, și arhitectură software.

**Q: Ce SO vom folosi la laborator?**
A: Ubuntu Linux 24.04 în mașină virtuală, cu acces opțional la WSL2 pentru Windows.

**Q: Trebuie să știu să programez în C?**
A: Cunoștințe de bază C sunt utile dar nu obligatorii. Vom folosi și Python pentru scripturi.

---

## Note pentru Instructor

- Începe cu exemple concrete (smartphone, laptop) înainte de abstractizări
- Folosește analogii: SO = "managerul" care coordonează resursele
- Lasă timp pentru întrebări - este prima întâlnire cu conceptele
- Menționează că detaliile tehnice vor fi aprofundate în cursurile următoare

---

*Material actualizat: Ianuarie 2026*