# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — Curs 15: Conectarea la Rețea (Supl.)
# Sisteme de Operare | ASE București - CSIE | 2025-2026
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: all diagrams quiz test-scripts clean help check

# Configurație
COURSE_NUM := 15
COURSE_NAME := Conectarea la Rețea (Supl.)
PLANTUML_JAR := /usr/share/plantuml/plantuml.jar

# Culori pentru output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# ─────────────────────────────────────────────────────────────────────────────
# Target principal
# ─────────────────────────────────────────────────────────────────────────────
all: check diagrams quiz
	@echo "$(GREEN)✓ Build complet pentru Cursul $(COURSE_NUM)$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# Verificare structură
# ─────────────────────────────────────────────────────────────────────────────
check:
	@echo "$(YELLOW)Verificare structură Curs $(COURSE_NUM)...$(NC)"
	@test -f README.md || (echo "$(RED)✗ README.md lipsește$(NC)" && exit 1)
	@echo "$(GREEN)✓ README.md există$(NC)"
	@test -d docs || mkdir -p docs
	@echo "$(GREEN)✓ Directorul docs/ verificat$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# Generare diagrame PlantUML
# ─────────────────────────────────────────────────────────────────────────────
diagrams:
	@echo "$(YELLOW)Generare diagrame PlantUML...$(NC)"
	@if [ -d diagrame ] && ls diagrame/*.puml 1> /dev/null 2>&1; then \
		for f in diagrame/*.puml; do \
			echo "  Procesez $$f..."; \
			java -jar $(PLANTUML_JAR) -tpng "$$f" 2>/dev/null || \
			plantuml -tpng "$$f" 2>/dev/null || \
			echo "$(YELLOW)  ⚠ PlantUML nu este instalat$(NC)"; \
		done; \
		echo "$(GREEN)✓ Diagrame procesate$(NC)"; \
	else \
		echo "$(YELLOW)  ⚠ Nu există diagrame/*.puml$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# Validare YAML quiz
# ─────────────────────────────────────────────────────────────────────────────
quiz:
	@echo "$(YELLOW)Validare YAML evaluare formativă...$(NC)"
	@if ls docs/C*_05_EVALUARE_FORMATIVA.yaml 1> /dev/null 2>&1; then \
		for f in docs/C*_05_EVALUARE_FORMATIVA.yaml; do \
			python3 -c "import yaml; yaml.safe_load(open('$$f'))" && \
			echo "$(GREEN)✓ $$f valid$(NC)"; \
		done; \
	else \
		echo "$(YELLOW)  ⚠ Nu există fișiere YAML evaluare$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# Testare scripturi
# ─────────────────────────────────────────────────────────────────────────────
test-scripts:
	@echo "$(YELLOW)Verificare sintaxă scripturi...$(NC)"
	@if [ -d scripts ]; then \
		for f in scripts/*.py 2>/dev/null; do \
			[ -f "$$f" ] && python3 -m py_compile "$$f" && echo "$(GREEN)  ✓ $$f$(NC)"; \
		done; \
		for f in scripts/*.sh 2>/dev/null; do \
			[ -f "$$f" ] && bash -n "$$f" && echo "$(GREEN)  ✓ $$f$(NC)"; \
		done; \
	else \
		echo "$(YELLOW)  ⚠ Nu există director scripts/$(NC)"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# Curățare
# ─────────────────────────────────────────────────────────────────────────────
clean:
	@rm -f diagrame/*.png 2>/dev/null || true
	@rm -f scripts/*.pyc 2>/dev/null || true
	@rm -rf scripts/__pycache__ 2>/dev/null || true
	@echo "$(GREEN)✓ Curățare completă$(NC)"

# ─────────────────────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Makefile — Curs $(COURSE_NUM): $(COURSE_NAME)$(NC)"
	@echo "$(GREEN)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "Targets: make [all|check|diagrams|quiz|test-scripts|clean|help]"
	@echo ""
