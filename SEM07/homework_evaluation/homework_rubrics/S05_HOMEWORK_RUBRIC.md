# Rubrică de evaluare — teme S05

> **Sisteme de Operare** | ASE Bucharest - CSIE  
> Seminar 05: scripting avansat și bune practici

---

## Prezentarea temelor

| ID | Subiect | Durată | Dificultate |
|----|-------|----------|------------|
| S05a | Recapitulare prerequisite‑uri | 30 min | ⭐ |
| S05b | Funcții avansate | 50 min | ⭐⭐⭐ |
| S05c | Arrays în Bash | 55 min | ⭐⭐⭐ |
| S05d | Robusteză în scripting | 60 min | ⭐⭐⭐⭐ |
| S05e | Trap și tratarea erorilor | 50 min | ⭐⭐⭐ |
| S05f | Logging și depanare | 45 min | ⭐⭐ |

---

## S05a - Recapitulare prerequisite‑uri (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Comenzi de bază | 3.0 | cd, ls, cat, grep, etc. |
| Variabile | 2.0 | setare, export, quoting |
| Redirecționare | 2.0 | >, >>, 2>, pipes |
| Bucle | 2.0 | for, while |
| Stil | 1.0 | organizare și lizibilitate |

---

## S05b - Funcții avansate (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Definire funcții | 2.0 | Sintaxă corectă |
| Parametri | 2.5 | $1, $2, $@, $# |
| Return codes | 2.0 | return, $? |
| Scope variabile | 2.0 | local vs global |
| Utilizare practică | 1.5 | Refactorizare cu funcții |

### Pattern așteptat
```bash
myfunc() {
    local param="$1"
    echo "Processing: $param"
    return 0
}
```

---

## S05c - Arrays în Bash (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Declarare | 2.0 | arr=(), declare -a |
| Indexare | 2.5 | ${arr[0]}, ${arr[@]} |
| Iterare | 2.0 | for element in "${arr[@]}" |
| Modificare | 2.0 | append, remove, slice |
| Arrays asociative | 1.5 | declare -A, chei/valori |

### Pattern așteptat
```bash
declare -a files=("a.txt" "b.txt" "c.txt")
for f in "${files[@]}"; do
    echo "$f"
done

declare -A map
map["key"]="value"
```

---

## S05d - Robusteză în scripting (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Strict mode | 3.0 | set -euo pipefail |
| Validare input | 2.5 | Verificarea argumentelor |
| Tratarea erorilor | 2.0 | Mesaje clare, exit codes |
| Funcții utilitare | 1.5 | log, die, usage |
| Testare | 1.0 | Cazuri de test |

### Pattern așteptat
```bash
set -euo pipefail

usage() {
    echo "Usage: $0 <input_file>"
    exit 1
}

[[ $# -eq 1 ]] || usage
```

---

## S05e - Trap și tratarea erorilor (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| trap de bază | 2.5 | trap 'handler' EXIT |
| Semnale | 2.5 | INT, TERM, ERR |
| Cleanup | 2.0 | Eliminarea fișierelor temporare |
| Debug hooks | 1.5 | DEBUG trap |
| Utilizare practică | 1.5 | Script robust cu cleanup |

### Pattern așteptat
```bash
cleanup() {
    rm -f "$tmpfile"
}

trap cleanup EXIT INT TERM
```

---

## S05f - Logging și depanare (10 puncte)

| Criteriu | Puncte | Cerințe |
|-----------|--------|--------------|
| Logging de bază | 2.5 | stdout/stderr adecvat |
| Niveluri log | 2.5 | INFO, WARN, ERROR |
| Timestamp‑uri | 2.0 | Date și timp în log |
| Depanare | 2.0 | set -x, PS4 |
| Rotirea logurilor | 1.0 | logrotate sau implementare simplă |

### Pattern așteptat
```bash
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >&2
}

log INFO "Starting script"
log ERROR "Something failed"
```

---

*De Revolvix pentru disciplina OPERATING SYSTEMS | licență restricționată 2017-2030*
