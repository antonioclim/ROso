#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  backup_with_lock.sh -s SOURCE_DIR -d DEST_DIR [-n ROTATIONS] [--dry-run]

Scop (Săptămâna 6: sincronizare / race conditions):
- demonstrează un „lock” practic ( hookup între teorie și viața reală):
  dacă scriptul este lansat simultan (manual sau din cron), rotațiile pot fi corupte.
- folosim `flock` ca mecanism de mutual exclusion.

Exemple:
  ./backup_with_lock.sh -s ~/proiect -d ~/backups -n 5
  ./backup_with_lock.sh -s ~/proiect -d ~/backups --dry-run
EOF
}

SOURCE=""
DEST=""
ROT=7
DRYRUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s) SOURCE="${2:-}"; shift 2 ;;
    -d) DEST="${2:-}"; shift 2 ;;
    -n) ROT="${2:-}"; shift 2 ;;
    --dry-run) DRYRUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument necunoscut: $1" >&2; usage; exit 2 ;;
  esac
done

[[ -n "$SOURCE" && -n "$DEST" ]] || { echo "Eroare: -s și -d sunt obligatorii." >&2; usage; exit 2; }
[[ -d "$SOURCE" ]] || { echo "Eroare: SOURCE nu este director: $SOURCE" >&2; exit 2; }
mkdir -p -- "$DEST"

run() { if (( DRYRUN )); then echo "+ $*"; else "$@"; fi; }

LOCKFILE="$DEST/.backup.lock"
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "Altă instanță rulează deja (lock: $LOCKFILE). Ieșire." >&2
  exit 1
fi

ts="$(date +%Y%m%d_%H%M%S)"
archive="$DEST/backup_${ts}.tar.gz"

echo "[INFO] Creez arhivă: $archive" >&2
run tar -czf "$archive" -C "$SOURCE" .

echo "[INFO] Rotație: păstrez ultimele $ROT arhive" >&2
# listează arhivele, sortează desc după nume (timestamp), șterge restul
mapfile -t archives < <(ls -1 "$DEST"/backup_*.tar.gz 2>/dev/null | sort -r || true)

if (( ${#archives[@]} > ROT )); then
  for old in "${archives[@]:ROT}"; do
    echo "[INFO] Șterg: $old" >&2
    run rm -f -- "$old"
  done
fi

echo "[INFO] Gata." >&2