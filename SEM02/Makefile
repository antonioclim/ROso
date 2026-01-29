# ═══════════════════════════════════════════════════════════════════════════════
# Makefile - Seminarul 02: Operatori, Redirecționare, Filtre, Bucle
# ═══════════════════════════════════════════════════════════════════════════════
#
# Sisteme de Operare | ASE București - CSIE
# Orchestrare: quiz, teste, linting, validare
#
# UTILIZARE:
#   make help     - Afișează acest mesaj
#   make quiz     - Rulează quiz-ul formativ interactiv
#   make test     - Rulează toate testele
#   make lint     - Verifică calitatea codului (shellcheck + python)
#   make validate - Verifică structura completă a pachetului
#   make clean    - Șterge fișierele generate
#   make all      - Rulează lint + test
#
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint lint-bash lint-python validate clean all check-deps

# Culori pentru output
CYAN := \033[1;36m
GREEN := \033[1;32m
YELLOW := \033[1;33m
RED := \033[1;31m
RESET := \033[0m

# Directoare
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
DOCS := docs
TESTS := teste

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: help (default)
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo ""
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(CYAN)  Makefile - Seminarul 02 SO                                       $(RESET)"
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)Targeturi disponibile:$(RESET)"
	@echo ""
	@echo "  $(YELLOW)make quiz$(RESET)      - Rulează quiz-ul formativ interactiv"
	@echo "  $(YELLOW)make test$(RESET)      - Rulează toate testele automate"
	@echo "  $(YELLOW)make lint$(RESET)      - Verifică calitatea codului"
	@echo "  $(YELLOW)make lint-bash$(RESET) - Verifică doar scripturile Bash"
	@echo "  $(YELLOW)make lint-python$(RESET) - Verifică doar scripturile Python"
	@echo "  $(YELLOW)make validate$(RESET)  - Verifică structura pachetului"
	@echo "  $(YELLOW)make clean$(RESET)     - Șterge fișierele generate"
	@echo "  $(YELLOW)make all$(RESET)       - Rulează lint + test"
	@echo "  $(YELLOW)make check-deps$(RESET) - Verifică dependențele instalate"
	@echo ""
	@echo "$(GREEN)Exemple:$(RESET)"
	@echo "  make quiz            # Pornește quiz-ul interactiv"
	@echo "  make lint && make test  # Verifică și testează"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: quiz - Rulează quiz-ul formativ
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "$(CYAN)═══ Pornire Quiz Formativ ═══$(RESET)"
	@if [ -f "$(FORMATIVE)/quiz_runner.py" ] && [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		python3 $(FORMATIVE)/quiz_runner.py $(FORMATIVE)/quiz.yaml; \
	else \
		echo "$(RED)Eroare: Fișierele quiz nu există.$(RESET)"; \
		echo "Verifică: $(FORMATIVE)/quiz_runner.py și $(FORMATIVE)/quiz.yaml"; \
		exit 1; \
	fi

quiz-shuffle:
	@echo "$(CYAN)═══ Quiz cu întrebări amestecate ═══$(RESET)"
	@python3 $(FORMATIVE)/quiz_runner.py --shuffle $(FORMATIVE)/quiz.yaml

quiz-short:
	@echo "$(CYAN)═══ Quiz scurt (10 întrebări) ═══$(RESET)"
	@python3 $(FORMATIVE)/quiz_runner.py --limit 10 --shuffle $(FORMATIVE)/quiz.yaml

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: test - Rulează testele
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "$(CYAN)═══ Rulare Teste ═══$(RESET)"
	@if [ -f "$(TESTS)/run_all_tests.sh" ]; then \
		bash $(TESTS)/run_all_tests.sh; \
	else \
		echo "$(YELLOW)Avertisment: $(TESTS)/run_all_tests.sh nu există.$(RESET)"; \
		echo "Se încearcă rularea testelor individuale..."; \
		for script in $(SCRIPTS_BASH)/*.sh; do \
			echo "Verificare sintaxă: $$script"; \
			bash -n "$$script" || exit 1; \
		done; \
		echo "$(GREEN)Toate scripturile au sintaxă validă.$(RESET)"; \
	fi

test-validator:
	@echo "$(CYAN)═══ Test Validator Teme ═══$(RESET)"
	@if [ -f "$(SCRIPTS_BASH)/S02_03_validator.sh" ]; then \
		bash $(SCRIPTS_BASH)/S02_03_validator.sh --help; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: lint - Verificare calitate cod
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo "$(GREEN)═══ Linting complet! ═══$(RESET)"

lint-bash:
	@echo "$(CYAN)═══ Verificare Bash (shellcheck) ═══$(RESET)"
	@if command -v shellcheck > /dev/null 2>&1; then \
		echo "Verificare $(SCRIPTS_BASH)/*.sh ..."; \
		shellcheck --severity=warning $(SCRIPTS_BASH)/*.sh 2>/dev/null || true; \
		echo "Verificare $(SCRIPTS_DEMO)/*.sh ..."; \
		shellcheck --severity=warning $(SCRIPTS_DEMO)/*.sh 2>/dev/null || true; \
		echo "$(GREEN)Verificare Bash completă.$(RESET)"; \
	else \
		echo "$(YELLOW)Avertisment: shellcheck nu e instalat.$(RESET)"; \
		echo "Instalează cu: sudo apt install shellcheck"; \
		echo "Se face doar verificare sintaxă de bază..."; \
		for script in $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh; do \
			bash -n "$$script" 2>/dev/null || echo "$(RED)Eroare în: $$script$(RESET)"; \
		done; \
	fi

lint-python:
	@echo "$(CYAN)═══ Verificare Python ═══$(RESET)"
	@echo "Verificare sintaxă Python..."
	@for pyfile in $(SCRIPTS_PYTHON)/*.py $(FORMATIVE)/*.py; do \
		if [ -f "$$pyfile" ]; then \
			python3 -m py_compile "$$pyfile" 2>/dev/null && \
				echo "  $(GREEN)✓$(RESET) $$pyfile" || \
				echo "  $(RED)✗$(RESET) $$pyfile"; \
		fi; \
	done
	@if command -v ruff > /dev/null 2>&1; then \
		echo "Rulare ruff..."; \
		ruff check $(SCRIPTS_PYTHON)/ $(FORMATIVE)/ 2>/dev/null || true; \
	elif command -v flake8 > /dev/null 2>&1; then \
		echo "Rulare flake8..."; \
		flake8 --max-line-length=100 $(SCRIPTS_PYTHON)/ $(FORMATIVE)/ 2>/dev/null || true; \
	else \
		echo "$(YELLOW)Notă: ruff/flake8 nu sunt instalate (opțional).$(RESET)"; \
	fi
	@echo "$(GREEN)Verificare Python completă.$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: validate - Verificare structură pachet
# ═══════════════════════════════════════════════════════════════════════════════

validate:
	@echo "$(CYAN)═══ Validare Structură Pachet ═══$(RESET)"
	@echo ""
	@echo "$(YELLOW)Verificare fișiere obligatorii:$(RESET)"
	@MISSING=0; \
	for f in \
		"README.md" \
		"$(DOCS)/S02_00_ANALIZA_SI_PLAN_PEDAGOGIC.md" \
		"$(DOCS)/S02_01_GHID_INSTRUCTOR.md" \
		"$(DOCS)/S02_02_MATERIAL_PRINCIPAL.md" \
		"$(DOCS)/S02_03_PEER_INSTRUCTION.md" \
		"$(DOCS)/S02_04_PARSONS_PROBLEMS.md" \
		"$(DOCS)/S02_05_LIVE_CODING_GUIDE.md" \
		"$(DOCS)/S02_06_EXERCITII_SPRINT.md" \
		"$(DOCS)/S02_07_LLM_AWARE_EXERCISES.md" \
		"$(DOCS)/S02_08_DEMO_SPECTACULOASE.md" \
		"$(DOCS)/S02_09_CHEAT_SHEET_VIZUAL.md" \
		"$(DOCS)/S02_10_AUTOEVALUARE_REFLEXIE.md" \
		"$(SCRIPTS_BASH)/S02_01_setup_seminar.sh" \
		"$(SCRIPTS_BASH)/S02_02_quiz_interactiv.sh" \
		"$(SCRIPTS_BASH)/S02_03_validator.sh" \
		"$(SCRIPTS_PYTHON)/S02_01_autograder.py" \
		"$(SCRIPTS_PYTHON)/S02_02_quiz_generator.py" \
		"$(SCRIPTS_PYTHON)/S02_03_report_generator.py" \
	; do \
		if [ -f "$$f" ]; then \
			echo "  $(GREEN)✓$(RESET) $$f"; \
		else \
			echo "  $(RED)✗$(RESET) $$f (LIPSĂ)"; \
			MISSING=$$((MISSING + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "$(YELLOW)Verificare fișiere opționale (CI/CD):$(RESET)"; \
	for f in \
		"$(FORMATIVE)/quiz.yaml" \
		"$(FORMATIVE)/quiz_lms.json" \
		"$(FORMATIVE)/quiz_runner.py" \
		"$(DOCS)/lo_traceability.md" \
		"Makefile" \
		"requirements.txt" \
		"ci/github_actions.yml" \
		"ci/linting.toml" \
	; do \
		if [ -f "$$f" ]; then \
			echo "  $(GREEN)✓$(RESET) $$f"; \
		else \
			echo "  $(YELLOW)○$(RESET) $$f (opțional)"; \
		fi; \
	done; \
	echo ""; \
	if [ $$MISSING -eq 0 ]; then \
		echo "$(GREEN)═══ Structură validă! ═══$(RESET)"; \
	else \
		echo "$(RED)═══ $$MISSING fișiere lipsă! ═══$(RESET)"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: check-deps - Verificare dependențe
# ═══════════════════════════════════════════════════════════════════════════════

check-deps:
	@echo "$(CYAN)═══ Verificare Dependențe ═══$(RESET)"
	@echo ""
	@echo "$(YELLOW)Obligatorii:$(RESET)"
	@command -v bash > /dev/null && echo "  $(GREEN)✓$(RESET) bash" || echo "  $(RED)✗$(RESET) bash"
	@command -v python3 > /dev/null && echo "  $(GREEN)✓$(RESET) python3" || echo "  $(RED)✗$(RESET) python3"
	@echo ""
	@echo "$(YELLOW)Recomandate:$(RESET)"
	@command -v shellcheck > /dev/null && echo "  $(GREEN)✓$(RESET) shellcheck" || echo "  $(YELLOW)○$(RESET) shellcheck (sudo apt install shellcheck)"
	@command -v ruff > /dev/null && echo "  $(GREEN)✓$(RESET) ruff" || echo "  $(YELLOW)○$(RESET) ruff (pip install ruff)"
	@command -v flake8 > /dev/null && echo "  $(GREEN)✓$(RESET) flake8" || echo "  $(YELLOW)○$(RESET) flake8 (pip install flake8)"
	@echo ""
	@echo "$(YELLOW)Module Python:$(RESET)"
	@python3 -c "import yaml" 2>/dev/null && echo "  $(GREEN)✓$(RESET) pyyaml" || echo "  $(YELLOW)○$(RESET) pyyaml (pip install pyyaml)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: clean - Curățare fișiere generate
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "$(CYAN)═══ Curățare ═══$(RESET)"
	@echo "Ștergere fișiere temporare..."
	@rm -rf __pycache__ */__pycache__ */*/__pycache__
	@rm -f *.pyc */*.pyc */*/*.pyc
	@rm -f *.log *.tmp
	@rm -f quiz_results_*.json
	@echo "$(GREEN)Curățare completă.$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET: all - Rulează totul
# ═══════════════════════════════════════════════════════════════════════════════

all: lint test
	@echo "$(GREEN)═══ Toate verificările complete! ═══$(RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# FIN
# ═══════════════════════════════════════════════════════════════════════════════
