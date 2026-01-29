# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Seminarul 04: Text Processing
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# Orchestrare: quiz, teste, linting, setup
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help setup quiz test lint clean demo all check-deps

# Variabile
SHELL := /bin/bash
PYTHON := python3
SHELLCHECK := shellcheck
SEMINAR := 04

# Directoare
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
TESTE := teste
TEME_SOL := teme/solutii

# Culori pentru output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET-URI PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════

help: ## Afișează acest mesaj de ajutor
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║  Makefile — Seminarul $(SEMINAR): Text Processing                      ║"
	@echo "╠════════════════════════════════════════════════════════════════════╣"
	@echo "║  Target-uri disponibile:                                           ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

all: check-deps lint test ## Rulează lint și teste complete
	@echo -e "$(GREEN)✓ Toate verificările au trecut$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP ȘI DEPENDENȚE
# ═══════════════════════════════════════════════════════════════════════════════

check-deps: ## Verifică dependențele necesare
	@echo "Verificare dependențe..."
	@command -v $(PYTHON) >/dev/null 2>&1 || { echo -e "$(RED)✗ Python3 lipsește$(NC)"; exit 1; }
	@command -v $(SHELLCHECK) >/dev/null 2>&1 || echo -e "$(YELLOW)⚠ shellcheck lipsește (opțional)$(NC)"
	@$(PYTHON) -c "import yaml" 2>/dev/null || echo -e "$(YELLOW)⚠ pyyaml lipsește: pip install pyyaml$(NC)"
	@echo -e "$(GREEN)✓ Verificare dependențe completă$(NC)"

setup: ## Configurează mediul de lucru pentru seminar
	@echo "Configurare mediu seminar..."
	@bash $(SCRIPTS_BASH)/S$(SEMINAR)_01_setup_seminar.sh
	@echo -e "$(GREEN)✓ Setup complet$(NC)"

install-deps: ## Instalează dependențele Python
	@echo "Instalare dependențe Python..."
	@$(PYTHON) -m pip install -r requirements.txt --break-system-packages 2>/dev/null || \
		$(PYTHON) -m pip install -r requirements.txt
	@echo -e "$(GREEN)✓ Dependențe instalate$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ ȘI EVALUARE
# ═══════════════════════════════════════════════════════════════════════════════

quiz: ## Rulează quiz-ul formativ interactiv
	@echo "Lansare quiz formativ..."
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml

quiz-shuffle: ## Rulează quiz-ul cu întrebări amestecate
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --shuffle

quiz-category: ## Rulează quiz pentru o categorie Bloom (ex: make quiz-category CAT=understand)
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml --category $(CAT)

quiz-test: ## Verifică integritatea quiz-ului (self-test)
	@echo "Verificare integritate quiz..."
	@$(PYTHON) $(FORMATIVE)/quiz_runner.py --self-test
	@echo -e "$(GREEN)✓ Quiz valid$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# TESTE
# ═══════════════════════════════════════════════════════════════════════════════

test: ## Rulează toate testele automate
	@echo "Rulare teste automate..."
	@bash $(TESTE)/run_all_tests.sh
	@echo -e "$(GREEN)✓ Toate testele au trecut$(NC)"

test-regex: ## Rulează doar testele pentru regex
	@bash $(TESTE)/test_01_regex_basics.sh

test-grep: ## Rulează doar testele pentru grep
	@bash $(TESTE)/test_02_grep_mastery.sh

test-sed: ## Rulează doar testele pentru sed
	@bash $(TESTE)/test_03_sed_transforms.sh

test-awk: ## Rulează doar testele pentru awk
	@bash $(TESTE)/test_04_awk_analysis.sh

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING ȘI CALITATE COD
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python ## Rulează toate verificările de linting
	@echo -e "$(GREEN)✓ Linting complet$(NC)"

