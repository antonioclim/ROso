# A02: Interactive Shell Extension

> **Nivel:** ADVANCED | **Timp estimat:** 40-50 ore | **Componente:** Bash + C

---

## Descriere

Extensie pentru shell interactiv: command completion avansat, syntax highlighting, history search inteligent și command suggestions. Componenta C oferă parsing eficient și integrare cu libreadline.

---

## De ce C?

Componenta C oferă:
- **Parsing rapid** pentru syntax highlighting în timp real
- **Trie data structure** pentru autocomplete eficient
- **Integrare readline** pentru input handling profesionist
- **Performance** - procesare fără lag perceptibil

---

## Obiective de Învățare

- Libreadline și custom completions
- Parsing și tokenizare (lexer simplu)
- Trie pentru prefix matching
- ANSI escape codes pentru culori
- Terminal I/O și raw mode

---

## Cerințe Funcționale

### Obligatorii (Bash)
1. **Custom prompt** - informativ (user, host, dir, git branch)
2. **Aliases și funcții** - management și persistence
3. **History enhancement** - search, deduplication
4. **Directory bookmarks** - jump rapid la locații
5. **Command hooks** - pre/post execution
6. **Environment management** - profiles, export

### Componenta C (Obligatorie pentru ADVANCED)
7. **Syntax highlighter** - colorare în timp real
8. **Smart completion** - trie-based, context-aware
9. **Command validator** - verificare sintaxă înainte de execuție

### Opționale
10. **Fuzzy matching** - completion aproximativ
11. **Command suggestions** - bazat pe history
12. **Plugin system** - extensibilitate

---

## Arhitectură

```
┌─────────────────────────────────────────────────────────┐
│                    Interactive Shell                     │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Prompt      │  │  Highlighter │  │  Completer   │  │
│  │  (Bash)      │  │  (C + Bash)  │  │  (C)         │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  History     │  │  Bookmarks   │  │  Hooks       │  │
│  │  Manager     │  │  Manager     │  │  System      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    libshellext.so (C)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Lexer/      │  │  Trie        │  │  Readline    │  │
│  │  Tokenizer   │  │  Completion  │  │  Integration │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Structură Proiect

```
A02_Interactive_Shell_Extension/
├── README.md
├── Makefile
├── src/
│   ├── bash/
│   │   ├── shellext.sh          # Main loader
│   │   ├── prompt.sh            # Custom prompt
│   │   ├── history.sh           # History enhancements
│   │   ├── bookmarks.sh         # Directory bookmarks
│   │   ├── hooks.sh             # Pre/post hooks
│   │   └── aliases.sh           # Alias management
│   └── c/
│       ├── shellext.h           # Public header
│       ├── lexer.c              # Tokenizer
│       ├── highlighter.c        # Syntax highlighting
│       ├── trie.c               # Trie for completion
│       ├── completer.c          # Completion engine
│       └── readline_ext.c       # Readline integration
├── etc/
│   └── shellext.conf
├── tests/
│   ├── test_lexer.c
│   ├── test_trie.c
│   └── test_integration.sh
└── docs/
    └── INTEGRATION.md
```

---

## Componenta C - Implementare

### Header Principal (shellext.h)

```c
#ifndef SHELLEXT_H
#define SHELLEXT_H

#include <stddef.h>

/* Token types for syntax highlighting */
typedef enum {
    TOKEN_WORD,         /* Regular word */
    TOKEN_COMMAND,      /* Executable command */
    TOKEN_BUILTIN,      /* Shell builtin */
    TOKEN_KEYWORD,      /* if, then, else, fi, etc. */
    TOKEN_STRING,       /* "..." or '...' */
    TOKEN_VARIABLE,     /* $VAR or ${VAR} */
    TOKEN_OPERATOR,     /* |, &, >, <, etc. */
    TOKEN_COMMENT,      /* # comment */
    TOKEN_NUMBER,       /* Numeric literal */
    TOKEN_PATH,         /* File path */
    TOKEN_OPTION,       /* -flag or --option */
    TOKEN_ERROR,        /* Syntax error */
    TOKEN_END
} TokenType;

/* Token structure */
typedef struct {
    TokenType type;
    const char *start;
    size_t length;
    int error_code;     /* For TOKEN_ERROR */
} Token;

/* ANSI color codes */
typedef struct {
    const char *command;    /* Bold green */
    const char *builtin;    /* Cyan */
    const char *keyword;    /* Bold yellow */
    const char *string;     /* Yellow */
    const char *variable;   /* Blue */
    const char *operator_;  /* Magenta */
    const char *comment;    /* Gray */
    const char *number;     /* Cyan */
    const char *path;       /* Underline */
    const char *option;     /* Green */
    const char *error;      /* Red */
    const char *reset;      /* Reset */
} ColorScheme;

