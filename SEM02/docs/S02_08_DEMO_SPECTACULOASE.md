# Demo-uri Spectaculoase - Seminarul 3-4
## Sisteme de Operare | Operatori, Redirecționare, Filtre, Bucle

**Versiune**: 1.0 | **Scop**: Wow-factor pentru engagement și memorare concepte  
**Inspirat din**: BASH_MAGIC_COLLECTION.md

---

## DEPENDENȚE ȘI INSTALARE

### Instalare Rapidă (toate tool-urile)

```bash
# Rulează ÎNAINTE de seminar pentru a pregăti demo-urile
sudo apt update && sudo apt install -y \
    figlet toilet lolcat cowsay fortune \
    pv dialog whiptail \
    htop tree ncdu \
    bc jq
```

### Verificare Disponibilitate

```bash

*Notă personală: Mulți preferă `zsh`, dar eu rămân la Bash pentru că e standardul pe servere. Consistența bate confortul.*

# Script de verificare (poate fi rulat în setup_seminar.sh)
check_tool() {
    if command -v "$1" &>/dev/null; then
        echo -e "✓ $1 \033[32mdisponibil\033[0m"
    else
        echo -e "✗ $1 \033[31mlipsă\033[0m (sudo apt install $1)"
    fi
}

echo "═══ VERIFICARE TOOL-URI DEMO ═══"
for tool in figlet toilet lolcat cowsay pv dialog htop tree bc; do
    check_tool "$tool"
done
```

### Fallback pentru Tool-uri Lipsă

Toate demo-urile includ fallback pentru situații când tool-urile nu sunt instalate. Codul verifică disponibilitatea și oferă alternative text-based.

---

## DEMO-URI PENTRU DESCHIDERE (HOOK)

### DEMO H1: Pipeline Power Showcase
**Moment**: Primele 3 minute | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_h1_pipeline_power.sh - Hook spectaculos cu puterea pipeline-urilor

clear
echo -e "\n\033[1;36m"
if command -v figlet &>/dev/null; then
    figlet -c "PIPES" | lolcat 2>/dev/null || figlet -c "PIPES"

> 💡 Experiența arată că debugging-ul e 80% citit cu atenție și 20% scris cod nou.

else
    echo "╔═══════════════════════════════════════════╗"
    echo "║           P I P E L I N E S               ║"
    echo "╚═══════════════════════════════════════════╝"
fi
echo -e "\033[0m"

sleep 1

echo -e "\033[1;33m>>> Găsesc cele mai mari 5 fișiere din /usr...\033[0m\n"
sleep 0.5

# Pipeline spectaculos cu output formatat
find /usr -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | \
    head -5 | \
    while read size path; do
        # Formatare cu culori și animație
        size_mb=$(echo "scale=2; $size / 1048576" | bc)
        printf "\033[1;32m%8.2f MB\033[0m → \033[1;37m%s\033[0m\n" "$size_mb" "$path"
        sleep 0.3
    done

echo ""
echo -e "\033[1;35m✨ Totul într-o SINGURĂ comandă cu PIPE-URI! ✨\033[0m"
echo ""
echo -e "\033[1;36mComanda: find | sort | head | while read\033[0m"
sleep 2
```

### DEMO H2: Countdown Epic
**Moment**: Alternatival la H1 | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash

*(Bash-ul are o sintaxă urâtă, recunosc. Dar rulează peste tot, și asta contează enorm în practică.)*

#!/bin/bash
# demo_h2_countdown.sh - Countdown vizual spectaculos

countdown() {
    local n=${1:-5}
    for i in $(seq $n -1 1); do
        clear
        if command -v figlet &>/dev/null; then
            figlet -f big -c "$i" | lolcat 2>/dev/null || figlet -f big -c "$i"
        else
            echo -e "\n\n\n"
            echo "         ╔═══════╗"
            echo "         ║   $i   ║"
            echo "         ╚═══════╝"
        fi
        sleep 1
    done
    
    clear
    if command -v figlet &>/dev/null; then
        figlet -c "BASH!" | lolcat 2>/dev/null || figlet -c "BASH!"
        echo ""
        figlet -f small -c "Let's code!" | lolcat 2>/dev/null || figlet -f small -c "Let's code!"
    else
        echo -e "\n\n"
        echo "╔═══════════════════════════════════════╗"
        echo "║         B A S H   M A G I C           ║"
        echo "║           Let's code!                 ║"
        echo "╚═══════════════════════════════════════╝"
    fi
    echo ""
}

countdown 5
```