lint-bash: ## Verifică scripturile Bash cu shellcheck
	@echo "Verificare scripturi Bash..."
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		$(SHELLCHECK) --severity=warning $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh $(TEME_SOL)/*.sh 2>/dev/null || true; \
		echo -e "$(GREEN)✓ Bash lint complet$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ shellcheck nu este instalat, verificare manuală:$(NC)"; \
		echo "  sudo apt install shellcheck"; \
	fi

lint-python: ## Verifică scripturile Python cu ruff/flake8
	@echo "Verificare scripturi Python..."
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py 2>/dev/null || true; \
	elif command -v flake8 >/dev/null 2>&1; then \
		flake8 $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py --max-line-length=100 2>/dev/null || true; \
	else \
		echo -e "$(YELLOW)⚠ ruff/flake8 nu este instalat$(NC)"; \
		$(PYTHON) -m py_compile $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py && \
		echo -e "$(GREEN)✓ Sintaxă Python validă$(NC)"; \
	fi

lint-yaml: ## Verifică fișierele YAML
	@echo "Verificare fișiere YAML..."
	@$(PYTHON) -c "import yaml; yaml.safe_load(open('$(FORMATIVE)/quiz.yaml'))" && \
		echo -e "$(GREEN)✓ quiz.yaml valid$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# DEMO-URI
# ═══════════════════════════════════════════════════════════════════════════════

demo: ## Lansează meniul de demo-uri interactive
	@echo "Demo-uri disponibile:"
	@echo "  1. make demo-regex"
	@echo "  2. make demo-grep"
	@echo "  3. make demo-sed"
	@echo "  4. make demo-awk"
	@echo "  5. make demo-hook"

demo-hook: ## Rulează hook demo (captare atenție)
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_01_hook_demo.sh

demo-regex: ## Rulează demo expresii regulate
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_02_demo_regex.sh

demo-grep: ## Rulează demo grep
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_03_demo_grep.sh

demo-sed: ## Rulează demo sed
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_04_demo_sed.sh

demo-awk: ## Rulează demo awk
	@bash $(SCRIPTS_DEMO)/S$(SEMINAR)_05_demo_awk.sh

# ═══════════════════════════════════════════════════════════════════════════════
# CURĂȚARE
# ═══════════════════════════════════════════════════════════════════════════════

clean: ## Șterge fișierele temporare și generate
	@echo "Curățare fișiere temporare..."
	@rm -f *.log *.tmp *.bak *~
	@rm -rf __pycache__ .pytest_cache .ruff_cache
	@rm -f $(SCRIPTS_PYTHON)/__pycache__/*.pyc 2>/dev/null || true
	@rm -f $(FORMATIVE)/__pycache__/*.pyc 2>/dev/null || true
	@echo -e "$(GREEN)✓ Curățare completă$(NC)"

clean-all: clean ## Curățare completă inclusiv date generate
	@rm -rf ~/demo_sem4 2>/dev/null || true
	@echo -e "$(GREEN)✓ Curățare completă (inclusiv date demo)$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITARE
# ═══════════════════════════════════════════════════════════════════════════════

validate: ## Validează structura completă a seminarului
	@echo "Validare structură seminar..."
	@bash $(SCRIPTS_BASH)/S$(SEMINAR)_03_validator.sh || true
	@echo -e "$(GREEN)✓ Validare completă$(NC)"

stats: ## Afișează statistici despre materiale
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "  STATISTICI SEMINAR $(SEMINAR)"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Fișiere Markdown:"
	@find . -name "*.md" | wc -l
	@echo ""
	@echo "Scripturi Bash:"
	@find . -name "*.sh" | wc -l
	@echo ""
	@echo "Scripturi Python:"
	@find . -name "*.py" | wc -l
	@echo ""
	@echo "Total linii cod:"
	@find . \( -name "*.sh" -o -name "*.py" -o -name "*.md" \) -exec cat {} + | wc -l
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# FIN
# ═══════════════════════════════════════════════════════════════════════════════