/* Lexer functions */
void lexer_init(const char *input);
Token lexer_next_token(void);
void lexer_reset(void);

/* Highlighter functions */
void highlighter_init(const ColorScheme *colors);
char *highlight_line(const char *line);
void highlighter_free(char *highlighted);

/* Trie for completion */
typedef struct TrieNode TrieNode;

TrieNode *trie_create(void);
void trie_insert(TrieNode *root, const char *word);
char **trie_complete(TrieNode *root, const char *prefix, int *count);
void trie_free_results(char **results, int count);
void trie_destroy(TrieNode *root);

/* Completion engine */
int completer_init(void);
void completer_add_command(const char *cmd);
void completer_add_path(const char *path);
char **completer_complete(const char *prefix, int *count);
void completer_cleanup(void);

/* Readline integration */
int readline_setup(void);
char *readline_highlight(const char *prompt);

/* Validation */
int validate_syntax(const char *line, char *error_msg, size_t error_size);

#endif /* SHELLEXT_H */
```

### Lexer/Tokenizer (lexer.c)

```c
#include "shellext.h"
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

static const char *input_buffer = NULL;
static size_t input_pos = 0;
static size_t input_len = 0;

/* Shell keywords */
static const char *keywords[] = {
    "if", "then", "else", "elif", "fi",
    "case", "esac", "for", "while", "until",
    "do", "done", "in", "function",
    "select", "time", "coproc",
    NULL
};

/* Shell builtins */
static const char *builtins[] = {
    "cd", "echo", "exit", "export", "source",
    "alias", "unalias", "read", "printf", "test",
    "set", "unset", "shift", "return", "break",
    "continue", "eval", "exec", "trap", "wait",
    "jobs", "fg", "bg", "kill", "pwd", "history",
    NULL
};

static bool is_keyword(const char *word, size_t len) {
    for (int i = 0; keywords[i]; i++) {
        if (strlen(keywords[i]) == len && 
            strncmp(word, keywords[i], len) == 0) {
            return true;
        }
    }
    return false;
}

static bool is_builtin(const char *word, size_t len) {
    for (int i = 0; builtins[i]; i++) {
        if (strlen(builtins[i]) == len && 
            strncmp(word, builtins[i], len) == 0) {
            return true;
        }
    }
    return false;
}

static bool is_operator_char(char c) {
    return strchr("|&;<>(){}[]!", c) != NULL;
}

void lexer_init(const char *input) {
    input_buffer = input;
    input_pos = 0;
    input_len = input ? strlen(input) : 0;
}

void lexer_reset(void) {
    input_pos = 0;
}

static char peek(void) {
    if (input_pos >= input_len) return '\0';
    return input_buffer[input_pos];
}

static char advance(void) {
    if (input_pos >= input_len) return '\0';
    return input_buffer[input_pos++];
}

