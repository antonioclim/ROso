#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Săptămâna 14): detectare virtualizare / container.
# În practică, astfel de detectări sunt utile pentru: tuning, observabilitate, licensing, debugging.

echo "=== Virtualization / container detection ==="
echo "Timestamp: $(date -Is)"
echo

if command -v systemd-detect-virt >/dev/null 2>&1; then
  echo "== systemd-detect-virt =="
  systemd-detect-virt || true
  echo
else
  echo "[INFO] systemd-detect-virt nu este disponibil." >&2
fi

echo "== /proc/cpuinfo: hypervisor flag (dacă există) =="
grep -m1 -i 'flags' /proc/cpuinfo | grep -o 'hypervisor' || echo "(nu apare explicit)"
echo

echo "== cgroup info (PID 1) =="
if [[ -r /proc/1/cgroup ]]; then
  cat /proc/1/cgroup
else
  echo "Nu pot citi /proc/1/cgroup."
fi
echo

echo "== environ hints (container) =="
if [[ -f /.dockerenv ]]; then
  echo "Fișier /.dockerenv prezent (indicator Docker)."
else
  echo "Nu găsesc /.dockerenv."
fi
echo

cat <<'NOTES'
Observații didactice:
- Virtualizare (VM) și containerele rezolvă probleme diferite:
  VM: izolare hardware-ish prin VMM/hypervisor; container: izolare la nivel de kernel (namespaces/cgroups).
- Detectarea este euristică și depinde de platformă.
NOTES