# Teme - Seminar 4: Text Processing (grep/sed/awk)

> **⚠️ STRUCTURĂ SPECIALĂ:** Acest seminar are structură diferită față de SEM01-03, SEM05.

---

## Despre Structura Temelor

Seminarul 04 (Text Processing) folosește o structură extinsă datorită complexității și volumului de material:

| Structură Standard (SEM01-03, SEM05) | Structură SEM04 |
|--------------------------------------|-----------------|
| `S0X_01_TEMA.md` | `S04_01_TEMA_OBLIGATORIE.md` |
| `S0X_02_creeaza_tema.sh` | `S04_02_TEMA_BONUS.md` |
| `S0X_03_RUBRICA_EVALUARE.md` | `S04_03_RUBRICA_EVALUARE.md` |
| - | `S04_04_TEMPLATE_SUBMISIE.md` |

---

## Motivația Structurii

### 1. Separare Obligatoriu / Bonus

Seminarul de **Text Processing** este unul dintre cele mai dense din curs, acoperind:
- Expresii regulate (BRE, ERE)
- `grep` cu toate opțiunile
- `sed` pentru modificări stream
- `awk` pentru procesare avansată

Pentru a nu supraîncărca studenții, temele sunt separate în:
- **Tema Obligatorie** (100%) - cerințe de bază
- **Tema Bonus** (până la +20%) - exerciții avansate opționale

### 2. Template de Submisie

Datorită complexității (4 scripturi + output-uri multiple), s-a adăugat un document separat cu:
- Structura exactă a arhivei de predare
- Checklist înainte de predare
- Template README pentru documentare
- Comenzi utile pentru verificare

---

## Conținutul Fișierelor

| Fișier | Conținut | Audiență |
|--------|----------|----------|
| `S04_00_README.md` | Acest document explicativ | Instructori |
| `S04_01_TEMA_OBLIGATORIE.md` | 4 exerciții obligatorii (100%) | Studenți |
| `S04_02_TEMA_BONUS.md` | 5 exerciții bonus (+20p max) | Studenți |
| `S04_03_RUBRICA_EVALUARE.md` | Criterii detaliate evaluare | Instructori |
| `S04_04_TEMPLATE_SUBMISIE.md` | Ghid predare arhivă | Studenți |

---

## Timeline Recomandat

| Săptămâna | Activitate |
|-----------|------------|
| 1 | Rezolvare Tema Obligatorie |
| 2 | Predare Tema Obligatorie + Start Bonus (opțional) |
| 3 | Predare Tema Bonus (opțional) |

---

## Distribuția Punctajelor

```
Tema Obligatorie (100%)
├── Ex1: Validare și Extragere Date    25p
├── Ex2: Procesare Log-uri             25p
├── Ex3: Transformare Date             25p
└── Ex4: Pipeline Combinat             25p

Tema Bonus (max +20p)
├── B1: Log Aggregator Multi-Format    8p
├── B2: Diff și Patch cu Regex         6p
├── B3: Generator Rapoarte HTML        6p
├── B4: Mini Grep cu Highlighting      5p
└── B5: Config File Linter             5p
    (Maximum cumulat: 20p)
```

---

## Comparație cu Alte Seminarii

| Aspect | SEM01-03, SEM05 | SEM04 |
|--------|-----------------|-------|
| Număr exerciții obligatorii | 4-5 | 4 |
| Exerciții bonus | Integrate în temă | Fișier separat |
| Template predare | În TEMA.md | Fișier separat |
| Script generare | Da | Nu (complexitate prea mare) |
| Complexitate | Medie | Ridicată |

---

## Note pentru Instructori

1. **Evaluare diferențiată**: Studenții pot preda doar tema obligatorie pentru nota de trecere
2. **Deadline extins bonus**: Tema bonus are deadline cu o săptămână mai târziu
3. **Verificare plagiat**: Atenție specială la exercițiile bonus (cod mai complex)
4. **Suport**: Exercițiile folosesc fișierele din `../resurse/sample_data/`

---

## Resurse Asociate

- `../docs/S04_*` - Materiale documentație
- `../prezentari/S04_*` - Slide-uri prezentare
- `../resurse/sample_data/` - Fișiere de test pentru teme
- `../scripts/` - Exemple și soluții

---

*Material pentru cursul de Sisteme de Operare | ASE București - CSIE*