Token lexer_next_token(void) {
    Token token = {TOKEN_END, NULL, 0, 0};
    
    /* Skip whitespace */
    while (input_pos < input_len && isspace(peek())) {
        advance();
    }
    
    if (input_pos >= input_len) {
        return token;
    }
    
    token.start = &input_buffer[input_pos];
    char c = peek();
    
    /* Comment */
    if (c == '#') {
        token.type = TOKEN_COMMENT;
        while (peek() && peek() != '\n') {
            advance();
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* String (double quotes) */
    if (c == '"') {
        token.type = TOKEN_STRING;
        advance();
        while (peek() && peek() != '"') {
            if (peek() == '\\') advance(); /* Escape */
            advance();
        }
        if (peek() == '"') advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* String (single quotes) */
    if (c == '\'') {
        token.type = TOKEN_STRING;
        advance();
        while (peek() && peek() != '\'') {
            advance();
        }
        if (peek() == '\'') advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Variable */
    if (c == '$') {
        token.type = TOKEN_VARIABLE;
        advance();
        if (peek() == '{') {
            advance();
            while (peek() && peek() != '}') {
                advance();
            }
            if (peek() == '}') advance();
        } else if (peek() == '(') {
            /* Command substitution - simplified */
            advance();
            int depth = 1;
            while (peek() && depth > 0) {
                if (peek() == '(') depth++;
                if (peek() == ')') depth--;
                advance();
            }
        } else {
            while (peek() && (isalnum(peek()) || peek() == '_')) {
                advance();
            }
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Operators */
    if (is_operator_char(c)) {
        token.type = TOKEN_OPERATOR;
        advance();
        /* Handle multi-char operators */
        if ((c == '|' || c == '&' || c == '<' || c == '>') && 
            peek() == c) {
            advance();
        }
        if (c == '>' && peek() == '&') advance();
        if (c == '<' && peek() == '&') advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Option (starts with -) */
    if (c == '-' && input_pos > 0 && 
        isspace(input_buffer[input_pos - 1])) {
        token.type = TOKEN_OPTION;
        advance();
        if (peek() == '-') advance(); /* Long option */
        while (peek() && (isalnum(peek()) || peek() == '-' || peek() == '_')) {
            advance();
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Number */
    if (isdigit(c)) {
        token.type = TOKEN_NUMBER;
        while (isdigit(peek())) {
            advance();
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Word (command, keyword, path, etc.) */
    token.type = TOKEN_WORD;
    while (peek() && !isspace(peek()) && 
           !is_operator_char(peek()) && 
           peek() != '"' && peek() != '\'' && peek() != '#') {
        advance();
    }
    token.length = &input_buffer[input_pos] - token.start;
    
    /* Determine word type */
    if (is_keyword(token.start, token.length)) {
        token.type = TOKEN_KEYWORD;
    } else if (is_builtin(token.start, token.length)) {
        token.type = TOKEN_BUILTIN;
    } else if (memchr(token.start, '/', token.length)) {
        token.type = TOKEN_PATH;
    }
    
    return token;
}
```

### Syntax Highlighter (highlighter.c)

```c
#include "shellext.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static ColorScheme colors = {
    .command   = "\033[1;32m",    /* Bold green */
    .builtin   = "\033[36m",      /* Cyan */
    .keyword   = "\033[1;33m",    /* Bold yellow */
    .string    = "\033[33m",      /* Yellow */
    .variable  = "\033[34m",      /* Blue */
    .operator_ = "\033[35m",      /* Magenta */
    .comment   = "\033[90m",      /* Gray */
    .number    = "\033[36m",      /* Cyan */
    .path      = "\033[4m",       /* Underline */
    .option    = "\033[32m",      /* Green */
    .error     = "\033[31m",      /* Red */
    .reset     = "\033[0m"
};

void highlighter_init(const ColorScheme *custom_colors) {
    if (custom_colors) {
        colors = *custom_colors;
    }
}

char *highlight_line(const char *line) {
    if (!line) return NULL;
    
    /* Allocate buffer (worst case: each char + color codes) */
    size_t max_len = strlen(line) * 20 + 1;
    char *result = malloc(max_len);
    if (!result) return NULL;
    
    char *out = result;
    lexer_init(line);
    
    const char *last_end = line;
    Token token;
    bool first_word = true;
    
    while ((token = lexer_next_token()).type != TOKEN_END) {
        /* Copy any skipped whitespace */
        while (last_end < token.start) {
            *out++ = *last_end++;
        }
        
        /* Get color for token type */
        const char *color = NULL;
        switch (token.type) {
            case TOKEN_KEYWORD:  color = colors.keyword; break;
            case TOKEN_BUILTIN:  color = colors.builtin; break;
            case TOKEN_STRING:   color = colors.string; break;
            case TOKEN_VARIABLE: color = colors.variable; break;
            case TOKEN_OPERATOR: color = colors.operator_; break;
            case TOKEN_COMMENT:  color = colors.comment; break;
            case TOKEN_NUMBER:   color = colors.number; break;
            case TOKEN_PATH:     color = colors.path; break;
            case TOKEN_OPTION:   color = colors.option; break;
            case TOKEN_ERROR:    color = colors.error; break;
            case TOKEN_WORD:
                /* First word is command */
                if (first_word) {
                    color = colors.command;
                    first_word = false;
                }
                break;
            default: break;
        }
        
        /* Reset first_word flag on pipe or semicolon */
        if (token.type == TOKEN_OPERATOR && 
            (token.start[0] == '|' || token.start[0] == ';')) {
            first_word = true;
        }
        
        /* Write colored token */
        if (color) {
            out += sprintf(out, "%s", color);
        }
        memcpy(out, token.start, token.length);
        out += token.length;
        if (color) {
            out += sprintf(out, "%s", colors.reset);
        }
        
        last_end = token.start + token.length;
    }
    
    /* Copy remaining */
    while (*last_end) {
        *out++ = *last_end++;
    }
    *out = '\0';
    
    return result;
}

void highlighter_free(char *highlighted) {
    free(highlighted);
}
```

### Trie pentru Completion (trie.c)

```c
#include "shellext.h"
#include <stdlib.h>
#include <string.h>

#define ALPHABET_SIZE 128

struct TrieNode {
    struct TrieNode *children[ALPHABET_SIZE];
    bool is_end;
    char *word;  /* Store complete word at end nodes */
};

TrieNode *trie_create(void) {
    TrieNode *node = calloc(1, sizeof(TrieNode));
    return node;
}

void trie_insert(TrieNode *root, const char *word) {
    if (!root || !word) return;
    
    TrieNode *node = root;
    
    for (const char *p = word; *p; p++) {
        unsigned char idx = (unsigned char)*p;
        if (idx >= ALPHABET_SIZE) continue;
        
        if (!node->children[idx]) {
            node->children[idx] = trie_create();
        }
        node = node->children[idx];
    }
    
    node->is_end = true;
    node->word = strdup(word);
}

static void collect_words(TrieNode *node, char ***results, int *count, int *capacity) {
    if (!node) return;
    
    if (node->is_end && node->word) {
        if (*count >= *capacity) {
            *capacity *= 2;
            *results = realloc(*results, *capacity * sizeof(char *));
        }
        (*results)[(*count)++] = strdup(node->word);
    }
    
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        if (node->children[i]) {
            collect_words(node->children[i], results, count, capacity);
        }
    }
}

char **trie_complete(TrieNode *root, const char *prefix, int *count) {
    *count = 0;
    if (!root || !prefix) return NULL;
    
    /* Navigate to prefix node */
    TrieNode *node = root;
    for (const char *p = prefix; *p; p++) {
        unsigned char idx = (unsigned char)*p;
        if (idx >= ALPHABET_SIZE || !node->children[idx]) {
            return NULL;
        }
        node = node->children[idx];
    }
    
    /* Collect all words from this node */
    int capacity = 16;
    char **results = malloc(capacity * sizeof(char *));
    
    collect_words(node, &results, count, &capacity);
    
    return results;
}

void trie_free_results(char **results, int count) {
    if (!results) return;
    for (int i = 0; i < count; i++) {
        free(results[i]);
    }
    free(results);
}

void trie_destroy(TrieNode *root) {
    if (!root) return;
    
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        if (root->children[i]) {
            trie_destroy(root->children[i]);
        }
    }
    
    free(root->word);
    free(root);
}
```

---

## Makefile

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC
LDFLAGS = -lreadline

SRC_DIR = src/c
BUILD_DIR = build

LIB_SOURCES = $(SRC_DIR)/lexer.c $(SRC_DIR)/highlighter.c \
              $(SRC_DIR)/trie.c $(SRC_DIR)/completer.c
LIB_TARGET = $(BUILD_DIR)/libshellext.so

.PHONY: all clean test install

all: $(LIB_TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LIB_TARGET): $(LIB_SOURCES) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

test: $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/test_lexer tests/test_lexer.c \
		-L$(BUILD_DIR) -lshellext -Wl,-rpath,$(BUILD_DIR)
	./$(BUILD_DIR)/test_lexer

clean:
	rm -rf $(BUILD_DIR)

install: $(LIB_TARGET)
	cp $(LIB_TARGET) /usr/local/lib/
	cp src/bash/*.sh /usr/local/share/shellext/
	ldconfig
```

---

## Integrare Bash

### Loader Principal (shellext.sh)

```bash
#!/bin/bash
# shellext.sh - Load shell extensions

SHELLEXT_DIR="${SHELLEXT_DIR:-$(dirname "${BASH_SOURCE[0]}")}"

# Load C library
if [[ -f "$SHELLEXT_DIR/../build/libshellext.so" ]]; then
    export LD_PRELOAD="$SHELLEXT_DIR/../build/libshellext.so"
fi

# Source all modules
source "$SHELLEXT_DIR/prompt.sh"
source "$SHELLEXT_DIR/history.sh"
source "$SHELLEXT_DIR/bookmarks.sh"
source "$SHELLEXT_DIR/hooks.sh"
source "$SHELLEXT_DIR/aliases.sh"

# Enable syntax highlighting (requires C library)
if command -v shellext_highlight &>/dev/null; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_shellext_highlight_command"
    
    _shellext_highlight_command() {
        # Hook into readline for live highlighting
        :
    }
fi

echo "Shell extensions loaded!"
```

---

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Syntax highlighting | 25% | Lexer corect, culori |
| Completion engine | 20% | Trie, context-aware |
| Prompt & history | 15% | Informativ, search |
| Bookmarks & hooks | 15% | Funcționale |
| Integrare readline | 15% | Smooth UX |
| Calitate cod | 5% | Clean, documented |
| Documentație | 5% | README, examples |

---

## Resurse

- GNU Readline documentation
- ANSI escape codes reference
- "Writing Your Own Shell" tutorials
- Seminar 4-5 - Text processing, regex

---

*Proiect ADVANCED | Sisteme de Operare | ASE-CSIE*