### DEMO H3: System Heartbeat
**Moment**: Alternativă simplă | **Wow Factor**: ⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_h3_heartbeat.sh - Puls sistem în timp real

echo -e "\033[1;36m>>> PULSUL SISTEMULUI (Ctrl+C pentru oprire)\033[0m\n"

trap "echo -e '\n\033[1;32m✓ Demo încheiat\033[0m'; exit" INT

count=0
while [[ $count -lt 10 ]]; do
    load=$(cat /proc/loadavg | cut -d' ' -f1)
    mem=$(free -h | awk '/^Mem/{print $3"/"$2}')
    procs=$(ps aux 2>/dev/null | wc -l)
    disk=$(df -h / | awk 'NR==2{print $5}')
    
    printf "\r\033[K💓 Load: \033[1;33m%-5s\033[0m | Mem: \033[1;32m%-12s\033[0m | Procs: \033[1;35m%-4d\033[0m | Disk: \033[1;31m%s\033[0m" \
        "$load" "$mem" "$procs" "$disk"
    
    sleep 1
    ((count++))
done
echo -e "\n\n\033[1;36m>>> Asta e puterea BUCLELOR și PIPELINE-URILOR!\033[0m"
```

---

## DEMO-URI OPERATORI DE CONTROL

### DEMO C1: Vizualizare && și ||
**Concept**: Exit codes și execuție condiționată

```bash
#!/bin/bash
# demo_c1_conditionals.sh - Vizualizare operatori && și ||

demo_section() {
    echo ""
    echo -e "\033[1;33m═══ $1 ═══\033[0m"
    echo ""
}

demo_section "OPERATORUL && (AND)"
echo "Comandă: mkdir test_dir && echo 'Creat cu succes!'"
echo ""
echo -n "Execut prima dată: "
sleep 1
mkdir test_dir 2>/dev/null && echo -e "\033[1;32m✓ Creat cu succes!\033[0m" || echo -e "\033[1;31m✗ Eroare\033[0m"

sleep 1
echo -n "Execut a doua oară: "
sleep 1
mkdir test_dir 2>/dev/null && echo -e "\033[1;32m✓ Creat cu succes!\033[0m" || echo -e "\033[1;31m✗ Directorul există deja!\033[0m"

rm -rf test_dir

demo_section "OPERATORUL || (OR)"
echo "Comandă: cat /inexistent || echo 'Fișier nu există'"
echo ""
echo -n "Execut: "
sleep 1
cat /inexistent 2>/dev/null || echo -e "\033[1;33m⚠ Fișier nu există - am afișat mesajul de fallback\033[0m"

demo_section "COMBINAȚIE && ||"
echo "Pattern: cmd && echo 'OK' || echo 'FAIL'"
echo ""
echo -n "Test cu comandă reușită (ls /): "
sleep 1
ls / >/dev/null && echo -e "\033[1;32m✓ OK\033[0m" || echo -e "\033[1;31m✗ FAIL\033[0m"

echo -n "Test cu comandă eșuată (ls /xxx): "
sleep 1
ls /xxx 2>/dev/null && echo -e "\033[1;32m✓ OK\033[0m" || echo -e "\033[1;31m✗ FAIL\033[0m"

