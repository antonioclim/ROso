# C02_03_INTREBARI_DISCUTIE.md
# Întrebări pentru Discuție — Concepte de Bază ale SO

> Săptămâna 2 | by Revolvix

---

## Întrebări de Bază

1. **De ce întreruperile sunt esențiale pentru SO moderne?** Ce s-ar întâmpla dacă am folosi doar polling?

2. **Explică diferența între interrupt și trap.** Dă exemple concrete pentru fiecare.

3. **Ce rol are Interrupt Vector Table?** Cum știe CPU-ul ce handler să execute?

---

## Întrebări de Analiză

4. **Trade-off polling vs interrupts**: În ce situații ar fi polling-ul preferabil întreruperilor?

5. **De ce DMA este crucial pentru performanță?** Calculează overhead-ul copierii a 1GB de date byte-cu-byte.

6. **Nested interrupts**: Ce probleme pot apărea dacă o întrerupere de prioritate mică întrerupe una de prioritate mare?

---

## Întrebări de Sinteză

7. **Design**: Proiectezi un sistem embedded pentru senzori. Cum ai organiza prioritățile întreruperilor?

8. **Scenarii**: Un driver de rețea primește pachete la 10Gbps. De ce DMA este obligatoriu?

---

*Întrebări pentru seminar și studiu individual*

---

# C02_04_GHID_STUDIU.md
# Ghid de Studiu — Concepte de Bază ale SO

> Săptămâna 2 | by Revolvix

---

## Concepte Cheie

### Întreruperi
- **Definiție**: Semnal care solicită atenția CPU
- **Tipuri**: Hardware (asincrone) vs Software/Trap (sincrone)
- **Flux**: Save → Handler → Restore

### Polling vs Interrupts
| Polling | Interrupts |
|---------|------------|
| CPU verifică continuu | CPU notificat când e nevoie |
| Simplu, latență mică | Eficient, CPU liber |
| Irosește cicluri | Overhead context switch |

### DMA (Direct Memory Access)
- Transfer date I/O ↔ RAM fără CPU
- CPU doar inițiază și primește notificare la final
- Esențial pentru dispozitive rapide (disk, network)

---

## Termeni Cheie

| Termen | Definiție |
|--------|-----------|
| **IRQ** | Interrupt Request - linie hardware pentru semnalizare |
| **ISR** | Interrupt Service Routine - codul handler-ului |
| **IVT** | Interrupt Vector Table - mapare IRQ→handler |
| **NMI** | Non-Maskable Interrupt - nu poate fi dezactivat |
| **EOI** | End Of Interrupt - semnal că handler-ul a terminat |

---

## Auto-Evaluare

1. Ce se întâmplă când sosește o întrerupere?
2. De ce DMA îmbunătățește performanța?
3. Când folosim polling în loc de interrupts?

---

## Exerciții Practice

```bash
# Vezi întreruperile sistemului
cat /proc/interrupts

# Monitorizează IRQ-uri în timp real
watch -n1 cat /proc/interrupts
```

---

*Timp studiu: 2 ore | Dificultate: Medie*