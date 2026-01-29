# Makefile - Orchestrare build și teste pentru SEM01
# Sisteme de Operare | ASE București - CSIE

SHELL := /bin/bash
PYTHON := python3
SHELLCHECK := shellcheck
RUFF := ruff

# Culori pentru output
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[1;33m
NC := \033[0m

.PHONY: help setup quiz quiz-shuffle test lint lint-bash lint-python validate-yaml clean check-deps

# Target implicit
help:
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  SEM01 - Shell Fundamentals - Makefile"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "Utilizare: make <target>"
	@echo ""
	@echo "Targets disponibile:"
	@echo "  setup         - Instalează dependențele Python"
	@echo "  quiz          - Rulează quiz-ul formativ"
	@echo "  quiz-shuffle  - Rulează quiz-ul cu întrebări amestecate"
	@echo "  test          - Rulează toate testele"
	@echo "  lint          - Verifică stilul codului (bash + python)"
	@echo "  lint-bash     - Verifică doar scripturile Bash"
	@echo "  lint-python   - Verifică doar codul Python"
	@echo "  validate-yaml - Validează fișierele YAML"
	@echo "  clean         - Curăță fișierele temporare"
	@echo "  check-deps    - Verifică dependențele instalate"
	@echo ""

# Setup - instalează dependențele
setup:
	@echo -e "$(GREEN)>>> Instalare dependențe Python...$(NC)"
	$(PYTHON) -m pip install -r requirements.txt --quiet
	@echo -e "$(GREEN)>>> Dependențe instalate cu succes.$(NC)"

# Rulează quiz-ul
quiz:
	@echo -e "$(GREEN)>>> Pornire quiz formativ...$(NC)"
	cd formative && $(PYTHON) quiz_runner.py quiz.yaml

# Rulează quiz-ul cu shuffle
quiz-shuffle:
	@echo -e "$(GREEN)>>> Pornire quiz formativ (shuffled)...$(NC)"
	cd formative && $(PYTHON) quiz_runner.py quiz.yaml --shuffle

# Rulează testele
test:
	@echo -e "$(GREEN)>>> Rulare teste...$(NC)"
	@if command -v pytest &> /dev/null; then \
		pytest tests/ -v; \
	else \
		echo -e "$(YELLOW)pytest nu este instalat. Rulează: pip install pytest$(NC)"; \
		$(PYTHON) -m py_compile formative/quiz_runner.py && echo "Sintaxă Python OK"; \
	fi
	@echo -e "$(GREEN)>>> Teste Bash...$(NC)"
	@for script in scripts/bash/*.sh scripts/demo/*.sh; do \
		if [ -f "$$script" ]; then \
			bash -n "$$script" && echo "  ✓ $$script"; \
		fi; \
	done

# Linting complet
lint: lint-bash lint-python validate-yaml
	@echo -e "$(GREEN)>>> Linting complet finalizat.$(NC)"

# Lint Bash
lint-bash:
	@echo -e "$(GREEN)>>> Verificare Bash cu shellcheck...$(NC)"
	@if command -v $(SHELLCHECK) &> /dev/null; then \
		find scripts -name "*.sh" -exec $(SHELLCHECK) {} \; || true; \
	else \
		echo -e "$(YELLOW)shellcheck nu este instalat.$(NC)"; \
	fi

# Lint Python
lint-python:
	@echo -e "$(GREEN)>>> Verificare Python cu ruff...$(NC)"
	@if command -v $(RUFF) &> /dev/null; then \
		$(RUFF) check formative/ tests/ || true; \
	else \
		echo -e "$(YELLOW)ruff nu este instalat. Verificare sintaxă de bază...$(NC)"; \
		$(PYTHON) -m py_compile formative/quiz_runner.py; \
	fi

# Validare YAML
validate-yaml:
	@echo -e "$(GREEN)>>> Validare fișiere YAML...$(NC)"
	@$(PYTHON) -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))" && \
		echo -e "  $(GREEN)✓ formative/quiz.yaml valid$(NC)" || \
		echo -e "  $(RED)✗ formative/quiz.yaml invalid$(NC)"

# Curățenie
clean:
	@echo -e "$(GREEN)>>> Curățare fișiere temporare...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@echo -e "$(GREEN)>>> Curățare completă.$(NC)"

# Verificare dependențe
check-deps:
	@echo -e "$(GREEN)>>> Verificare dependențe...$(NC)"
	@echo -n "Python: " && $(PYTHON) --version
	@echo -n "PyYAML: " && $(PYTHON) -c "import yaml; print(yaml.__version__)" 2>/dev/null || echo "NU INSTALAT"
	@echo -n "pytest: " && pytest --version 2>/dev/null || echo "NU INSTALAT"
	@echo -n "shellcheck: " && $(SHELLCHECK) --version 2>/dev/null | head -1 || echo "NU INSTALAT"
	@echo -n "ruff: " && $(RUFF) --version 2>/dev/null || echo "NU INSTALAT"
