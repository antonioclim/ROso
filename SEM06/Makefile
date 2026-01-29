# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — SEM06 CAPSTONE Build Orchestration
# ═══════════════════════════════════════════════════════════════════════════════
# Sisteme de Operare | ASE București - CSIE
# Utilizare: make [target]
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help quiz test lint clean install check all

# Culori pentru output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Directoare
SCRIPTS_DIR := scripts
PROJECTS_DIR := $(SCRIPTS_DIR)/projects
FORMATIVE_DIR := formative
TESTS_DIR := teste

help:
	@echo ""
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo "$(CYAN)  SEM06 CAPSTONE — Build System$(RESET)"
	@echo "$(CYAN)═══════════════════════════════════════════════════════════════$(RESET)"
	@echo ""
	@echo "$(GREEN)Targeturi disponibile:$(RESET)"
	@echo "  $(YELLOW)make quiz$(RESET)      — Rulează quiz-ul formativ interactiv"
	@echo "  $(YELLOW)make quiz-practice$(RESET) — Quiz în mod practică"
	@echo "  $(YELLOW)make test$(RESET)      — Rulează toate testele"
	@echo "  $(YELLOW)make lint$(RESET)      — Verifică calitatea codului"
	@echo "  $(YELLOW)make check$(RESET)     — Verifică dependențele"
	@echo "  $(YELLOW)make clean$(RESET)     — Curăță fișierele generate"
	@echo "  $(YELLOW)make all$(RESET)       — lint + test + quiz-test"
	@echo ""

quiz:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py $(FORMATIVE_DIR)/quiz.yaml

quiz-practice:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py $(FORMATIVE_DIR)/quiz.yaml --practice

quiz-test:
	@python3 $(FORMATIVE_DIR)/quiz_runner.py --test

test:
	@bash $(TESTS_DIR)/run_all_tests.sh

lint:
	@echo "$(CYAN)Verificare calitate cod...$(RESET)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -S warning $(SCRIPTS_DIR)/*.sh 2>/dev/null || true; \
	else \
		echo "$(YELLOW)shellcheck nu este instalat$(RESET)"; \
	fi

check:
	@echo "$(CYAN)Verificare dependențe...$(RESET)"
	@for cmd in bash python3 tar curl; do \
		command -v $$cmd >/dev/null && echo "$(GREEN)✓$(RESET) $$cmd" || echo "$(RED)✗$(RESET) $$cmd"; \
	done
	@python3 -c "import yaml" 2>/dev/null && echo "$(GREEN)✓$(RESET) pyyaml" || echo "$(YELLOW)○$(RESET) pyyaml (pip install pyyaml)"

clean:
	@rm -f *.log *.tmp results_*.json
	@rm -rf __pycache__
	@echo "$(GREEN)Curățare completată.$(RESET)"

all: lint test quiz-test
	@echo "$(GREEN)Toate verificările au trecut!$(RESET)"
