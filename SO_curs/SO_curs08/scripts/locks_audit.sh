#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  locks_audit.sh [PATH]

Scop:
  Demonstrație pentru Săptămâna 8:
  - identifică procese care țin deschis un fișier sau un director (I/O resource),
    situație care în practică poate duce la „blocaje” operaționale (ex.: nu poți unmount).

Exemple:
  ./locks_audit.sh /var/log
  ./locks_audit.sh /home/user/proiect

Observație:
  Necesită `lsof` (de obicei pachetul lsof) sau `fuser` (psmisc).
EOF
}

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  usage
  exit 0
fi

echo "=== Audit resurse deschise pentru: $TARGET ==="

if command -v lsof >/dev/null 2>&1; then
  echo
  echo "[INFO] lsof (primele 30 linii):"
  lsof +D "$TARGET" 2>/dev/null | head -n 30 || true
else
  echo "[WARN] lsof nu este instalat. (Ubuntu: sudo apt-get install lsof)" >&2
fi

if command -v fuser >/dev/null 2>&1; then
  echo
  echo "[INFO] fuser:"
  fuser -v "$TARGET" 2>/dev/null || true
else
  echo "[WARN] fuser nu este instalat (psmisc)." >&2
fi

cat <<'NOTES'

Observații didactice:
- În deadlock-ul clasic (Coffman), vorbim despre resurse alocate și așteptate.
- În practică, „resursa” poate fi și un fișier deschis, un socket, un lock de fișier, un mountpoint.
- Instrumentele de observabilitate (`lsof`, `fuser`) sunt esențiale pentru debugging.
NOTES
