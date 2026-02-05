# M15: Motor Execuție Paralelă

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Motor execuție paralelă pentru task-uri: rulare comenzi pe fișiere/host-uri multiple simultan, control concurență, agregare rezultate și gestionare erori. Similar cu GNU Parallel dar simplificat și cu funcționalități adiționale.

---

## Obiective de Învățare

- Procesare paralelă în Bash (jobs, background)
- Control concurență și rate limiting
- Agregare output și gestionare erori
- IPC (pipe-uri, named pipes, semnale)
- Gestionare procese și cleanup

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Execuție paralelă**
   - Rulare comandă pe listă input-uri
   - Control număr workeri (concurență)
   - Timeout per task

2. **Surse input**
   - Din fișier (câte unul per linie)
   - Din pipe (stdin)
   - Pattern-uri glob pentru fișiere
   - Intervale (1-100)

3. **Gestionare output**
   - Agregare stdout/stderr
   - Output ordonat sau timp real
   - Separare output per job

4. **Progres și status**
   - Bară progres
   - ETA calculat
   - Statistici finale

5. **Gestionare erori**
   - Continuare la eroare (configurabil)
   - Retry job-uri eșuate
   - Coduri ieșire agregate

### Opționale (pentru punctaj complet)

6. **Execuție remote** - SSH paralel pe host-uri multiple
7. **Cozi job-uri** - Coadă persistentă cu resume
8. **Limite resurse** - Limite CPU/memorie per job
9. **Grafuri dependențe** - Task-uri cu dependențe
10. **Dashboard web** - Status și control

---

## Interfață CLI

```bash
./pexec.sh [options] <command> [args···]

Input sources:
  -a, --arg LIST        List of arguments (comma-separated)
  -i, --input FILE      File with inputs (one per line)
  -I, --stdin           Read inputs from stdin
  -g, --glob PATTERN    Expand glob pattern
  -r, --range START-END Numeric range

Execution options:
  -j, --jobs N          Number of parallel workers (default: CPU cores)
  -t, --timeout SEC     Timeout per job
  -k, --keep-going      Continue on errors
  --retry N             Retry failed jobs
  --delay SEC           Delay between launches

Output options:
  -o, --output DIR      Directory for per-job output
  -O, --ordered         Output in input order
  -q, --quiet           Errors only
  -v, --verbose         Detailed output
  --progress            Display progress bar
  --no-color            No colours

Placeholders in command:
  {}                    Replaced with current input
  {.}                   Input without extension
  {/}                   Basename
  {//}                  Directory
  {#}                   Job number (1, 2, 3···)

Examples:
  ./pexec.sh -j 4 -a "f1.txt,f2.txt,f3.txt" gzip {}
  cat urls.txt | ./pexec.sh -I -j 10 curl -O {}
  ./pexec.sh -g "*.log" -j 8 gzip {}
  ./pexec.sh -r 1-100 -j 20 ./process.sh {}
  ./pexec.sh -i hosts.txt -j 5 ssh {} "uptime"
```

---

## Exemple Output

### Progres Execuție

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    MOTOR EXECUȚIE PARALELĂ                                   ║
║                    Job-uri: 100 | Workeri: 8                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

Comandă: gzip {}
Input: 100 fișiere din *.log

PROGRES
═══════════════════════════════════════════════════════════════════════════════
[████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░] 67% (67/100)

Rulează: 8 | Completate: 67 | Eșuate: 2 | Rămase: 25
ETA: 12 secunde | Trecut: 24 secunde

WORKERI ACTIVI
───────────────────────────────────────────────────────────────────────────────
  [1] gzip app.log.15         (3.2s)
  [2] gzip app.log.16         (2.8s)
  [3] gzip app.log.17         (2.1s)
  [4] gzip app.log.18         (1.5s)
  [5] gzip app.log.19         (1.2s)
  [6] gzip app.log.20         (0.8s)
  [7] gzip app.log.21         (0.4s)
  [8] gzip app.log.22         (0.1s)

COMPLETĂRI RECENTE
───────────────────────────────────────────────────────────────────────────────
  ✓ app.log.14 (0.5s)
  ✓ app.log.13 (0.6s)
  ✗ app.log.12 - Permission denied (0.1s)
  ✓ app.log.11 (0.4s)
