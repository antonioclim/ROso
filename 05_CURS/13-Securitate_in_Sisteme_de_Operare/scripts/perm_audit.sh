#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  perm_audit.sh [ROOT]

Scop (Săptămâna 13): audit minim de permisiuni într-un arbore de directoare.
- găsește fișiere world-writable;
- găsește fișiere cu SUID/SGID;
- găsește directoare world-writable fără sticky bit (risc).

Exemplu:
  ./perm_audit.sh .
  ./perm_audit.sh /tmp

Capcană:
  Nu rulează automat remedieri; doar raportează.
EOF
}

ROOT="${1:-.}"
[[ -d "$ROOT" ]] || { echo "Eroare: ROOT nu este director: $ROOT" >&2; exit 2; }

echo "=== Permission audit: $ROOT ==="
echo

echo "== World-writable files (-perm -0002) (primele 30) =="
find "$ROOT" -xdev -type f -perm -0002 2>/dev/null | head -n 30 || true
echo

echo "== SUID files (-perm -4000) (primele 30) =="
find "$ROOT" -xdev -type f -perm -4000 2>/dev/null | head -n 30 || true
echo

echo "== SGID files (-perm -2000) (primele 30) =="
find "$ROOT" -xdev -type f -perm -2000 2>/dev/null | head -n 30 || true
echo

echo "== World-writable directories without sticky bit (rwxrwxrwx but no +t) =="
# sticky bit (1000) este important în directoare partajate (ex.: /tmp)
find "$ROOT" -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | head -n 30 || true
echo

cat <<'NOTES'
Interpretare didactică:
- DAC (Discretionary Access Control) în Unix: permisiuni rwx pentru user/group/others.
- SUID/SGID schimbă identitatea efectivă la execuție; utile, dar sensibile.
- Sticky bit pe directoare partajate împiedică ștergerea fișierelor altor useri (ex.: /tmp).
NOTES