# M15: Parallel Execution Engine

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Motor de execuție paralelă pentru task-uri: rulare comenzi pe multiple fișiere/hosturi simultan, control concurență, agregare rezultate și gestionare erori. Similar cu GNU Parallel dar simplificat și cu features adiționale.

---

## Obiective de Învățare

- Procesare paralelă în Bash (jobs, background)
- Control concurență și rate limiting
- Agregare output și error handling
- IPC (pipes, named pipes, signals)
- Process management și cleanup

---

## Cerințe Funcționale

### Obligatorii (pentru notă de trecere)

1. **Execuție paralelă**
   - Rulare comandă pe listă de intrări
   - Control număr workers (concurență)
   - Timeout per task

2. **Input sources**
   - Din fișier (una per linie)
   - Din pipe (stdin)
   - Glob patterns pentru fișiere
   - Range-uri (1-100)

3. **Output management**
   - Agregare stdout/stderr
   - Output ordonat sau real-time
   - Separare output per job

4. **Progress și status**
   - Progress bar
   - ETA calculat
   - Statistici la final

5. **Error handling**
   - Continue on error (configurabil)
   - Retry failed jobs
   - Exit codes agregat

### Opționale (pentru punctaj complet)

6. **Remote execution** - SSH parallel pe multiple hosturi
7. **Job queues** - Persistent queue cu resume
8. **Resource limits** - CPU/memory limits per job
9. **Dependency graphs** - Task-uri cu dependențe
10. **Web dashboard** - Status și control

---

## Interfață CLI

```bash
./pexec.sh [opțiuni] <command> [args...]

Input sources:
  -a, --arg LIST        Lista de argumente (comma-separated)
  -i, --input FILE      Fișier cu intrări (una per linie)
  -I, --stdin           Citește intrări din stdin
  -g, --glob PATTERN    Expand glob pattern
  -r, --range START-END Range numeric

Execution options:
  -j, --jobs N          Număr workers paraleli (default: CPU cores)
  -t, --timeout SEC     Timeout per job
  -k, --keep-going      Continuă la erori
  --retry N             Reîncearcă jobs failed
  --delay SEC           Delay între lansări

Output options:
  -o, --output DIR      Director pentru output per job
  -O, --ordered         Output în ordinea intrărilor
  -q, --quiet           Doar erori
  -v, --verbose         Output detaliat
  --progress            Afișează progress bar
  --no-color            Fără culori

Placeholders în comandă:
  {}                    Înlocuit cu input curent
  {.}                   Input fără extensie
  {/}                   Basename
  {//}                  Directory
  {#}                   Număr job (1, 2, 3...)

Exemple:
  ./pexec.sh -j 4 -a "f1.txt,f2.txt,f3.txt" gzip {}
  cat urls.txt | ./pexec.sh -I -j 10 curl -O {}
  ./pexec.sh -g "*.log" -j 8 gzip {}
  ./pexec.sh -r 1-100 -j 20 ./process.sh {}
  ./pexec.sh -i hosts.txt -j 5 ssh {} "uptime"
```

---

## Exemple Output

### Execution Progress

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PARALLEL EXECUTION ENGINE                                 ║
║                    Jobs: 100 | Workers: 8                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Command: gzip {}
Input: 100 files from *.log

PROGRESS
═══════════════════════════════════════════════════════════════════════════════
[████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░] 67% (67/100)

Running: 8 | Completed: 67 | Failed: 2 | Remaining: 25
ETA: 12 seconds | Elapsed: 24 seconds

ACTIVE WORKERS
───────────────────────────────────────────────────────────────────────────────
  [1] gzip app.log.15         (3.2s)
  [2] gzip app.log.16         (2.8s)
  [3] gzip app.log.17         (2.1s)
  [4] gzip app.log.18         (1.5s)
  [5] gzip app.log.19         (1.2s)
  [6] gzip app.log.20         (0.8s)
  [7] gzip app.log.21         (0.4s)
  [8] gzip app.log.22         (0.1s)

RECENT COMPLETIONS
───────────────────────────────────────────────────────────────────────────────
  ✓ app.log.14 (0.5s)
  ✓ app.log.13 (0.6s)
  ✗ app.log.12 - Permission denied (0.1s)
  ✓ app.log.11 (0.4s)
