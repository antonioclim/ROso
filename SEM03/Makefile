# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Seminarul 03: System Administration
# Sisteme de Operare | ASE București - CSIE
# ═══════════════════════════════════════════════════════════════════════════════
# Utilizare: make [target]
# Targeturi principale: setup, quiz, test, lint, clean, all
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help setup quiz quiz-json test lint lint-bash lint-python clean all check-deps validate

# Variabile
SHELL := /bin/bash
PYTHON := python3
SHELLCHECK := shellcheck
RUFF := ruff

# Directoare
SCRIPTS_BASH := scripts/bash
SCRIPTS_DEMO := scripts/demo
SCRIPTS_PYTHON := scripts/python
FORMATIVE := formative
TESTS := teste

# ═══════════════════════════════════════════════════════════════════════════════
# TARGET PRINCIPAL: help
# ═══════════════════════════════════════════════════════════════════════════════

help:
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo "  Makefile — Seminarul 03: System Administration"
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Targeturi disponibile:"
	@echo ""
	@echo "  setup       - Pregătește mediul de lucru pentru seminar"
	@echo "  quiz        - Rulează quizul formativ interactiv (YAML)"
	@echo "  quiz-json   - Validează și afișează quizul în format JSON"
	@echo "  test        - Rulează toate testele automate"
	@echo "  lint        - Verifică calitatea codului (Bash + Python)"
	@echo "  lint-bash   - Verifică doar scripturile Bash cu shellcheck"
	@echo "  lint-python - Verifică doar scripturile Python cu ruff"
	@echo "  validate    - Validează structura completă a seminarului"
	@echo "  clean       - Șterge fișierele temporare și cache"
	@echo "  all         - Rulează: lint → test → validate"
	@echo "  check-deps  - Verifică dependențele instalate"
	@echo ""
	@echo "Exemple:"
	@echo "  make setup      # Pregătește mediul înainte de seminar"
	@echo "  make lint test  # Verifică cod și rulează teste"
	@echo "  make all        # Verificare completă"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP
# ═══════════════════════════════════════════════════════════════════════════════

setup:
	@echo "═══ Setup Seminar 03 ═══"
	@if [ -f "$(SCRIPTS_BASH)/S03_01_setup_seminar.sh" ]; then \
		bash "$(SCRIPTS_BASH)/S03_01_setup_seminar.sh"; \
	else \
		echo "Avertisment: Script setup nu există"; \
	fi
	@echo "Setup complet!"

# ═══════════════════════════════════════════════════════════════════════════════
# QUIZ
# ═══════════════════════════════════════════════════════════════════════════════

