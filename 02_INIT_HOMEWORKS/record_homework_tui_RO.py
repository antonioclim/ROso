#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║          📹 SISTEM ÎNREGISTRARE TEME - EDIȚIA MATRIX                          ║
║                    Sisteme de Operare 2023-2027                               ║
║                       Revolvix/github.com                                     ║
║                                                                               ║
║                         Versiunea 1.1.0                                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

Un TUI elegant în stil Matrix pentru înregistrarea temelor cu asciinema.
Funcții: semnături criptografice RSA, upload automat, animații frumoase.

Cerințe: Python 3.8+, asciinema, openssl, sshpass
Auto-instalare: rich, questionary (pachete Python)

Changelog:
    1.1.0 (2025-01): Type hints, docstrings îmbunătățite, error handling robust
    1.0.0 (2025-01): Versiune inițială cu temă Matrix
"""

from __future__ import annotations

import os
import sys
import subprocess
import tempfile
import base64
import re
import time
import random
import shutil
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, Callable, TypeVar, List, Tuple

# 
# CONFIGURARE
# 

CONFIG_FILE: str = os.path.expanduser("~/.homework_recorder_config.json")

PUBLIC_KEY: str = """-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"""

SCP_SERVER: str = "sop.ase.ro"
SCP_PORT: str = "1002"
SCP_PASSWORD: str = "stud"
SCP_BASE_PATH: str = "/home/HOMEWORKS"
MAX_RETRIES: int = 3

SPECIALIZATIONS: Dict[str, Tuple[str, str]] = {
    "1": ("roinfo", "Informatică Economică (Română)"),
    "2": ("grupeid", "Grupă ID")
}

# Type variable pentru funcții generice
T = TypeVar('T')

# 
# FUNCȚII CONFIGURARE (SALVARE/ÎNCĂRCARE DATE ANTERIOARE)
# 

def load_config() -> Dict[str, Any]:
    """
    Încarcă configurația salvată anterior (dacă există).
    
    Returns:
        Dict cu cheile: surname, firstname, group, specialization_key
        sau dict gol dacă nu există/nu poate fi citit.
    
    Note:
        Configurația este salvată în ~/.homework_recorder_config.json
    """
    config_path = Path(CONFIG_FILE)
    if not config_path.exists():
        return {}
    
    try:
        with config_path.open('r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError, PermissionError):
        return {}


def save_config(data: Dict[str, str]) -> bool:
    """
    Salvează configurația pentru utilizare ulterioară.
    
    Args:
        data: Dict cu datele studentului (surname, firstname, group, etc.)
    
    Returns:
        True dacă salvarea a reușit, False altfel.
    """
    config: Dict[str, str] = {
        'surname': data.get('surname', ''),
        'firstname': data.get('firstname', ''),
        'group': data.get('group', ''),
        'specialization_key': data.get('specialization_key', '1')
    }
    try:
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        return True
    except IOError:
        return False


# 
# AUTO-INSTALARE DEPENDENȚE
# 

def install_python_packages() -> None:
    """
    Instalează pachetele Python necesare dacă lipsesc.
    
    Raises:
        SystemExit: Dacă instalarea eșuează critic.
    """
    # Verifică dacă pip este instalat, dacă nu - instalează-l
    try:
        subprocess.run(
            [sys.executable, '-m', 'pip', '--version'],
            capture_output=True,
            check=True
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("\n\033[33m⚡ Se instalează pip...\033[0m\n")
        subprocess.run(['sudo', 'apt', 'update', '-qq'], check=True)
        subprocess.run(['sudo', 'apt', 'install', '-y', 'python3-pip'], check=True)
        print("\033[32m✓ pip a fost instalat!\033[0m\n")
    
    required: List[str] = ['rich', 'questionary']
    missing: List[str] = []
    
    for pkg in required:
        try:
            __import__(pkg)
        except ImportError:
            missing.append(pkg)
    
    if missing:
        print(f"\n\033[33m⚡ Se instalează pachetele Python: {', '.join(missing)}...\033[0m\n")
        
        # Detectează versiunea pip pentru a decide dacă folosim --break-system-packages
        pip_version_result = subprocess.run(
            [sys.executable, '-m', 'pip', '--version'],
            capture_output=True,
            text=True
        )
        pip_version_str = pip_version_result.stdout.split()[1] if pip_version_result.returncode == 0 else "0"
        
        # Extrage versiunea majoră
        try:
            pip_major_version = int(pip_version_str.split('.')[0])
        except (ValueError, IndexError):
            pip_major_version = 0
        
        # --break-system-packages este necesar doar pentru pip >= 23 pe sisteme cu externally-managed
        pip_cmd: List[str] = [sys.executable, '-m', 'pip', 'install', '--quiet', '--user']
        
        # Încearcă întâi cu --user (funcționează pe toate versiunile)
        try:
            subprocess.run(pip_cmd + missing, check=True)
        except subprocess.CalledProcessError:
            # Dacă --user eșuează, încearcă fără (poate cere sudo)
            try:
                subprocess.run([sys.executable, '-m', 'pip', 'install', '--quiet'] + missing, check=True)
            except subprocess.CalledProcessError:
                # Ultima încercare: cu --break-system-packages (pip 23+)
                if pip_major_version >= 23:
                    subprocess.run(
                        [sys.executable, '-m', 'pip', 'install', '--quiet', '--break-system-packages'] + missing,
                        check=True
                    )
                else:
                    # Instalare prin apt ca fallback
                    print("\033[33m⚡ Se instalează prin apt...\033[0m\n")
                    apt_packages: List[str] = ['python3-rich']
                    subprocess.run(['sudo', 'apt', 'install', '-y'] + apt_packages, check=False)
                    subprocess.run([sys.executable, '-m', 'pip', 'install', '--quiet', 'questionary'], check=True)
        
        print("\033[32m✓ Pachetele Python au fost instalate!\033[0m\n")
        
        # Re-importă după instalare - adaugă calea user la sys.path dacă e necesar
        import site
        user_site = site.getusersitepackages()
        if user_site not in sys.path:
            sys.path.insert(0, user_site)
        
        # Re-importă modulele
        for pkg in missing:
            globals()[pkg] = __import__(pkg)


def check_system_packages() -> None:
    """
    Verifică și instalează pachetele de sistem dacă lipsesc.
    
    Packages verificate: asciinema, openssl, sshpass
    """
    packages: Dict[str, str] = {
        'asciinema': 'asciinema',
        'openssl': 'openssl',
        'sshpass': 'sshpass'
    }
    
    missing: List[str] = []
    for cmd, pkg in packages.items():
        if shutil.which(cmd) is None:
            missing.append(pkg)
    
    if missing:
        print(f"\n\033[33m⚡ Se instalează pachetele de sistem: {', '.join(missing)}...\033[0m\n")
        subprocess.run(['sudo', 'apt', 'update', '-qq'], check=True)
        subprocess.run(['sudo', 'apt', 'install', '-y'] + missing, check=True)
        print("\033[32m✓ Pachetele de sistem au fost instalate!\033[0m\n")


# Rulează verificările de instalare înainte de importul rich/questionary
try:
    install_python_packages()
    check_system_packages()
except Exception as e:
    print(f"\033[31m✗ Eroare la instalare: {e}\033[0m")
    sys.exit(1)

# Acum importă pachetele
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.table import Table
from rich.layout import Layout
from rich.live import Live
from rich.align import Align
from rich.style import Style
from rich.box import DOUBLE, ROUNDED, HEAVY
from rich import box
import questionary
from questionary import Style as QStyle

# 
# TEMA MATRIX
# 

console: Console = Console()

# Paleta de culori Matrix
MATRIX_GREEN: str = "#00ff41"
MATRIX_DARK_GREEN: str = "#00cc44"
MATRIX_BRIGHT: str = "#00ff00"
MATRIX_DIM: str = "#00aa33"
MATRIX_CYAN: str = "#00ffff"
MATRIX_YELLOW: str = "#ffff00"
MATRIX_RED: str = "#ff0040"

# Stil questionary (tema Matrix)
matrix_style: QStyle = QStyle([
    ('qmark', f'fg:{MATRIX_BRIGHT} bold'),
    ('question', f'fg:{MATRIX_GREEN} bold'),
    ('answer', f'fg:{MATRIX_CYAN} bold'),
    ('pointer', f'fg:{MATRIX_BRIGHT} bold'),
    ('highlighted', f'fg:{MATRIX_BRIGHT} bold'),
    ('selected', f'fg:{MATRIX_CYAN}'),
    ('separator', f'fg:{MATRIX_DIM}'),
    ('instruction', f'fg:{MATRIX_DIM}'),
    ('text', f'fg:{MATRIX_GREEN}'),
    ('disabled', f'fg:{MATRIX_DIM} italic'),
])

# 
# EFECTE MATRIX
# 

def matrix_rain(duration: float = 1.5, width: Optional[int] = None) -> None:
    """
    Afișează efectul de ploaie digitală Matrix.
    
    Args:
        duration: Durata efectului în secunde
        width: Lățimea ecranului (None pentru auto-detect)
    """
    if width is None:
        width = console.width
    
    chars: str = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789ABCDEF"
    columns: List[int] = [0] * width
    
    start_time: float = time.time()
    
    with Live(console=console, refresh_per_second=20, transient=True) as live:
        while time.time() - start_time < duration:
            lines: List[str] = []
            for y in range(min(20, console.height - 5)):
                line: str = ""
                for x in range(width):
                    if random.random() < 0.1:
                        columns[x] = random.randint(0, 20)
                    
                    if columns[x] > 0:
                        if columns[x] > 15:
                            line += f"[bold {MATRIX_BRIGHT}]{random.choice(chars)}[/]"
                        elif columns[x] > 10:
                            line += f"[{MATRIX_GREEN}]{random.choice(chars)}[/]"
                        else:
                            line += f"[{MATRIX_DARK_GREEN}]{random.choice(chars)}[/]"
                        columns[x] -= 1
                    else:
                        line += " "
                lines.append(line)
            
            text = Text.from_markup("\n".join(lines))
            live.update(text)
            time.sleep(0.05)


def typing_effect(text: str, style: str = MATRIX_GREEN, delay: float = 0.02) -> None:
    """
    Afișează text cu efect de tastare.
    
    Args:
        text: Textul de afișat
        style: Stilul de culoare
        delay: Întârzierea între caractere în secunde
    """
    for char in text:
        console.print(char, style=style, end="")
        time.sleep(delay)
    console.print()


def glitch_text(text: str, iterations: int = 5) -> None:
    """
    Afișează text cu efect glitch.
    
    Args:
        text: Textul de afișat
        iterations: Numărul de iterații glitch
    """
    glitch_chars: str = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
    
    with Live(console=console, refresh_per_second=20, transient=True) as live:
        for i in range(iterations):
            glitched: str = ""
            for char in text:
                if random.random() < 0.3 - (i * 0.05):
                    glitched += random.choice(glitch_chars)
                else:
                    glitched += char
            live.update(Text(glitched, style=f"bold {MATRIX_GREEN}"))
            time.sleep(0.1)
        
        live.update(Text(text, style=f"bold {MATRIX_BRIGHT}"))
        time.sleep(0.3)


def spinner_task(description: str, task_func: Callable[..., T], *args: Any, **kwargs: Any) -> T:
    """
    Execută o sarcină cu un spinner în stil Matrix.
    
    Args:
        description: Descrierea sarcinii afișată lângă spinner
        task_func: Funcția de executat
        *args: Argumente poziționale pentru funcție
        **kwargs: Argumente keyword pentru funcție
    
    Returns:
        Rezultatul funcției executate
    """
    with Progress(
        SpinnerColumn(spinner_name="dots", style=f"bold {MATRIX_GREEN}"),
        TextColumn(f"[{MATRIX_GREEN}]{{task.description}}"),
        console=console,
        transient=True
    ) as progress:
        task = progress.add_task(description, total=None)
        result: T = task_func(*args, **kwargs)
        progress.update(task, completed=True)
    return result


def progress_bar(description: str, total: int, update_func: Callable[[int], None]) -> None:
    """
    Afișează o bară de progres în stil Matrix.
    
    Args:
        description: Descrierea sarcinii
        total: Numărul total de pași
        update_func: Funcție apelată la fiecare pas cu indexul curent
    """
    with Progress(
        TextColumn(f"[{MATRIX_GREEN}]{{task.description}}"),
        BarColumn(bar_width=40, style=MATRIX_DARK_GREEN, complete_style=MATRIX_BRIGHT),
        TaskProgressColumn(),
        console=console
    ) as progress:
        task = progress.add_task(description, total=total)
        for i in range(total):
            update_func(i)
            progress.update(task, advance=1)
            time.sleep(0.05)


# 
# COMPONENTE UI
# 

def clear_screen() -> None:
    """Curăță ecranul terminalului."""
    console.clear()


def show_banner() -> None:
    """Afișează bannerul în stil Matrix."""
    banner: str = """
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║   ██╗  ██╗ ██████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗║
    ║   ██║  ██║██╔═══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝║
    ║   ███████║██║   ██║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ ║
    ║   ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ ║
    ║   ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗║
    ║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝║
    ║                                                                          ║
    ║         ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ██████╗ ███████╗██████╗ ║
    ║         ██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗║
    ║         ██████╔╝█████╗  ██║     ██║   ██║██████╔╝██║  ██║█████╗  ██████╔╝║
    ║         ██╔══██╗██╔══╝  ██║     ██║   ██║██╔══██╗██║  ██║██╔══╝  ██╔══██╗║
    ║         ██║  ██║███████╗╚██████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║║
    ║         ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝║
    ║                                                                          ║
    ║                   [ SISTEME DE OPERARE 2023-2027 ]                       ║
    ║                        [ EDIȚIA MATRIX v1.1 ]                            ║
    ║                                                                          ║
    ╚══════════════════════════════════════════════════════════════════════════╝
    """
    console.print(banner, style=f"bold {MATRIX_GREEN}")


def show_section(title: str, subtitle: Optional[str] = None) -> None:
    """
    Afișează un header de secțiune.
    
    Args:
        title: Titlul secțiunii
        subtitle: Subtitlu opțional
    """
    console.print()
    panel_content = Text(title, style=f"bold {MATRIX_BRIGHT}")
    if subtitle:
        panel_content.append(f"\n{subtitle}", style=f"{MATRIX_DARK_GREEN}")
    
    console.print(Panel(
        Align.center(panel_content),
        border_style=MATRIX_GREEN,
        box=DOUBLE,
        padding=(0, 2)
    ))
    console.print()


def show_success(message: str) -> None:
    """Afișează mesaj de succes."""
    console.print(f"  [{MATRIX_BRIGHT}]✓[/] [{MATRIX_GREEN}]{message}[/]")


def show_error(message: str) -> None:
    """Afișează mesaj de eroare."""
    console.print(f"  [{MATRIX_RED}]✗ {message}[/]")


def show_warning(message: str) -> None:
    """Afișează mesaj de avertizare."""
    console.print(f"  [{MATRIX_YELLOW}]⚠ {message}[/]")


def show_info(message: str) -> None:
    """Afișează mesaj informativ."""
    console.print(f"  [{MATRIX_CYAN}]ℹ {message}[/]")


# 
# FUNCȚII DE VALIDARE
# 

def validate_surname(text: str) -> bool:
    """
    Validează numele de familie.
    
    Args:
        text: String de validat
        
    Returns:
        True dacă conține doar litere și cratimă, 
        nu începe/termină cu cratimă.
    
    Examples:
        >>> validate_surname("Ionescu")
        True
        >>> validate_surname("Ionescu-Popescu")
        True
        >>> validate_surname("-Invalid")
        False
        >>> validate_surname("")
        False
    """
    if not text:
        return False
    if not re.match(r'^[a-zA-Z-]+$', text):
        return False
    if text.startswith('-') or text.endswith('-'):
        return False
    return True


def validate_firstname(text: str) -> bool:
    """
    Validează prenumele.
    
    Args:
        text: String de validat
        
    Returns:
        True dacă e valid (aceleași reguli ca validate_surname)
    """
    return validate_surname(text)


def validate_group(text: str) -> bool:
    """
    Validează grupa (exact 4 cifre).
    
    Args:
        text: String de validat
        
    Returns:
        True dacă conține exact 4 cifre
        
    Examples:
        >>> validate_group("1029")
        True
        >>> validate_group("123")
        False
    """
    return bool(re.match(r'^\d{4}$', text))


def validate_homework(text: str) -> bool:
    """
    Validează numărul temei (01-07 urmat de o literă).
    
    Args:
        text: String de validat
        
    Returns:
        True dacă are formatul corect
        
    Examples:
        >>> validate_homework("01a")
        True
        >>> validate_homework("03b")
        True
        >>> validate_homework("08a")
        False
    """
    return bool(re.match(r'^0[1-7][a-zA-Z]$', text))


# 
# COLECTARE DATE
# 

def collect_student_data() -> Dict[str, str]:
    """
    Colectează și validează datele studentului cu prompturi în stil Matrix.
    
    Returns:
        Dict cu cheile: surname, firstname, group, specialization,
        specialization_name, specialization_key, homework
        
    Raises:
        KeyboardInterrupt: Dacă utilizatorul apasă Ctrl+C
    """
    data: Dict[str, str] = {}
    
    # Încarcă configurația anterioară (dacă există)
    config: Dict[str, Any] = load_config()
    prev_surname: str = config.get('surname', '')
    prev_firstname: str = config.get('firstname', '')
    prev_group: str = config.get('group', '')
    
    show_section("📝 IDENTIFICARE STUDENT", "Introdu datele tale mai jos")
    
    # Info despre valori precompletate
    if prev_surname or prev_firstname or prev_group:
        show_info("Valorile anterioare sunt precompletate. Apasă ENTER pentru a le păstra sau scrie altceva.")
        console.print()
    
    # Nume de familie
    while True:
        default_hint: str = f" [{prev_surname}]" if prev_surname else ""
        surname: Optional[str] = questionary.text(
            f"Nume de familie{default_hint}:",
            default=prev_surname,
            style=matrix_style,
            instruction="(doar litere și cratimă, ex: Ionescu-Popescu)"
        ).ask()
        
        if surname is None:  # Utilizatorul a apăsat Ctrl+C
            raise KeyboardInterrupt
        
        # Dacă a apăsat doar ENTER și avem valoare default
        if surname == '' and prev_surname:
            surname = prev_surname
        
        if validate_surname(surname):
            data['surname'] = surname.upper()
            show_success(f"Nume: {data['surname']}")
            break
        else:
            show_error("Invalid! Folosește doar litere și cratimă (fără spații).")
    
    console.print()
    
    # Prenume
    while True:
        default_hint = f" [{prev_firstname}]" if prev_firstname else ""
        firstname: Optional[str] = questionary.text(
            f"Prenume{default_hint}:",
            default=prev_firstname,
            style=matrix_style,
            instruction="(doar litere și cratimă, ex: Andrei-Maria)"
        ).ask()
        
        if firstname is None:
            raise KeyboardInterrupt
        
        if firstname == '' and prev_firstname:
            firstname = prev_firstname
        
        if validate_firstname(firstname):
            data['firstname'] = firstname.title()
            show_success(f"Prenume: {data['firstname']}")
            break
        else:
            show_error("Invalid! Folosește doar litere și cratimă (fără spații).")
    
    console.print()
    
    # Grupă
    while True:
        default_hint = f" [{prev_group}]" if prev_group else ""
        group: Optional[str] = questionary.text(
            f"Număr grupă{default_hint}:",
            default=prev_group,
            style=matrix_style,
            instruction="(exact 4 cifre, ex: 1029)"
        ).ask()
        
        if group is None:
            raise KeyboardInterrupt
        
        if group == '' and prev_group:
            group = prev_group
        
        if validate_group(group):
            data['group'] = group
            show_success(f"Grupă: {data['group']}")
            break
        else:
            show_error("Invalid! Grupa trebuie să aibă exact 4 cifre.")
    
    console.print()
    
    # Specializare
    spec_choices = [
        questionary.Choice(title=v[1], value=k) 
        for k, v in SPECIALIZATIONS.items()
    ]
    
    spec_choice: Optional[str] = questionary.select(
        "Selectează specializarea:",
        choices=spec_choices,
        style=matrix_style,
        instruction="(folosește săgețile)"
    ).ask()
    
    if spec_choice is None:
        raise KeyboardInterrupt
    
    data['specialization'] = SPECIALIZATIONS[spec_choice][0]
    data['specialization_name'] = SPECIALIZATIONS[spec_choice][1]
    data['specialization_key'] = spec_choice  # Salvează cheia pentru config
    show_success(f"Specializare: {data['specialization_name']}")
    
    console.print()
    
    # Număr temă (NU se precompletează - mereu diferit)
    while True:
        homework: Optional[str] = questionary.text(
            "Număr temă:",
            style=matrix_style,
            instruction="(01-07 + literă, ex: 03b)"
        ).ask()
        
        if homework is None:
            raise KeyboardInterrupt
        
        if validate_homework(homework):
            data['homework'] = homework[:2] + homework[2].lower()
            show_success(f"Temă: HW{data['homework']}")
            break
        else:
            show_error("Invalid! Format: 01-07 urmat de o literă (ex: 01a, 03b, 07c)")
    
    # Salvează configurația pentru data viitoare
    save_config(data)
    
    return data


# 
# OPERAȚII CU FIȘIERE
# 

def generate_filename(data: Dict[str, str]) -> str:
    """
    Generează numele fișierului pentru temă.
    
    Args:
        data: Dict cu datele studentului
        
    Returns:
        Numele fișierului în format: GRUPA_NUME_Prenume_HWxx.cast
    """
    return f"{data['group']}_{data['surname']}_{data['firstname']}_HW{data['homework']}.cast"


def start_recording(filepath: str, data: Dict[str, str]) -> None:
    """
    Pornește înregistrarea asciinema cu comandă de oprire personalizată.
    
    Args:
        filepath: Calea completă către fișierul .cast
        data: Dict cu datele studentului
    """
    show_section("🎬 SESIUNE DE ÎNREGISTRARE", "Tastează 'STOP_tema' pentru a opri")
    
    # Creează bashrc temporar cu alias
    temp_rc = tempfile.NamedTemporaryFile(mode='w', suffix='.bashrc', delete=False)
    temp_rc.write('''
# Încarcă configurația implicită
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Alias Matrix pentru oprire
alias STOP_tema='echo ""; echo -e "\\033[32m🛑 Înregistrare oprită. Se salvează...\\033[0m"; exit'

# Mesaj de start înregistrare
echo ""
echo -e "\\033[32m╔═══════════════════════════════════════════════════════════════════════╗\\033[0m"
echo -e "\\033[32m║                     🔴 ÎNREGISTRARE ÎN CURS                           ║\\033[0m"
echo -e "\\033[32m╠═══════════════════════════════════════════════════════════════════════╣\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m║   Pentru a OPRI și SALVA înregistrarea, tastează: \\033[1;33mSTOP_tema\\033[32m     ║\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m║   sau apasă Ctrl+D                                                    ║\\033[0m"
echo -e "\\033[32m║                                                                       ║\\033[0m"
echo -e "\\033[32m╚═══════════════════════════════════════════════════════════════════════╝\\033[0m"
echo ""
''')
    temp_rc.close()
    
    # Afișează informații despre înregistrare
    table = Table(box=box.ROUNDED, border_style=MATRIX_GREEN, show_header=False)
    table.add_column("Câmp", style=MATRIX_DARK_GREEN)
    table.add_column("Valoare", style=f"bold {MATRIX_BRIGHT}")
    table.add_row("Student", f"{data['surname']} {data['firstname']}")
    table.add_row("Grupă", data['group'])
    table.add_row("Specializare", data['specialization'])
    table.add_row("Temă", f"HW{data['homework']}")
    table.add_row("Fișier", os.path.basename(filepath))
    
    console.print(table)
    console.print()
    
    # Numărătoare inversă
    for i in range(3, 0, -1):
        console.print(f"  [{MATRIX_YELLOW}]Se pornește în {i}...[/]", end="\r")
        time.sleep(1)
    console.print(f"  [{MATRIX_BRIGHT}]🎬 ÎNREGISTRARE![/]          ")
    console.print()
    
    # Rulează asciinema
    try:
        subprocess.run(
            ['asciinema', 'rec', '--overwrite', filepath, '-c', f'bash --rcfile {temp_rc.name}'],
            check=True
        )
    finally:
        # Cleanup
        os.unlink(temp_rc.name)
    
    console.print()
    show_success("Înregistrare finalizată!")


def generate_signature(filepath: str, data: Dict[str, str]) -> str:
    """
    Generează semnătura criptografică pentru înregistrare.
    
    Args:
        filepath: Calea către fișierul .cast
        data: Dict cu datele studentului
        
    Returns:
        String-ul de date care a fost semnat
    """
    show_section("🔐 SEMNĂTURĂ CRIPTOGRAFICĂ", "Se securizează tema...")
    
    def do_sign() -> str:
        # Obține informații fișier
        file_size: int = os.path.getsize(filepath)
        current_date: str = datetime.now().strftime("%d-%m-%Y")
        current_time: str = datetime.now().strftime("%H:%M:%S")
        system_user: str = os.getenv('USER', 'unknown')
        absolute_path: str = os.path.abspath(filepath)
        
        # Construiește datele pentru semnătură
        data_to_sign: str = f"{data['surname']}+{data['firstname']} {data['group']} {file_size} {current_date} {current_time} {system_user} {absolute_path}"
        
        # Hash cu SHA-256 pentru a garanta că datele încap în blocul RSA 1024-bit
        # (RSA 1024 + PKCS1 permite max 117 bytes; SHA-256 hex = 64 bytes, mereu OK)
        import hashlib
        data_hash: str = hashlib.sha256(data_to_sign.encode()).hexdigest()
        
        # Salvează cheia publică temporar
        temp_key = tempfile.NamedTemporaryFile(mode='w', suffix='.pem', delete=False)
        temp_key.write(PUBLIC_KEY)
        temp_key.close()
        
        try:
            # Criptează hash-ul SHA-256 cu RSA
            process = subprocess.run(
                ['openssl', 'pkeyutl', '-encrypt', '-pubin', '-inkey', temp_key.name, '-pkeyopt', 'rsa_padding_mode:pkcs1'],
                input=data_hash.encode(),
                capture_output=True,
                check=True
            )
            
            # Convertește la base64
            encrypted_b64: str = base64.b64encode(process.stdout).decode()
            
            # Adaugă semnătura ȘI metadatele la fișier
            # SIG = hash-ul SHA-256 criptat RSA; META = datele în clar
            with open(filepath, 'a') as f:
                f.write(f"\n## SIG:{encrypted_b64}\n")
                f.write(f"## META:{data_to_sign}\n")
            
            return data_to_sign
        finally:
            os.unlink(temp_key.name)
    
    # Execută cu spinner
    signed_data: str = spinner_task("Se generează semnătura RSA...", do_sign)
    
    show_success("Semnătura criptografică a fost adăugată!")
    show_info(f"Date semnate: {signed_data[:50]}...")
    
    return signed_data


def upload_homework(filepath: str, data: Dict[str, str]) -> bool:
    """
    Încarcă tema pe server cu logică de reîncercare.
    
    Args:
        filepath: Calea către fișierul .cast
        data: Dict cu datele studentului
        
    Returns:
        True dacă upload-ul a reușit, False altfel
    """
    show_section("📤 ÎNCĂRCARE PE SERVER", f"Destinație: {SCP_SERVER}:{SCP_PORT}")
    
    filename: str = os.path.basename(filepath)
    scp_user: str = "stud-id"
    scp_dest: str = f"{SCP_BASE_PATH}/{data['specialization']}"
    
    # Afișează informații conexiune
    table = Table(box=box.ROUNDED, border_style=MATRIX_GREEN, show_header=False)
    table.add_column("", style=MATRIX_DARK_GREEN)
    table.add_column("", style=f"bold {MATRIX_CYAN}")
    table.add_row("Server", f"{SCP_SERVER}:{SCP_PORT}")
    table.add_row("Utilizator", scp_user)
    table.add_row("Destinație", scp_dest)
    table.add_row("Fișier", filename)
    console.print(table)
    console.print()
    
    # Verificare conectivitate înainte de upload
    import socket
    show_info(f"Se verifică conectivitatea cu {SCP_SERVER}:{SCP_PORT}...")
    try:
        sock = socket.create_connection((SCP_SERVER, int(SCP_PORT)), timeout=5)
        sock.close()
        show_success(f"Conexiune verificată - portul {SCP_PORT} este deschis.")
    except (socket.timeout, socket.error, OSError):
        show_warning(f"Portul {SCP_PORT} pe {SCP_SERVER} nu este accesibil.")
        show_warning("Posibile cauze: serverul SSH este oprit, firewall, VPN activ.")
        show_info("Se continuă cu încercările SCP (pot eșua)...")
    console.print()
    
    for attempt in range(1, MAX_RETRIES + 1):
        show_info(f"Încercarea {attempt} din {MAX_RETRIES}...")
        
        try:
            # Simulare progres
            with Progress(
                SpinnerColumn(spinner_name="dots12", style=f"bold {MATRIX_GREEN}"),
                TextColumn(f"[{MATRIX_GREEN}]Se încarcă..."),
                BarColumn(bar_width=30, style=MATRIX_DARK_GREEN, complete_style=MATRIX_BRIGHT),
                TaskProgressColumn(),
                console=console,
                transient=True
            ) as progress:
                task = progress.add_task("upload", total=100)
                
                # Pornește SCP în background
                process = subprocess.Popen(
                    [
                        'sshpass', '-p', SCP_PASSWORD,
                        'scp', '-P', SCP_PORT,
                        '-o', 'StrictHostKeyChecking=no',
                        '-o', 'UserKnownHostsFile=/dev/null',
                        '-o', 'LogLevel=ERROR',
                        filepath,
                        f"{scp_user}@{SCP_SERVER}:{scp_dest}/"
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                
                # Simulează progres în timp ce așteaptă
                while process.poll() is None:
                    current: float = progress.tasks[0].completed
                    if current < 90:
                        progress.update(task, advance=random.randint(5, 15))
                    time.sleep(0.3)
                
                progress.update(task, completed=100)
            
            if process.returncode == 0:
                console.print()
                console.print(Panel(
                    Align.center(Text("✅ ÎNCĂRCARE REUȘITĂ!", style=f"bold {MATRIX_BRIGHT}")),
                    border_style=MATRIX_GREEN,
                    box=DOUBLE
                ))
                return True
            else:
                raise subprocess.CalledProcessError(process.returncode, 'scp')
                
        except Exception:
            show_warning(f"Încercarea {attempt} a eșuat.")
            if attempt < MAX_RETRIES:
                show_info("Se reîncearcă în 3 secunde...")
                time.sleep(3)
    
    # Toate încercările au eșuat
    console.print()
    console.print(Panel(
        Align.center(Text.from_markup(f"""[bold {MATRIX_RED}]❌ NU AM PUTUT TRIMITE TEMA![/]

