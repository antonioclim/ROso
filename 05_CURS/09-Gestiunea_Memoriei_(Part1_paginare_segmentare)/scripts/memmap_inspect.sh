#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  memmap_inspect.sh <PID>

Scop (Săptămâna 9): observarea spațiului de adrese și a mapărilor de memorie.
- `/proc/<PID>/maps` arată segmentele mapate (text, heap, stack, mmap, shared libs).
- `pmap -x` (dacă există) oferă sumar pe segmente.

Exemplu:
  # pornește un proces de test:
  python3 -c 'import time; a=[0]*10_000_00; time.sleep(60)' &
  PID=$!
  ./memmap_inspect.sh $PID
EOF
}

PID="${1:-}"
[[ -n "$PID" ]] || { usage; exit 2; }
[[ -r "/proc/$PID/maps" ]] || { echo "Eroare: nu pot citi /proc/$PID/maps (PID valid?)." >&2; exit 2; }

echo "=== MemMap inspect: PID=$PID ==="
echo

echo "== /proc/$PID/status (memorie, sumar) =="
grep -E '^(Name|State|VmSize|VmRSS|VmData|VmStk|VmExe|VmLib|Threads):' "/proc/$PID/status" || true
echo

echo "== /proc/$PID/maps (primele 40 linii) =="
sed -n '1,40p' "/proc/$PID/maps"
echo

if command -v pmap >/dev/null 2>&1; then
  echo "== pmap -x (sumar) =="
  pmap -x "$PID" | sed -n '1,25p'
  echo
else
  echo "[INFO] pmap nu este disponibil. (Ubuntu: sudo apt-get install procps)" >&2
fi

cat <<'NOTES'
Observații didactice:
- `VmSize` = virtual memory total mapată; nu înseamnă RAM consumat.
- `VmRSS` = memorie rezidentă (aprox. RAM efectiv folosit).
- `/proc/<PID>/maps` reflectă segmentarea logică a address space-ului și mapările (inclusiv shared libs).
NOTES