#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo pentru Săptămâna 4: efectul priorităților "nice" asupra scheduling-ului.
# Folosește două procese CPU-bound identice și setează niveluri diferite de nice.

usage() {
  cat <<'EOF'
Utilizare:
  nice_demo.sh [--seconds S]

Exemplu:
  ./nice_demo.sh --seconds 5

Observații:
- `nice` pozitiv (ex: 10, 15) este permis unui user obișnuit.
- `nice` negativ necesită privilegii.
- Pentru demonstrație mai clară, se recomandă pinning pe un singur CPU cu `taskset` (dacă există).
EOF
}

SECONDS=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds) SECONDS="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument necunoscut: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOG="$SCRIPT_DIR/cpu_hog.py"

if [[ ! -x "$HOG" ]]; then
  echo "Eroare: nu găsesc cpu_hog.py executabil în $SCRIPT_DIR" >&2
  exit 1
fi

run_hog() {
  local nice_level="$1"
  local label="$2"

  if command -v taskset >/dev/null 2>&1; then
    # pin pe CPU0: reduce variația din migrarea între core-uri
    nice -n "$nice_level" taskset -c 0 "$HOG" --seconds "$SECONDS" \
      1>"/tmp/hog_${label}.out" 2>"/tmp/hog_${label}.err" &
  else
    nice -n "$nice_level" "$HOG" --seconds "$SECONDS" \
      1>"/tmp/hog_${label}.out" 2>"/tmp/hog_${label}.err" &
  fi
  echo $!
}

echo "=== Demo nice ==="
echo "[INFO] Durată per proces: ${SECONDS}s"
echo

pid_a="$(run_hog 0 "A_nice0")"
pid_b="$(run_hog 10 "B_nice10")"

echo "[INFO] Procese pornite:"
echo "  A (nice=0)  PID=$pid_a"
echo "  B (nice=10) PID=$pid_b"
echo

echo "[INFO] Snapshot ps (ni/pri):"
ps -o pid,ni,pri,stat,cmd -p "$pid_a","$pid_b" || true
echo

wait "$pid_a"
wait "$pid_b"

echo "=== Output A (nice=0) ==="
cat "/tmp/hog_A_nice0.out"
echo
echo "=== Output B (nice=10) ==="
cat "/tmp/hog_B_nice10.out"
echo

cat <<'NOTES'

Observații didactice:
- În Linux, `nice` controlează (în linii mari) „cât de politicos” este un proces: cu cât valoarea e mai mare,
  cu atât procesul primește mai puțin CPU atunci când există competiție.
- Rezultatele pot varia în funcție de: numărul de core-uri, încărcarea sistemului, governors CPU.
- Pentru un experiment mai curat: închide aplicații grele și rulează de câteva ori.
NOTES