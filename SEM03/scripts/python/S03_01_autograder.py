#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
═══════════════════════════════════════════════════════════════════════════════
S03_01_autograder.py - Sistem de Evaluare Automată pentru Seminar 5-6
═══════════════════════════════════════════════════════════════════════════════
Sisteme de Operare | ASE București - CSIE

DESCRIERE:
    Evaluator automat pentru temele din Seminarul 5-6 care verifică:
    - Comenzi find și xargs
    - Scripturi cu parametri și getopts
    - Setări permisiuni (chmod, chown, umask)
    - Configurații cron
    
FUNCȚIONALITĂȚI:
    - Evaluare automată a scripturilor bash
    - Verificare sintaxă și funcționalitate
    - Testare parametri și opțiuni
    - Validare permisiuni și securitate
    - Verificare expresii cron
    - Generare rapoarte detaliate
    - Feedback formativ pentru studenți
    
UTILIZARE:
    python3 S03_01_autograder.py --submission <director>
    python3 S03_01_autograder.py --submission <director> --verbose
    python3 S03_01_autograder.py --batch <director_clase>
    python3 S03_01_autograder.py --test-find <fisier_comenzi>
    python3 S03_01_autograder.py --test-cron <fisier_crontab>

AUTOR: Echipa SO | VERSIUNE: 1.0 | DATA: 2025
═══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import re
import json
import subprocess
import tempfile
import shutil
import argparse
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Optional, Tuple, Any
from enum import Enum
import traceback

# 
# CONFIGURARE CULORI TERMINAL
# 

