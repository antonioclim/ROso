# A02: Interactive Shell Extension

> **Nivel:** ADVANCED | **Timp estimat:** 40-50 ore | **Componente:** Bash + C

---

## Descriere

Extensie pentru Bash care adaugă features avansate: syntax highlighting, autocompletare inteligentă, command history search și inline documentation. Componenta C gestionează parsing-ul eficient.

---

## De ce C?

Componenta C oferă:
- **Lexer rapid** pentru syntax highlighting
- **Trie data structure** pentru autocompletare
- **History indexing** pentru căutare rapidă

---

## Cerințe

### Obligatorii (Bash)
1. **Syntax highlighting** - comenzi, argumente, pipes, redirects
2. **Smart autocomplete** - bazat pe context și history
3. **History search** - Ctrl+R îmbunătățit
4. **Inline man** - preview scurt la Tab+Tab
5. **Directory bookmarks** - jump rapid între locații
6. **Command timing** - durată automată pentru comenzi lungi

### Componenta C (Obligatorie)
7. **Lexer** - tokenizare comandă pentru highlighting
8. **Trie** - pentru autocomplete rapid
9. **History index** - pentru full-text search

### Opționale
10. **Git integration** - status în prompt
11. **Abbreviations** - expandare comenzi scurte
12. **Themes** - scheme de culori

---

## Integrare

```bash
# În .bashrc
source /path/to/shell_ext/init.sh

# Componenta C ca shared library
export LD_PRELOAD=/path/to/libshellext.so
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
| Syntax highlighting | 15% |
| Autocomplete | 20% |
| Componenta C | 25% |
| History features | 10% |
| Integrare lină | 10% |
| Calitate cod | 10% |
| Teste | 5% |
| Documentație | 5% |

---

*Proiect ADVANCED | Sisteme de Operare | ASE-CSIE*
