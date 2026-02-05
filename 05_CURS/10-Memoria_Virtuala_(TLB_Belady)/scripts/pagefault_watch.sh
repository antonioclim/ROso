#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Utilizare:
  pagefault_watch.sh [--] <comanda> [args...]

Scop (Săptămâna 10): măsurarea *page faults* pentru o comandă.
- Folosește `/usr/bin/time -v` (GNU time) dacă este disponibil.

Exemple:
  ./pagefault_watch.sh -- python3 ../SO_Saptamana_09/scripts/rss_probe.py --mb 100 --step 10
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

TIME_BIN="/usr/bin/time"
if [[ -x "$TIME_BIN" ]]; then
  echo "=== /usr/bin/time -v ===" >&2
  "$TIME_BIN" -v -- "$@" 2>&1 | grep -E "Command being timed|User time|System time|Elapsed|Maximum resident|Minor|Major"
else
  echo "Eroare: /usr/bin/time nu este disponibil." >&2
  exit 1
fi

cat <<'NOTES'

Interpretare didactică:
- Minor faults: pagini mapate care pot fi satisfăcute fără I/O (ex.: deja în cache).
- Major faults: necesită I/O (ex.: pagina nu e în RAM și trebuie citită de pe disc).
- Numerele depind de caching, de starea sistemului și de repetabilitatea experimentului.
NOTES