[{MATRIX_YELLOW}]Fișierul a fost salvat local.[/]

[bold {MATRIX_BRIGHT}]
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║   📁  {filename:<68} ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
[/]

[{MATRIX_CYAN}]Încearcă mai târziu (când restabilești conexiunea la internet) folosind:[/]

[bold {MATRIX_GREEN}]scp -P {SCP_PORT} {filename} {scp_user}@{SCP_SERVER}:{scp_dest}/[/]

[{MATRIX_YELLOW}]⚠️  NU modifica fișierul .cast înainte de trimitere![/]""")),
        border_style=MATRIX_RED,
        box=DOUBLE,
        title="[bold] Trimitere Eșuată [/]",
        title_align="center"
    ))
    
    return False


# 
# FLUX PRINCIPAL
# 

def show_summary(data: Dict[str, str], filepath: str, upload_success: bool) -> None:
    """
    Afișează rezumatul final.
    
    Args:
        data: Dict cu datele studentului
        filepath: Calea către fișierul .cast
        upload_success: True dacă upload-ul a reușit
    """
    show_section("📋 REZUMAT FINAL", "Sesiune completă")
    
    table = Table(box=box.DOUBLE, border_style=MATRIX_GREEN)
    table.add_column("Câmp", style=MATRIX_DARK_GREEN)
    table.add_column("Valoare", style=f"bold {MATRIX_BRIGHT}")
    
    table.add_row("Student", f"{data['surname']} {data['firstname']}")
    table.add_row("Grupă", data['group'])
    table.add_row("Specializare", data['specialization_name'])
    table.add_row("Temă", f"HW{data['homework']}")
    table.add_row("Fișier", os.path.basename(filepath))
    table.add_row("Cale locală", filepath)
    
    status: str = f"[{MATRIX_BRIGHT}]✓ Încărcat[/]" if upload_success else f"[{MATRIX_YELLOW}]⚠ Doar local[/]"
    table.add_row("Status", status)
    
    console.print(table)


def main() -> None:
    """Punct de intrare principal."""
    try:
        clear_screen()
        
        # Intro cu ploaie Matrix
        matrix_rain(duration=1.0)
        
        clear_screen()
        show_banner()
        
        time.sleep(0.5)
        
        # Colectează date
        data: Dict[str, str] = collect_student_data()
        
        # Generează nume fișier
        filename: str = generate_filename(data)
        filepath: str = os.path.join(os.getcwd(), filename)
        
        console.print()
        show_section("📄 INFORMAȚII FIȘIER")
        show_success(f"Nume fișier: {filename}")
        show_info(f"Cale: {filepath}")
        
        # Confirmă înainte de înregistrare
        console.print()
        confirm_result: Optional[bool] = questionary.confirm(
            "Ești pregătit să începi înregistrarea?",
            style=matrix_style,
            default=True
        ).ask()
        
        if not confirm_result:
            show_warning("Înregistrare anulată.")
            return
        
        # Pornește înregistrarea
        start_recording(filepath, data)
        
        # Generează semnătura
        console.print()
        generate_signature(filepath, data)
        
        # Încarcă
        console.print()
        upload_success: bool = upload_homework(filepath, data)
        
        # Rezumat
        console.print()
        show_summary(data, filepath, upload_success)
        
        # Mesaj final
        console.print()
        console.print(Panel(
            Align.center(Text("🎉 PROCES FINALIZAT!", style=f"bold {MATRIX_BRIGHT}")),
            border_style=MATRIX_GREEN,
            box=DOUBLE
        ))
        
        # Ieșire cu efect Matrix
        console.print()
        typing_effect("Mulțumim că ai folosit Homework Recorder. Succes!", style=MATRIX_GREEN, delay=0.03)
        console.print()
        
    except KeyboardInterrupt:
        console.print()
        show_warning("Operațiune anulată de utilizator.")
        sys.exit(1)
    except Exception as e:
        console.print()
        show_error(f"A apărut o eroare: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