class Colors:
    """Coduri ANSI pentru culori în terminal"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    GRAY = '\033[0;90m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'
    
    @classmethod
    def disable(cls):
        """Dezactivează culorile (pentru output non-terminal)"""
        for attr in dir(cls):
            if not attr.startswith('_') and attr.isupper():
                setattr(cls, attr, '')

# Detectare automată dacă terminal suportă culori
if not sys.stdout.isatty():
    Colors.disable()

# 
# MODELE DE DATE
# 

class TestStatus(Enum):
    """Status posibile pentru un test"""
    PASSED = "passed"
    FAILED = "failed"
    PARTIAL = "partial"
    ERROR = "error"
    SKIPPED = "skipped"

@dataclass
class TestResult:
    """Rezultatul unui test individual"""
    name: str
    status: TestStatus
    points_earned: float
    points_max: float
    message: str
    details: List[str] = field(default_factory=list)
    suggestions: List[str] = field(default_factory=list)
    
    @property
    def percentage(self) -> float:
        if self.points_max == 0:
            return 100.0
        return (self.points_earned / self.points_max) * 100

@dataclass
class CategoryResult:
    """Rezultatul unei categorii de teste"""
    name: str
    tests: List[TestResult] = field(default_factory=list)
    
    @property
    def total_earned(self) -> float:
        return sum(t.points_earned for t in self.tests)
    
    @property
    def total_max(self) -> float:
        return sum(t.points_max for t in self.tests)
    
    @property
    def percentage(self) -> float:
        if self.total_max == 0:
            return 100.0
        return (self.total_earned / self.total_max) * 100
    
    @property
    def passed_count(self) -> int:
        return sum(1 for t in self.tests if t.status == TestStatus.PASSED)

@dataclass
class GradingResult:
    """Rezultatul complet al evaluării"""
    student_id: str
    submission_path: str
    timestamp: str
    categories: List[CategoryResult] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    security_issues: List[str] = field(default_factory=list)
    
    @property
    def total_earned(self) -> float:
        return sum(c.total_earned for c in self.categories)
    
    @property
    def total_max(self) -> float:
        return sum(c.total_max for c in self.categories)
    
    @property
    def percentage(self) -> float:
        if self.total_max == 0:
            return 100.0
        return (self.total_earned / self.total_max) * 100
    
    @property
    def grade(self) -> str:
        """Calculează nota finală"""
        p = self.percentage
        if p >= 90:
            return "10"
        elif p >= 80:
            return "9"
        elif p >= 70:
            return "8"
        elif p >= 60:
            return "7"
        elif p >= 50:
            return "6"
        elif p >= 40:
            return "5"
        else:
            return "4"

# 
# VALIDATOARE SPECIFICE
# 

class BashValidator:
    """Validare scripturi Bash"""
    
    @staticmethod
    def check_syntax(script_path: str) -> Tuple[bool, str]:
        """Verifică sintaxa unui script bash"""
        try:
            result = subprocess.run(
                ['bash', '-n', script_path],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                return True, "Sintaxă corectă"
            else:
                return False, result.stderr.strip()
        except subprocess.TimeoutExpired:
            return False, "Timeout la verificarea sintaxei"
        except Exception as e:
            return False, f"Eroare: {str(e)}"
    
    @staticmethod
    def check_shebang(script_path: str) -> Tuple[bool, str]:
        """Verifică prezența shebang-ului"""
        try:
            with open(script_path, 'r') as f:
                first_line = f.readline().strip()
            
            if first_line.startswith('#!'):
                if 'bash' in first_line:
                    return True, f"Shebang corect: {first_line}"
                elif 'sh' in first_line:
                    return True, f"Shebang POSIX: {first_line} (consideră #!/bin/bash)"
                else:
                    return False, f"Shebang neobișnuit: {first_line}"
            else:
                return False, "Lipsește shebang-ul (#!/bin/bash)"
        except Exception as e:
            return False, f"Eroare la citire: {str(e)}"
    
    @staticmethod
    def check_executable(script_path: str) -> Tuple[bool, str]:
        """Verifică dacă scriptul este executabil"""
        if os.access(script_path, os.X_OK):
            return True, "Scriptul este executabil"
        else:
            mode = oct(os.stat(script_path).st_mode)[-3:]
            return False, f"Scriptul nu este executabil (permisiuni: {mode})"
    
    @staticmethod
    def has_usage_function(script_content: str) -> bool:
        """Verifică dacă scriptul are funcție usage/help"""
        patterns = [
            r'usage\s*\(\s*\)',
            r'show_help\s*\(\s*\)',
            r'print_usage\s*\(\s*\)',
            r'help\s*\(\s*\)',
            r'-h\s*\|.*--help',
            r'--help\s*\)',
        ]
        for pattern in patterns:
            if re.search(pattern, script_content, re.IGNORECASE):
                return True
        return False
    
    @staticmethod
    def uses_getopts(script_content: str) -> bool:
        """Verifică utilizarea getopts"""
        return bool(re.search(r'while\s+getopts\s+', script_content))
    
    @staticmethod
    def uses_shift_after_getopts(script_content: str) -> bool:
        """Verifică dacă folosește shift după getopts"""
        # Caută pattern-ul shift $((OPTIND - 1)) după getopts
        getopts_match = re.search(r'while\s+getopts\s+', script_content)
        if getopts_match:
            after_getopts = script_content[getopts_match.end():]
            # Caută shift OPTIND în următoarele linii
            if re.search(r'shift\s+\$\(\(OPTIND', after_getopts[:500]):
                return True
            if re.search(r'shift\s+`expr\s+\$OPTIND', after_getopts[:500]):
                return True
        return False
    
    @staticmethod
    def check_error_handling(script_content: str) -> Dict[str, bool]:
        """Verifică tehnici de error handling"""
        checks = {
            'set_e': bool(re.search(r'set\s+-e', script_content)),
            'set_u': bool(re.search(r'set\s+-u', script_content)),
            'set_pipefail': bool(re.search(r'set\s+-o\s+pipefail', script_content)),
            'exit_codes': bool(re.search(r'exit\s+[1-9]', script_content)),
            'error_function': bool(re.search(r'(error|die|fail)\s*\(\s*\)', script_content)),
            'trap': bool(re.search(r'trap\s+', script_content)),
        }
        return checks

class FindValidator:
    """Validare comenzi find"""
    
    @staticmethod
    def parse_find_command(command: str) -> Dict[str, Any]:
        """Parsează o comandă find și extrage componentele"""
        result = {
            'valid': True,
            'path': None,
            'tests': [],
            'actions': [],
            'operators': [],
            'errors': []
        }
        
        # Verifică dacă începe cu find
        if not command.strip().startswith('find'):
            result['valid'] = False
            result['errors'].append("Comanda nu începe cu 'find'")
            return result
        
        # Extrage părțile comenzii
        parts = command.split()
        if len(parts) < 2:
            result['valid'] = False
            result['errors'].append("Comanda find este incompletă")
            return result
        
        # Detectează path-ul
        if len(parts) > 1 and not parts[1].startswith('-'):
            result['path'] = parts[1]
        
        # Detectează teste comune
        tests_patterns = {
            '-name': 'căutare după nume',
            '-iname': 'căutare după nume (case insensitive)',
            '-type': 'căutare după tip',
            '-size': 'căutare după dimensiune',
            '-mtime': 'căutare după timp modificare (zile)',
            '-mmin': 'căutare după timp modificare (minute)',
            '-atime': 'căutare după timp acces',
            '-ctime': 'căutare după timp creare',
            '-perm': 'căutare după permisiuni',
            '-user': 'căutare după owner',
            '-group': 'căutare după grup',
            '-newer': 'căutare fișiere mai noi decât',
            '-maxdepth': 'limită adâncime',
            '-mindepth': 'adâncime minimă',
        }
        
        for test, desc in tests_patterns.items():
            if test in command:
                result['tests'].append((test, desc))
        
        # Detectează acțiuni
        actions_patterns = {
            '-print': 'afișare (implicit)',
            '-print0': 'afișare cu null delimiter',
            '-printf': 'afișare formatată',
            '-exec': 'execuție comandă',
            '-ok': 'execuție cu confirmare',
            '-delete': 'ștergere',
            '-ls': 'afișare detaliată',
        }
        
        for action, desc in actions_patterns.items():
            if action in command:
                result['actions'].append((action, desc))
        
        # Detectează operatori
        if ' -o ' in command or ' -or ' in command:
            result['operators'].append('OR')
        if ' -a ' in command or ' -and ' in command:
            result['operators'].append('AND explicit')
        if ' ! ' in command or ' -not ' in command:
            result['operators'].append('NOT')
        if '\\(' in command or '( ' in command:
            result['operators'].append('grupare')
        
        return result
    
    @staticmethod
    def test_find_command(command: str, test_dir: str) -> Tuple[bool, str, str]:
        """Testează o comandă find într-un director de test"""
        try:
            # Înlocuiește path-ul cu directorul de test
            # Detectează și înlocuiește primul argument care nu e opțiune
            parts = command.split()
            if len(parts) > 1:
                if not parts[1].startswith('-'):
                    parts[1] = test_dir
                else:
                    parts.insert(1, test_dir)
                command = ' '.join(parts)
            
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=test_dir
            )
            
            stdout = result.stdout.strip()
            stderr = result.stderr.strip()
            
            if result.returncode == 0:
                return True, stdout, stderr
            else:
                return False, stdout, stderr
                
        except subprocess.TimeoutExpired:
            return False, "", "Timeout la execuție"
        except Exception as e:
            return False, "", f"Eroare: {str(e)}"
    
    @staticmethod
    def check_dangerous_patterns(command: str) -> List[str]:
        """Verifică pattern-uri periculoase în comenzi find"""
        warnings = []
        
        # -delete fără confirmare
        if '-delete' in command and '-print' not in command:
            warnings.append("⚠️ -delete fără -print pentru verificare prealabilă")
        
        # -exec rm fără -i
        if '-exec' in command and 'rm' in command and '-i' not in command:
            warnings.append("⚠️ -exec rm fără -i (interactiv)")
        
        # Path-uri periculoase
        dangerous_paths = ['/', '/etc', '/usr', '/var', '/home']
        for path in dangerous_paths:
            if f'find {path} ' in command or f'find {path}/' in command:
                if '-delete' in command or 'rm' in command:
                    warnings.append(f"☠️ Comandă periculoasă pe {path}!")
        
        return warnings

class PermissionsValidator:
    """Validare permisiuni și comenzi chmod"""
    
    OCTAL_PATTERN = re.compile(r'^[0-7]{3,4}$')
    SYMBOLIC_PATTERN = re.compile(r'^[ugoa]*[+\-=][rwxXst]+$')
    
    @staticmethod
    def parse_octal(octal: str) -> Dict[str, Any]:
        """Parsează permisiuni octale"""
        result = {
            'valid': True,
            'special': None,
            'owner': None,
            'group': None,
            'others': None,
            'symbolic': '',
            'description': ''
        }
        
        if not PermissionsValidator.OCTAL_PATTERN.match(octal):
            result['valid'] = False
            return result
        
        # Normalizează la 4 cifre
        if len(octal) == 3:
            octal = '0' + octal
        
        special = int(octal[0])
        owner = int(octal[1])
        group = int(octal[2])
        others = int(octal[3])
        
        result['special'] = special
        result['owner'] = owner
        result['group'] = group
        result['others'] = others
        
        # Convertește la simbolic
        def digit_to_rwx(d: int) -> str:
            r = 'r' if d & 4 else '-'
            w = 'w' if d & 2 else '-'
            x = 'x' if d & 1 else '-'
            return r + w + x
        
        symbolic = digit_to_rwx(owner) + digit_to_rwx(group) + digit_to_rwx(others)
        
        # Ajustează pentru special bits
        if special & 4:  # SUID
            symbolic = symbolic[:2] + ('s' if owner & 1 else 'S') + symbolic[3:]
        if special & 2:  # SGID
            symbolic = symbolic[:5] + ('s' if group & 1 else 'S') + symbolic[6:]
        if special & 1:  # Sticky
            symbolic = symbolic[:8] + ('t' if others & 1 else 'T')
        
        result['symbolic'] = symbolic
        
        # Generează descriere
        descriptions = []
        perm_names = {
            '755': 'Standard pentru directoare și scripturi executabile',
            '644': 'Standard pentru fișiere normale',
            '600': 'Fișiere private (doar owner)',
            '700': 'Directoare private',
            '777': '⚠️ PERICULOS - oricine poate face orice',
            '666': '⚠️ PERICULOS - oricine poate citi/scrie',
            '750': 'Director partajat cu grupul',
            '640': 'Fișier partajat cu grupul (read-only)',
            '400': 'Read-only pentru owner',
            '444': 'Read-only pentru toți',
        }
        
        short_octal = octal[-3:]
        if short_octal in perm_names:
            result['description'] = perm_names[short_octal]
        
        return result
    
    @staticmethod
    def check_dangerous_permissions(octal: str) -> List[str]:
        """Verifică permisiuni periculoase"""
        warnings = []
        
        if octal in ['777', '0777']:
            warnings.append("☠️ 777 - Permisiuni complet deschise! Risc major de securitate.")
        elif octal in ['666', '0666']:
            warnings.append("⚠️ 666 - Oricine poate citi/scrie. Nesigur pentru majoritatea cazurilor.")
        elif octal.endswith('7'):
            warnings.append("⚠️ World-writable - oricine poate modifica.")
        elif octal.endswith('6'):
            warnings.append("⚠️ World-readable și writable.")
        
        # SUID pe fișiere nestandard
        if octal.startswith('4') and len(octal) == 4:
            warnings.append("ℹ️ SUID setat - verifică dacă este necesar.")
        
        return warnings
    
    @staticmethod
    def validate_chmod_command(command: str) -> Tuple[bool, List[str]]:
        """Validează o comandă chmod"""
        issues = []
        
        if not command.strip().startswith('chmod'):
            return False, ["Comanda nu începe cu 'chmod'"]
        
        # Verifică pattern-uri periculoase
        if '777' in command:
            issues.append("☠️ Folosește 777 - evită acest lucru!")
        if '666' in command:
            issues.append("⚠️ Folosește 666 - nesigur pentru majoritatea fișierelor")
        
        # Verifică recursivitate fără X
        if '-R' in command and 'X' not in command:
            if re.search(r'-R.*[0-7]{3}', command):
                issues.append("💡 chmod -R cu octal - consideră folosirea 'X' în loc de 'x' pentru directoare")
        
        # Verifică dacă e pe root
        if '/' in command and not re.search(r'/[a-zA-Z]', command):
            issues.append("☠️ Posibil chmod pe / - PERICULOS!")
        
        return len(issues) == 0, issues

class CronValidator:
    """Validare expresii și configurații cron"""
    
    FIELD_RANGES = {
        'minute': (0, 59),
        'hour': (0, 23),
        'dom': (1, 31),
        'month': (1, 12),
        'dow': (0, 7)
    }
    
    SPECIAL_STRINGS = {
        '@reboot': 'La pornirea sistemului',
        '@yearly': 'Anual (0 0 1 1 *)',
        '@annually': 'Anual (0 0 1 1 *)',
        '@monthly': 'Lunar (0 0 1 * *)',
        '@weekly': 'Săptămânal (0 0 * * 0)',
        '@daily': 'Zilnic (0 0 * * *)',
        '@midnight': 'Zilnic (0 0 * * *)',
        '@hourly': 'La fiecare oră (0 * * * *)',
    }
    
    @staticmethod
    def parse_cron_expression(expression: str) -> Dict[str, Any]:
        """Parsează o expresie cron"""
        result = {
            'valid': True,
            'fields': {},
            'description': '',
            'errors': [],
            'warnings': []
        }
        
        expression = expression.strip()
        
        # Verifică string-uri speciale
        if expression.startswith('@'):
            first_word = expression.split()[0]
            if first_word in CronValidator.SPECIAL_STRINGS:
                result['description'] = CronValidator.SPECIAL_STRINGS[first_word]
                result['fields'] = {'special': first_word}
                return result
            else:
                result['valid'] = False
                result['errors'].append(f"String special necunoscut: {first_word}")
                return result
        
        # Parsează cele 5 câmpuri
        parts = expression.split()
        if len(parts) < 5:
            result['valid'] = False
            result['errors'].append(f"Expresie incompletă - necesită 5 câmpuri, găsite {len(parts)}")
            return result
        
        fields = ['minute', 'hour', 'dom', 'month', 'dow']
        for i, (field_name, field_value) in enumerate(zip(fields, parts[:5])):
            validation = CronValidator.validate_field(field_value, field_name)
            result['fields'][field_name] = {
                'value': field_value,
                'valid': validation['valid'],
                'meaning': validation['meaning']
            }
            if not validation['valid']:
                result['valid'] = False
                result['errors'].extend(validation['errors'])
        
        # Generează descriere
        if result['valid']:
            result['description'] = CronValidator.generate_description(result['fields'])
        
        # Verifică pattern-uri problematice
        result['warnings'] = CronValidator.check_problematic_patterns(result['fields'])
        
        return result
    
    @staticmethod
    def validate_field(value: str, field_name: str) -> Dict[str, Any]:
        """Validează un câmp individual"""
        result = {
            'valid': True,
            'meaning': '',
            'errors': []
        }
        
        min_val, max_val = CronValidator.FIELD_RANGES[field_name]
        
        # Wildcard
        if value == '*':
            result['meaning'] = 'orice valoare'
            return result
        
        # Step (*/n sau range/n)
        if '/' in value:
            base, step = value.split('/', 1)
            if not step.isdigit():
                result['valid'] = False
                result['errors'].append(f"Step invalid în {field_name}: {step}")
                return result
            step_val = int(step)
            if base == '*':
                result['meaning'] = f'la fiecare {step_val}'
            else:
                result['meaning'] = f'la fiecare {step_val} în {base}'
            return result
        
        # Range (n-m)
        if '-' in value and not value.startswith('-'):
            parts = value.split('-')
            if len(parts) == 2:
                try:
                    start = int(parts[0])
                    end = int(parts[1])
                    if start < min_val or end > max_val:
                        result['valid'] = False
                        result['errors'].append(f"Interval în afara limitelor pentru {field_name}")
                    else:
                        result['meaning'] = f'de la {start} la {end}'
                    return result
                except ValueError:
                    pass
        
        # List (n,m,o)
        if ',' in value:
            values = value.split(',')
            try:
                nums = [int(v) for v in values]
                for n in nums:
                    if n < min_val or n > max_val:
                        result['valid'] = False
                        result['errors'].append(f"Valoare {n} în afara limitelor pentru {field_name}")
                result['meaning'] = f'valorile {", ".join(values)}'
                return result
            except ValueError:
                result['valid'] = False
                result['errors'].append(f"Valori invalide în {field_name}: {value}")
                return result
        
        # Valoare simplă
        try:
            num = int(value)
            if num < min_val or num > max_val:
                result['valid'] = False
                result['errors'].append(f"Valoare {num} în afara limitelor pentru {field_name} ({min_val}-{max_val})")
            else:
                result['meaning'] = str(num)
            return result
        except ValueError:
            # Poate fi nume de zi sau lună
            day_names = {'sun': 0, 'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6}
            month_names = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
                          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12}
            
            if field_name == 'dow' and value.lower() in day_names:
                result['meaning'] = value.capitalize()
                return result
            if field_name == 'month' and value.lower() in month_names:
                result['meaning'] = value.capitalize()
                return result
            
            result['valid'] = False
            result['errors'].append(f"Valoare invalidă pentru {field_name}: {value}")
            return result
    
    @staticmethod
    def generate_description(fields: Dict) -> str:
        """Generează o descriere în limbaj natural"""
        minute = fields.get('minute', {}).get('value', '*')
        hour = fields.get('hour', {}).get('value', '*')
        dom = fields.get('dom', {}).get('value', '*')
        month = fields.get('month', {}).get('value', '*')
        dow = fields.get('dow', {}).get('value', '*')
        
        # Pattern-uri comune
        if minute == '*' and hour == '*' and dom == '*' and month == '*' and dow == '*':
            return "La fiecare minut"
        if minute == '0' and hour == '*' and dom == '*' and month == '*' and dow == '*':
            return "La fiecare oră (minutul 0)"
        if minute == '0' and hour == '0' and dom == '*' and month == '*' and dow == '*':
            return "Zilnic la miezul nopții"
        
        parts = []
        
        # Timp
        if minute != '*' or hour != '*':
            if minute.isdigit() and hour.isdigit():
                parts.append(f"la {hour}:{minute.zfill(2)}")
            elif minute.startswith('*/'):
                parts.append(f"la fiecare {minute[2:]} minute")
            elif hour.startswith('*/'):
                parts.append(f"la fiecare {hour[2:]} ore")
        
        # Zi
        if dow != '*' and dow != '0-7':
            if dow == '1-5':
                parts.append("Luni-Vineri")
            elif dow in ['0', '7']:
                parts.append("Duminică")
            elif dow == '6':
                parts.append("Sâmbătă")
            else:
                parts.append(f"zilele {dow}")
        
        if dom != '*':
            parts.append(f"pe zilele {dom} ale lunii")
        
        if month != '*':
            parts.append(f"în luna {month}")
        
        return ', '.join(parts) if parts else "Programare personalizată"
    
    @staticmethod
    def check_problematic_patterns(fields: Dict) -> List[str]:
        """Verifică pattern-uri problematice"""
        warnings = []
        
        minute = fields.get('minute', {}).get('value', '')
        
        # Job care rulează prea des
        if minute == '*':
            warnings.append("⚠️ Rulează la fiecare minut - asigură-te că e necesar")
        
        # dom și dow ambele specificate
        dom = fields.get('dom', {}).get('value', '')
        dow = fields.get('dow', {}).get('value', '')
        if dom != '*' and dow != '*':
            warnings.append("ℹ️ Atât dom cât și dow sunt specificate - e relație OR, nu AND!")
        
        return warnings
    
    @staticmethod
    def check_cron_best_practices(cron_line: str) -> List[str]:
        """Verifică best practices pentru o linie crontab"""
        issues = []
        
        # Verifică căi absolute
        if not re.search(r'(^|\s)/\S+\.(sh|py|pl)', cron_line):
            if re.search(r'\.(sh|py|pl)(\s|$)', cron_line):
                issues.append("💡 Folosește căi absolute pentru scripturi")
        
        # Verifică logging
        if '>>' not in cron_line and '>/dev/null' not in cron_line:
            if not cron_line.strip().startswith('#'):
                issues.append("💡 Consideră adăugarea de logging (>> /path/to/log 2>&1)")
        
        # Verifică % neescapat
        if '%' in cron_line and '\\%' not in cron_line:
            if not cron_line.strip().startswith('#'):
                issues.append("⚠️ Caracterul % trebuie escaped (\\%) în crontab")
        
        return issues

# 
# CLASA PRINCIPALĂ DE EVALUARE
# 

class Autograder:
    """Evaluator automat pentru teme Seminar 5-6"""
    
    def __init__(self, submission_path: str, verbose: bool = False):
        self.submission_path = Path(submission_path)
        self.verbose = verbose
        self.result = GradingResult(
            student_id=self._extract_student_id(),
            submission_path=str(self.submission_path),
            timestamp=datetime.now().isoformat()
        )
        self.temp_dir = None
    
    def _extract_student_id(self) -> str:
        """Extrage ID-ul studentului din calea de submisie"""
        # Încearcă să găsească un pattern de ID student
        path_str = str(self.submission_path)
        
        # Pattern: nume_prenume sau similar
        match = re.search(r'([a-zA-Z]+_[a-zA-Z]+)', path_str)
        if match:
            return match.group(1)
        
        # Folosește numele directorului
        return self.submission_path.name
    
    def _log(self, message: str, level: str = "info"):
        """Logging cu nivele"""
        if not self.verbose and level == "debug":
            return
        
        prefix = {
            "info": f"{Colors.CYAN}ℹ️ {Colors.RESET}",
            "success": f"{Colors.GREEN}✅{Colors.RESET}",
            "warning": f"{Colors.YELLOW}⚠️ {Colors.RESET}",
            "error": f"{Colors.RED}❌{Colors.RESET}",
            "debug": f"{Colors.GRAY}🔍{Colors.RESET}",
        }.get(level, "")
        
        print(f"{prefix} {message}")
    
    def setup_test_environment(self):
        """Creează mediu de test temporar"""
        self.temp_dir = tempfile.mkdtemp(prefix="autograder_")
        
        # Creează structură de directoare pentru teste
        test_dirs = ['src', 'docs', 'tests', 'build', 'logs']
        for d in test_dirs:
            os.makedirs(os.path.join(self.temp_dir, d), exist_ok=True)
        
        # Creează fișiere de test
        test_files = [
            ('src/main.c', '// Main source file\nint main() { return 0; }'),
            ('src/utils.c', '// Utilities'),
            ('src/config.h', '// Config header'),
            ('docs/README.md', '# Documentation'),
            ('docs/manual.txt', 'User manual'),
            ('tests/test_main.py', '# Test file'),
            ('tests/test_utils.py', '# Test utilities'),
            ('logs/app.log', 'Log entries here'),
            ('build/output.o', 'Binary content'),
        ]
        
        for path, content in test_files:
            full_path = os.path.join(self.temp_dir, path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            with open(full_path, 'w') as f:
                f.write(content)
        
        # Creează fișiere cu diferite dimensiuni
        with open(os.path.join(self.temp_dir, 'large_file.bin'), 'wb') as f:
            f.write(b'\0' * (2 * 1024 * 1024))  # 2MB
        
        # Creează fișiere cu timestamps diferite
        old_file = os.path.join(self.temp_dir, 'old_file.txt')
        with open(old_file, 'w') as f:
            f.write('Old content')
        os.utime(old_file, (0, 0))  # Timestamp foarte vechi
        
        self._log(f"Mediu de test creat în {self.temp_dir}", "debug")
    
    def cleanup_test_environment(self):
        """Curăță mediul de test"""
        if self.temp_dir and os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
            self._log("Mediu de test curățat", "debug")
    
    def grade(self) -> GradingResult:
        """Execută evaluarea completă"""
        self._log(f"Începe evaluarea pentru: {self.submission_path}")
        
        try:
            self.setup_test_environment()
            
            # Verifică că directorul există
            if not self.submission_path.exists():
                self.result.warnings.append(f"Directorul de submisie nu există: {self.submission_path}")
                return self.result
            
            # Evaluare pe categorii
            self._grade_find_commands()
            self._grade_scripts()
            self._grade_permissions()
            self._grade_cron()
            
            # Verificări de securitate finale
            self._security_check()
            
        finally:
            self.cleanup_test_environment()
        
        return self.result
    
    def _grade_find_commands(self):
        """Evaluează comenzile find"""
        category = CategoryResult(name="Comenzi Find și Xargs")
        
        # Caută fișierul cu comenzi find
        find_files = list(self.submission_path.glob('**/find*.txt')) + \
                    list(self.submission_path.glob('**/comenzi*.txt'))
        
        if not find_files:
            category.tests.append(TestResult(
                name="Fișier comenzi find",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=20,
                message="Nu s-a găsit fișierul cu comenzi find"
            ))
        else:
            find_file = find_files[0]
            self._log(f"Analizez comenzi find din: {find_file}")
            
            with open(find_file, 'r') as f:
                content = f.read()
            
            # Extrage comenzile find
            commands = [line.strip() for line in content.split('\n') 
                       if line.strip().startswith('find')]
            
            if commands:
                # Test 1: Număr comenzi
                category.tests.append(TestResult(
                    name="Număr comenzi find",
                    status=TestStatus.PASSED if len(commands) >= 5 else TestStatus.PARTIAL,
                    points_earned=min(len(commands), 5) * 2,
                    points_max=10,
                    message=f"{len(commands)} comenzi find găsite",
                    suggestions=["Cerință: minim 5 comenzi find diverse"] if len(commands) < 5 else []
                ))
                
                # Test 2: Diversitate teste
                all_tests = set()
                for cmd in commands:
                    parsed = FindValidator.parse_find_command(cmd)
                    for test, _ in parsed.get('tests', []):
                        all_tests.add(test)
                
                diversity_score = min(len(all_tests) / 5, 1.0) * 10
                category.tests.append(TestResult(
                    name="Diversitate teste find",
                    status=TestStatus.PASSED if len(all_tests) >= 5 else TestStatus.PARTIAL,
                    points_earned=diversity_score,
                    points_max=10,
                    message=f"Teste folosite: {', '.join(all_tests)}",
                    details=[f"Total tipuri de teste: {len(all_tests)}"]
                ))
                
                # Test 3: Utilizare xargs
                xargs_commands = [c for c in content.split('\n') if 'xargs' in c]
                category.tests.append(TestResult(
                    name="Utilizare xargs",
                    status=TestStatus.PASSED if xargs_commands else TestStatus.FAILED,
                    points_earned=10 if xargs_commands else 0,
                    points_max=10,
                    message=f"{len(xargs_commands)} comenzi cu xargs" if xargs_commands else "Lipsește utilizarea xargs",
                    suggestions=[] if xargs_commands else ["Adaugă exemple cu find | xargs"]
                ))
                
                # Test 4: Verificări de securitate
                all_warnings = []
                for cmd in commands:
                    warnings = FindValidator.check_dangerous_patterns(cmd)
                    all_warnings.extend(warnings)
                
                if all_warnings:
                    self.result.security_issues.extend(all_warnings)
                    category.tests.append(TestResult(
                        name="Securitate comenzi find",
                        status=TestStatus.PARTIAL,
                        points_earned=5,
                        points_max=10,
                        message="Probleme de securitate detectate",
                        details=all_warnings
                    ))
                else:
                    category.tests.append(TestResult(
                        name="Securitate comenzi find",
                        status=TestStatus.PASSED,
                        points_earned=10,
                        points_max=10,
                        message="Fără probleme de securitate detectate"
                    ))
        
        self.result.categories.append(category)
    
    def _grade_scripts(self):
        """Evaluează scripturile bash"""
        category = CategoryResult(name="Scripturi Bash cu Parametri")
        
        # Caută scripturi .sh
        scripts = list(self.submission_path.glob('**/*.sh'))
        
        if not scripts:
            category.tests.append(TestResult(
                name="Scripturi bash",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=30,
                message="Nu s-au găsit scripturi .sh"
            ))
        else:
            self._log(f"Analizez {len(scripts)} scripturi bash")
            
            for script in scripts[:3]:  # Limitează la primele 3
                script_name = script.name
                
                # Verificare sintaxă
                syntax_ok, syntax_msg = BashValidator.check_syntax(str(script))
                category.tests.append(TestResult(
                    name=f"Sintaxă: {script_name}",
                    status=TestStatus.PASSED if syntax_ok else TestStatus.FAILED,
                    points_earned=5 if syntax_ok else 0,
                    points_max=5,
                    message=syntax_msg
                ))
                
                if not syntax_ok:
                    continue
                
                # Citește conținutul
                with open(script, 'r') as f:
                    content = f.read()
                
                # Verificare shebang
                shebang_ok, shebang_msg = BashValidator.check_shebang(str(script))
                category.tests.append(TestResult(
                    name=f"Shebang: {script_name}",
                    status=TestStatus.PASSED if shebang_ok else TestStatus.FAILED,
                    points_earned=2 if shebang_ok else 0,
                    points_max=2,
                    message=shebang_msg
                ))
                
                # Verificare usage/help
                has_usage = BashValidator.has_usage_function(content)
                category.tests.append(TestResult(
                    name=f"Funcție help: {script_name}",
                    status=TestStatus.PASSED if has_usage else TestStatus.FAILED,
                    points_earned=3 if has_usage else 0,
                    points_max=3,
                    message="Are funcție usage/help" if has_usage else "Lipsește funcția de ajutor",
                    suggestions=[] if has_usage else ["Adaugă o funcție usage() pentru -h/--help"]
                ))
                
                # Verificare getopts
                uses_getopts = BashValidator.uses_getopts(content)
                if uses_getopts:
                    uses_shift = BashValidator.uses_shift_after_getopts(content)
                    category.tests.append(TestResult(
                        name=f"getopts: {script_name}",
                        status=TestStatus.PASSED if uses_shift else TestStatus.PARTIAL,
                        points_earned=5 if uses_shift else 3,
                        points_max=5,
                        message="Folosește getopts corect cu shift" if uses_shift else "Folosește getopts dar fără shift OPTIND",
                        suggestions=[] if uses_shift else ["Adaugă: shift $((OPTIND - 1)) după bucla getopts"]
                    ))
                
                # Verificare error handling
                error_checks = BashValidator.check_error_handling(content)
                error_score = sum(error_checks.values()) * 1.5
                error_details = [f"{'✓' if v else '✗'} {k}" for k, v in error_checks.items()]
                category.tests.append(TestResult(
                    name=f"Error handling: {script_name}",
                    status=TestStatus.PASSED if error_score >= 6 else TestStatus.PARTIAL,
                    points_earned=min(error_score, 9),
                    points_max=9,
                    message=f"{sum(error_checks.values())}/6 tehnici de error handling",
                    details=error_details
                ))
        
        self.result.categories.append(category)
    
    def _grade_permissions(self):
        """Evaluează configurările de permisiuni"""
        category = CategoryResult(name="Permisiuni și chmod")
        
        # Caută fișiere relevante
        perm_files = list(self.submission_path.glob('**/perm*.txt')) + \
                    list(self.submission_path.glob('**/chmod*.txt')) + \
                    list(self.submission_path.glob('**/permis*.sh'))
        
        if not perm_files:
            # Verifică în scripturi
            scripts = list(self.submission_path.glob('**/*.sh'))
            chmod_usage = False
            for script in scripts:
                with open(script, 'r') as f:
                    if 'chmod' in f.read():
                        chmod_usage = True
                        perm_files.append(script)
            
        if not perm_files:
            category.tests.append(TestResult(
                name="Configurări permisiuni",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=25,
                message="Nu s-au găsit configurări de permisiuni"
            ))
        else:
            # Analizează comenzile chmod găsite
            all_chmod_commands = []
            for pf in perm_files:
                with open(pf, 'r') as f:
                    content = f.read()
                    # Extrage comenzi chmod
                    chmod_matches = re.findall(r'chmod\s+[^\n]+', content)
                    all_chmod_commands.extend(chmod_matches)
            
            if all_chmod_commands:
                # Test: Număr comenzi chmod
                category.tests.append(TestResult(
                    name="Comenzi chmod",
                    status=TestStatus.PASSED if len(all_chmod_commands) >= 3 else TestStatus.PARTIAL,
                    points_earned=min(len(all_chmod_commands) * 2, 10),
                    points_max=10,
                    message=f"{len(all_chmod_commands)} comenzi chmod găsite"
                ))
                
                # Test: Utilizare octal și simbolic
                octal_used = any(re.search(r'chmod\s+[0-7]{3,4}', cmd) for cmd in all_chmod_commands)
                symbolic_used = any(re.search(r'chmod\s+[ugoa]+[+\-=]', cmd) for cmd in all_chmod_commands)
                
                category.tests.append(TestResult(
                    name="Mod octal",
                    status=TestStatus.PASSED if octal_used else TestStatus.FAILED,
                    points_earned=5 if octal_used else 0,
                    points_max=5,
                    message="Folosește chmod cu valori octale" if octal_used else "Nu folosește chmod octal"
                ))
                
                category.tests.append(TestResult(
                    name="Mod simbolic",
                    status=TestStatus.PASSED if symbolic_used else TestStatus.FAILED,
                    points_earned=5 if symbolic_used else 0,
                    points_max=5,
                    message="Folosește chmod simbolic" if symbolic_used else "Nu folosește chmod simbolic"
                ))
                
                # Verificare securitate permisiuni
                all_issues = []
                for cmd in all_chmod_commands:
                    valid, issues = PermissionsValidator.validate_chmod_command(cmd)
                    all_issues.extend(issues)
                
                if all_issues:
                    self.result.security_issues.extend(all_issues)
                
                category.tests.append(TestResult(
                    name="Securitate permisiuni",
                    status=TestStatus.PASSED if not all_issues else TestStatus.PARTIAL,
                    points_earned=5 if not all_issues else 2,
                    points_max=5,
                    message="Fără probleme de securitate" if not all_issues else f"{len(all_issues)} probleme găsite",
                    details=all_issues
                ))
        
        self.result.categories.append(category)
    
    def _grade_cron(self):
        """Evaluează configurările cron"""
        category = CategoryResult(name="Configurare Cron")
        
        # Caută fișiere crontab
        cron_files = list(self.submission_path.glob('**/cron*.txt')) + \
                    list(self.submission_path.glob('**/crontab*')) + \
                    list(self.submission_path.glob('**/*.cron'))
        
        if not cron_files:
            category.tests.append(TestResult(
                name="Configurări cron",
                status=TestStatus.SKIPPED,
                points_earned=0,
                points_max=15,
                message="Nu s-au găsit configurări cron"
            ))
        else:
            self._log(f"Analizez {len(cron_files)} fișiere cron")
            
            all_cron_lines = []
            for cf in cron_files:
                with open(cf, 'r') as f:
                    lines = [l.strip() for l in f.readlines() 
                            if l.strip() and not l.strip().startswith('#')]
                    all_cron_lines.extend(lines)
            
            valid_expressions = 0
            cron_warnings = []
            
            for line in all_cron_lines:
                # Extrage expresia (primele 5 câmpuri sau string special)
                if line.startswith('@'):
                    expr = line.split()[0]
                else:
                    parts = line.split()
                    if len(parts) >= 5:
                        expr = ' '.join(parts[:5])
                    else:
                        continue
                
                parsed = CronValidator.parse_cron_expression(expr)
                if parsed['valid']:
                    valid_expressions += 1
                
                # Best practices
                bp_issues = CronValidator.check_cron_best_practices(line)
                cron_warnings.extend(bp_issues)
            
            # Test: Expresii cron valide
            category.tests.append(TestResult(
                name="Expresii cron valide",
                status=TestStatus.PASSED if valid_expressions >= 3 else TestStatus.PARTIAL,
                points_earned=min(valid_expressions * 3, 9),
                points_max=9,
                message=f"{valid_expressions} expresii cron valide",
                suggestions=["Cerință: minim 3 expresii cron"] if valid_expressions < 3 else []
            ))
            
            # Test: Best practices
            category.tests.append(TestResult(
                name="Best practices cron",
                status=TestStatus.PASSED if not cron_warnings else TestStatus.PARTIAL,
                points_earned=6 if not cron_warnings else 3,
                points_max=6,
                message="Urmează best practices" if not cron_warnings else f"{len(cron_warnings)} sugestii",
                details=cron_warnings
            ))
        
        self.result.categories.append(category)
    
    def _security_check(self):
        """Verificări finale de securitate"""
        # Caută pattern-uri periculoase în toate fișierele
        dangerous_patterns = [
            (r'rm\s+-rf\s+/', "rm -rf / detectat!"),
            (r'chmod\s+777\s+/', "chmod 777 pe rădăcină!"),
            (r'eval\s+\$', "eval cu variabilă - risc de injecție"),
            (r'\|\s*bash', "Pipe direct în bash - risc de injecție"),
            (r'curl.*\|\s*sh', "curl | sh - execuție cod remote nesigur"),
        ]
        
        for file_path in self.submission_path.glob('**/*'):
            if file_path.is_file() and file_path.suffix in ['.sh', '.txt', '.cron', '']:
                try:
                    with open(file_path, 'r', errors='ignore') as f:
                        content = f.read()
                    
                    for pattern, message in dangerous_patterns:
                        if re.search(pattern, content):
                            self.result.security_issues.append(
                                f"☠️ {message} în {file_path.name}"
                            )
                except Exception:
                    pass

# 
# RAPORTARE
# 

class ReportGenerator:
    """Generator de rapoarte"""
    
    @staticmethod
    def print_console_report(result: GradingResult):
        """Afișează raportul în consolă"""
        c = Colors
        
        print()
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print(f"{c.CYAN}║{c.RESET} {c.BOLD}RAPORT EVALUARE - Seminar 5-6 SO{c.RESET}")
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print()
        
        print(f"  {c.WHITE}Student:{c.RESET} {result.student_id}")
        print(f"  {c.WHITE}Data:{c.RESET} {result.timestamp}")
        print(f"  {c.WHITE}Submisie:{c.RESET} {result.submission_path}")
        print()
        
        # Rezultate pe categorii
        for category in result.categories:
            status_icon = "✅" if category.percentage >= 80 else "⚠️" if category.percentage >= 50 else "❌"
            print(f"{c.YELLOW}┌{'─' * 78}┐{c.RESET}")
            print(f"{c.YELLOW}│{c.RESET} {status_icon} {c.BOLD}{category.name}{c.RESET}")
            print(f"{c.YELLOW}│{c.RESET}   Punctaj: {category.total_earned:.1f}/{category.total_max:.1f} ({category.percentage:.1f}%)")
            print(f"{c.YELLOW}└{'─' * 78}┘{c.RESET}")
            
            for test in category.tests:
                if test.status == TestStatus.PASSED:
                    icon = f"{c.GREEN}✓{c.RESET}"
                elif test.status == TestStatus.PARTIAL:
                    icon = f"{c.YELLOW}◐{c.RESET}"
                elif test.status == TestStatus.SKIPPED:
                    icon = f"{c.GRAY}○{c.RESET}"
                else:
                    icon = f"{c.RED}✗{c.RESET}"
                
                print(f"  {icon} {test.name}: {test.points_earned:.1f}/{test.points_max:.1f}")
                print(f"    {c.DIM}{test.message}{c.RESET}")
                
                for detail in test.details[:3]:
                    print(f"    {c.GRAY}  • {detail}{c.RESET}")
                
                for suggestion in test.suggestions:
                    print(f"    {c.CYAN}  💡 {suggestion}{c.RESET}")
            
            print()
        
        # Probleme de securitate
        if result.security_issues:
            print(f"{c.RED}{'─' * 80}{c.RESET}")
            print(f"{c.RED}⚠️  PROBLEME DE SECURITATE DETECTATE:{c.RESET}")
            for issue in result.security_issues:
                print(f"  {c.RED}• {issue}{c.RESET}")
            print()
        
        # Avertismente
        if result.warnings:
            print(f"{c.YELLOW}{'─' * 80}{c.RESET}")
            print(f"{c.YELLOW}ℹ️  AVERTISMENTE:{c.RESET}")
            for warning in result.warnings:
                print(f"  {c.YELLOW}• {warning}{c.RESET}")
            print()
        
        # Rezumat final
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        grade_color = c.GREEN if result.percentage >= 50 else c.RED
        print(f"{c.CYAN}║{c.RESET} {c.BOLD}REZULTAT FINAL:{c.RESET}")
        print(f"{c.CYAN}║{c.RESET}   Punctaj total: {result.total_earned:.1f}/{result.total_max:.1f} ({result.percentage:.1f}%)")
        print(f"{c.CYAN}║{c.RESET}   Notă estimată: {grade_color}{result.grade}{c.RESET}")
        print(f"{c.CYAN}{'═' * 80}{c.RESET}")
        print()
    
    @staticmethod
    def generate_json_report(result: GradingResult) -> str:
        """Generează raport JSON"""
        data = {
            'student_id': result.student_id,
            'submission_path': result.submission_path,
            'timestamp': result.timestamp,
            'total_earned': result.total_earned,
            'total_max': result.total_max,
            'percentage': result.percentage,
            'grade': result.grade,
            'categories': [],
            'security_issues': result.security_issues,
            'warnings': result.warnings
        }
        
        for cat in result.categories:
            cat_data = {
                'name': cat.name,
                'total_earned': cat.total_earned,
                'total_max': cat.total_max,
                'percentage': cat.percentage,
                'tests': []
            }
            for test in cat.tests:
                cat_data['tests'].append({
                    'name': test.name,
                    'status': test.status.value,
                    'points_earned': test.points_earned,
                    'points_max': test.points_max,
                    'message': test.message,
                    'details': test.details,
                    'suggestions': test.suggestions
                })
            data['categories'].append(cat_data)
        
        return json.dumps(data, indent=2, ensure_ascii=False)
    
    @staticmethod
    def generate_markdown_report(result: GradingResult) -> str:
        """Generează raport Markdown"""
        lines = [
            f"# Raport Evaluare - Seminar 5-6 SO",
            "",
            f"**Student:** {result.student_id}",
            f"**Data:** {result.timestamp}",
            f"**Notă estimată:** {result.grade}",
            "",
            "## Rezultate",
            "",
            f"| Total | {result.total_earned:.1f} / {result.total_max:.1f} | {result.percentage:.1f}% |",
            "|-------|---------|------|",
            ""
        ]
        
        for cat in result.categories:
            lines.append(f"### {cat.name}")
            lines.append("")
            lines.append(f"Punctaj: **{cat.total_earned:.1f} / {cat.total_max:.1f}** ({cat.percentage:.1f}%)")
            lines.append("")
            lines.append("| Test | Punctaj | Status |")
            lines.append("|------|---------|--------|")
            
            for test in cat.tests:
                status_emoji = "✅" if test.status == TestStatus.PASSED else "⚠️" if test.status == TestStatus.PARTIAL else "❌"
                lines.append(f"| {test.name} | {test.points_earned:.1f}/{test.points_max:.1f} | {status_emoji} |")
            
            lines.append("")
        
        if result.security_issues:
            lines.append("## ⚠️ Probleme de Securitate")
            lines.append("")
            for issue in result.security_issues:
                lines.append(f"- {issue}")
            lines.append("")
        
        return '\n'.join(lines)

# 
# INTERFAȚĂ CLI
# 

def create_sample_submission():
    """Creează o submisie exemplu pentru testare"""
    sample_dir = Path('./sample_submission')
    sample_dir.mkdir(exist_ok=True)
    
    # Fișier comenzi find
    (sample_dir / 'comenzi_find.txt').write_text("""# Comenzi find pentru tema S5-6

