#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  fs_metadata_report.sh [-o OUT]

Scop (Săptămâna 12): colectează metadate relevante despre filesystem și journaling.
- unele comenzi pot necesita privilegii (ex.: tune2fs).

Exemplu:
  ./fs_metadata_report.sh
  ./fs_metadata_report.sh -o raport_fs.txt
EOF
}

OUT=""
while getopts ":o:h" opt; do
  case "$opt" in
    o) OUT="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Eroare: -$OPTARG necesită argument." >&2; usage; exit 2 ;;
    \?) echo "Eroare: opțiune invalidă -$OPTARG" >&2; usage; exit 2 ;;
  esac
done

ts="$(date +%Y%m%d_%H%M%S)"
: "${OUT:=./fs_report_${ts}.txt}"

{
  echo "=== Filesystem report ==="
  echo "Timestamp: $(date -Is)"
  echo

  echo "== mount / findmnt =="
  command -v findmnt >/dev/null 2>&1 && findmnt || mount
  echo

  echo "== lsblk =="
  command -v lsblk >/dev/null 2>&1 && lsblk -f || true
  echo

  echo "== df (space) =="
  df -hT
  echo

  echo "== df (inodes) =="
  df -i
  echo

  echo "== dmesg (filesystem-related, last 50 lines) =="
  if command -v dmesg >/dev/null 2>&1; then
    dmesg --color=never | grep -iE 'ext4|xfs|btrfs|fsck|journal' | tail -n 50 || true
  fi
  echo

  echo "== (optional) tune2fs (ext*) =="
  cat <<'NOTE'
Dacă sistemul folosește ext4 și ai permisiuni:
  sudo tune2fs -l /dev/<device> | grep -iE 'Filesystem features|Journal|Mount count|Last mount'
NOTE
} > "$OUT"

echo "[INFO] Raport scris în: $OUT" >&2