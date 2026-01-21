# TC4f - Editarea cu VI/VIM

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 4

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Navigeze eficient în VI/VIM
- Editeze text în diferite moduri
- Folosească căutarea și înlocuirea
- Configureze VIM pentru productivitate

---

## 1. Introducere în VI/VIM

### 1.1 Ce este VI/VIM?

**VI** (Visual Editor) este editorul standard Unix, disponibil pe orice sistem.
**VIM** (VI IMproved) este versiunea îmbunătățită cu funcții adiționale.

### 1.2 De ce VI/VIM?

- Disponibil pe orice sistem Unix/Linux
- Foarte rapid pentru editare text
- Funcționează în terminal (SSH, servere)
- foarte configurabil

---

## 2. Modurile de Operare

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌──────────────┐                    ┌──────────────┐     │
│   │ NORMAL MODE  │◄──── ESC ──────────│ INSERT MODE  │     │
│   │  (comenzi)   │────► i, a, o, I, A │  (editare)   │     │
│   └──────┬───────┘                    └──────────────┘     │
│          │                                                  │
│          │ :                                                │
│          ▼                                                  │
│   ┌──────────────┐                    ┌──────────────┐     │
│   │ COMMAND MODE │                    │ VISUAL MODE  │     │
│   │ (ex commands)│◄──── ESC ──────────│ (selectare)  │     │
│   └──────────────┘                    └──────────────┘     │
│                                             ▲              │
│                                             │ v, V, Ctrl+v │
│                                             │              │
│   NORMAL MODE ──────────────────────────────┘              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.1 Normal Mode (Command Mode)

- Modul default când deschizi VIM
- Pentru navigare și comenzi
- Apasă `ESC` pentru a reveni aici

### 2.2 Insert Mode

- Pentru editare text
- Intrare: `i`, `a`, `o`, `I`, `A`, `O`
- Ieșire: `ESC`

### 2.3 Visual Mode

- Pentru selectare text
- Intrare: `v` (caractere), `V` (linii), `Ctrl+v` (bloc)
- Ieșire: `ESC`

### 2.4 Command-Line Mode

- Pentru comenzi Ex (salvare, ieșire, etc.)
- Intrare: `:`
- Ieșire: `Enter` sau `ESC`

---

## 3. Navigare (Normal Mode)

### 3.1 Mișcări de Bază

```bash
h       # stânga
j       # jos
k       # sus
l       # dreapta

# Cu multiplier
5j      # 5 linii în jos
10l     # 10 caractere la dreapta
```

### 3.2 Navigare pe Cuvinte

```bash
w       # început cuvânt următor
W       # cuvânt următor (WORD, ignoră punctuație)
e       # sfârșit cuvânt curent/următor
E       # sfârșit WORD
b       # început cuvânt anterior
B       # WORD anterior
```

### 3.3 Navigare pe Linie

```bash
0       # început de linie (coloana 0)
^       # primul caracter non-spațiu
$       # sfârșit de linie
g_      # ultimul caracter non-spațiu
```

### 3.4 Navigare în Fișier

```bash
gg      # început de fișier
G       # sfârșit de fișier
:N      # mergi la linia N (ex: :50)
NG      # alternativ, 50G pentru linia 50
Ctrl+f  # pagină în jos (forward)
Ctrl+b  # pagină în sus (backward)
Ctrl+d  # jumătate de pagină în jos
Ctrl+u  # jumătate de pagină în sus
H       # sus pe ecran (High)
M       # mijloc pe ecran (Middle)
L       # jos pe ecran (Low)
```

---

## 4. Intrare în Insert Mode

```bash
i       # inserează înainte de cursor
I       # inserează la începutul liniei
a       # inserează după cursor
A       # inserează la sfârșitul liniei
o       # linie nouă dedesubt
O       # linie nouă deasupra
s       # șterge caracterul și inserează
S       # șterge linia și inserează
```

---

## 5. Editare (Normal Mode)

### 5.1 Ștergere

```bash
x       # șterge caracter sub cursor
X       # șterge caracter înainte de cursor
dd      # șterge linia curentă
D       # șterge de la cursor până la sfârșit de linie
dw      # șterge cuvântul
d$      # șterge până la sfârșit de linie
d0      # șterge până la început de linie
dG      # șterge până la sfârșitul fișierului
dgg     # șterge până la începutul fișierului

# Cu multiplier
3dd     # șterge 3 linii
5x      # șterge 5 caractere
```

### 5.2 Copiere (Yank)

```bash
yy      # copiază linia curentă
Y       # echivalent cu yy
yw      # copiază cuvântul
y$      # copiază până la sfârșit de linie
y0      # copiază până la început de linie

3yy     # copiază 3 linii
```

