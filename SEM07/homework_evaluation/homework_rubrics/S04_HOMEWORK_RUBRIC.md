# Rubrică de evaluare — teme S04

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 04: procesare de text și expresii regulate

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S04b | Expresii regulate | 50 min | ⭐⭐⭐ |
| S04c | Familia grep | 45 min | ⭐⭐ |
| S04d | Editorul de flux sed | 50 min | ⭐⭐⭐ |
| S04e | Procesare cu awk | 55 min | ⭐⭐⭐ |
| S04f | Editoare de text | 40 min | ⭐⭐ |

---

## S04b - Expresii regulate (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Pattern‑uri de bază | 2.5 | ., *, +, ?, ^ , $ |
| Clase de caractere | 2.0 | [...], [^...], \d, \w |
| Cuantificatori | 2.0 | {n}, {n,}, {n,m} |
| Grupuri/alternare | 2.0 | (...), \| |
| Potrivire practică | 1.5 | pattern‑uri pentru e‑mail, IP, dată |

### Pattern‑uri așteptate
```bash
# Email (simplified)
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# IP address
[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}

# Date YYYY-MM-DD
[0-9]{4}-[0-9]{2}-[0-9]{2}
```

---

## S04c - Familia grep (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| grep de bază | 2.0 | Potrivire pe pattern |
| Opțiuni grep | 2.5 | -i, -v, -c, -n, -l, -r |
| grep extins | 2.0 | grep -E sau egrep |
| Șiruri fixe | 1.5 | grep -F sau fgrep |
| Opțiuni de context | 2.0 | -A, -B, -C |

### Comenzi așteptate
```bash
grep -rn "error" /var/log/
grep -E "warn|error|fatal" log.txt
grep -c "pattern" file.txt
grep -v "^#" config.conf | grep -v "^$"
```

---

## S04d - Editorul de flux sed (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Substituție | 3.0 | s/old/new/g, flag‑uri |
| Adrese | 2.0 | Numere de linie, pattern‑uri |
| Ștergere/inserare | 2.0 | comenzi d, i, a |
| Editare in‑place | 1.5 | opțiunea -i |
| Comenzi multiple | 1.5 | -e sau ; sau fișier‑script |

### Comenzi așteptate
```bash
sed 's/old/new/g' file.txt
sed -n '10,20p' file.txt
sed '/pattern/d' file.txt
sed -i.bak 's/foo/bar/g' file.txt
sed '/^#/d; /^$/d' config.conf
```

---

## S04e - Procesare cu awk (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Câmpuri și înregistrări | 2.5 | $1, $2, NF, NR |
| Pattern‑uri și acțiuni | 2.0 | /pattern/ { action } |
| Variabile built‑in | 2.0 | FS, OFS, RS, ORS |
| Structuri de control | 2.0 | if, for, while |
| Funcții | 1.5 | length, substr, split |

### Comenzi așteptate
```bash
awk '{print $1, $3}' file.txt
awk -F: '{print $1}' /etc/passwd
awk 'NR > 1 {sum += $2} END {print sum}' data.txt
awk '/error/ {count++} END {print count}' log.txt
```

---

## S04f - Editoare de text (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Bazele Nano | 2.0 | Deschidere, editare, salvare, ieșire |
| Modurile Vim | 3.0 | Normal, insert, command |
| Navigare în Vim | 2.5 | h,j,k,l, w,b,e, gg,G |
| Editare în Vim | 2.5 | i,a,o,d,y,p,:w,:q |

### Comenzi Vim așteptate
```vim
:wq             " Save and quit
:q!             " Quit without saving
dd              " Delete line
yy              " Yank (copy) line
p               " Paste
/pattern        " Search
:%s/old/new/g   " Replace all
```

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
