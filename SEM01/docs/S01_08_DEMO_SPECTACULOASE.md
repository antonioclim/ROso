# Demo-uri Spectaculoase - Seminarul 1-2
## Integrare BASH_MAGIC_COLLECTION pentru Impact Vizual

**Scop**: Captează atenția studenților prin demonstrații vizuale memorabile  
**Principiu**: "Wow factor" + explicație didactică = înțelegere profundă

---

## PREGĂTIRE - INSTALARE TOOLS

Rulează **ÎNAINTE** de seminar pe mașina de prezentare:

```bash

*Notă personală: Prefer scripturi Bash pentru automatizări simple și Python când logica devine complexă. E o chestiune de pragmatism.*

# Pachetele esențiale pentru demo-uri
sudo apt update && sudo apt install -y \
    figlet toilet cmatrix sl cowsay fortune lolcat \
    htop btop tree ncdu pv dialog whiptail \
    strace ltrace bc jq

# Verificare
for cmd in figlet lolcat cmatrix cowsay fortune tree pv dialog; do
    which $cmd >/dev/null && echo "✅ $cmd" || echo "❌ $cmd - LIPSEȘTE!"
done
```

---

## DEMO 1:

> **Observație**: Aceste demo-uri sunt testate pe studenți reali, nu doar pe colegi IT care "deja știu tot". Efectul "wow" e garantat dacă le prezinți cu entuziasm. Pro tip: repetă de 2-3 ori înainte de seminar, timingul contează! Hook de Deschidere
**Moment**: Primele 3 minute ale seminarului  
**Scop**: Captează atenția, stabilește tonul interactiv

> 💡 Un student m-a întrebat odată de ce nu putem folosi doar interfața grafică pentru tot — răspunsul e că terminalul e de 10 ori mai rapid pentru operații repetitive.


### Scriptul Complet:

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

#!/bin/bash
# hook_opening.sh - Rulează la începutul seminarului

clear
sleep 1

# Banner dramatic
figlet -f slant "BASH" | lolcat -a -d 5
sleep 2

# Efect matrix (scurt)
timeout 3 cmatrix -b -C green
clear

# Mesaj prietenos
cowsay -f tux "Bine ați venit la Sisteme de Operare!" | lolcat
echo ""
echo "În următoarele 100 de minute, veți descoperi magia terminalului..."
echo ""

# Teaser - arată comanda complexă
echo "La final, veți înțelege comenzi ca aceasta:"
echo ""
echo -e "\e[33m  find /var/log -name '*.log' -mtime -7 | xargs wc -l | sort -n | tail -5\e[0m"
echo ""
read -p "Apasă Enter pentru a începe aventura... "
```

### Versiune Minimală (fără instalări):

```bash
clear
echo "
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║    ██████╗  █████╗ ███████╗██╗  ██╗                          ║
║    ██╔══██╗██╔══██╗██╔════╝██║  ██║                          ║
║    ██████╔╝███████║███████╗███████║                          ║
║    ██╔══██╗██╔══██║╚════██║██╔══██║                          ║
║    ██████╔╝██║  ██║███████║██║  ██║                          ║
║    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                          ║
║                                                               ║
║           Sisteme de Operare - Seminar 1                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
"
sleep 2
```

---

## DEMO 2: Vizualizarea Ierarhiei de Fișiere
**Moment**: După explicația teoretică despre FHS  
**Scop**: modifică abstractul în concret

### Demo tree spectaculos:

```bash
# Pregătire structură demo
mkdir -p ~/demo_fhs/{bin,etc,home/{alice,bob},var/{log,cache},tmp}
touch ~/demo_fhs/etc/{passwd,hosts,bashrc}
touch ~/demo_fhs/home/alice/{.bashrc,document.txt}
touch ~/demo_fhs/var/log/{syslog,auth.log}

# Vizualizare colorată
echo "🌳 STRUCTURA SISTEMULUI DE FIȘIERE"
echo "═══════════════════════════════════"
tree -C ~/demo_fhs | lolcat