echo ""
echo -e "\033[1;36m>>> Observați cum && și || controlează FLUXUL de execuție!\033[0m"
```

### DEMO C2: Background Jobs Live
**Concept**: & și job control

```bash
#!/bin/bash
# demo_c2_background.sh - Demonstrație procese background

echo -e "\033[1;36m═══ DEMO: BACKGROUND JOBS ═══\033[0m\n"

echo "Pornesc 3 procese în background cu durate diferite..."
echo ""

# Pornire procese
(sleep 3; echo -e "\n\033[1;32m[Job 1] ✓ Terminat după 3s\033[0m") &
echo "Job 1 pornit (3 secunde): PID=$!"

(sleep 2; echo -e "\n\033[1;33m[Job 2] ✓ Terminat după 2s\033[0m") &
echo "Job 2 pornit (2 secunde): PID=$!"

(sleep 1; echo -e "\n\033[1;35m[Job 3] ✓ Terminat după 1s\033[0m") &
echo "Job 3 pornit (1 secundă): PID=$!"

echo ""
echo -e "\033[1;36mJobs active:\033[0m"
jobs -l

echo ""
echo "Aștept toate procesele să termine..."
wait

echo ""
echo -e "\033[1;32m═══ TOATE PROCESELE AU TERMINAT ═══\033[0m"
echo ""
echo -e "\033[1;36m>>> Operatorul & pornește procese în BACKGROUND!\033[0m"
echo -e "\033[1;36m>>> wait așteaptă terminarea tuturor\033[0m"
```

---

## DEMO-URI REDIRECȚIONARE

### DEMO R1: File Descriptors Vizual
**Concept**: stdin, stdout, stderr

```bash
#!/bin/bash
# demo_r1_descriptors.sh - Vizualizare file descriptors

clear
echo -e "\033[1;36m"
cat << 'ASCII'
╔══════════════════════════════════════════════════════════════╗
║               FILE DESCRIPTORS - VIZUALIZARE                 ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║     ┌─────────────┐                   ┌─────────────┐        ║
║     │   STDIN     │ ──────fd 0────▶   │             │        ║
║     │   (input)   │                   │   PROCES    │        ║
║     └─────────────┘                   │             │        ║
║                                       │  (comanda)  │        ║
║                      ◀────fd 1─────── │             │        ║

> 💡 La examenele din sesiunile trecute, această întrebare a picat în mod constant — deci merită atenție.

║     ┌─────────────┐                   │             │        ║
║     │   STDOUT    │                   └─────────────┘        ║
║     │   (output)  │                         │                ║
║     └─────────────┘                         │                ║
║                                        fd 2 │                ║
║     ┌─────────────┐                         ▼                ║
║     │   STDERR    │ ◀────────────────────────                ║
║     │   (errors)  │                                          ║
║     └─────────────┘                                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
ASCII
echo -e "\033[0m"

sleep 2

echo -e "\n\033[1;33m═══ DEMONSTRAȚIE PRACTICĂ ═══\033[0m\n"

echo "Comandă: ls /home /inexistent"
echo ""
sleep 1
echo -e "\033[1;36mOutput normal (stdout + stderr amestecat):\033[0m"
ls /home /inexistent 2>&1
echo ""

sleep 1
echo -e "\033[1;36mDoar STDOUT (stderr suprimat cu 2>/dev/null):\033[0m"
ls /home /inexistent 2>/dev/null
echo ""

sleep 1
echo -e "\033[1;36mDoar STDERR (stdout suprimat cu >/dev/null):\033[0m"
ls /home /inexistent >/dev/null
echo ""

echo -e "\033[1;32m>>> Poți CONTROLA unde merg stdout și stderr!\033[0m"
```

### DEMO R2: Progress Bar cu pv
**Concept**: Pipe și vizualizare transfer

```bash
#!/bin/bash
# demo_r2_progress.sh - Progress bar pentru operații I/O