# Găsește toate fișierele .c
find . -type f -name "*.c"

# Găsește fișiere mai mari de 1MB
find . -type f -size +1M

# Găsește fișiere modificate în ultima oră
find . -type f -mmin -60

# Găsește și afișează cu ls -l
find . -type f -name "*.txt" -exec ls -l {} \\;

# Combinație cu xargs
find . -type f -name "*.log" -print0 | xargs -0 wc -l

# Șterge fișiere vechi (cu verificare)
find /tmp -type f -mtime +30 -print -delete
""")
    
    # Script cu getopts
    (sample_dir / 'fileinfo.sh').write_text("""#!/bin/bash
# Script pentru afișare informații fișiere

set -e

usage() {
    echo "Utilizare: $0 [-h] [-v] [-s] file..."
    echo "  -h  Afișează acest ajutor"
    echo "  -v  Mod verbose"
    echo "  -s  Afișează dimensiunea"
    exit 0
}

VERBOSE=false
SHOW_SIZE=false

while getopts "hvs" opt; do
    case $opt in
        h) usage ;;
        v) VERBOSE=true ;;
        s) SHOW_SIZE=true ;;
        ?) echo "Opțiune invalidă"; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo "Eroare: specificați cel puțin un fișier"
    exit 1
fi

for file in "$@"; do
    if [ ! -e "$file" ]; then
        echo "Fișierul nu există: $file"
        continue
    fi
    
    echo "Fișier: $file"
    if $SHOW_SIZE; then
        ls -lh "$file" | awk '{print "  Dimensiune: " $5}'
    fi
    if $VERBOSE; then
        file "$file" | sed 's/^/  Tip: /'
    fi
