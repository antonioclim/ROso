# Soluții Model - Seminar 07-08

> **⚠️ DOCUMENT CONFIDENȚIAL - DOAR PENTRU INSTRUCTORI**

---

## Conținut

| Fișier | Exercițiu | Descriere |
|--------|-----------|-----------|
| `ex1_validator.sh` | Ex1 (25 pct) | Validare email, IP, telefon |
| `ex2_log_analyzer.sh` | Ex2 (25 pct) | Analiză log-uri, severitate, auth |
| `ex3_data_transform.sh` | Ex3 (25 pct) | modificare CSV, statistici dept |
| `ex4_sales_report.sh` | Ex4 (25 pct) | Raport vânzări, anomalii |

---

## Testare Soluții

```bash
# Din directorul solutii/
cd teme/solutii

# Fă scripturile executabile
chmod +x *.sh

# Testează fiecare exercițiu
./ex1_validator.sh ../../resurse/sample_data/contacts.txt
./ex2_log_analyzer.sh ../../resurse/sample_data/server.log
./ex3_data_transform.sh ../../resurse/sample_data/employees.csv
./ex4_sales_report.sh ../../resurse/sample_data/sales.csv
```

---

## Note pentru Evaluare

### Exercițiul 1
- **Regex Email**: Acceptabil pattern simplu, bonus pentru validare strictă
- **IP Validation**: Suficient pattern `[0-9.]+`, bonus pentru validare 0-255
- **Telefon**: Trebuie să accepte minim 2 formate diferite
- Verifică întotdeauna rezultatul înainte de a continua

### Exercițiul 2
- **Severitate**: AWK cu array-uri asociative e soluția optimă
- **Auth Failed**: Grep + extragere e acceptabil, AWK e bonus
- **Statistici**: Timestamp parsing poate fi în jur de
- Verifică întotdeauna rezultatul înainte de a continua

### Exercițiul 3
- **Tabel**: `printf` cu width e suficient, box chars e bonus
- **Statistici**: Valorile trebuie să fie corecte matematic
- **Update CSV**: Toate cele 3 modificări necesare

### Exercițiul 4
- **Top N**: Sortare + head e acceptabil, AWK e elegant
- **Anomalii**: Threshold fix e OK, stddev e bonus
- **Export**: Fișier creat cu conținut corect
- Testează mai întâi cu date simple

---

## Comparație Anti-Plagiat

Verifică următoarele elemente între submisii:

1. **Structură identică**: Aceeași ordine funcții, aceleași variabile
2. **Comentarii similare**: Copy-paste evident
3. **Erori identice**: Aceleași bug-uri în locuri diferite
4. **Formatting**: Spații, indentare, stil identic

**Instrumente recomandate:**
```bash
# Diff simplu
diff -y student1.sh student2.sh | head -50

# Similarity check
diff <(cat student1.sh | grep -v '^#' | grep -v '^$') \
     <(cat student2.sh | grep -v '^#' | grep -v '^$')
```

---

## Puncte Cheie de Evaluat

1. **Funcționează corect pe datele de test?**
2. **Gestionează edge cases?** (fișier gol, input invalid)
3. **Cod organizat și comentat?**
4. **Folosește uneltele potrivite?** (nu reinventează roata)
5. **Output profesional?** (formatare, culori, structură)

---

*Soluții oficiale - Seminar 07-08: Text Processing*
