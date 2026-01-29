#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  trace_cmd.sh [-o OUT] [-e SYSCALLS] [--] <comanda> [args...]

Scop:
  Demonstrație pentru Săptămâna 2 (system calls):
  - rulează o comandă sub strace;
  - salvează log-ul și opțional filtrează syscalls.

Exemple:
  ./trace_cmd.sh -- ls -la
  ./trace_cmd.sh -e openat,read,write,close -- cat /etc/hosts
  ./trace_cmd.sh -o trace_ls.txt -- ls

Observație:
  Necesită `strace`. În Ubuntu: sudo apt-get install strace
EOF
}

OUT=""
SYSCALLS=""

# parse până la --
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) OUT="${2:-}"; shift 2 ;;
    -e) SYSCALLS="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

if [[ $# -lt 1 ]]; then
  echo "Eroare: lipsește comanda de urmărit." >&2
  usage
  exit 2
fi

command -v strace >/dev/null 2>&1 || { echo "Eroare: strace nu este instalat." >&2; exit 1; }

ts="$(date +%Y%m%d_%H%M%S)"
: "${OUT:=./strace_${ts}.log}"

# construire opțiuni
opts=(-f -tt -T -o "$OUT")
if [[ -n "$SYSCALLS" ]]; then
  opts+=(-e "trace=${SYSCALLS}")
fi

echo "[INFO] Output: $OUT" >&2
echo "[INFO] Command: $*" >&2

strace "${opts[@]}" -- "$@"

echo "[INFO] Rezumat statistic (strace -c):" >&2
# `-c` rulează comanda din nou; în laborator e util să vezi ambele perspective.
strace -c -- "$@" 2>&1 | sed 's/^/[STATS] /'
