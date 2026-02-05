#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Demo (Săptămâna 11): hard links vs symlinks și inode.
# Rulează într-un director de lucru; creează fișiere temporare și le șterge la final.

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"

echo "=== Demo links (hard vs symbolic) ==="
echo "[INFO] Working dir: $TMPDIR"
echo

echo "Hello, inode!" > original.txt
ln original.txt hard.txt
ln -s original.txt soft.txt

echo "== ls -li =="
ls -li
echo

echo "== stat (inode & link count) =="
stat -c 'file=%n inode=%i links=%h size=%s' original.txt hard.txt soft.txt
echo

echo "[INFO] Șterg original.txt"
rm -f original.txt
echo

echo "== Observă efectul =="
echo "- hard.txt încă funcționează (același inode)."
echo "- soft.txt devine dangling symlink."
echo

echo "hard.txt:"
cat hard.txt
echo

echo "soft.txt:"
cat soft.txt 2>/dev/null || echo "[OK] soft.txt nu poate fi dereferențiat (dangling)."