if ! command -v pv &>/dev/null; then
    echo -e "\033[1;33m⚠ pv nu este instalat. Instalează cu: sudo apt install pv\033[0m"
    echo "Demo alternativ cu progress simulat..."
    
    echo ""
    echo -n "Procesare: ["
    for i in {1..50}; do
        echo -n "#"
        sleep 0.05
    done
    echo "] 100%"
    exit 0
fi

echo -e "\033[1;36m═══ DEMO: PROGRESS BAR CU pv ═══\033[0m\n"

echo "Generez 20MB de date și le afișez progresul..."
echo ""

pv -s 20M /dev/urandom 2>&1 | head -c 20M > /tmp/demo_progress_file

echo ""
echo -e "\033[1;32m✓ Fișier creat: $(ls -lh /tmp/demo_progress_file | awk '{print $5}')\033[0m"

rm -f /tmp/demo_progress_file

echo ""
echo -e "\033[1;36m>>> pv (pipe viewer) arată progresul în PIPELINE-uri!\033[0m"
```

---

## DEMO-URI FILTRE

### DEMO F1: Capcana uniq
**Concept**: uniq necesită sort (misconceptie critică!)

```bash
#!/bin/bash
# demo_f1_uniq_trap.sh - Demonstrația capcanei uniq

echo -e "\033[1;36m═══ DEMO: CAPCANA uniq ═══\033[0m\n"

# Creare date de test
cat > /tmp/colors.txt << 'EOF'
rosu
verde
rosu
albastru
verde
rosu
galben
albastru
EOF

echo -e "\033[1;33mDate originale:\033[0m"
cat -n /tmp/colors.txt
echo ""

sleep 1

echo -e "\033[1;31m>>> GREȘIT: uniq FĂRĂ sort\033[0m"
echo "Comandă: cat colors.txt | uniq"
echo "Rezultat:"
cat /tmp/colors.txt | uniq | while read line; do
    echo -e "  \033[1;31m$line\033[0m"
done
echo ""
echo -e "\033[1;31m⚠ OBSERVĂ: 'rosu' și 'verde' apar de mai multe ori!\033[0m"
echo -e "\033[1;31m  uniq elimină doar duplicate CONSECUTIVE!\033[0m"

sleep 2

echo ""
echo -e "\033[1;32m>>> CORECT: sort | uniq\033[0m"
echo "Comandă: cat colors.txt | sort | uniq"
echo "Rezultat:"
cat /tmp/colors.txt | sort | uniq | while read line; do
    echo -e "  \033[1;32m$line\033[0m"
done

sleep 1

echo ""
echo -e "\033[1;36m>>> BONUS: sort | uniq -c pentru frecvențe\033[0m"
echo "Rezultat:"
cat /tmp/colors.txt | sort | uniq -c | sort -rn | while read count color; do
    printf "  \033[1;35m%2d×\033[0m %s\n" "$count" "$color"
done

rm -f /tmp/colors.txt

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  MEMOREAZĂ: uniq necesită SORT pentru a funcționa!    \033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

### DEMO F2: Pipeline Incremental
**Concept**: Construire pas cu pas

```bash
#!/bin/bash
# demo_f2_pipeline_build.sh - Construire incrementală pipeline

echo -e "\033[1;36m═══ DEMO: CONSTRUIRE PIPELINE PAS CU PAS ═══\033[0m\n"

echo "OBIECTIV: Top 5 useri după număr de procese"
echo ""
sleep 1

echo -e "\033[1;33m[Pas 1] ps aux - toate procesele:\033[0m"
ps aux | head -3
echo "..."
sleep 1

echo ""
echo -e "\033[1;33m[Pas 2] | awk '{print \$1}' - extrage doar username:\033[0m"
ps aux | awk '{print $1}' | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Pas 3] | sort - sortare alfabetică:\033[0m"
ps aux | awk '{print $1}' | sort | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Pas 4] | uniq -c - numără aparițiile:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Pas 5] | sort -rn - sortare descrescătoare:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
sleep 1

echo ""
echo -e "\033[1;33m[Pas 6] | head -5 - doar primii 5:\033[0m"
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5

echo ""
echo -e "\033[1;32m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32mPIPELINE FINAL:\033[0m"
echo -e "\033[1;36mps aux | awk '{print \$1}' | sort | uniq -c | sort -rn | head -5\033[0m"
echo -e "\033[1;32m═══════════════════════════════════════════════════════\033[0m"
```

