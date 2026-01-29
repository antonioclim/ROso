# S04_TC05 - Editoare Text în Terminal

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 4 (MODIFICAT - include nano și vim)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Folosească editorul `nano` pentru editări rapide
- Navigeze eficient în VI/VIM
- Editeze text în diferite moduri
- Aleagă editorul potrivit pentru fiecare situație

---


## Partea II: Editorul VI/VIM

### 2. Introducere în VI/VIM

**VI** (Visual Editor) este editorul standard Unix, disponibil pe orice sistem.
**VIM** (VI IMproved) este versiunea îmbunătățită cu funcții adiționale.

### 2.1 De ce VI/VIM?

- Disponibil pe ORICE sistem Unix/Linux (inclusiv servere minimale)
- Foarte rapid pentru editare text
- Funcționează în terminal (SSH, servere)
- Extrem de configurabil și extensibil
- Productivitate înaltă odată învățat

### 2.2 Modurile de Operare

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

**Normal Mode** - modul default, pentru comenzi și navigare
**Insert Mode** - pentru editare text (`i`, `a`, `o`)
**Visual Mode** - pentru selectare (`v`, `V`, `Ctrl+v`)
**Command-Line Mode** - pentru comenzi Ex (`:`)

### 2.3 Comenzi de Supraviețuire VIM

```bash
# INTRARE
vim fisier.txt      # deschide fișier
i                   # intră în Insert mode

# IEȘIRE (din Normal mode)
:w                  # salvează
:q                  # ieși
:wq                 # salvează și ieși
:q!                 # ieși FĂRĂ salvare (forțat)
ZZ                  # salvează și ieși (scurtătură)

# REVENIRE LA NORMAL
ESC                 # întotdeauna revii la Normal mode
```

### 2.4 Navigare în VIM (Normal Mode)

```bash
# Mișcări de bază
h j k l           # stânga, jos, sus, dreapta

# Pe cuvinte
w                 # următorul cuvânt (început)
e                 # următorul cuvânt (sfârșit)
b                 # cuvântul anterior

# Pe linii
0                 # început de linie
$                 # sfârșit de linie
^                 # primul caracter non-spațiu

# Pe fișier
gg                # începutul fișierului
G                 # sfârșitul fișierului
:10               # linia 10
```

### 2.5 Editare în VIM

```bash
# Inserare text
i                 # insert înainte de cursor
a                 # append după cursor
o                 # linie nouă dedesubt
O                 # linie nouă deasupra
I                 # insert la începutul liniei
A                 # append la sfârșitul liniei

# Ștergere
x                 # șterge caracter
dd                # șterge linie
dw                # șterge cuvânt
d$                # șterge până la sfârșit de linie
D                 # la fel ca d$

# Copiere și lipire
yy                # copiază (yank) linie
yw                # copiază cuvânt
p                 # lipește după cursor
P                 # lipește înainte de cursor

# Undo/Redo
u                 # undo
Ctrl+r            # redo
```

### 2.6 Căutare și Înlocuire în VIM

```bash
# Căutare
/pattern          # caută înainte
?pattern          # caută înapoi
n                 # următoarea potrivire
N                 # potrivirea anterioară

# Înlocuire
:s/old/new/       # înlocuiește primul pe linia curentă
:s/old/new/g      # înlocuiește toate pe linia curentă
:%s/old/new/g     # înlocuiește în tot fișierul
:%s/old/new/gc    # cu confirmare
```

### 2.7 Configurare VIM (~/.vimrc)

```vim
" Numere de linie
set number
set relativenumber

" Syntax highlighting
syntax on

" Indentare
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Căutare
set hlsearch
set incsearch
set ignorecase
set smartcase

" Interfață
set showcmd
set ruler
set wildmenu
```

---

## Partea III: Comparație și Alegere

### 3.1 Când să folosești nano

✅ **Folosește nano pentru:**
- Editări rapide de configurații
- Când ești nou în Linux
- Când ai nevoie de ceva simplu și intuitiv
- Modificări mici în fișiere text

### 3.2 Când să folosești vim

✅ **Folosește vim pentru:**
- Editare cod sursă
- Sesiuni lungi de editare
- Când ai nevoie de macro-uri și automatizări
- Pe servere unde nano nu e instalat
- Productivitate maximă (după curba de învățare)

### 3.3 Tabel Comparativ

| Aspect | nano | vim |
|--------|------|-----|
| Curba de învățare | Ușoară | Abruptă |
| Disponibilitate | Majoritate sisteme | Toate sistemele Unix |
| Productivitate inițială | Înaltă | Scăzută |
| Productivitate expert | Medie | Foarte înaltă |
| Extensibilitate | Limitată | Nelimitată |
| Moduri de operare | Unul | Multiple |
| Scurtături | Ctrl+X | Combinații complexe |

---

## 4. Exerciții Practice

### Exercițiul 1: nano
1. Deschide un fișier nou cu nano
2. Scrie 10 linii de text
3. Caută și înlocuiește un cuvânt
4. Salvează și ieși

### Exercițiul 2: vim
1. Deschide un fișier cu vim
2. Navighează folosind h, j, k, l
3. Șterge 3 linii cu `3dd`
4. Undo cu `u`
5. Salvează și ieși cu `:wq`

### Exercițiul 3: Comparație
Editează același fișier de configurare (ex: `.bashrc`) o dată cu nano și o dată cu vim. Compară experiența.

---

## Cheat Sheet Combinat

### nano
```
Ctrl+O  Salvează        Ctrl+K  Taie linie
Ctrl+X  Ieșire          Ctrl+U  Lipește
Ctrl+W  Caută           Ctrl+\  Înlocuiește
Ctrl+G  Ajutor          Ctrl+_  Salt la linie
```

### vim
```
i       Insert mode     ESC     Normal mode
:w      Salvează        :q      Ieși
:wq     Salvează+Ieși   :q!     Ieși forțat
dd      Șterge linie    yy      Copiază linie
p       Lipește         u       Undo
/text   Caută           :%s/a/b/g  Înlocuiește
```

---

## Referințe

- `man nano`
- `man vim`
- `vimtutor` - Tutorial interactiv vim (rulează în terminal)
- [Vim Adventures](https://vim-adventures.com/) - Joc pentru învățare vim
- [OpenVim](https://www.openvim.com/) - Tutorial interactiv online

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