```

### Rezumat Final

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EXECUȚIE COMPLETĂ                                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

REZUMAT
═══════════════════════════════════════════════════════════════════════════════
  Total job-uri:        100
  Reușite:              98 (98%)
  Eșuate:               2 (2%)
  
  Timp total:           36.2 secunde
  Medie per job:        0.36 secunde
  Factor paralelism:    8x

JOB-URI EȘUATE
───────────────────────────────────────────────────────────────────────────────
  app.log.12     Exit 1: Permission denied
  app.log.45     Exit 1: No space left on device

STATISTICI TIMING
───────────────────────────────────────────────────────────────────────────────
  Job cel mai rapid:    0.1s (app.log.3)
  Job cel mai lent:     2.8s (app.log.67)
  Medie:                0.36s
  Deviație std:         0.42s

OUTPUT
───────────────────────────────────────────────────────────────────────────────
  Stdout combinat:      /tmp/pexec_20250120/stdout.log
  Stderr combinat:      /tmp/pexec_20250120/stderr.log
  Output per job:       /tmp/pexec_20250120/jobs/

Retry eșuate: ./pexec.sh --retry-failed /tmp/pexec_20250120
```

### Execuție SSH Paralelă

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EXECUȚIE SSH PARALELĂ                                     ║
║                    Host-uri: 10 | Comandă: uptime                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

[████████████████████████████████████████████████████████████████████████] 100%

REZULTATE
═══════════════════════════════════════════════════════════════════════════════

Host                Status    Rezultat
─────────────────────────────────────────────────────────────────────────────
server01.local      ✓ OK      up 45 days, load: 0.12
server02.local      ✓ OK      up 45 days, load: 0.08
server03.local      ✓ OK      up 30 days, load: 0.45
server04.local      ✓ OK      up 30 days, load: 0.23
server05.local      ✓ OK      up 15 days, load: 1.23
server06.local      ✗ FAIL    Connection refused
server07.local      ✓ OK      up 60 days, load: 0.05
server08.local      ✓ OK      up 60 days, load: 0.18
server09.local      ✗ TIMEOUT ssh: connect timed out
server10.local      ✓ OK      up 20 days, load: 0.34

Rezumat: 8/10 reușite (80%)
```

---

## Structură Proiect

```
M15_Parallel_Execution_Engine/
├── README.md
├── Makefile
├── src/
│   ├── pexec.sh                 # Main script
│   └── lib/
│       ├── worker.sh            # Worker process
│       ├── queue.sh             # Job queue management
│       ├── input.sh             # Input sources
│       ├── output.sh            # Output aggregation
│       ├── progress.sh          # Progress display
│       └── utils.sh             # Utility functions
├── etc/
│   └── pexec.conf
├── tests/
│   ├── test_parallel.sh
│   ├── test_input.sh
│   └── slow_command.sh
└── docs/
    ├── INSTALL.md
    └── EXAMPLES.md
```

---

## Indicii de Implementare

### Coadă job-uri cu workeri

```bash
readonly MAX_JOBS="${JOBS:-$(nproc)}"
declare -a PIDS=()
declare -A JOB_STATUS

