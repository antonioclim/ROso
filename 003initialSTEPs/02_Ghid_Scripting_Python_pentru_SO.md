# Ghid de scripting Python (pentru disciplina Sisteme de Operare)

În acest kit, Python este folosit ca „lupă”: pentru a măsura, a instrumenta și a procesa date despre sistem (procese, fișiere, memorie, log-uri) cu mai multă structură decât în Bash.

## 1. Convenții de bază

- Folosește Python 3.12+ (unde este posibil).
- Preferă `pathlib.Path` în loc de concatenări manuale de string-uri.
- Preferă `argparse` pentru CLI predictibil.
- Pentru output tabular: fie `print` + formatare simplă, fie CSV/JSON.

## 2. Interacțiunea cu sistemul: `subprocess`

Exemplu sigur (fără `shell=True`):
```python
import subprocess

result = subprocess.run(
    ["ps", "-eo", "pid,ppid,comm,%cpu,%mem", "--sort=-%cpu"],
    text=True,
    check=True,
    capture_output=True,
)
print(result.stdout)
```

Recomandări:

Concret: `check=True` pentru a detecta erorile;. `capture_output=True` doar când ai nevoie să procesezi output-ul;. Și evită `shell=True` în proiecte (risc de injection)..


## 3. Citirea informațiilor despre procese

Pe Linux, multe informații sunt disponibile în `/proc`:
- `/proc/<pid>/status`
- `/proc/meminfo`
- `/proc/cpuinfo`
- Consultă `man` sau `--help` dacă ai dubii

Exemplu (simplificat):
```python
from pathlib import Path

status = Path("/proc/self/status").read_text(encoding="utf-8")
for line in status.splitlines():
    if line.startswith(("VmRSS:", "Threads:", "State:")):
        print(line)
```

## 4. Parsing de log-uri (exemplu realist)

Scenariu: extragi tentative de autentificare din log-uri (pentru a discuta securitatea și auditul).

- cu `journalctl` → output text
- cu Python → agregare (număr pe IP, top utilizatori, intervale)

## 5. Măsurare și timp

- `time.perf_counter()` pentru intervale scurte
- `resource.getrusage()` pentru CPU time (unde este cazul)

## 6. Recomandări de stil


- Folosește type hints acolo unde ajută
- Separă „logica" de „I/O" (citire/afișare)
- Scrie `--help` și exemple de rulare


Data ediției: **10 ianuarie 2026**
