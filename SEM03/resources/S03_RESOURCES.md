# Resurse Suplimentare - Seminarul 03
## Sisteme de Operare | ASE București - CSIE

Utilitare Avansate • Scripturi Profesionale • Permisiuni Unix • Automatizare

---

## Cuprins

1. [Documentație Oficială](#1-documentație-oficială)
2. [Tutoriale și Ghiduri Online](#2-tutoriale-și-ghiduri-online)
3. [Cărți Recomandate](#3-cărți-recomandate)
4. [Platforme de Practică](#4-platforme-de-practică)
5. [Cheat Sheets și Referințe Rapide](#5-cheat-sheets-și-referințe-rapide)
6. [Videoclipuri Educaționale](#6-videoclipuri-educaționale)
7. [Instrumente Online](#7-instrumente-online)
8. [Articole Tehnice Avansate](#8-articole-tehnice-avansate)
9. [Comunități și Forumuri](#9-comunități-și-forumuri)
10. [Resurse pentru Securitate](#10-resurse-pentru-securitate)
11. [Exerciții și Provocări](#11-exerciții-și-provocări)
12. [Resurse Specifice per Modul](#12-resurse-specifice-per-modul)

---

## 1. Documentație Oficială

### 1.1 GNU Coreutils și Findutils

| Resursă | URL | Descriere |
|---------|-----|-----------|
| GNU Find Manual | https://www.gnu.org/software/findutils/manual/html_mono/find.html | Documentația completă oficială |
| GNU Coreutils | https://www.gnu.org/software/coreutils/manual/ | chmod, chown, stat, etc. |
| Bash Reference Manual | https://www.gnu.org/software/bash/manual/ | Referință completă Bash |
| POSIX Specifications | https://pubs.opengroup.org/onlinepubs/9699919799/ | Standard portabilitate |

### 1.2 Man Pages Online

```bash
# Accesează local:
man find
man xargs
man chmod
man crontab

# Secțiuni specifice:
man 5 crontab     # Formatul fișierului crontab
man 8 cron        # Daemon-ul cron
```

| Man Page Online | URL |
|-----------------|-----|
| man7.org | https://man7.org/linux/man-pages/ |
| die.net | https://linux.die.net/man/ |
| Ubuntu Manpage | https://manpages.ubuntu.com/ |

### 1.3 Documentație Ubuntu

- Ubuntu Server Guide: https://ubuntu.com/server/docs
- Ubuntu Security: https://ubuntu.com/security
- Ubuntu Community Help: https://help.ubuntu.com/community/

---

## 2. Tutoriale și Ghiduri Online

### 2.1 find și xargs

| Resursă | Nivel | Descriere |
|---------|-------|-----------|
| [Linux find command tutorial](https://www.computerhope.com/unix/ufind.htm) | Începător | Introducere cu exemple |
| [35 Practical Examples of find](https://www.tecmint.com/35-practical-examples-of-linux-find-command/) | Intermediar | Exemple practice |
| [GNU findutils Examples](https://www.gnu.org/software/findutils/manual/html_node/find_html/) | Avansat | Toate opțiunile |
| [xargs Tutorial](https://shapeshed.com/unix-xargs/) | Intermediar | Ghid complet xargs |
| [Parallel Processing with xargs](https://www.cyberciti.biz/faq/linux-xargs-command-tutorial-examples/) | Avansat | xargs -P |

### 2.2 Parametri Script și getopts

| Resursă | Nivel | Descriere |
|---------|-------|-----------|
| [Bash Positional Parameters](https://www.gnu.org/software/bash/manual/html_node/Positional-Parameters.html) | Oficial | Documentație GNU |
| [getopts Tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) | Intermediar | Ghid complet |
| [Shell Scripting Tutorial](https://www.shellscript.sh/) | Începător | De la zero |
| [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) | Avansat | TLDP classic |
| [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible) | Avansat | Tehnici fără dependențe |

### 2.3 Permisiuni Unix

| Resursă | Nivel | Descriere |
|---------|-------|-----------|
| [Linux File Permissions Explained](https://www.redhat.com/sysadmin/linux-file-permissions-explained) | Începător | Red Hat |
| [chmod Calculator](https://chmod-calculator.com/) | Instrument | Calculator online |
| [Understanding SUID/SGID](https://www.linuxnix.com/suid-set-suid-linuxunix/) | Intermediar | Permisiuni speciale |
| [umask Explained](https://www.cyberciti.biz/tips/understanding-linux-unix-umask-value-usage.html) | Intermediar | Detaliat |
| [Linux Security Modules](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html) | Avansat | SELinux, AppArmor |

### 2.4 Cron și Automatizare

| Resursă | Nivel | Descriere |
|---------|-------|-----------|
| [Crontab Guru](https://crontab.guru/) | Instrument | Editor/validator online |
| [Cron Expression Generator](https://www.freeformatter.com/cron-expression-generator-quartz.html) | Instrument | Generator |
| [Systemd Timers vs Cron](https://wiki.archlinux.org/title/Systemd/Timers) | Avansat | Alternativă modernă |
| [Cron Best Practices](https://blog.healthchecks.io/2022/01/cron-job-best-practices/) | Intermediar | Producție |

---

## 3. Cărți Recomandate

### 3.1 Gratuite Online

| Titlu | Autor | Format | URL |
|-------|-------|--------|-----|
| The Linux Command Line | William Shotts | PDF/HTML | https://linuxcommand.org/tlcl.php |
| Advanced Bash-Scripting Guide | Mendel Cooper | HTML | https://tldp.org/LDP/abs/html/ |
| Bash Guide for Beginners | Machtelt Garrels | HTML | https://tldp.org/LDP/Bash-Beginners-Guide/html/ |
| GNU/Linux Command-Line Tools Summary | Gareth Anderson | HTML | https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/ |
| Linux Fundamentals | Paul Cobbaut | PDF | https://linux-training.be/linuxfun.pdf |

### 3.2 Cărți de Referință (Achiziție)

| Titlu | Autor | Editură | Nivel |
|-------|-------|---------|-------|
| Unix and Linux System Administration Handbook | Nemeth, Snyder, Hein | Pearson | complet |
| Learning the bash Shell | Newham, Rosenblatt | O'Reilly | Intermediar |
| Mastering Regular Expressions | Jeffrey Friedl | O'Reilly | Avansat |
| How Linux Works | Brian Ward | No Starch | Intermediar |
| Linux Bible | Christopher Negus | Wiley | complet |

### 3.3 eBooks Specifice

| Titlu | Focus | Disponibilitate |
|-------|-------|-----------------|
| Bash Cookbook | Rețete practice | O'Reilly Safari |
| Shell Scripting Recipes | Automatizare | Various |
| Wicked Cool Shell Scripts | Scripturi utile | No Starch |

---

## 4. Platforme de Practică

### 4.1 Platforme Interactive

| Platformă | URL | Caracteristici |
|-----------|-----|----------------|
| OverTheWire: Bandit | https://overthewire.org/wargames/bandit/ | Wargames Linux (perfect pentru permisiuni!) |
| Exercism: Bash Track | https://exercism.org/tracks/bash | Exerciții cu mentoring |
| HackerRank: Linux Shell | https://www.hackerrank.com/domains/shell | Provocări categorisate |
| LeetCode: Shell | https://leetcode.com/problemset/shell/ | Probleme competitive |
| Linux Survival | https://linuxsurvival.com/ | Tutorial interactiv |

### 4.2 Sandbox-uri Online

| Platformă | URL | Caracteristici |
|-----------|-----|----------------|
| repl.it | https://replit.com/ | Terminal complet în browser |
| JDoodle | https://www.jdoodle.com/test-bash-shell-script-online | Compilator Bash online |
| OnlineGDB | https://www.onlinegdb.com/online_bash_shell | Debug online |
| Paiza.io | https://paiza.io/en/projects/new?language=bash | Multi-limbaj |

### 4.3 Laboratoare Virtuale

| Resursă | Tip | Descriere |
|---------|-----|-----------|
| Katacoda (O'Reilly) | Browser | Scenarii interactive |
| Linux Parcurs | Web | Curs structurat |
| Webminal | SSH Browser | Terminal real |

---

## 5. Cheat Sheets și Referințe Rapide

### 5.1 find Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                    FIND QUICK REFERENCE                          ║
╠══════════════════════════════════════════════════════════════════╣
║ SEARCH BY NAME                                                   ║
║   find /path -name "*.txt"        Case sensitive                 ║
║   find /path -iname "*.txt"       Case insensitive               ║
║                                                                  ║
║ SEARCH BY TYPE                                                   ║
║   -type f    Regular file       -type d    Directory            ║
║   -type l    Symbolic link      -type b    Block device         ║
║                                                                  ║
║ SEARCH BY SIZE                                                   ║
║   -size +10M     Larger than 10MB                               ║
║   -size -100k    Smaller than 100KB                             ║
║   -size 50c      Exactly 50 bytes                               ║
║                                                                  ║
║ SEARCH BY TIME (days)                                            ║
║   -mtime -7      Modified in last 7 days                        ║
║   -mtime +30     Modified more than 30 days ago                 ║
║   -mmin -60      Modified in last 60 minutes                    ║
║                                                                  ║
║ LOGICAL OPERATORS                                                ║
║   -and / -a      AND (implicit)                                 ║
║   -or  / -o      OR                                             ║
║   -not / !       NOT                                            ║
║   \( \)          Grouping                                       ║
║                                                                  ║
║ ACTIONS                                                          ║
║   -print         Display (default)                              ║
║   -print0        Null-separated (for xargs -0)                  ║
║   -exec cmd {} \;   Execute for each                            ║
║   -exec cmd {} +    Execute batched                             ║
║   -delete        Delete (⚠️ test first!)                        ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.2 xargs Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                    XARGS QUICK REFERENCE                         ║
╠══════════════════════════════════════════════════════════════════╣
║ BASIC USAGE                                                      ║
║   cmd | xargs               Execute with all args                ║
║   cmd | xargs -n 1          One arg per execution               ║
║   cmd | xargs -I {} cmd {}  Custom placeholder                  ║
║                                                                  ║
║ HANDLING SPECIAL CHARACTERS                                      ║
║   find . -print0 | xargs -0    Null-separated (spaces safe)     ║
║                                                                  ║
║ PARALLEL EXECUTION                                               ║
║   xargs -P 4                Execute 4 processes in parallel      ║
║                                                                  ║
║ COMMON PATTERNS                                                  ║
║   find . -name "*.log" | xargs rm                               ║
║   find . -name "*.txt" -print0 | xargs -0 grep "pattern"        ║
║   cat files.txt | xargs -I {} cp {} backup/                     ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.3 Permissions Cheat Sheet

```
╔══════════════════════════════════════════════════════════════════╗
║                 PERMISSIONS QUICK REFERENCE                      ║
╠══════════════════════════════════════════════════════════════════╣
║ PERMISSION BITS                                                  ║
║                                                                  ║
║   Symbolic:  r w x   r w x   r w x                              ║
║              │ │ │   │ │ │   │ │ │                              ║
║              └─┴─┴─owner─┴─group─┴─others                        ║
║                                                                  ║
║   Octal:    4 2 1   4 2 1   4 2 1                               ║
║             │ │ │   │ │ │   │ │ │                               ║
║             r w x   r w x   r w x                               ║
║                                                                  ║
║ COMMON PERMISSIONS                                               ║
║   755 rwxr-xr-x   Executables, directories                      ║
║   644 rw-r--r--   Regular files                                 ║
║   600 rw-------   Private files                                 ║
║   700 rwx------   Private directories/scripts                   ║
║   666 rw-rw-rw-   ⚠️ Avoid! Everyone can write                  ║
║   777 rwxrwxrwx   ⚠️ NEVER! Security nightmare                  ║
║                                                                  ║
║ SPECIAL PERMISSIONS                                              ║
║   SUID (4xxx)   Execute as owner       chmod u+s / chmod 4755   ║
║   SGID (2xxx)   Inherit group          chmod g+s / chmod 2755   ║
║   Sticky (1xxx) Only owner deletes     chmod +t  / chmod 1777   ║
║                                                                  ║
║ x ON DIRECTORY = ACCESS (cd), NOT EXECUTE!                       ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.4 umask Calculator

```
╔══════════════════════════════════════════════════════════════════╗
║                    UMASK CALCULATOR                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   Default permissions:                                           ║
║     Files:       666 (rw-rw-rw-)                                ║
║     Directories: 777 (rwxrwxrwx)                                ║
║                                                                  ║
║   umask REMOVES bits from default!                               ║
║                                                                  ║
║   ┌─────────────────────────────────────────────────────────┐   ║
║   │ umask │ Files (666-umask) │ Directories (777-umask)    │   ║
║   ├─────────────────────────────────────────────────────────┤   ║
║   │  000  │  666 (rw-rw-rw-)  │  777 (rwxrwxrwx)          │   ║
║   │  002  │  664 (rw-rw-r--)  │  775 (rwxrwxr-x)          │   ║
║   │  022  │  644 (rw-r--r--)  │  755 (rwxr-xr-x) ← typical │   ║
║   │  027  │  640 (rw-r-----)  │  750 (rwxr-x---)          │   ║
║   │  077  │  600 (rw-------)  │  700 (rwx------) ← secure │   ║
║   └─────────────────────────────────────────────────────────┘   ║
║                                                                  ║
║   Formula: Final = Default - umask (per digit)                   ║
║   ⚠️ umask NU ADAUGĂ biți, doar ELIMINĂ!                        ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.5 Cron Format Reference

```
╔══════════════════════════════════════════════════════════════════╗
║                    CRON FORMAT REFERENCE                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   ┌───────────── minute (0-59)                                  ║
║   │ ┌───────────── hour (0-23)                                  ║
║   │ │ ┌───────────── day of month (1-31)                        ║
║   │ │ │ ┌───────────── month (1-12 or JAN-DEC)                  ║
║   │ │ │ │ ┌───────────── day of week (0-7, SUN=0 or 7)          ║
║   │ │ │ │ │                                                     ║
║   * * * * * command                                             ║
║                                                                  ║
║ SPECIAL CHARACTERS                                               ║
║   *       Every value           */n     Every n                 ║
║   n-m     Range n to m          n,m     List n and m            ║
║                                                                  ║
║ COMMON EXAMPLES                                                  ║
║   0 * * * *        Every hour at :00                            ║
║   */15 * * * *     Every 15 minutes                             ║
║   0 3 * * *        Daily at 3:00 AM                             ║
║   0 3 * * 0        Sundays at 3:00 AM                           ║
║   0 0 1 * *        First of each month at midnight              ║
║   30 4 1,15 * *    1st and 15th at 4:30 AM                      ║
║                                                                  ║
║ SHORTCUTS (if supported)                                         ║
║   @reboot          At startup                                   ║
║   @yearly          0 0 1 1 *                                    ║
║   @monthly         0 0 1 * *                                    ║
║   @weekly          0 0 * * 0                                    ║
║   @daily           0 0 * * *                                    ║
║   @hourly          0 * * * *                                    ║
║                                                                  ║
║ ⚠️ DOM + DOW: EITHER matches (OR logic, not AND!)               ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.6 getopts Reference

```
╔══════════════════════════════════════════════════════════════════╗
║                   GETOPTS QUICK REFERENCE                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║ BASIC TEMPLATE                                                   ║
║   while getopts "hvf:n:" opt; do                                ║
║       case $opt in                                              ║
║           h) usage; exit 0 ;;                                   ║
║           v) VERBOSE=1 ;;                                       ║
║           f) FILE="$OPTARG" ;;                                  ║
║           n) NUM="$OPTARG" ;;                                   ║
║           ?) usage; exit 1 ;;                                   ║
║       esac                                                      ║
║   done                                                          ║
║   shift $((OPTIND-1))                                           ║
║                                                                  ║
║ OPTSTRING FORMAT                                                 ║
║   "abc"     -a, -b, -c without arguments                        ║
║   "a:b:c"   -a ARG, -b ARG, -c ARG required                     ║
║   "a:bc"    -a ARG required, -b -c optional                     ║
║   ":abc"    Silent errors (leading :)                           ║
║                                                                  ║
║ SPECIAL VARIABLES                                                ║
║   $OPTARG   Value of current option's argument                  ║
║   $OPTIND   Index of next argument to process                   ║
║   $opt      Current option letter                               ║
║                                                                  ║
║ ⚠️ getopts ONLY handles short options (-a, -b)                  ║
║    For --long options, use manual parsing with case             ║
╚══════════════════════════════════════════════════════════════════╝
```

### 5.7 Resurse Downloadabile

| Resursă | Format | URL |
|---------|--------|-----|
| DevHints Bash | Web/PDF | https://devhints.io/bash |
| Linux Command Cheat Sheet | PDF | https://www.linuxtrainingacademy.com/linux-commands-cheat-sheet/ |
| chmod Calculator | Web | https://chmod-calculator.com/ |
| Crontab Guru | Web | https://crontab.guru/ |

---

## 6. Videoclipuri Educaționale

### 6.1 Canale YouTube Recomandate

| Canal | Focus | Link |
|-------|-------|------|
| Learn Linux TV | Server administration | https://www.youtube.com/@LearnLinuxTV |
| NetworkChuck | Linux basics, fun style | https://www.youtube.com/@NetworkChuck |
| The Linux Experiment | Desktop Linux | https://www.youtube.com/@TheLinuxExperiment |
| tutoriaLinux | System admin | https://www.youtube.com/@tutoriaLinux |
| DistroTube | Command line power | https://www.youtube.com/@DistroTube |

### 6.2 Playlisturi Specifice

| Subiect | Creator | Link Playlist |
|---------|---------|---------------|
| Bash Scripting | Learn Linux TV | Search: "Bash Scripting on Linux" |
| Linux Permissions | tutoriaLinux | Search: "Linux Permissions Explained" |
| Cron Jobs | NetworkChuck | Search: "Cron Jobs Linux" |
| find Command | LinuxHint | Search: "Linux find command tutorial" |

### 6.3 Cursuri Video Complete

| Platformă | Curs | Tip |
|-----------|------|-----|
| Udemy | Linux Shell Scripting | Plătit |
| Coursera | Unix and Bash for Beginners | Free audit |
| edX | Introduction to Linux | Free audit |
| LinkedIn Learning | Linux Command Line | Free with trial |
| Pluralsight | Linux Command Line Interface | Subscription |

---

## 7. Instrumente Online

### 7.1 Validatoare și Editori

| Instrument | URL | Utilizare |
|------------|-----|-----------|
| ShellCheck | https://www.shellcheck.net/ | Validare și linting Bash |
| ExplainShell | https://explainshell.com/ | Explică comenzi |
| chmod Calculator | https://chmod-calculator.com/ | Calculator permisiuni |
| Crontab.guru | https://crontab.guru/ | Editor cron vizual |
| Regex101 | https://regex101.com/ | Testare expresii regulate |

### 7.2 Sandboxuri și Testere

| Instrument | URL | Caracteristici |
|------------|-----|----------------|
| repl.it Bash | https://replit.com/languages/bash | Terminal complet |
| JSFiddle pentru terminal | https://www.jdoodle.com/ | Testare rapidă |
| OnlineGDB | https://www.onlinegdb.com/ | Debug integrat |

### 7.3 Diagrame și Vizualizări

| Instrument | URL | Utilizare |
|------------|-----|-----------|
| ASCIIFlow | https://asciiflow.com/ | Diagrame ASCII |
| Mermaid Live | https://mermaid.live/ | Diagrame în Markdown |
| draw.io | https://app.diagrams.net/ | Diagrame profesionale |

---

## 8. Articole Tehnice Avansate

### 8.1 find și xargs în Profunzime

| Articol | URL | Focus |
|---------|-----|-------|
| "GNU find Optimization" | GNU Manual | Optimizare căutări |
| "xargs vs find -exec" | Stack Overflow | Performanță |
| "Parallel Processing with find" | Linux Journal | -P și GNU Parallel |

### 8.2 Securitate și Permisiuni

| Articol | Sursă | Focus |
|---------|-------|-------|
| "Understanding SUID, SGID, Sticky" | Red Hat | Permisiuni speciale |
| "Linux Security Best Practices" | CIS Benchmarks | Hardening |
| "Why SUID root shell scripts are dangerous" | Stack Exchange | Securitate |
| "umask and File Security" | Cyberciti | Best practices |

### 8.3 Automatizare Avansată

| Articol | Sursă | Focus |
|---------|-------|-------|
| "Cron Job Monitoring" | healthchecks.io | Monitoring |
| "Systemd Timers vs Cron" | Arch Wiki | Alternative moderne |
| "Avoiding Cron Pitfalls" | Various | Probleme comune |
| "Lock Files in Shell Scripts" | Linux Journal | Prevenire race conditions |

---

## 9. Comunități și Forumuri

### 9.1 Q&A și Forumuri

| Comunitate | URL | Focus |
|------------|-----|-------|
| Unix & Linux Stack Exchange | https://unix.stackexchange.com/ | Q&A tehnic |
| Ask Ubuntu | https://askubuntu.com/ | Ubuntu specific |
| Server Fault | https://serverfault.com/ | Administrare |
| Reddit r/linux | https://reddit.com/r/linux | Discuții generale |
| Reddit r/bash | https://reddit.com/r/bash | Scripting Bash |
| Reddit r/linuxadmin | https://reddit.com/r/linuxadmin | Administrare |
| LinuxQuestions.org | https://www.linuxquestions.org/ | Forum clasic |

### 9.2 Chat și Instant Help

| Platformă | Canal | Link |
|-----------|-------|------|
| Discord | Linux Hub | https://discord.gg/linux |
| IRC | #bash pe Libera.Chat | irc://irc.libera.chat/#bash |
| Telegram | Linux Groups | Various |

### 9.3 Comunități Românești

| Comunitate | Platformă | Focus |
|------------|-----------|-------|
| Romanian Linux Users Group | Forum/Facebook | General |
| DevForum.ro | Forum | Development |
| ROSEdu | Various | Open Source Education |

---

## 10. Resurse pentru Securitate

### 10.1 Ghiduri de Hardening

| Resursă | URL | Descriere |
|---------|-----|-----------|
| CIS Benchmarks | https://www.cisecurity.org/cis-benchmarks | Standard industrial |
| OWASP | https://owasp.org/ | Securitate web/aplicații |
| NSA/CISA Linux Hardening | DISA STIGs | Guvernamental |
| Lynis | https://cisofy.com/lynis/ | Audit tool |

### 10.2 Vulnerabilități și CVE

| Resursă | URL | Descriere |
|---------|-----|-----------|
| CVE Details | https://www.cvedetails.com/ | Database CVE |
| NVD | https://nvd.nist.gov/ | NIST Vulnerability DB |
| Ubuntu Security Notices | https://ubuntu.com/security/notices | Ubuntu specific |

### 10.3 Practică Securitate

| Platformă | URL | Tip |
|-----------|-----|-----|
| OverTheWire | https://overthewire.org/ | Wargames |
| HackTheBox | https://www.hackthebox.eu/ | CTF/Pentest |
| TryHackMe | https://tryhackme.com/ | Learning paths |
| PicoCTF | https://picoctf.org/ | CTF pentru începători |

---

## 11. Exerciții și Provocări

### 11.1 Provocări find

```bash
# 1. Găsește toate fișierele SUID din sistem
find / -perm -4000 -type f 2>/dev/null

# 2. Găsește fișiere world-writable
find / -perm -002 -type f 2>/dev/null

# 3. Găsește fișiere fără owner valid
find / -nouser -o -nogroup 2>/dev/null

# 4. Găsește fișiere modificate în ultimele 24h
find /home -mtime -1 -type f

# 5. Găsește și comprimă log-uri vechi de 30+ zile
find /var/log -name "*.log" -mtime +30 -exec gzip {} \;
```

### 11.2 Provocări Permisiuni

```bash
# 1. Fixează permisiunile pentru un proiect web
find /var/www -type d -exec chmod 755 {} \;
find /var/www -type f -exec chmod 644 {} \;

# 2. Configurează director partajat pentru grup
mkdir /shared
chgrp developers /shared
chmod 2775 /shared

# 3. Creează director "drop box" (doar scriere)
mkdir /dropbox
chmod 733 /dropbox

# 4. Audit rapid securitate
find . -perm -777 -ls 2>/dev/null
```

### 11.3 Provocări Cron

```
# 1. Backup zilnic la 2:30 AM
30 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# 2. Cleanup săptămânal Duminică la 3 AM
0 3 * * 0 find /tmp -mtime +7 -delete

# 3. Raport lunar în prima zi la 6 AM
0 6 1 * * /usr/local/bin/monthly_report.sh

# 4. Verificare disk la fiecare 6 ore
0 */6 * * * df -h > /var/log/disk_usage.log
```

### 11.4 Mini-Proiecte

| Proiect | Dificultate | Concept Testat |
|---------|-------------|----------------|
| File organizer (by extension) | Mediu | find + scripting |
| Backup rotator | Mediu | cron + scripting |
| Permission auditor | Mediu | find -perm + report |
| Log analyzer | Dificil | find + xargs + awk |
| Directory sync | Dificil | find + rsync |

---

## 12. Resurse Specifice per Modul

### 12.1 Modul 1: find și xargs

Must-Read:
- GNU Find Manual (secțiunile 2-6)
- xargs man page (opțiunile -0, -I, -P)

Practice:
- OverTheWire Bandit (levels 1-10 folosesc find)
- HackerRank Shell challenges

Tools:
- ShellCheck pentru validare
- explainshell.com pentru înțelegere

### 12.2 Modul 2: Parametri și getopts

Must-Read:
- Bash Reference Manual, Section 3.4 (Shell Parameters)
- Advanced Bash Scripting Guide, Chapter 4 (Parameters)

Practice:
- Rescrie 3 scripturi existente să folosească getopts
- Creează un CLI tool complet cu --help

Tools:
- ShellCheck (verifică best practices)
- GNU style guides pentru CLI

### 12.3 Modul 3: Permisiuni

Must-Read:
- `man chmod`, `man chown`, `man umask`
- Linux File System Hierarchy Standard

Practice:
- OverTheWire Bandit (levels 10-20)
- Configurează un server LAMP cu permisiuni corecte

Security:
- CIS Benchmark pentru Ubuntu
- Lynis audit tool

### 12.4 Modul 4: Cron

Must-Read:
- `man 5 crontab` (formatul fișierului)
- `man 8 cron` (daemon-ul)

Practice:
- Creează 5 cron jobs pentru scenarii reale
- Implementează logging și error handling

Tools:
- crontab.guru pentru construcție
- healthchecks.io pentru monitoring

---

## Resurse Adiționale

### Quick Links Utile

```
╔══════════════════════════════════════════════════════════════════╗
║                    QUICK LINKS                                   ║
╠══════════════════════════════════════════════════════════════════╣
║ chmod calculator     → https://chmod-calculator.com/            ║
║ crontab editor       → https://crontab.guru/                    ║
║ shellcheck           → https://www.shellcheck.net/              ║
║ explainshell         → https://explainshell.com/                ║
║ regex tester         → https://regex101.com/                    ║
║ ASCII diagrams       → https://asciiflow.com/                   ║
║ Bash cheat sheet     → https://devhints.io/bash                 ║
║ Linux man pages      → https://man7.org/linux/man-pages/        ║
╚══════════════════════════════════════════════════════════════════╝
```

### Citire Recomandată (Ordine)

1. Începător: Linux Command Line (William Shotts) - gratuit
2. Intermediar: Learning the bash Shell (O'Reilly)
3. Avansat: Unix and Linux System Administration Handbook

### Certificări Relevante

| Certificare | Organizație | Focus |
|-------------|-------------|-------|
| LPIC-1 | Linux Professional Institute | Linux basics |
| RHCSA | Red Hat | System administration |
| Linux+ | CompTIA | General Linux |
| LFCS | Linux Foundation | System administration |

---

## Index de URL-uri

Pentru referință rapidă, toate URL-urile importante:

### Documentație

- https://www.gnu.org/software/findutils/manual/
- https://www.gnu.org/software/bash/manual/
- https://man7.org/linux/man-pages/


### Instrumente
- https://www.shellcheck.net/
- https://chmod-calculator.com/
- https://crontab.guru/
- https://explainshell.com/

### Practică
- https://overthewire.org/wargames/bandit/
- https://exercism.org/tracks/bash
- https://www.hackerrank.com/domains/shell

### Comunități
- https://unix.stackexchange.com/
- https://askubuntu.com/
- https://reddit.com/r/bash

---

Document generat pentru: Seminarul 03 SO, ASE București - CSIE  
Versiune: 1.0  
Ultima actualizare: Ianuarie 2025

*💡 Sugestie: Salvează această pagină în bookmarks pentru acces rapid în timpul studiului!*
