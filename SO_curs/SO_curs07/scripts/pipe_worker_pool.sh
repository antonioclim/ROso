#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Săptămâna 7): "worker pool" cu pipeline + xargs -P.
# Legătură cu conceptul producer/consumer: un producer generează tasks, un pool de consumatori le procesează.

usage() {
  cat <<'EOF'
Utilizare:
  pipe_worker_pool.sh [-p PARALELISM] [-n TASKS]

Exemplu:
  ./pipe_worker_pool.sh -p 4 -n 20
EOF
}

P=4
N=20
while getopts ":p:n:h" opt; do
  case "$opt" in
    p) P="$OPTARG" ;;
    n) N="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Eroare: -$OPTARG necesită argument." >&2; usage; exit 2 ;;
    \?) echo "Eroare: opțiune invalidă -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

echo "=== Worker pool (xargs -P) ==="
echo "[INFO] tasks=$N, parallelism=$P"
echo

# Producer: generează numere 1..N
seq 1 "$N" \
  | xargs -n 1 -P "$P" bash -c 'echo "[worker $$] processing item=$1"; sleep 0.1' _

echo
echo "Observație didactică:"
echo "- `xargs -P` oferă un parallelism controlat: similar conceptual cu un pool de threads/procese."
echo "- Într-un OS, blocking vs busy-wait contează: aici, worker-ii dorm (sleep), nu consumă CPU."
