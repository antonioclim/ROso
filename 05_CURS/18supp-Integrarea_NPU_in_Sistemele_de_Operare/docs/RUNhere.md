# 📁 Documentație Curs 18supp — Integrarea NPU

> **Locație:** `05_LECTURES/18supp-Integrarea_NPU_in_Sistemele_de_Operare/docs/`  
> **Temă:** Calcul heterogen, scheduling NPU

## Conținut

### Simulatoare HTML Interactive

Consultați fișierele `.html` din acest director pentru simulări interactive.

### Evaluare Formativă (YAML)

| Fișier | Descriere |
|--------|-----------|
| `C18_05_EVALUARE_FORMATIVA.yaml` | Quiz de evaluare formativă (distribuit Bloom) |

### Documentație Pedagogică

| Fișier | Scop |
|--------|------|
| `C18_01_PLAN_CURS.md` | Obiective de învățare și timing sesiune |
| `C18_02_CONCEPT_MAP.md` | Relații vizuale între concepte |
| `C18_03_INTREBARI_DISCUTIE.md` | Întrebări pentru discuții în grup |
| `C18_04_GHID_STUDIU.md` | Ghid de studiu individual |

---

## Cum să Utilizezi

### Simulatoare HTML Interactive

Deschide orice fișier `.html` direct în browser:

```bash
# Linux/WSL
xdg-open 01ex1_-_Dual_Mode_Simulator.html

# Sau dublu-click pe fișier în managerul de fișiere
```

**Caracteristici:**
- Autoconținute (nu necesită server)
- Controale și vizualizări interactive
- Moduri de execuție pas cu pas
- Butoane de resetare

### Quiz Formativ YAML

Rulează quiz-ul folosind runner-ul din orice folder SEM:

```bash
cd ../../SEM01/formative/
python3 quiz_runner.py --file ../../05_LECTURES/.../docs/C18_05_EVALUARE_FORMATIVA.yaml
```

**Sau revizuire manuală:**
1. Deschide fișierul `.yaml` în orice editor text
2. Răspunde mental la întrebări
3. Verifică câmpul `corect` (indexat de la 0) pentru răspunsuri
4. Citește `explicatie` pentru înțelegere

**Structura quiz:**
- ~12 întrebări per curs
- Distribuție pe taxonomia Bloom (remember, understand, apply, analyse)
- Timp estimat: 15 minute

### Documente Pedagogice

| Document | Când să-l folosești |
|----------|---------------------|
| `*_PLAN_CURS.md` | Înainte de curs — înțelege obiectivele |
| `*_CONCEPT_MAP.md` | În timpul studiului — vezi relațiile |
| `*_INTREBARI_DISCUTIE.md` | La seminar — peer instruction |
| `*_GHID_STUDIU.md` | După curs — recapitulare |

---

## Resurse Conexe

- **Părinte:** [`../README.md`](../README.md) — Prezentare generală a unității
- **Scripturi:** [`../scripts/`](../scripts/) — Scripturi demonstrative
- **Diagrame:** [`../diagrams/`](../diagrams/) — Diagrame conceptuale

---

*Cursul 18 (suplimentar) din 18*

*Ultima actualizare: Februarie 2026*