### 5.3 Lipire (Paste)

```bash
p       # lipește după cursor / sub linie
P       # lipește înainte de cursor / deasupra liniei
```

### 5.4 Înlocuire

```bash
r       # înlocuiește un caracter
R       # mod Replace (suprascrie)
cw      # change word (șterge cuvânt și intră în Insert)
cc      # change line
C       # change până la sfârșit de linie
c$      # echivalent cu C
```

### 5.5 Undo / Redo

```bash
u       # undo
Ctrl+r  # redo
.       # repetă ultima comandă
```

---

## 6. Căutare și Înlocuire

### 6.1 Căutare

```bash
/pattern        # caută înainte
?pattern        # caută înapoi
n               # următoarea potrivire
N               # potrivirea anterioară
*               # caută cuvântul sub cursor (înainte)
# # caută cuvântul sub cursor (înapoi)

# Opțiuni căutare
:set hlsearch   # highlight rezultate
:set incsearch  # căutare incrementală
:nohlsearch     # șterge highlight-ul (:noh)
```

### 6.2 Înlocuire

```bash
:s/old/new/         # prima apariție pe linia curentă
:s/old/new/g        # toate aparițiile pe linia curentă
:%s/old/new/g       # în tot fișierul
:%s/old/new/gc      # cu confirmare
:5,10s/old/new/g    # pe liniile 5-10
:'<,'>s/old/new/g   # în selecția vizuală
```

---

## 7. Visual Mode

```bash
v       # Visual mode (selectare caractere)
V       # Visual Line (selectare linii)
Ctrl+v  # Visual Block (selectare bloc)

# După selectare:
d       # șterge selecția
y       # copiază selecția
c       # change (înlocuiește)
>       # indentează la dreapta
<       # indentează la stânga
~       # toggle case
```

---

## 8. Salvare și Ieșire

```bash
:w              # salvează
:w filename     # salvează ca
:q              # ieșire (dacă nu sunt modificări)
:q!             # ieșire forțată (pierde modificări)
:wq             # salvează și ieși
:x              # echivalent cu :wq
ZZ              # echivalent cu :wq (Normal mode)
ZQ              # echivalent cu :q! (Normal mode)
:e filename     # deschide alt fișier
:e!             # reîncarcă fișierul (pierde modificări)
```

---

## 9. Configurare de Bază

```bash
# În ~/.vimrc
set number          # afișează numere de linie
set relativenumber  # numere relative
set tabstop=4       # tab = 4 spații
set shiftwidth=4    # indentare = 4 spații
set expandtab       # tab -> spații
set autoindent      # auto-indentare
set hlsearch        # highlight căutare
set incsearch       # căutare incrementală
set ignorecase      # case-insensitive
set smartcase       # smart case (dacă ai majusculă, e case-sensitive)
syntax on           # syntax highlighting
set mouse=a         # suport mouse
```

---

## 10. Exerciții Practice

### Exercițiul 1: Navigare
```
1. Deschide un fișier: vim file.txt
2. Mergi la linia 50: :50 sau 50G
3. Mergi la sfârșitul fișierului: G
4. Mergi la început: gg
5. Navighează pe cuvinte: w, b, e
```

### Exercițiul 2: Editare
```
1. Șterge o linie: dd
2. Copiază 3 linii: 3yy
3. Lipește: p
4. Undo: u
5. Redo: Ctrl+r
```

### Exercițiul 3: Căutare și Înlocuire
```
1. Caută "error": /error
2. Următoarea potrivire: n
3. Înlocuiește "error" cu "warning": :%s/error/warning/g
```

---

## Cheat Sheet

```bash
# MODURI
i, a, o     → Insert Mode
ESC         → Normal Mode
:           → Command Mode
v, V, Ctrl+v → Visual Mode

# NAVIGARE
h j k l     stânga/jos/sus/dreapta
w b e       cuvinte
0 ^ $       început/primul char/sfârșit linie
gg G        început/sfârșit fișier
:N          linia N
Ctrl+f/b    pagină jos/sus

# EDITARE
x           șterge caracter
dd          șterge linie
yy          copiază linie
p           paste
u           undo
Ctrl+r      redo
.           repetă

# CĂUTARE
/pattern    caută înainte
?pattern    caută înapoi
n N         următoarea/anterioara
*           caută cuvânt curent
:%s/a/b/g   înlocuiește toate

# SALVARE/IEȘIRE
:w          salvează
:q          ieșire
:wq sau ZZ  salvează și ieși
:q!         ieșire forțată
```

---
*Material adaptat pentru cursul de Sisteme de Operare | ASE București - CSIE*