---

## DEMO-URI BUCLE

### DEMO B1: Capcana Brace Expansion
**Concept**: {1..$N} nu funcționează cu variabile!

```bash
#!/bin/bash
# demo_b1_brace_trap.sh - Capcana brace expansion cu variabile

echo -e "\033[1;36m═══ DEMO: CAPCANA BRACE EXPANSION ═══\033[0m\n"

echo -e "\033[1;32m>>> FUNCȚIONEAZĂ: Brace expansion cu valori literale\033[0m"
echo 'Comandă: for i in {1..5}; do echo $i; done'
echo "Rezultat:"
for i in {1..5}; do echo -n "$i "; done
echo ""
echo ""

sleep 2

echo -e "\033[1;31m>>> NU FUNCȚIONEAZĂ: Brace expansion cu variabile\033[0m"
echo 'N=5'
echo 'Comandă: for i in {1..$N}; do echo $i; done'
echo "Rezultat:"
N=5
for i in {1..$N}; do echo -n "$i "; done
echo ""
echo -e "\033[1;31m⚠ A afișat LITERAL '{1..5}' pentru că brace expansion\033[0m"
echo -e "\033[1;31m  se face ÎNAINTE de substituția variabilelor!\033[0m"
echo ""

sleep 2

echo -e "\033[1;32m>>> SOLUȚIA 1: Folosește seq\033[0m"
echo 'Comandă: for i in $(seq 1 $N); do echo $i; done'
echo "Rezultat:"
for i in $(seq 1 $N); do echo -n "$i "; done
echo ""
echo ""

sleep 1

echo -e "\033[1;32m>>> SOLUȚIA 2: Folosește for în stil C\033[0m"
echo 'Comandă: for ((i=1; i<=N; i++)); do echo $i; done'
echo "Rezultat:"
for ((i=1; i<=N; i++)); do echo -n "$i "; done
echo ""

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  MEMOREAZĂ: {1..\$N} → seq sau for ((...))\033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

### DEMO B2: Problema Subshell cu Pipe
**Concept**: Variabile nu persistă în pipe

```bash
#!/bin/bash
# demo_b2_subshell_trap.sh - Problema subshell cu pipe

echo -e "\033[1;36m═══ DEMO: PROBLEMA SUBSHELL CU PIPE ═══\033[0m\n"

# Creare fișier de test
echo -e "linia1\nlinia2\nlinia3" > /tmp/test_lines.txt

echo -e "\033[1;31m>>> PROBLEMA: Variabila NU se actualizează\033[0m"
echo ""

count=0
echo "ÎNAINTE: count=$count"
echo ""
echo 'Comandă: cat file | while read line; do ((count++)); done'
cat /tmp/test_lines.txt | while read line; do
    ((count++))
    echo "  În buclă: count=$count (linia: $line)"
done
echo ""
echo "DUPĂ: count=$count"
echo ""
echo -e "\033[1;31m⚠ count este tot 0! Bucla while a rulat într-un SUBSHELL!\033[0m"

sleep 2

echo ""
echo -e "\033[1;32m>>> SOLUȚIA: Redirect în loc de pipe\033[0m"
echo ""

count=0
echo "ÎNAINTE: count=$count"
echo ""
echo 'Comandă: while read line; do ((count++)); done < file'
while read line; do
    ((count++))
    echo "  În buclă: count=$count (linia: $line)"
done < /tmp/test_lines.txt
echo ""
echo "DUPĂ: count=$count"
echo ""
echo -e "\033[1;32m✓ count este 3! Redirect-ul NU creează subshell!\033[0m"

