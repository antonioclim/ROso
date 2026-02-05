# Resurse - Seminar 1: Shell Bash

## Link-uri Utile

### Documentație Oficială
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Linux man pages online](https://man7.org/linux/man-pages/)
- [Filesystem Hierarchy Standard (FHS)](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)

### Instrumente Interactive
- [ExplainShell](https://explainshell.com/) - Explică comenzi shell vizual
- [ShellCheck](https://www.shellcheck.net/) - Verificator online pentru scripturi
- [TLDR pages](https://tldr.sh/) - Exemple rapide pentru comenzi
- [Bash Academy](https://guide.bash.academy/) - Tutorial interactiv

### Cheat Sheets
- [Devhints Bash Cheatsheet](https://devhints.io/bash)
- [LeCoupa Bash Cheatsheet](https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh)

### Practică Online
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Joc pentru învățare Linux
- [Linux Journey](https://linuxjourney.com/) - Tutorial pas cu pas
- [Terminus](https://web.mit.edu/mprat/Public/web/Terminus/Web/main.html) - Joc terminal în browser

---

## Bibliografie

### Cărți Recomandate
1. **"The Linux Command Line"** - William Shotts
   - Disponibilă gratuit: https://linuxcommand.org/tlcl.php
   - Capitolele 1-12 pentru acest seminar

2. **"Learning the bash Shell"** - Cameron Newham (O'Reilly)
   - Referință clasică pentru Bash

3. **"Bash Pocket Reference"** - Arnold Robbins (O'Reilly)
   - Referință rapidă, foarte utilă

4. **"UNIX and Linux System Administration Handbook"** - Evi Nemeth et al.
   - Capitolul despre shell scripting

### Articole și Tutoriale
- Bash Guide for Beginners: https://tldp.org/LDP/Bash-Beginners-Guide/html/
- Advanced Bash-Scripting Guide: https://tldp.org/LDP/abs/html/

---

## Software Necesar

### Obligatoriu
- **Terminal Linux** (WSL2, VM, sau instalare nativă)
- **Bash shell** (versiunea 4.0+)
- **Editor text** (nano, vim, sau VS Code)

### Recomandat pentru Demo-uri
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y figlet lolcat cmatrix cowsay tree ncdu pv dialog

# Verificare instalare
which figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

### Opțional pentru Productivitate
- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder
- **bat** - Cat cu syntax highlighting
- **exa/eza** - Ls modern

---

## Comenzi man Utile

Pentru a învăța mai multe despre orice comandă:

```bash
# Manual complet
man bash
man ls
man cd

# Secțiune specifică din manual
man 1 intro      # Introducere în comenzi
man 7 hier       # Ierarhia sistemului de fișiere

# Căutare în manuale
apropos "search term"
man -k "keyword"

# Ajutor rapid
help cd          # Pentru comenzi built-in
ls --help        # Pentru comenzi externe
```

---

## Obiective de Învățare

După completarea acestui seminar, studenții vor fi capabili să:

### Nivel Fundamental (Remember/Understand)
- [ ] Explice rolul shell-ului în sistemul de operare
- [ ] Identifice și descrie directoarele principale din FHS
- [ ] Distingă între variabile locale și de mediu

### Nivel Intermediar (Apply/Analyze)
- [ ] Navigheze eficient în sistemul de fișiere
- [ ] Creeze și manipuleze fișiere și directoare
- [ ] Configureze mediul de lucru prin .bashrc
- [ ] Folosească wildcards pentru selecție de fișiere

### Nivel Avansat (Evaluate/Create)
- [ ] Scrie scripturi bash funcționale
- [ ] Depaneze probleme comune cu variabile și quoting
- [ ] Automatizeze task-uri repetitive prin alias-uri și funcții

---

## Greșeli Comune de Evitat

1. **Spații în atribuiri**: `VAR = "val"` ❌ → `VAR="val"` ✅
2. **$ la atribuire**: `$VAR="val"` ❌ → `VAR="val"` ✅
3. **Lipsa ghilimelelor**: `echo $VAR` pentru fișiere cu spații ❌
4. **rm -rf fără grijă**: Verifică ÎNTOTDEAUNA calea!
5. **Confuzie ~ vs /**: ~ = $HOME, NU rădăcina
6. **Single vs double quotes**: Alege corect pentru context
7. **Uitarea de `source`**: După modificarea .bashrc

---

## Contact și Suport

- **Platforma de curs**: [Link către platforma ASE]
- **Forum discuții**: [Link forum]
- **Ore de consultații**: [Program]

---

*Ultima actualizare: Ianuarie 2025*
