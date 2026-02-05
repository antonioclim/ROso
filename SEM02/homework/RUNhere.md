# 📁 Temă — materiale de atribuire

> **Locație:** `SEM02/homework/`  
> **Scop:** specificația temei, scripturi de generare, criterii de evaluare

## Conținut

| Fișier | Scop |
|------|---------|
| `S02_01_HOMEWORK.md` | specificația temei |
| `S02_02_create_homework.sh` | script de generare a temei |
| `S02_03_EVALUATION_RUBRIC.md` | criterii de notare |
| `S02_04_ORAL_VERIFICATION_LOG.md` | listă de verificare pentru interviu |
| `solutions/` | soluții de referință (cadre didactice) |
| `OLD_HW/` | arhivă cu teme anterioare |

---

## S02_02_create_homework.sh

**Scop:** generează teme personalizate pentru studenți.

### Utilizare

```bash
./S02_02_create_homework.sh [options]

Options:
  --student-id ID    Generate for specific student
  --batch FILE       Generate from student list CSV
  --seed N           Random seed for reproducibility
  --output DIR       Output directory
  --template FILE    Custom assignment template
```

### Exemple

```bash
# Generează pentru un singur student
./S02_02_create_homework.sh --student-id ABC123

# Generare în lot
./S02_02_create_homework.sh --batch students.csv --output assignments/

# Generare reproductibilă
./S02_02_create_homework.sh --batch students.csv --seed 42
```

### Cum funcționează personalizarea

Scriptul generează valori unice pentru:
- nume de fișiere și căi
- valori de date (numere, șiruri)
- output-uri așteptate

Astfel se reduce copierea directă între studenți.

---

## Reguli de predare

1. Rezolvă toate exercițiile din `S02_01_HOMEWORK.md`
2. Validează: folosește `../../03_GUIDES/check_my_submission.sh`
3. Înregistrează: folosește `../../02_INIT_HOMEWORKS/record_homework_EN.sh`
4. Predă pe platforma desemnată

---

## Notare

Vezi `S02_03_EVALUATION_RUBRIC.md` pentru:
- distribuția punctelor pe exerciții
- cerințe de stil
- așteptări privind documentarea
- criterii pentru punctaj parțial

---

*Vezi și: [`../docs/`](../docs/) pentru materiale de studiu*  
*Vezi și: `../../03_GUIDES/` pentru ghidul de predare*

*Ultima actualizare: ianuarie 2026*
