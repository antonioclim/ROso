# Ghid de scripting Bash (pentru disciplina Sisteme de Operare)

Acest ghid fixează un set de practici recomandate pentru scripturile Bash folosite în laborator: **stabilitate**, **predictibilitate** și **siguranță**. În context OS, Bash este util în special pentru *orchestrare* (lanțuri de comenzi, automatizări, integrarea utilitarelor), în timp ce Python este adesea mai potrivit pentru logică complexă și parsare.

## 1. Shebang, mod strict, convenții

### Shebang
Folosește explicit Bash (pentru portabilitate între distribuții):
```bash
#!/usr/bin/env bash
```

### Mod strict (recomandat)
```bash
set -euo pipefail
IFS=$'\n\t'
```

- `-e` oprește scriptul la prima comandă care eșuează (atenție la excepții controlate);
- `-u` tratează variabilele nedefinite ca erori;
- `pipefail` propagă erori din pipeline-uri.

### Mesaje și logging
- output-ul „normal” → `stdout`
- mesaje de debugging / erori → `stderr`

Exemplu:
```bash
log() { printf '%s\n' "$*" >&2; }
die() { log "Eroare: $*"; exit 1; }
```

## 2. Quoting: regula de aur

În Bash, majoritatea bug-urilor încep de la lipsa ghilimelelor.

Greșit:
```bash
for f in *.txt; do
  echo $f
done
```

Corect:
```bash
shopt -s nullglob  # evită erori când nu există fișiere
for f in ./*.txt; do
  [[ -f "$f" ]] || continue
  printf '%s\n' "$f"
done
```

De reținut:
- `"$var"` aproape întotdeauna, nu `$var`
- `"$@"` pentru a păstra argumentele ca listă

## 3. Argumente și opțiuni

### Parametri poziționali
- `$0` numele scriptului
- `$1`, `$2`, ... argumente
- `$#` număr argumente
- `"$@"` lista argumentelor

### `getopts` (opțiuni scurte)
Pattern recomandat:
```bash
readonly SCRIPT_NAME="${0##*/}"
usage() { cat <<EOF >&2
Utilizare: $SCRIPT_NAME [-n] [-o OUTPUT] ARG1
EOF
  exit 2
}

OUTPUT=""
DRY_RUN=0

while getopts ":no:" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    o) OUTPUT="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))
[[ $# -ge 1 ]] || usage  # validare argument obligatoriu
```

## 4. Funcții și structuri de control

Preferă funcții mici, ușor de testat:
```bash
ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Lipsește comanda: $1"
}
```

Structuri uzuale:
- `if [[ ... ]]`
- `case "$var" in ... esac`
- `for`, `while read -r ...`

## 5. Fișiere temporare și cleanup

În OS, scripturile creează frecvent fișiere temporare. Folosește `mktemp` + `trap`:

```bash
readonly TMP_DIR="$(mktemp -d)" || exit 1
cleanup() { [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM
```

## 6. Error handling și coduri de ieșire

Convenție practică:
- `0` = succes
- `1` = eroare generică
- `2` = utilizare greșită (CLI)
- `3+` = coduri specifice aplicației

## 7. Calitate: ShellCheck și stil

Rulează:
```bash
shellcheck -x path/to/script.sh
```

Sugestii:
- documentează opțiunile în `usage()`;
- evită „magic values”;
- preferă `printf` în loc de `echo` pentru output predictibil.

## 8. Exemple tipice (legate de OS)

### 8.1. Audit de procese
```bash
ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 15
```

### 8.2. Inventariere rapidă a sistemului
```bash
uname -a
lsb_release -a 2>/dev/null || cat /etc/os-release
free -h
df -h
```

### 8.3. Pipeline pentru log-uri
```bash
journalctl -u ssh --since "today" | grep -E "Failed password|Accepted" | tail -n 50
```

Data ediției: **27 ianuarie 2026**