run_parallel() {
    local -a inputs=("$@")
    local total=${#inputs[@]}
    local completed=0
    local failed=0
    local job_num=0
    
    for input in "${inputs[@]}"; do
        # Wait for free slot
        while ((${#PIDS[@]} >= MAX_JOBS)); do
            wait_for_slot
        done
        
        # Launch job
        ((job_num++))
        run_job "$input" "$job_num" &
        PIDS+=($!)
        
        show_progress "$completed" "$total"
    done
    
    # Wait for all jobs
    wait_all
}

wait_for_slot() {
    local pid
    for i in "${!PIDS[@]}"; do
        pid="${PIDS[$i]}"
        if ! kill -0 "$pid" 2>/dev/null; then
            wait "$pid"
            JOB_STATUS[$pid]=$?
            unset 'PIDS[i]'
            ((completed++))
            return
        fi
    done
    
    # No free slot, wait for any
    wait -n
    # Re-check
    wait_for_slot
}

wait_all() {
    for pid in "${PIDS[@]}"; do
        wait "$pid"
        JOB_STATUS[$pid]=$?
    done
}
```

### Proces worker

```bash
run_job() {
    local input="$1"
    local job_num="$2"
    local output_dir="$OUTPUT_DIR/jobs/$job_num"
    
    mkdir -p "$output_dir"
    
    # Build command with substitutions
    local cmd="$COMMAND"
    cmd="${cmd//\{\}/$input}"
    cmd="${cmd//\{.\}/${input%.*}}"
    cmd="${cmd//\{\/\}/$(basename "$input")}"
    cmd="${cmd//\{\/\/\}/$(dirname "$input")}"
    cmd="${cmd//\{#\}/$job_num}"
    
    local start_time
    start_time=$(date +%s.%N)
    
    # Execute with timeout
    if [[ -n "$TIMEOUT" ]]; then
        timeout "$TIMEOUT" bash -c "$cmd" \
            > "$output_dir/stdout" \
            2> "$output_dir/stderr"
    else
        bash -c "$cmd" \
            > "$output_dir/stdout" \
            2> "$output_dir/stderr"
    fi
    
    local exit_code=$?
    local end_time
    end_time=$(date +%s.%N)
    
    # Save metadata
    cat > "$output_dir/meta" << EOF
input=$input
job_num=$job_num
exit_code=$exit_code
start_time=$start_time
end_time=$end_time
duration=$(echo "$end_time - $start_time" | bc)
EOF
    
    return $exit_code
}
```

### Surse input

```bash
parse_input_source() {
    local source_type="$1"
    local source_value="$2"
    
    case "$source_type" in
        arg)
            # Comma-separated list
            IFS=',' read -ra inputs <<< "$source_value"
            printf '%s\n' "${inputs[@]}"
            ;;
        file)
            # File with one input per line
            cat "$source_value"
            ;;
        stdin)
            # Read from stdin
            cat
            ;;
        glob)
            # Expand glob pattern
            compgen -G "$source_value"
            ;;
        range)
            # Numeric range (1-100)
            local start end
            IFS='-' read -r start end <<< "$source_value"
            seq "$start" "$end"
            ;;
    esac
}
```

### Bară progres

```bash
show_progress() {
    local completed="$1"
    local total="$2"
    local width=50
    
    local percent=$((completed * 100 / total))
    local filled=$((width * completed / total))
    local empty=$((width - filled))
    
    # Calculate ETA
    local elapsed=$(($(date +%s) - START_TIME))
    local eta="--:--"
    if ((completed > 0)); then
        local remaining=$((total - completed))
        local time_per_job=$((elapsed / completed))
        local eta_seconds=$((remaining * time_per_job))
        eta=$(printf '%02d:%02d' $((eta_seconds / 60)) $((eta_seconds % 60)))
    fi
    
    printf '\r['
    printf '█%.0s' $(seq 1 $filled)
    printf '░%.0s' $(seq 1 $empty)
    printf '] %3d%% (%d/%d) ETA: %s' "$percent" "$completed" "$total" "$eta"
}
```

### Paralelism stil xargs (alternativă)

```bash
run_with_xargs() {
    local jobs="$MAX_JOBS"
    local command="$COMMAND"
    
    # xargs with parallel and placeholder
    xargs -P "$jobs" -I {} bash -c "$command"
}

# Or with GNU parallel (if available)
run_with_gnu_parallel() {
    parallel -j "$MAX_JOBS" --progress "$COMMAND"
}
```

### Retry job-uri eșuate

```bash
retry_failed() {
    local run_dir="$1"
    local max_retries="${2:-3}"
    
    local failed_jobs=()
    
    for job_dir in "$run_dir/jobs/"*/; do
        local meta="$job_dir/meta"
        [[ -f "$meta" ]] || continue
        
        source "$meta"
        if ((exit_code != 0)); then
            failed_jobs+=("$input")
        fi
    done
    
    if ((${#failed_jobs[@]} == 0)); then
        echo "No failed jobs to retry"
        return 0
    fi
    
    echo "Retrying ${#failed_jobs[@]} failed jobs···"
    
    for input in "${failed_jobs[@]}"; do
        local attempts=0
        while ((attempts < max_retries)); do
            ((attempts++))
            echo "Retry $attempts/$max_retries: $input"
            
            if run_job "$input" "retry_$attempts"; then
                break
            fi
        done
    done
}
```

---

## Criterii Specifice de Evaluare

| Criteriu | Pondere | Descriere |
|-----------|--------|-------------|
| Execuție paralelă | 25% | Workeri, control concurență |
| Surse input | 15% | Fișier, stdin, glob, range |
| Gestionare output | 15% | Agregare, per-job, ordonat |
| Progres & statistici | 15% | Bară progres, ETA, rezumat |
| Gestionare erori | 15% | Continuare, retry, coduri ieșire |
| Execuție remote | 5% | SSH paralel |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, exemple |

---

## Resurse

- `man xargs` - Bazele execuție paralelă
- `man parallel` - Referință GNU Parallel
- `man wait` - Așteptare procese
- Seminar 2-3 - Job-uri background, semnale

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
