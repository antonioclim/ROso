#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo pentru Săptămâna 3: procese, PID/PPID, semnale, grupuri de procese.

cleanup_pids=()

cleanup() {
  for pid in "${cleanup_pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT

echo "=== Demo procese: PID/PPID, ps --forest, semnale ==="
echo "[INFO] PID script: $$"
echo

echo "[INFO] Pornesc 3 procese child (sleep 60) în background..."
sleep 60 & cleanup_pids+=("$!")
sleep 60 & cleanup_pids+=("$!")
sleep 60 & cleanup_pids+=("$!")

echo "[INFO] PID-uri create: ${cleanup_pids[*]}"
echo

echo "== ps (forest) =="
ps -o pid,ppid,stat,cmd --forest -p "$$","${cleanup_pids[0]}","${cleanup_pids[1]}","${cleanup_pids[2]}" || true
echo

if command -v pstree >/dev/null 2>&1; then
  echo "== pstree (dacă este disponibil) =="
  pstree -p "$$" || true
  echo
fi

echo "== Semnale: SIGTERM vs SIGKILL =="
echo "[INFO] Trimit SIGTERM către primul child (${cleanup_pids[0]})."
kill -TERM "${cleanup_pids[0]}" 2>/dev/null || true
sleep 0.2
ps -o pid,ppid,stat,cmd -p "${cleanup_pids[0]}" || echo "[OK] Procesul a terminat (SIGTERM)."
echo

echo "[INFO] Trimit SIGKILL către al doilea child (${cleanup_pids[1]})."
kill -KILL "${cleanup_pids[1]}" 2>/dev/null || true
sleep 0.2
ps -o pid,ppid,stat,cmd -p "${cleanup_pids[1]}" || echo "[OK] Procesul a terminat (SIGKILL)."
echo

echo "== Observații didactice =="
cat <<'NOTES'
- Un proces poate ignora SIGTERM (sau poate face cleanup), dar nu poate ignora SIGKILL.
- Dacă un părinte nu apelează wait(), child-ul terminat rămâne temporar în stare Z (zombie).
- În laborator, folosește `ps -eo pid,ppid,stat,cmd --forest` ca să vizualizezi ierarhii.
NOTES