rm -f /tmp/test_lines.txt

echo ""
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m  MEMOREAZĂ: Folosește 'done < file' NU 'cat file |'   \033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════\033[0m"
```

---

## DEMO INTERACTIV FINAL

### DEMO I1: System Explorer cu Dialog
**Moment**: Demo final spectaculos | **Wow Factor**: ⭐⭐⭐⭐⭐

```bash
#!/bin/bash
# demo_i1_sys_explorer.sh - Explorator sistem interactiv

if ! command -v dialog &>/dev/null; then
    echo -e "\033[1;33m⚠ dialog nu este instalat. Instalează cu: sudo apt install dialog\033[0m"
    exit 1
fi

while true; do
    choice=$(dialog --stdout --title "🔍 SYSTEM EXPLORER" \
        --menu "Selectează informația dorită:" 18 60 10 \
        1 "📊 Info CPU" \
        2 "💾 Info Memorie" \
        3 "💿 Info Disk-uri" \
        4 "🔄 Procese active (top 10)" \
        5 "🌐 Conexiuni rețea" \
        6 "👤 Utilizatori logați" \
        7 "📈 Load Average" \
        8 "🕐 Uptime sistem" \
        9 "❌ Ieșire")
    
    [[ -z "$choice" ]] && break
    
    case $choice in
        1) dialog --title "📊 CPU Info" --msgbox "$(lscpu | head -15)" 20 70 ;;
        2) dialog --title "💾 Memorie" --msgbox "$(free -h)" 12 50 ;;
        3) dialog --title "💿 Disk-uri" --msgbox "$(df -h | head -10)" 15 70 ;;
        4) dialog --title "🔄 Top Procese" --msgbox "$(ps aux --sort=-%mem | head -11)" 18 100 ;;
        5) dialog --title "🌐 Conexiuni" --msgbox "$(ss -tuln | head -15)" 20 80 ;;
        6) dialog --title "👤 Utilizatori" --msgbox "$(who)" 12 50 ;;
        7) dialog --title "📈 Load" --msgbox "$(cat /proc/loadavg)" 8 50 ;;
        8) dialog --title "🕐 Uptime" --msgbox "$(uptime -p)" 8 50 ;;
        9) break ;;
    esac
done

clear
echo -e "\033[1;32m✓ System Explorer închis. La revedere!\033[0m"
```

---

## INDEX DEMO-URI

| Demo | Concept | Durată | Wow Factor | Moment Optim |
|------|---------|--------|------------|--------------|
| H1 | Pipeline power | 2 min | ⭐⭐⭐⭐⭐ | Deschidere seminar |
| H2 | Countdown | 1 min | ⭐⭐⭐⭐⭐ | Alternativă deschidere |
| H3 | System heartbeat | 1 min | ⭐⭐⭐⭐ | Quick hook |
| C1 | && și \|\| | 2 min | ⭐⭐⭐ | După teorie operatori |
| C2 | Background jobs | 2 min | ⭐⭐⭐⭐ | După explicat & |
| R1 | File descriptors | 2 min | ⭐⭐⭐ | Începutul redirecționare |
| R2 | Progress bar pv | 2 min | ⭐⭐⭐⭐⭐ | Wow moment redirect |
| F1 | Capcana uniq | 2 min | ⭐⭐⭐⭐ | CRITICĂ - după uniq |
| F2 | Pipeline build | 3 min | ⭐⭐⭐⭐ | Demonstrație incrementală |
| B1 | Brace trap | 2 min | ⭐⭐⭐⭐ | CRITICĂ - după for |
| B2 | Subshell pipe | 2 min | ⭐⭐⭐⭐ | CRITICĂ - după while |
| I1 | System explorer | 3 min | ⭐⭐⭐⭐⭐ | Final spectaculos |

---

*Document generat pentru Seminarul 3-4 SO | ASE București - CSIE*  
*Demo-uri spectaculoase pentru engagement și memorare concepte critice*
