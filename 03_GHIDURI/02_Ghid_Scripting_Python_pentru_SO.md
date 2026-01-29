# Ghid de scripting Python (pentru disciplina Sisteme de Operare)

În acest kit, Python este folosit ca „lupă": pentru a măsura, a instrumenta și a procesa date despre sistem (procese, fișiere, memorie, log-uri) cu mai multă structură decât în Bash.

## 1. Convenții de bază

- Python 3.12+ (pentru pattern matching, type hints moderne)
- `pathlib.Path` în loc de `os.path.join()` sau concatenări
- `argparse` pentru CLI predictibil
- Type hints pe funcții publice (ajută la documentare și IDE)

## 2. Interacțiunea cu sistemul: `subprocess`

```python
import subprocess
from typing import Optional

def run_cmd(args: list[str], timeout: int = 30) -> Optional[str]:
    """Execută comandă, returnează stdout sau None la eroare."""
    try:
        result = subprocess.run(
            args, text=True, check=True,
            capture_output=True, timeout=timeout
        )
        return result.stdout
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        print(f"Eroare: {e}", file=__import__('sys').stderr)
        return None

# Utilizare
if output := run_cmd(["ps", "-eo", "pid,comm,%cpu", "--sort=-%cpu"]):
    print(output)
```

Reguli:
- `check=True` — excepție la returncode ≠ 0
- `capture_output=True` — doar când chiar procesezi output
- **Niciodată** `shell=True` — risc de command injection

## 3. Citirea din `/proc` (fără subprocess)

```python
from pathlib import Path

def get_process_info(pid: int | str = "self") -> dict[str, str]:
    """Extrage informații din /proc/<pid>/status."""
    status_path = Path(f"/proc/{pid}/status")
    if not status_path.exists():
        return {}
    
    keys = ("Name", "State", "Pid", "PPid", "VmRSS", "Threads")
    info = {}
    for line in status_path.read_text(encoding="utf-8").splitlines():
        key, _, value = line.partition(":")
        if key in keys:
            info[key] = value.strip()
    return info

# Utilizare
print(get_process_info())        # procesul curent
print(get_process_info(1))       # init/systemd
```

Alte surse utile: `/proc/meminfo`, `/proc/cpuinfo`, `/proc/loadavg`.

## 4. Agregare log-uri (pattern Counter)

```python
from collections import Counter
import subprocess
import re

def analyze_ssh_logs(since: str = "today") -> Counter[str]:
    """Numără IP-uri cu autentificare eșuată."""
    output = subprocess.run(
        ["journalctl", "-u", "ssh", "--since", since, "--no-pager"],
        text=True, capture_output=True
    ).stdout
    
    ip_pattern = re.compile(r"Failed password.*from (\d+\.\d+\.\d+\.\d+)")
    return Counter(ip_pattern.findall(output))

# Utilizare
for ip, count in analyze_ssh_logs().most_common(5):
    print(f"{ip}: {count} tentative")
```

## 5. Măsurare timp execuție

```python
import time
from contextlib import contextmanager
from typing import Generator

@contextmanager
def measure_time(label: str = "Operație") -> Generator[None, None, None]:
    """Context manager pentru măsurare timp."""
    start = time.perf_counter()
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        print(f"{label}: {elapsed:.3f}s")

# Utilizare
with measure_time("Citire /proc"):
    info = get_process_info()
```

Pentru CPU time (nu wall-clock): `resource.getrusage(resource.RUSAGE_SELF)`.

## 6. Pattern: fișiere temporare cu cleanup

```python
import tempfile
from pathlib import Path
from contextlib import contextmanager
from typing import Generator

@contextmanager
def temp_workspace() -> Generator[Path, None, None]:
    """Creează director temporar, șters automat la ieșire."""
    tmp = tempfile.mkdtemp(prefix="so_lab_")
    try:
        yield Path(tmp)
    finally:
        import shutil
        shutil.rmtree(tmp, ignore_errors=True)

# Utilizare
with temp_workspace() as ws:
    (ws / "test.txt").write_text("date temporare")
    # la ieșirea din with, directorul dispare
```

## 7. Checklist calitate

- [ ] `if __name__ == "__main__":` pentru scripturi executabile
- [ ] `argparse` cu `-h` funcțional
- [ ] Type hints pe funcții (verificabil cu `mypy --strict`)
- [ ] Docstrings pe funcții publice
- [ ] Separare I/O de logică (testabilitate)

Data ediției: **27 ianuarie 2026**
