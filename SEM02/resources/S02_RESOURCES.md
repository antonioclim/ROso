# Resurse și Referințe - Seminarul 3-4
## Sisteme de Operare | ASE București - CSIE

> Versiune: 1.0 | Actualizat: Ianuarie 2025  
> Scop: Colecție curată de resurse pentru aprofundarea conceptelor din Seminar 2

---

## Cuprins

1. [Documentație Oficială](#-documentație-oficială)
2. [Tutoriale Interactive](#-tutoriale-interactive)
3. [Cărți și Manuale](#-cărți-și-manuale)
4. [Cheat Sheets și Quick References](#-cheat-sheets-și-quick-references)
5. [Videoclipuri și Cursuri Online](#-videoclipuri-și-cursuri-online)
6. [Practică și Exerciții](#-practică-și-exerciții)
7. [Instrumente și Utilități](#-instrumente-și-utilități)
8. [Comunități și Forumuri](#-comunități-și-forumuri)
9. [Articole și Blog Posts](#-articole-și-blog-posts)
10. [Resurse în Română](#-resurse-în-română)

---

## Documentație Oficială

### GNU Bash Manual
- Link: https://www.gnu.org/software/bash/manual/bash.html
- Conținut: Documentația oficială completă pentru Bash
- Secțiuni relevante pentru seminar:
  - 3.2.4 Lists of Commands (operatori `;`, `&&`, `||`)
  - 3.6 Redirections (toate formele de redirecționare)
  - 3.2.6 GNU Parallel
  - 3.5.1 Brace Expansion
  - 4.1 Bourne Shell Builtins (`break`, `continue`)
- Folosește `man` sau `--help` când ai dubii

### Coreutils Manual
- Link: https://www.gnu.org/software/coreutils/manual/coreutils.html
- Secțiuni relevante:
  - sort: Sortare text
  - uniq: Raportare/omitere linii repetate
  - cut: Extragere secțiuni din linii
  - paste: Îmbinare linii de fișiere
  - tr: Traducere sau ștergere caractere
  - wc: Numărare linii, cuvinte, bytes
  - head/tail: Extragere porțiuni din fișiere
  - tee: Duplicare flux de date

### POSIX Shell Command Language
- Link: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
- Utilitate: Standard POSIX pentru portabilitate maximă

### Man Pages Online
- Link: https://man7.org/linux/man-pages/
- Comenzi relevante: `man bash`, `man sort`, `man uniq`, `man cut`, `man tr`

---

## Tutoriale Interactive

### Exercism - Bash Track
- Link: https://exercism.org/tracks/bash
- Descriere: Exerciții practice cu mentorat gratuit
- Nivel: Începător → Avansat
- Recomandat pentru: Practicare progresivă cu feedback

### Learn Shell - Interactive Tutorial
- Link: https://www.learnshell.org/
- Descriere: Tutorial interactiv în browser
- Secțiuni relevante:
  - Pipes and Filters
  - Process Substitution
  - Loops

### ShellCheck
- Link: https://www.shellcheck.net/
- Descriere: Linter online pentru scripturi shell
- Utilitate: Identifică erori și bad practices în cod
- Citește mesajele de eroare cu atenție — conțin indicii valoroase

### Explain Shell
- Link: https://explainshell.com/
- Descriere: Explică comenzi shell complexe
- Exemplu: Încearcă `cat file | sort | uniq -c | sort -rn | head -10`

### RegexOne - Regex Tutorial
- Link: https://regexone.com/
- Utilitate: Util pentru înțelegerea pattern-urilor folosite cu `grep`, `sed`

---

## Cărți și Manuale

### Gratuite (Online)

#### The Linux Command Line (William Shotts)
- Link: https://linuxcommand.org/tlcl.php
- Format: PDF gratuit, 500+ pagini
- Capitole relevante:
  - Part 1: Learning the Shell
  - Chapter 6: Redirection
  - Chapter 7: Seeing the World as the Shell Sees It
  - Part 4: Shell Scripting
- ⭐ Recomandat ca primă lectură

#### Advanced Bash-Scripting Guide
- Link: https://tldp.org/LDP/abs/html/
- Descriere: ghid complet pentru Bash avansat
- Capitole relevante:
  - Chapter 16: I/O Redirection
  - Chapter 11: Loops and Branches
  - Chapter 7: Tests

#### Bash Guide for Beginners
- Link: https://tldp.org/ldp/bash-beginners-guide/html/
- Nivel: Începător
- Stil: Accesibil, cu multe exemple

### Cu Plată (dar excelente)

#### "Learning the Bash Shell" - O'Reilly
- Autori: Cameron Newham
- ISBN: 978-0596009656
- Note: Clasic, ediția a 3-a
- Verifică rezultatul înainte de a continua

#### "Bash Cookbook" - O'Reilly
- Autori: Carl Albing, JP Vossen
- ISBN: 978-1491975336
- Note: Soluții practice pentru probleme reale

#### "Classic Shell Scripting" - O'Reilly
- Autori: Arnold Robbins, Nelson H.F. Beebe
- ISBN: 978-0596005955
- Note: Filosofia Unix, pipes și filtre
- Citește mesajele de eroare cu atenție — conțin indicii valoroase

---

## Cheat Sheets și Quick References

### Cheat Sheets Oficiale

#### Devhints - Bash Cheat Sheet
- Link: https://devhints.io/bash
- Format: Web, organizat pe secțiuni
- Puncte forte: Concis, actualizat

#### SS64 - Bash Reference
- Link: https://ss64.com/bash/
- Format: Dicționar de comenzi
- Utilitate: Referință rapidă per comandă

### Cheat Sheets PDF

#### Bash Reference Card
- Link: https://mywiki.wooledge.org/BashSheet
- Format: One-page reference
- Conținut: Sintaxă condensată
- Verifică rezultatul înainte de a continua

#### Linux Command Line Cheat Sheet
- Link: https://cheatography.com/davechild/cheat-sheets/linux-command-line/
- Format: PDF printabil

### Quick Reference Cards

#### Unix/Linux Command Reference (FOSSWire)
- Link: https://files.fosswire.com/2007/08/fwunixref.pdf
- Format: PDF A4 față-verso
- Stil: Foarte condensat

---

## Videoclipuri și Cursuri Online

### Gratuite

#### DistroTube - Bash Scripting
- Link: https://www.youtube.com/c/DistroTube
- Playlist: "Learning Bash Scripting"
- Stil: Practic, direct la subiect

#### The Linux Foundation - Introduction to Linux
- Link: https://www.edx.org/course/introduction-to-linux
- Platformă: edX
- Certificat: Disponibil (opțional, cu plată)

#### freeCodeCamp - Bash Scripting Tutorial
- Link: https://www.youtube.com/watch?v=tK9Oc6AEnR4
- Durată: ~5 ore
- Nivel: Începător → Intermediar

#### Ryan's Tutorials - Bash Scripting
- Link: https://ryanstutorials.net/bash-scripting-tutorial/
- Format: Text + exemple
- Stil: Foarte accesibil

### Cu Plată (calitate ridicată)

#### Linux Academy / A Cloud Guru
- Curs: "Linux Shell Scripting"
- Platformă: https://acloudguru.com/
- Nivel: Intermediar
- Folosește `man` sau `--help` când ai dubii

#### Udemy - "Bash Shell Scripting"
- Instructor: Jason Cannon
- Note: Așteaptă reduceri (frecvent la $10-15)

---

## Practică și Exerciții

### Platforme de Practică

#### HackerRank - Linux Shell
- Link: https://www.hackerrank.com/domains/shell
- Exerciții: 60+ probleme
- Categorii: Bash, Text Processing
- Nivel: Easy → Hard

#### LeetCode - Shell
- Link: https://leetcode.com/problemset/shell/
- Exerciții: 4 probleme clasice
- Stil: Interview-style

#### OverTheWire - Bandit
- Link: https://overthewire.org/wargames/bandit/
- Stil: Wargame / CTF
- Nivel: Începător
- ⭐ Foarte recomandat pentru învățare prin explorare

#### Cmdchallenge
- Link: https://cmdchallenge.com/
- Descriere: One-liners challenge
- Stil: Rezolvă în browser

### Seturi de Exerciții

#### Bash Practice Questions
- Link: https://github.com/topics/bash-exercises
- Format: GitHub repos cu exerciții
- Tip: Self-paced

#### Unix Workbench - Coursera
- Link: https://www.coursera.org/learn/unix
- Include: Quiz-uri și proiecte practice

---

## Instrumente și Utilități

### Pentru Dezvoltare

#### Visual Studio Code + Extensions
- Extension: "Bash IDE" (mads-hartmann.bash-ide-vscode)
- Extension: "shellcheck" (timonwong.shellcheck)
- Extension: "Bash Debug"
- Link: https://code.visualstudio.com/

#### ShellCheck (linter)
- Link: https://github.com/koalaman/shellcheck
- Instalare: `sudo apt install shellcheck`
- Utilizare: `shellcheck script.sh`

#### bat (cat cu syntax highlighting)
- Link: https://github.com/sharkdp/bat
- Instalare: `sudo apt install bat`
- Alias recomandat: `alias cat='batcat'` (pe Ubuntu)

### Pentru Debugging

#### bashdb (Bash Debugger)
- Link: http://bashdb.sourceforge.net/
- Instalare: `sudo apt install bashdb`
- Utilizare: `bashdb script.sh`
- Testează cu date simple înainte de cazuri complexe

#### set -x / set +x
```bash
set -x  # Activează trace mode
# comenzi
set +x  # Dezactivează
```

### Pentru Productivitate

#### fzf (Fuzzy Finder)
- Link: https://github.com/junegunn/fzf
- Utilizare: Navigare rapidă în history și fișiere
- Instalare: `sudo apt install fzf`

#### tldr (Simplified man pages)
- Link: https://tldr.sh/
- Instalare: `npm install -g tldr` sau `pip install tldr`
- Utilizare: `tldr tar`, `tldr find`

#### thefuck (Corector automat)
- Link: https://github.com/nvbn/thefuck
- Descriere: Corectează comanda anterioară greșită

---

## Comunități și Forumuri

### Reddit
- r/bash: https://www.reddit.com/r/bash/
- r/commandline: https://www.reddit.com/r/commandline/
- r/linux: https://www.reddit.com/r/linux/

### Stack Exchange
- Unix & Linux: https://unix.stackexchange.com/
- Ask Ubuntu: https://askubuntu.com/
- Super User: https://superuser.com/

### Discord
- Linux Hub: https://discord.gg/linux
- The Programmer's Hangout: https://discord.gg/programming

### IRC
- #bash on Libera.Chat: irc.libera.chat
- Web client: https://web.libera.chat/#bash

### Wiki-uri
- Greg's Bash Wiki: https://mywiki.wooledge.org/
  - BashFAQ: Cele mai frecvente întrebări
  - BashPitfalls: Greșeli comune de evitat
  - ⭐ Resursă excelentă!

---

## Articole și Blog Posts

### Articole Fundamentale

#### "Pipes: A Brief Introduction" - Linus Torvalds
- Context: Filosofia Unix a pipe-urilor
- Link: Diverse arhive online

#### "The Art of Command Line" ⭐ must-read!
- Link: https://github.com/jlevy/the-art-of-command-line
- Format: GitHub repo, tradus în multiple limbi

### Blog Posts Utile

#### Julia Evans - "Bite Size Bash"
- Link: https://wizardzines.com/zines/bite-size-bash/
- Format: Zine/comic explicativ
- Stil: Vizual și memorabil

#### Digital Ocean Tutorials
- Link: https://www.digitalocean.com/community/tutorial_series/getting-started-with-linux
- Calitate: Excelentă, pas cu pas

#### Linux Handbook
- Link: https://linuxhandbook.com/
- Topicuri: Bash scripting, comenzi Linux

#### Baeldung on Linux
- Link: https://www.baeldung.com/linux/
- Stil: Tutorial tehnic detaliat

---

## Resurse în Română

### Documentație și Tutoriale

#### Wiki Ubuntu România
- Link: https://wiki.ubuntu.ro/
- Conținut: Ghiduri în română

#### Linux.ro
- Link: https://www.linux.ro/
- Tip: Forum comunitate românească

#### DevForum.ro
- Link: https://devforum.ro/
- Secțiune: Linux & Unix

### Canale YouTube în Română

#### Diverse canale IT românești
- Căutare: "bash scripting tutorial română"
- Căutare: "linux terminal română"

### Cărți în Română

#### Introducere în Linux
- Autori: Diverse traduceri și materiale academice
- Notă: Verificați bibliotecile universitare pentru resurse

---

## Recomandări pe Nivel

### Începător
1. [Learn Shell](https://www.learnshell.org/) - Tutorial interactiv
2. [The Linux Command Line](https://linuxcommand.org/tlcl.php) - Capitolele 1-7
3. [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Level 0-10
4. [ExplainShell](https://explainshell.com/) - Pentru înțelegerea comenzilor

### Intermediar
1. [HackerRank Shell](https://www.hackerrank.com/domains/shell) - Easy și Medium
2. [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) - Capitole selectate
3. [Greg's Bash Wiki](https://mywiki.wooledge.org/) - BashFAQ, BashPitfalls
4. [Exercism Bash Track](https://exercism.org/tracks/bash) - Cu mentorat

### Avansat
1. [GNU Bash Manual](https://www.gnu.org/software/bash/manual/) - Complet
2. [ShellCheck](https://www.shellcheck.net/) - Înțelegerea avertismentelor
3. [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)
4. Contribuții la proiecte open-source

---

## Resurse pentru Examen

### Concepte de Revizuit
- [ ] Operatori de control: `;`, `&&`, `||`, `&`, `|`
- [ ] coduri de ieșire și `$?`
- [ ] Redirecționare: `>`, `>>`, `<`, `2>`, `2>&1`, `&>`
- [ ] Here documents și here strings
- [ ] descriptori de fișier (0, 1, 2)
- [ ] Toate filtrele: sort, uniq, cut, paste, tr, wc, head, tail, tee
- [ ] Bucle: for (3 forme), while, until
- [ ] Control flow: break, continue
- [ ] Problema subshell cu pipe

### Exerciții de Practică
1. Pipeline Analysis: Explicați pas cu pas ce face un pipeline complex
2. Debugging: Identificați eroarea într-un script dat
3. One-liners: Rezolvați probleme în maxim o linie de comandă
4. Script Writing: Scrieți scripturi complete cu validare

---

## Contact și Suport

### Pentru Întrebări Tehnice
- Laborator: WSL Ubuntu (user: stud, pass: stud)
- Portainer: localhost:9000 (user: stud, pass: studstudstud)

### Resurse Suplimentare Curs
- Verificați platforma eLearning pentru materiale actualizate
- Consultați sesiunile de laborator pentru exerciții practice

---

## Actualizări

| Data | Modificare |
|------|------------|
| Ian 2025 | Versiunea inițială |

---

> 💡 Sugestie: Bookmark-uiți această pagină și explorați resursele treptat.  
> Nu încercați să învățați totul deodată - practica constantă e cheia!

---

*Document generat pentru Seminarul 3-4 SO | ASE București - CSIE | 2025*