# Cleanup
rm -rf ~/demo_fhs
```

### Demo ncdu (interactiv):

```bash
# Explorare spațiu disk vizuală
echo "📊 EXPLORARE INTERACTIVĂ A SPAȚIULUI DISK"
echo "═══════════════════════════════════════════"
echo "Folosește săgețile pentru navigare, 'q' pentru ieșire"
sleep 2
ncdu /var --exclude-kernfs 2>/dev/null
```

---

## DEMO 3: Puterea Pipe-urilor (Progress Bar)
**Moment**: Când introduci conceptul de pipes  
**Scop**: Vizualizează fluxul de date

### Demo cu pv:

```bash
# Demo 1: Generare date cu progress bar
echo "📊 VIZUALIZAREA FLUXULUI DE DATE PRIN PIPE"
echo "═══════════════════════════════════════════"
echo ""
echo "Urmărește cum 10MB de date curg prin sistem..."
sleep 1
pv -petra /dev/urandom | head -c 10M > /dev/null

# Demo 2: Copiere cu vizualizare
echo ""
echo "Acum să vedem o copiere de fișier..."
dd if=/dev/zero bs=1M count=50 2>/dev/null | pv -s 50M > /tmp/test_file
rm /tmp/test_file
```

### Countdown spectaculos:

```bash
# Countdown pentru tranziții între secțiuni
echo "⏱️ COUNTDOWN VIZUAL"
for i in {5..1}; do
    clear
    figlet -c "$i" | lolcat
    sleep 1
done
clear
figlet -c "GO!" | lolcat -a -d 3
sleep 1
clear
```

---

## DEMO 4: Variabile în Acțiune
**Moment**: Când introduci variabilele  
**Scop**: Face abstractul tangibil

### Demo interactiv cu dialog:

```bash
#!/bin/bash
# var_demo_interactive.sh

# Colectează date de la utilizator
NAME=$(dialog --stdout --inputbox "Cum te cheamă?" 8 40)
AGE=$(dialog --stdout --inputbox "Câți ani ai?" 8 40)
LANG=$(dialog --stdout --menu "Limbajul preferat:" 12 40 4 \
    1 "Python" \
    2 "JavaScript" \
    3 "C/C++" \
    4 "Bash")

clear

# Afișează cu stil
echo "╔════════════════════════════════════════╗"
echo "║        VARIABILELE TALE                ║"
echo "╠════════════════════════════════════════╣"
echo "║  NAME = $NAME"
echo "║  AGE  = $AGE"
echo "║  LANG = $LANG"
echo "╚════════════════════════════════════════╝"

# Demonstrează utilizarea
echo ""
echo "Acum le folosim:"
echo "  Salut, $NAME! Ai $AGE ani și îți place limbajul $LANG."
```

### Demo export vs local:

```bash
echo "🔬 EXPERIMENT: VARIABILE LOCALE vs EXPORTATE"
echo "═══════════════════════════════════════════════"
echo ""

# Setup vizual
echo "Setăm două variabile:"
echo -e "  \e[33mLOCAL=\"sunt local\"\e[0m"
echo -e "  \e[32mexport EXPORTED=\"sunt exportat\"\e[0m"
LOCAL="sunt local"
export EXPORTED="sunt exportat"

echo ""
echo "În shell-ul CURENT:"
echo -e "  LOCAL = \e[33m$LOCAL\e[0m"
echo -e "  EXPORTED = \e[32m$EXPORTED\e[0m"

echo ""
echo "Într-un SUBSHELL (bash -c):"
bash -c 'echo -e "  LOCAL = \e[31m$LOCAL\e[0m (gol!)"'
bash -c 'echo -e "  EXPORTED = \e[32m$EXPORTED\e[0m (merge!)"'

echo ""
echo "💡 CONCLUZIE: export face variabila vizibilă în subprocese!"
```

---

## DEMO 5: Quoting Vizualizat
**Moment**: Când explici diferența între ' și "  
**Scop**: Elimină confuzia frecventă

```bash
echo "🔤 DIFERENȚA DINTRE GHILIMELE"
echo "══════════════════════════════"
echo ""

NAME="Student"
echo "Variabila: NAME=\"$NAME\""
echo ""

echo "┌─────────────────────────────────────────────────┐"
echo "│ COMANDĂ                    │ OUTPUT            │"
echo "├─────────────────────────────────────────────────┤"
echo -n "│ echo '\$NAME'              │ "
echo -e "\e[33m$(echo '$NAME')\e[0m              │"
echo -n "│ echo \"\$NAME\"              │ "
echo -e "\e[32m$(echo "$NAME")\e[0m            │"
echo -n "│ echo \$NAME                │ "
echo -e "\e[32m$(echo $NAME)\e[0m            │"
echo "└─────────────────────────────────────────────────┘"
echo ""
echo "💡 Single quotes = LITERAL, Double quotes = EXPANDEAZĂ"
```

---

## DEMO 6: Sistem Monitor (Preview Avansat)
**Moment**: Final de seminar - "ce veți putea face"  
**Scop**: Motivație pentru săptămânile următoare

```bash
#!/bin/bash
# sys_monitor_preview.sh

