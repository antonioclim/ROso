# C01_03_INTREBARI_DISCUTIE.md
# Întrebări pentru Discuție — Introducere în Sisteme de Operare

> Sisteme de Operare | ASE București - CSIE | 2025-2026  
> Săptămâna 1 | by Revolvix

---

## Întrebări de Bază (Verificare Înțelegere)

### 1. Definiție și Rol
> **Întrebare**: Cum ai explica unui prieten ce este un sistem de operare, fără a folosi termeni tehnici?

**Puncte de discuție**:
- Analogia cu un "manager" sau "coordonator"
- Exemple din viața de zi cu zi
- Ce s-ar întâmpla fără SO?

---

### 2. Dual Mode
> **Întrebare**: De ce este necesar să existe două moduri de execuție (kernel și user)? Ce s-ar întâmpla dacă orice program ar avea acces direct la hardware?

**Puncte de discuție**:
- Scenarii de erori/atacuri
- Stabilitate vs flexibilitate
- Overhead-ul protecției

---

### 3. System Calls
> **Întrebare**: Când scrii `printf("Hello")` în C, ce se întâmplă "în spatele scenei" la nivel de SO?

**Puncte de discuție**:
- Biblioteca C vs kernel
- Trap/interrupt
- Buffer vs scriere directă

---

## Întrebări de Analiză (Gândire Critică)

### 4. Trade-offs Arhitecturale
> **Întrebare**: Linux folosește un kernel monolitic, iar MINIX un microkernel. Care sunt compromisurile fiecărei abordări? În ce situații ai alege una sau alta?

**Puncte de discuție**:
- Performanță vs modularitate
- Suprafață de atac
- Ușurință de dezvoltare/debugging

---

### 5. Evoluția Tehnologiei
> **Întrebare**: Cum crezi că vor evolua sistemele de operare în următorii 10 ani? Ce probleme actuale vor fi rezolvate și ce noi provocări vor apărea?

**Puncte de discuție**:
- AI în SO (scheduling inteligent, predicție)
- Securitate post-cuantică
- Edge computing vs cloud
- SO pentru dispozitive IoT

---

### 6. Scenarii Practice
> **Întrebare**: Un dezvoltator scrie cod care accidental intră într-o buclă infinită. Cum poate SO-ul să prevină blocarea întregului sistem?

**Puncte de discuție**:
- Preemption
- Timer interrupts
- Watchdog mechanisms

---

## Întrebări de Sinteză (Aplicare Cunoștințe)

### 7. Design Challenge
> **Întrebare**: Dacă ai proiecta un SO pentru un automobil autonom, ce caracteristici ar fi esențiale? Cum ar diferi de un SO desktop?

**Puncte de discuție**:
- Real-time guarantees
- Fault tolerance
- Minimal attack surface
- Safety certification

---

### 8. Comparație Practică
> **Întrebare**: Compară procesul de boot al telefonului tău cu cel al unui laptop. Ce diferențe observi și de ce crezi că există?

**Puncte de discuție**:
- BIOS vs bootROM
- Secure boot
- Fast boot optimizations
- Power management

---

### 9. Studiu de Caz: Cloud
> **Întrebare**: În cloud computing, mii de mașini virtuale rulează pe același hardware fizic. Ce provocări speciale aduce acest lucru pentru sistemul de operare?

**Puncte de discuție**:
- Hypervisor overhead
- Resource allocation fairness
- Security isolation
- Live migration

---

## Întrebări pentru Reflecție Personală

### 10. Experiență Directă
> **Întrebare**: Ai întâlnit vreodată un "kernel panic" sau "Blue Screen of Death"? Ce crezi că a cauzat problema și cum ai rezolvat-o?

---

### 11. Alegeri Personale
> **Întrebare**: De ce folosești sistemul de operare pe care îl folosești (Windows/macOS/Linux)? Care sunt criteriile tale de alegere?

---

### 12. Perspectivă Etică
> **Întrebare**: Sistemele de operare moderne colectează telemetrie și date de utilizare. Unde tragi linia între funcționalitate utilă și încălcarea privacy-ului?

---

## Format Discuție Recomandată

### În Clasă (15-20 minute)
1. Împărțire în grupuri de 4-5 studenți
2. Fiecare grup primește 2-3 întrebări
3. 10 minute discuție în grup
4. 5-10 minute prezentare concluzii

### Individual (Temă)
- Alege 2 întrebări și scrie câte un paragraf de răspuns
- Include exemple concrete
- Citează surse dacă este necesar

---

## Resurse Suplimentare pentru Discuție

- [Operating Systems: Three Easy Pieces](https://pages.cs.wisc.edu/~remzi/OSTEP/) - Capitol introductiv
- [The Linux Kernel Documentation](https://www.kernel.org/doc/)
- Andrew Tanenbaum vs Linus Torvalds - Dezbaterea Monolithic vs Microkernel

---

*Întrebările sunt concepute pentru a stimula gândirea critică și aplicarea practică a conceptelor.*