```

### Final Summary

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EXECUTION COMPLETE                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total jobs:           100
  Successful:           98 (98%)
  Failed:               2 (2%)
  
  Total time:           36.2 seconds
  Average per job:      0.36 seconds
  Parallelism factor:   8x

FAILED JOBS
───────────────────────────────────────────────────────────────────────────────
  app.log.12     Exit 1: Permission denied
  app.log.45     Exit 1: No space left on device

TIMING STATISTICS
───────────────────────────────────────────────────────────────────────────────
  Fastest job:          0.1s (app.log.3)
  Slowest job:          2.8s (app.log.67)
  Average:              0.36s
  Std deviation:        0.42s

OUTPUT
───────────────────────────────────────────────────────────────────────────────
  Combined stdout:      /tmp/pexec_20250120/stdout.log
  Combined stderr:      /tmp/pexec_20250120/stderr.log
  Per-job output:       /tmp/pexec_20250120/jobs/

Retry failed: ./pexec.sh --retry-failed /tmp/pexec_20250120
```

### SSH Parallel Execution

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PARALLEL SSH EXECUTION                                    ║
║                    Hosts: 10 | Command: uptime                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

[████████████████████████████████████████████████████████████████████████] 100%

RESULTS
═══════════════════════════════════════════════════════════════════════════════

Host                Status    Result
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

Summary: 8/10 successful (80%)
```

---

## Structură Proiect

```
M15_Parallel_Execution_Engine/
├── README.md
├── Makefile
├── src/
│   ├── pexec.sh                 # Script principal
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

## Hints Implementare

### Job queue cu workers

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
        # Așteaptă slot liber
        while ((${#PIDS[@]} >= MAX_JOBS)); do
            wait_for_slot
        done
        
        # Lansează job
        ((job_num++))
        run_job "$input" "$job_num" &
        PIDS+=($!)
        
        show_progress "$completed" "$total"
    done
    
    # Așteaptă toate job-urile
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
    
    # Niciun slot liber, așteaptă oricare
    wait -n
    # Re-verifică
    wait_for_slot
}

wait_all() {
    for pid in "${PIDS[@]}"; do
        wait "$pid"
        JOB_STATUS[$pid]=$?
    done
}
```

### Worker process

```bash
run_job() {
    local input="$1"
    local job_num="$2"
    local output_dir="$OUTPUT_DIR/jobs/$job_num"
    
    mkdir -p "$output_dir"
    
    # Construiește comanda cu substituții
    local cmd="$COMMAND"
    cmd="${cmd//\{\}/$input}"
    cmd="${cmd//\{.\}/${input%.*}}"
    cmd="${cmd//\{\/\}/$(basename "$input")}"
    cmd="${cmd//\{\/\/\}/$(dirname "$input")}"
    cmd="${cmd//\{#\}/$job_num}"
    
    local start_time
    start_time=$(date +%s.%N)
    
    # Execută cu timeout
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
    
    # Salvează metadata
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

### Input sources

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

### Progress bar

```bash
show_progress() {
    local completed="$1"
    local total="$2"
    local width=50
    
    local percent=$((completed * 100 / total))
    local filled=$((width * completed / total))
    local empty=$((width - filled))
    
    # Calculează ETA
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

### xargs-style parallelism (alternativ)

```bash
run_with_xargs() {
    local jobs="$MAX_JOBS"
    local command="$COMMAND"
    
    # xargs cu parallel și placeholder
    xargs -P "$jobs" -I {} bash -c "$command"
}

# Sau cu GNU parallel (dacă e disponibil)
run_with_gnu_parallel() {
    parallel -j "$MAX_JOBS" --progress "$COMMAND"
}
```

### Retry failed jobs

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
    
    echo "Retrying ${#failed_jobs[@]} failed jobs..."
    
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

## Criterii Evaluare Specifice

| Criteriu | Pondere | Descriere |
|----------|---------|-----------|
| Execuție paralelă | 25% | Workers, concurrency control |
| Input sources | 15% | File, stdin, glob, range |
| Output management | 15% | Agregate, per-job, ordered |
| Progress & stats | 15% | Progress bar, ETA, summary |
| Error handling | 15% | Continue, retry, exit codes |
| Remote execution | 5% | SSH parallel |
| Calitate cod + teste | 5% | ShellCheck, teste |
| Documentație | 5% | README, examples |

---

## Resurse

- `man xargs` - Parallel execution basics
- `man parallel` - GNU Parallel reference
- `man wait` - Process waiting
- Seminar 2-3 - Background jobs, signals

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