done
""")
    
    # Fișier permisiuni
    (sample_dir / 'permisiuni.txt').write_text("""# Configurări permisiuni

# Setare permisiuni standard pentru scripturi
chmod 755 script.sh

# Fișier privat
chmod 600 config.txt

# Director partajat cu grupul
chmod 750 shared_dir

# Mod simbolic
chmod u+x,g+r,o-rwx important.sh

# GREȘIT: Nu face asta!
# chmod 777 everything.sh
""")
    
    # Fișier crontab
    (sample_dir / 'crontab.txt').write_text("""# Crontab pentru tema S5-6

# Backup zilnic la 3 AM
0 3 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Cleanup săptămânal (Duminică)
0 0 * * 0 /home/user/cleanup.sh

# Health check la fiecare oră în timpul zilei
0 9-18 * * 1-5 /home/user/health_check.sh >> /var/log/health.log 2>&1

# La pornirea sistemului
@reboot /home/user/start_services.sh
""")
    
    print(f"Submisie exemplu creată în: {sample_dir}")
    return sample_dir

def main():
    parser = argparse.ArgumentParser(
        description='Evaluator automat pentru teme Seminar 5-6 SO',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple de utilizare:
  %(prog)s --submission ./student_tema/
  %(prog)s --submission ./student_tema/ --verbose
  %(prog)s --submission ./student_tema/ --output report.json
  %(prog)s --create-sample
  %(prog)s --test-cron "0 3 * * *"
  %(prog)s --test-find "find . -type f -name '*.txt'"
        """
    )
    
    parser.add_argument('--submission', '-s', type=str,
                       help='Directorul cu submisia de evaluat')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Mod verbose')
    parser.add_argument('--output', '-o', type=str,
                       help='Fișier output pentru raport (JSON sau MD)')
    parser.add_argument('--batch', '-b', type=str,
                       help='Evaluare în lot - director cu mai multe submisii')
    parser.add_argument('--create-sample', action='store_true',
                       help='Creează o submisie exemplu pentru testare')
    parser.add_argument('--test-cron', type=str,
                       help='Testează o expresie cron')
    parser.add_argument('--test-find', type=str,
                       help='Testează o comandă find')
    parser.add_argument('--test-permissions', type=str,
                       help='Testează permisiuni octale (ex: 755)')
    parser.add_argument('--no-color', action='store_true',
                       help='Dezactivează culorile')
    
    args = parser.parse_args()
    
    if args.no_color:
        Colors.disable()
    
    # Creează submisie exemplu
    if args.create_sample:
        create_sample_submission()
        return 0
    
    # Testează expresie cron
    if args.test_cron:
        result = CronValidator.parse_cron_expression(args.test_cron)
        print(f"Expresie: {args.test_cron}")
        print(f"Valid: {result['valid']}")
        print(f"Descriere: {result['description']}")
        if result['errors']:
            print(f"Erori: {', '.join(result['errors'])}")
        if result['warnings']:
            print(f"Avertismente: {', '.join(result['warnings'])}")
        return 0
    
    # Testează comandă find
    if args.test_find:
        result = FindValidator.parse_find_command(args.test_find)
        print(f"Comandă: {args.test_find}")
        print(f"Valid: {result['valid']}")
        print(f"Path: {result['path']}")
        print(f"Teste: {[t[0] for t in result['tests']]}")
        print(f"Acțiuni: {[a[0] for a in result['actions']]}")
        warnings = FindValidator.check_dangerous_patterns(args.test_find)
        if warnings:
            print(f"Avertismente: {warnings}")
        return 0
    
    # Testează permisiuni
    if args.test_permissions:
        result = PermissionsValidator.parse_octal(args.test_permissions)
        print(f"Octal: {args.test_permissions}")
        print(f"Valid: {result['valid']}")
        print(f"Simbolic: {result['symbolic']}")
        print(f"Descriere: {result['description']}")
        warnings = PermissionsValidator.check_dangerous_permissions(args.test_permissions)
        if warnings:
            print(f"Avertismente: {warnings}")
        return 0
    
    # Evaluare submisie
    if args.submission:
        grader = Autograder(args.submission, verbose=args.verbose)
        result = grader.grade()
        
        # Afișează raport în consolă
        ReportGenerator.print_console_report(result)
        
        # Salvează raport dacă specificat
        if args.output:
            if args.output.endswith('.json'):
                with open(args.output, 'w') as f:
                    f.write(ReportGenerator.generate_json_report(result))
            elif args.output.endswith('.md'):
                with open(args.output, 'w') as f:
                    f.write(ReportGenerator.generate_markdown_report(result))
            print(f"Raport salvat în: {args.output}")
        
        return 0 if result.percentage >= 50 else 1
    
    # Evaluare în lot
    if args.batch:
        batch_dir = Path(args.batch)
        if not batch_dir.exists():
            print(f"Directorul nu există: {batch_dir}")
            return 1
        
        results = []
        for sub_dir in sorted(batch_dir.iterdir()):
            if sub_dir.is_dir():
                print(f"\n{'='*60}")
                print(f"Evaluare: {sub_dir.name}")
                print(f"{'='*60}")
                
                grader = Autograder(str(sub_dir), verbose=args.verbose)
                result = grader.grade()
                results.append(result)
                
                print(f"  → {result.student_id}: {result.percentage:.1f}% (Nota: {result.grade})")
        
        # Statistici sumare
        print(f"\n{'='*60}")
        print("STATISTICI GENERALE")
        print(f"{'='*60}")
        print(f"Total evaluări: {len(results)}")
        avg = sum(r.percentage for r in results) / len(results) if results else 0
        print(f"Medie: {avg:.1f}%")
        passed = sum(1 for r in results if float(r.grade) >= 5)
        print(f"Promovați: {passed}/{len(results)}")
        
        return 0
    
    # Fără argumente - afișează help
    parser.print_help()
    return 0

if __name__ == '__main__':
    sys.exit(main())
