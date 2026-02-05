# Jurnal Verificare Orală — Seminar 1

> **Doar pentru instructor** | Completați în timpul sau imediat după verificare  
> **Versiune:** 1.0 | **ID Formular:** S01-ORAL-____

---

## Informații student

| Câmp | Valoare |
|------|---------|
| **Nume student** | ________________________________ |
| **ID Student (Matricol)** | ________________________________ |
| **Grupă** | ________________________________ |
| **Data** | ____/____/20____ |
| **Ora** | ____:____ |
| **Evaluator** | ________________________________ |

---

## Detalii temă

| Element | Status |
|---------|--------|
| Arhivă primită | [ ] Da [ ] Nu |
| Scor autograder | ____/90 puncte |
| Scripturile execută | [ ] Da [ ] Nu [ ] Parțial |

---

## Întrebări adresate

### Întrebarea 1

| Aspect | Răspuns |
|--------|---------|
| **Tip** | [ ] V1-Explică linie [ ] V2-Prezice output [ ] V3-Justifică alegere [ ] V4-Modificare live [ ] V5-Debug |
| **Întrebarea specifică adresată** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Rezumatul răspunsului studentului** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Calitatea răspunsului** | [ ] Sigur și corect [ ] Ezitant dar corect [ ] Parțial corect [ ] Incorect [ ] Fără răspuns |
| **Timpul de răspuns** | [ ] Imediat (<5s) [ ] Normal (5-15s) [ ] Lent (15-30s) [ ] Excesiv (>30s) |

### Întrebarea 2

| Aspect | Răspuns |
|--------|---------|
| **Tip** | [ ] V1-Explică linie [ ] V2-Prezice output [ ] V3-Justifică alegere [ ] V4-Modificare live [ ] V5-Debug |
| **Întrebarea specifică adresată** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Rezumatul răspunsului studentului** | |
| | _________________________________________________________________ |
| | _________________________________________________________________ |
| **Calitatea răspunsului** | [ ] Sigur și corect [ ] Ezitant dar corect [ ] Parțial corect [ ] Incorect [ ] Fără răspuns |
| **Timpul de răspuns** | [ ] Imediat (<5s) [ ] Normal (5-15s) [ ] Lent (15-30s) [ ] Excesiv (>30s) |

---

## Listă verificare semnale de alarmă

Marcați indicatorii observați:

| # | Indicator | Observat |
|---|-----------|----------|
| 1 | Nu poate explica variabilele de bază din propriul script | [ ] |
| 2 | Nu știe ce face shebang-ul (`#!/bin/bash`) | [ ] |
| 3 | Nu poate modifica scriptul la cerere (ex.: adaugă o linie) | [ ] |
| 4 | Terminologia inconsistentă cu comentariile din cod | [ ] |
| 5 | Timp de răspuns excesiv pentru întrebări simple | [ ] |
| 6 | Nu poate naviga la propriile fișiere în terminal | [ ] |
| 7 | Nefamiliarizat cu comenzile prezente în propriul script | [ ] |
| 8 | Stilul codului drastic diferit de explicația verbală | [ ] |

**Număr semnale de alarmă:** ____/8

**Acțiune necesară:**
- [ ] 0-1 semnale: Normal — continuați cu notarea
- [ ] 2-3 semnale: Suspect — notați pentru urmărire
- [ ] 4+ semnale: Escaladați la investigație plagiat

---

## Rezultat verificare

### Punctaj

| Rezultat | Puncte | Marcare |
|----------|--------|---------|
| Ambele întrebări răspunse corect și cu încredere | 10% | [ ] |
| Ambele corecte dar ezitant | 8% | [ ] |
| Una corectă, una parțial corectă | 6% | [ ] |
| Una corectă, una incorectă | 5% | [ ] |
| Ambele parțial corecte | 4% | [ ] |
| Una parțial corectă, una incorectă | 2% | [ ] |
| Ambele incorecte sau a refuzat să răspundă | 0% | [ ] |

**Scor verificare orală:** _____% (din 10%)

### Calculul notei finale

```
Scor autograder:              ____/90  = ____%
Verificare orală:             ____/10  = ____%
Ajustare calitate cod:        ____     (interval: -5% la +5%)
Ajustare documentare:         ____     (interval: -3% la +3%)
                              ─────────────────
NOTA FINALĂ:                  ____%
```

---

## Note suplimentare

_Folosiți acest spațiu pentru observații, preocupări sau aprecieri:_

___________________________________________________________________________

___________________________________________________________________________

___________________________________________________________________________

___________________________________________________________________________

---

## Escaladare (dacă este necesară)

| Câmp | Detalii |
|------|---------|
| Motiv escaladare | ________________________________________________ |
| Dovezi păstrate | [ ] Capturi ecran [ ] Înregistrare [ ] Note scrise |
| Raportat către | ________________________________________________ |
| Data raportării | ____/____/20____ |

---

## Semnături

| Rol | Semnătură | Data |
|-----|-----------|------|
| **Student** | ________________________________ | ____/____/20____ |
| **Evaluator** | ________________________________ | ____/____/20____ |

> Prin semnare, studentul confirmă că verificarea orală a fost condusă echitabil și că a avut oportunitatea de a demonstra înțelegerea lucrării trimise.

---

## Referință bancă de întrebări

Pentru comoditatea evaluatorului — selectați întrebări din aceste categorii:

### V1: Explică linie specifică
- „Ce face linia __ din scriptul tău?"
- „Explică scopul variabilei `____` din codul tău."
- „De ce ai folosit `set -euo pipefail`?"

### V2: Prezice modificare
- „Ce se întâmplă dacă schimb `VAR='test'` în `VAR=`?"
- „Dacă elimin ghilimelele din jurul `$1`, ce ar putea merge prost?"
- „Ce ar afișa acest script dacă HOME ar fi `/root`?"

### V3: Justifică alegerea de design
- „De ce ai folosit o funcție aici în loc de cod inline?"
- „De ce `mkdir -p` în loc de doar `mkdir`?"
- „Care e avantajul abordării tale față de ____?"

### V4: Modificare live
- „Adaugă o linie care afișează data curentă la început."
- „Modifică scriptul să accepte un al doilea argument."
- „Adaugă gestionare erori dacă directorul nu există."

### V5: Scenariu debug
- „Scriptul eșuează cu 'command not found'. Unde ai căuta?"
- „Acesta nu afișează nimic. Cum l-ai depana?"
- „Variabila e goală când nu ar trebui să fie. De ce?"

---

*Formular versiunea 1.0 | Ianuarie 2025 | ASE București - CSIE*
