#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Orchestrare simplă pentru rularea benchmark-ului Threads vs Processes.
# Util pentru laborator: repetări și colectare output.

usage() {
  cat <<'EOF'
Utilizare:
  run_threads_bench.sh [-r REPETARI] [--workers W] [--n N]

Exemplu:
  ./run_threads_bench.sh -r 3 --workers 4 --n 20000
EOF
}

REPS=3
WORKERS=4
N=20000

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r) REPS="${2:-}"; shift 2 ;;
    --workers) WORKERS="${2:-}"; shift 2 ;;
    --n) N="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument necunoscut: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/threads_vs_processes.py"

echo "=== Run benchmark: reps=$REPS workers=$WORKERS n=$N ==="
for i in $(seq 1 "$REPS"); do
  echo
  echo "--- Run $i/$REPS ---"
  "$PY" --workers "$WORKERS" --n "$N"
done
