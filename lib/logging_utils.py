#!/usr/bin/env python3
"""
Kit Educațional ROso — Utilități Partajate de Logging

Oferă logging consistent și structurat pentru toate scripturile Python.
Suportă atât ieșire în consolă (cu culori) cât și logging în fișier.

Autor: ing. dr. Antonio Clim, ASE-CSIE
"""

import logging
import sys
from pathlib import Path
from typing import Optional

# Limba engleză britanică în comentarii și docstrings
# Limba engleză americană păstrată în stdlib Python (logging.WARNING, etc.)


class ColouredFormatter(logging.Formatter):
    """Formatter care adaugă culori ANSI la nivelele de log pentru output terminal."""
    
    COLOURS = {
        logging.DEBUG: '\033[0;36m',    # Cyan
        logging.INFO: '\033[0;32m',     # Verde
        logging.WARNING: '\033[0;33m',  # Galben
        logging.ERROR: '\033[0;31m',    # Roșu
        logging.CRITICAL: '\033[1;31m', # Roșu îngroșat
    }
    RESET = '\033[0m'
    
    def format(self, record: logging.LogRecord) -> str:
        """Formatează înregistrarea log cu codificare culori dacă terminalul suportă."""
        if sys.stdout.isatty():
            colour = self.COLOURS.get(record.levelno, self.RESET)
            record.levelname = f"{colour}{record.levelname}{self.RESET}"
        return super().format(record)


def setup_logging(
    name: str,
    level: int = logging.INFO,
    log_file: Optional[Path] = None,
    use_colours: bool = True
) -> logging.Logger:
    """
    Configurează logging structurat cu format consistent.
    
    Argumente:
        name: Numele logger-ului (de obicei __name__)
        level: Nivelul de logging (implicit: INFO)
        log_file: Cale opțională pentru logging în fișier
        use_colours: Dacă să folosească output colorat (implicit: True)
    
    Returnează:
        Instanță de logger configurată
    
    Exemplu:
        >>> logger = setup_logging(__name__)
        >>> logger.info("Procesare începută")
        [2025-01-30 10:00:00] [INFO] nume_modul: Procesare începută
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Evită handler-e duplicate la apeluri repetate
    if logger.handlers:
        return logger
    
    # Handler consolă cu culori
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    
    if use_colours and sys.stdout.isatty():
        console_formatter = ColouredFormatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
    else:
        console_formatter = logging.Formatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
    
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    # Handler fișier opțional (fără culori)
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        file_formatter = logging.Formatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
    
    return logger


def get_logger(name: str) -> logging.Logger:
    """Obține sau creează un logger cu configurația implicită ROso."""
    return setup_logging(name)
