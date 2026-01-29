#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  so_diag.sh [-o OUTPUT] [-v]

Scop:
  Colectează un „snapshot” de sistem util în laborator (kernel, CPU, memorie,
  disc, procese). Este intenționat simplu și fără dependențe exotice.

Opțiuni:
  -o  fișier output (default: ./so_diag_YYYYmmdd_HHMMSS.txt)
  -v  verbose (log pe stderr)
EOF
}

OUTPUT=""
VERBOSE=0

while getopts ":o:vh" opt; do
  case "$opt" in
    o) OUTPUT="$OPTARG" ;;
    v) VERBOSE=1 ;;
    h) usage; exit 0 ;;
    :) echo "Eroare: -$OPTARG necesită argument." >&2; usage; exit 2 ;;
    \?) echo "Eroare: opțiune invalidă -$OPTARG" >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

log() { (( VERBOSE )) && printf '[%s] %s\n' "$(date -Is)" "$*" >&2 || true; }

ts="$(date +%Y%m%d_%H%M%S)"
: "${OUTPUT:=./so_diag_${ts}.txt}"

log "Scriu raportul în: $OUTPUT"

{
  echo "=== SO diagnostic report ==="
  echo "Timestamp: $(date -Is)"
  echo

  echo "== Identitate sistem =="
  echo "Hostname: $(hostname)"
  echo "Kernel:   $(uname -srmo 2>/dev/null || uname -a)"
  if [[ -r /etc/os-release ]]; then
    echo "Distribuție: $(. /etc/os-release; echo "${PRETTY_NAME:-unknown}")"
  fi
  echo "Uptime:   $(uptime -p 2>/dev/null || uptime)"
  echo

  echo "== CPU (sumar) =="
  if command -v lscpu >/dev/null 2>&1; then
    lscpu | sed -n '1,20p'
  else
    echo "lscpu nu este disponibil."
  fi
  echo

  echo "== Memorie =="
  if command -v free >/dev/null 2>&1; then
    free -h
  else
    echo "free nu este disponibil."
  fi
  echo

  echo "== Disc (filesystem) =="
  if command -v df >/dev/null 2>&1; then
    df -hT
  fi
  echo

  echo "== Procese: top CPU (estimare) =="
  # Observație: %CPU poate depinde de intervalul de sampling; aici e un snapshot.
  ps -eo pid,ppid,stat,ni,pri,%cpu,%mem,rss,cmd --sort=-%cpu | head -n 15
  echo

  echo "== Procese: top RSS (memorie rezidentă) =="
  ps -eo pid,ppid,stat,ni,pri,%cpu,%mem,rss,cmd --sort=-rss | head -n 15
  echo

  echo "== Observații didactice =="
  cat <<'NOTES'
- Output-ul este un „snapshot”. Pentru scheduling și performanță, măsurarea are nevoie de
  interval (sampling) și de controlul variabilelor.
- Coloana RSS (Resident Set Size) reflectă memoria efectiv rezidentă în RAM, nu „virtual memory”.
- Procesele în stare Z sunt zombie: au terminat execuția, dar părintele nu a făcut încă wait().
NOTES
} > "$OUTPUT"

log "Gata."