echo "🖥️ PREVIEW: CE VEȚI PUTEA CONSTRUI"
echo "════════════════════════════════════"
echo ""
echo "Apasă Ctrl+C pentru a opri"
sleep 2

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║           SYSTEM MONITOR - Live Demo                  ║"
    echo "╠═══════════════════════════════════════════════════════╣"
    
    # CPU
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    printf "║ 🔥 CPU:     %-43s ║\n" "$CPU%"
    
    # Memory
    MEM=$(free -h | awk '/^Mem/{print $3 "/" $2}')
    printf "║ 💾 Memory:  %-43s ║\n" "$MEM"
    
    # Disk
    DISK=$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 " used)"}')
    printf "║ 💿 Disk:    %-43s ║\n" "$DISK"
    
    # Processes
    PROCS=$(ps aux | wc -l)
    printf "║ ⚙️  Procese: %-43s ║\n" "$PROCS"
    
    # Uptime
    UP=$(uptime -p)
    printf "║ ⏰ Uptime:  %-43s ║\n" "$UP"
    
    echo "╠═══════════════════════════════════════════════════════╣"
    echo "║           $(date '+%Y-%m-%d %H:%M:%S')                          ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    
    sleep 2
done
```

---

## DEMO 7: Heartbeat Vizual (One-liner)
**Moment**: Când demonstrezi while loops  
**Scop**: Arată puterea one-liner-elor

```bash
# One-liner spectaculos
echo "💓 HEARTBEAT VIZUAL AL SISTEMULUI"
echo "Apasă Ctrl+C pentru oprire"
sleep 2

while true; do
    printf "\r💓 Load: %s | Mem: %s | Procs: %s | %s   " \
        "$(cut -d' ' -f1 /proc/loadavg)" \
        "$(free -h | awk '/^Mem/{print $3"/"$2}')" \
        "$(ps aux | wc -l)" \
        "$(date +%H:%M:%S)"
    sleep 1
done
```

---

## GHID TIMING PENTRU INSTRUCTOR

| Demo | Durată | Moment Optim | Fallback |
|------|--------|--------------|----------|
| Hook Opening | 3 min | Start absolut | Banner ASCII |
| Tree FHS | 2 min | După teorie FHS | `ls -R /` |
| Progress Bar | 2 min | După pipes | `cat file` |
| Var Interactive | 3 min | După variabile | Echo simplu |
| Quoting Viz | 2 min | După quotes | Tabel pe whiteboard |
| Sys Monitor | 2 min | Final | htop |
| Heartbeat | 1 min | Demonstrație while | - |

---

## TROUBLESHOOTING

| Problemă | Soluție Rapidă |
|----------|----------------|
| lolcat nu e instalat | `echo "text" \| sed 's/./\x1b[3$(($RANDOM%7))m&/g'` |
| dialog nu merge | Folosește `read -p` |
| cmatrix prea lung | `timeout 3 cmatrix` |
| Terminal prea mic | Ctrl+Minus pentru font mai mic |
| Culorile nu apar | `export TERM=xterm-256color` |

---

## BONUS: Fortune + Cowsay pentru Pauze

```bash
# Rulează în pauza de 10 minute
while true; do
    clear
    COW=$(ls /usr/share/cowsay/cows/ | shuf -n1)
    fortune -s | cowsay -f "$COW" | lolcat
    sleep 15
done
```

---

## ÎNREGISTRARE DEMO (pentru materiale)

Folosește `asciinema` pentru a înregistra demo-uri:

```bash
# Instalare
sudo apt install asciinema

# Înregistrare
asciinema rec demo_hook.cast

# Rulează demo-ul...

# Oprește cu Ctrl+D sau 'exit'

# Play
asciinema play demo_hook.cast

# Upload (opțional)
asciinema upload demo_hook.cast
```

---

*Demo-uri Spectaculoase | SO Seminarul 1-2 | ASE-CSIE*