quiz:
	@echo "═══ Quiz Formativ ═══"
	@if [ -f "$(SCRIPTS_BASH)/S03_02_quiz_interactiv.sh" ]; then \
		bash "$(SCRIPTS_BASH)/S03_02_quiz_interactiv.sh"; \
	elif [ -f "$(SCRIPTS_PYTHON)/S03_02_quiz_generator.py" ] && [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		$(PYTHON) "$(SCRIPTS_PYTHON)/S03_02_quiz_generator.py" "$(FORMATIVE)/quiz.yaml"; \
	else \
		echo "Eroare: Nu s-a găsit script quiz"; \
		exit 1; \
	fi

quiz-json:
	@echo "═══ Validare Quiz JSON ═══"
	@if [ -f "$(FORMATIVE)/quiz_lms.json" ]; then \
		$(PYTHON) -m json.tool "$(FORMATIVE)/quiz_lms.json" > /dev/null && \
		echo "✓ Quiz JSON valid" && \
		$(PYTHON) -c "import json; q=json.load(open('$(FORMATIVE)/quiz_lms.json')); print(f'  Întrebări: {len(q[\"questions\"])}')" ; \
	else \
		echo "Eroare: $(FORMATIVE)/quiz_lms.json nu există"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# TESTE
# ═══════════════════════════════════════════════════════════════════════════════

test:
	@echo "═══ Rulare Teste ═══"
	@if [ -f "$(TESTS)/run_all_tests.sh" ]; then \
		bash "$(TESTS)/run_all_tests.sh"; \
	else \
		echo "Avertisment: $(TESTS)/run_all_tests.sh nu există"; \
		echo "Rulare teste de bază..."; \
		$(MAKE) test-basic; \
	fi

test-basic:
	@echo "Verificare sintaxă Bash..."
	@for f in $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh; do \
		if [ -f "$$f" ]; then \
			bash -n "$$f" 2>/dev/null || echo "  Eroare în: $$f"; \
		fi; \
	done
	@echo "Verificare sintaxă Python..."
	@for f in $(SCRIPTS_PYTHON)/*.py; do \
		if [ -f "$$f" ]; then \
			$(PYTHON) -m py_compile "$$f" 2>/dev/null || echo "  Eroare în: $$f"; \
		fi; \
	done
	@echo "Verificare YAML quiz..."
	@if [ -f "$(FORMATIVE)/quiz.yaml" ]; then \
		$(PYTHON) -c "import yaml; yaml.safe_load(open('$(FORMATIVE)/quiz.yaml'))" && \
		echo "✓ Quiz YAML valid"; \
	fi
	@echo "Teste de bază complete!"

# ═══════════════════════════════════════════════════════════════════════════════
# LINTING
# ═══════════════════════════════════════════════════════════════════════════════

lint: lint-bash lint-python
	@echo "═══ Linting complet! ═══"

lint-bash:
	@echo "═══ Verificare Bash (shellcheck) ═══"
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		$(SHELLCHECK) --shell=bash --severity=warning \
			$(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh 2>/dev/null || true; \
		echo "✓ Verificare shellcheck completă"; \
	else \
		echo "Avertisment: shellcheck nu e instalat"; \
		echo "  Instalare: sudo apt install shellcheck"; \
		echo "Verificare sintaxă de bază..."; \
		bash -n $(SCRIPTS_BASH)/*.sh $(SCRIPTS_DEMO)/*.sh && echo "✓ Sintaxă OK"; \
	fi

lint-python:
	@echo "═══ Verificare Python (ruff) ═══"
	@if command -v $(RUFF) >/dev/null 2>&1; then \
		$(RUFF) check $(SCRIPTS_PYTHON)/*.py || true; \
		echo "✓ Verificare ruff completă"; \
	else \
		echo "Avertisment: ruff nu e instalat"; \
		echo "  Instalare: pip install ruff"; \
		echo "Verificare sintaxă de bază..."; \
		$(PYTHON) -m py_compile $(SCRIPTS_PYTHON)/*.py && echo "✓ Sintaxă OK"; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDARE STRUCTURĂ
# ═══════════════════════════════════════════════════════════════════════════════

validate:
	@echo "═══ Validare Structură Seminar ═══"
	@ERRORS=0; \
	echo "Verificare fișiere obligatorii docs/..."; \
	for f in S03_00_ANALIZA_SI_PLAN_PEDAGOGIC.md S03_01_GHID_INSTRUCTOR.md \
		S03_02_MATERIAL_PRINCIPAL.md S03_03_PEER_INSTRUCTION.md \
		S03_04_PARSONS_PROBLEMS.md S03_05_LIVE_CODING_GUIDE.md \
		S03_06_EXERCITII_SPRINT.md S03_07_LLM_AWARE_EXERCISES.md \
		S03_08_DEMO_SPECTACULOASE.md S03_09_CHEAT_SHEET_VIZUAL.md \
		S03_10_AUTOEVALUARE_REFLEXIE.md lo_traceability.md; do \
		if [ -f "docs/$$f" ]; then \
			echo "  ✓ docs/$$f"; \
		else \
			echo "  ✗ docs/$$f LIPSEȘTE"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	echo "Verificare fișiere obligatorii root..."; \
	for f in README.md Makefile requirements.txt; do \
		if [ -f "$$f" ]; then \
			echo "  ✓ $$f"; \
		else \
			echo "  ✗ $$f LIPSEȘTE"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	echo "Verificare directoare..."; \
	for d in formative ci scripts/bash scripts/demo scripts/python teme teste; do \
		if [ -d "$$d" ]; then \
			echo "  ✓ $$d/"; \
		else \
			echo "  ✗ $$d/ LIPSEȘTE"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
	done; \
	if [ $$ERRORS -eq 0 ]; then \
		echo "═══ Validare completă: 0 erori ═══"; \
	else \
		echo "═══ Validare completă: $$ERRORS erori ═══"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════════

check-deps:
	@echo "═══ Verificare Dependențe ═══"
	@echo "Python:"
	@$(PYTHON) --version 2>/dev/null || echo "  ✗ Python3 nu e instalat"
	@echo "Shellcheck:"
	@$(SHELLCHECK) --version 2>/dev/null | head -1 || echo "  ✗ shellcheck nu e instalat (opțional)"
	@echo "Ruff:"
	@$(RUFF) --version 2>/dev/null || echo "  ✗ ruff nu e instalat (opțional)"
	@echo "PyYAML:"
	@$(PYTHON) -c "import yaml; print(f'  PyYAML {yaml.__version__}')" 2>/dev/null || \
		echo "  ✗ PyYAML nu e instalat (pip install pyyaml)"

# ═══════════════════════════════════════════════════════════════════════════════
# CLEAN
# ═══════════════════════════════════════════════════════════════════════════════

clean:
	@echo "═══ Curățare ═══"
	@rm -rf __pycache__ */__pycache__ */*/__pycache__
	@rm -f *.pyc */*.pyc */*/*.pyc
	@rm -f *.log */*.log
	@rm -rf .pytest_cache .ruff_cache
	@rm -rf /tmp/sem03_* /tmp/test_sem03_*
	@echo "Curățare completă!"

# ═══════════════════════════════════════════════════════════════════════════════
# ALL
# ═══════════════════════════════════════════════════════════════════════════════

all: check-deps lint test validate
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════════"
	@echo "  Verificare completă finalizată!"
	@echo "═══════════════════════════════════════════════════════════════════════════════"
