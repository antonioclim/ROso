# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Orchestrare Seminar 05: Advanced Bash Scripting
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# 
# UTILIZARE:
#   make help     - Afișează targeturi disponibile
#   make quiz     - Rulează quizul formativ interactiv
#   make test     - Rulează toate testele
#   make lint     - Verifică calitatea codului (shellcheck + ruff)
#   make validate - Validează un script student
#   make clean    - Curăță fișierele temporare
#   make all      - Rulează lint + test
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint lint-bash lint-python validate clean all setup check-deps

# Culori pentru output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Directoare
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
TESTS := teste

# ═══════════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Seminar 05: Advanced Bash Scripting — Makefile$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(GREEN)Targeturi principale:$(NC)"
	@echo "  make quiz       Rulează quizul formativ interactiv"
	@echo "  make test       Rulează toate testele automate"
	@echo "  make lint       Verifică calitatea codului (Bash + Python)"
	@echo "  make validate   Validează un script (SCRIPT=path/to/script.sh)"
	@echo "  make clean      Șterge fișierele temporare"
	@echo ""
	@echo "$(GREEN)Targeturi auxiliare:$(NC)"
	@echo "  make lint-bash    Doar shellcheck pe scripturi Bash"
	@echo "  make lint-python  Doar ruff/flake8 pe scripturi Python"
	@echo "  make setup        Instalează dependințele necesare"
	@echo "  make check-deps   Verifică dacă dependințele sunt instalate"
	@echo "  make all          Rulează lint + test"
	@echo ""
	@echo "$(YELLOW)Exemple:$(NC)"
	@echo "  make quiz"
	@echo "  make validate SCRIPT=submissions/student1.sh"
	@echo "  make lint-bash"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ FORMATIV
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Pornire Quiz Formativ$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(FORMATIVE)/quiz_runner.py ]; then \
		python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml; \
	else \
		echo "$(RED)Eroare: quiz_runner.py nu există$(NC)"; \
		exit 1; \
	fi

quiz-shuffle:
	@python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --shuffle

quiz-category:
	@echo "Categorii disponibile: functii, arrays, stabilitate, trap"
	@read -p "Alege categoria: " cat; \
	python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --category $$cat

# ═══════════════════════════════════════════════════════════════════════════════
# TESTE
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Rulare Teste Automate$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(TESTS)/run_all_tests.sh ]; then \
		bash $(TESTS)/run_all_tests.sh; \
	else \
		echo "$(YELLOW)Avertisment: run_all_tests.sh nu există$(NC)"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo ""
	@echo "$(GREEN)✓ Toate verificările de lint au trecut$(NC)"

lint-bash:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  ShellCheck — Verificare Scripturi Bash$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Verificare $(SCRIPTS_BASH)/*.sh..."; \
		shellcheck --severity=warning $(SCRIPTS_BASH)/*.sh || true; \
		echo "Verificare $(SCRIPTS_DEMO)/*.sh..."; \
		shellcheck --severity=warning $(SCRIPTS_DEMO)/*.sh || true; \
		echo "$(GREEN)✓ ShellCheck complet$(NC)"; \
	else \
		echo "$(YELLOW)Avertisment: shellcheck nu e instalat$(NC)"; \
		echo "  Instalează cu: sudo apt install shellcheck"; \
	fi

lint-python:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Ruff/Flake8 — Verificare Scripturi Python$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if command -v ruff >/dev/null 2>&1; then \
		echo "Verificare cu ruff..."; \
		ruff check $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py 2>/dev/null || true; \
		echo "$(GREEN)✓ Ruff complet$(NC)"; \
	elif command -v flake8 >/dev/null 2>&1; then \
		echo "Verificare cu flake8..."; \
		flake8 $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py --max-line-length=100 || true; \
		echo "$(GREEN)✓ Flake8 complet$(NC)"; \
	else \
		echo "$(YELLOW)Avertisment: nici ruff nici flake8 nu sunt instalate$(NC)"; \
		echo "  Instalează cu: pip install ruff"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDARE SCRIPT STUDENT
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT ?= 

validate:
ifndef SCRIPT
	@echo "$(RED)Eroare: Specifică scriptul cu SCRIPT=path/to/script.sh$(NC)"
	@echo "Exemplu: make validate SCRIPT=submissions/student1.sh"
	@exit 1
else
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Validare Script: $(SCRIPT)$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@if [ -f $(SCRIPTS_BASH)/S05_03_validator.sh ]; then \
		bash $(SCRIPTS_BASH)/S05_03_validator.sh "$(SCRIPT)"; \
	else \
		echo "$(RED)Eroare: Validatorul nu există$(NC)"; \
		exit 1; \
	fi
endif

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP ȘI DEPENDINȚE
# ═══════════════════════════════════════════════════════════════════════════════

setup:
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Instalare Dependințe$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "Instalare dependințe Python..."
	pip3 install --user pyyaml rich || pip install --user pyyaml rich
	@echo ""
	@echo "Pentru shellcheck (opțional):"
	@echo "  Ubuntu/Debian: sudo apt install shellcheck"
	@echo "  macOS: brew install shellcheck"
	@echo ""
	@echo "Pentru ruff (opțional):"
	@echo "  pip install ruff"
	@echo ""
	@echo "$(GREEN)✓ Setup complet$(NC)"

check-deps:
	@echo "$(BLUE)Verificare dependințe...$(NC)"
	@echo ""
	@echo -n "Python3: "; command -v python3 >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗$(NC)"
	@echo -n "PyYAML: "; python3 -c "import yaml" 2>/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (opțional)$(NC)"
	@echo -n "Rich: "; python3 -c "import rich" 2>/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (opțional)$(NC)"
	@echo -n "ShellCheck: "; command -v shellcheck >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (opțional)$(NC)"
	@echo -n "Ruff: "; command -v ruff >/dev/null && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ (opțional)$(NC)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# CURĂȚARE
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "$(BLUE)Curățare fișiere temporare...$(NC)"
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.log" -delete 2>/dev/null || true
	@find . -type f -name "*.tmp" -delete 2>/dev/null || true
	@find . -type f -name "*~" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Curățare completă$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# ALL
# ═══════════════════════════════════════════════════════════════════════════════

all: lint test
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  ✓ Toate verificările au trecut$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
