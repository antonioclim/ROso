# Specificații Teste Detaliate - Proiecte EASY (E01-E05)

## E01: File System Auditor

### Teste Automate Complete

```yaml
e01_file_system_auditor:
  metadata:
    project_id: E01
    name: "File System Auditor"
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 100
    auto_evaluable_percent: 95

  setup:
    # Creare structură test
    commands:
      - |
        mkdir -p /tmp/e01_test/{documents,images,code,empty}
        dd if=/dev/zero of=/tmp/e01_test/documents/large.pdf bs=1M count=50
        dd if=/dev/zero of=/tmp/e01_test/images/photo.jpg bs=1K count=500
        echo "small file" > /tmp/e01_test/code/script.sh
        touch /tmp/e01_test/documents/{a,b,c}.txt
        touch /tmp/e01_test/images/{1,2,3}.png
        chmod 777 /tmp/e01_test/code/script.sh
        chmod 000 /tmp/e01_test/documents/secret.txt 2>/dev/null || touch /tmp/e01_test/documents/secret.txt
        ln -s /tmp/e01_test/documents/large.pdf /tmp/e01_test/link_to_large
        # Fișiere duplicate
        echo "duplicate content" > /tmp/e01_test/documents/dup1.txt
        echo "duplicate content" > /tmp/e01_test/images/dup2.txt
        # Fișiere vechi
        touch -d "2020-01-01" /tmp/e01_test/documents/old.txt

  tests:
    # === STRUCTURAL (10 puncte) ===
    structural:
      - id: struct_01
        name: "Script principal există"
        command: "test -f src/fsaudit.sh || test -f fsaudit.sh"
        points: 3
        category: structural
        
      - id: struct_02
        name: "README.md există"
        command: "test -f README.md && wc -l < README.md | awk '$1 >= 20'"
        points: 2
        category: structural
        
      - id: struct_03
        name: "Script executabil"
        command: "test -x src/fsaudit.sh || test -x fsaudit.sh"
        points: 2
        category: structural
        
      - id: struct_04
        name: "Shebang corect"
        command: "head -1 src/fsaudit.sh 2>/dev/null || head -1 fsaudit.sh | grep -q '^#!/bin/bash'"
        points: 3
        category: structural

    # === STATIC ANALYSIS (10 puncte) ===
    static:
      - id: static_01
        name: "ShellCheck fără erori"
        command: "shellcheck -S error src/*.sh 2>/dev/null || shellcheck -S error *.sh"
        points: 5
        category: static_analysis
        partial_credit:
          warnings_allowed: 5
          deduction_per_warning: 0.5
          
      - id: static_02
        name: "Fără syntax errors"
        command: "bash -n src/fsaudit.sh 2>/dev/null || bash -n fsaudit.sh"
        points: 3
        category: static_analysis
        
      - id: static_03
        name: "Folosește set -e sau set -euo pipefail"
        command: "grep -E 'set -[euo]' src/fsaudit.sh 2>/dev/null || grep -E 'set -[euo]' fsaudit.sh"
        points: 2
        category: static_analysis

    # === FUNCȚIONAL CORE (40 puncte) ===
    functional_core:
      - id: func_01
        name: "Rulare fără argumente afișează help/usage"
        command: "./fsaudit.sh 2>&1"
        expect:
          exit_code: "!= 0"
          output_contains: ["usage", "Usage", "help", "-h", "--help"]
        points: 3
        category: functional
        
      - id: func_02
        name: "Flag --help funcționează"
        command: "./fsaudit.sh --help"
        expect:
          exit_code: 0
          output_contains: ["usage", "Usage"]
        points: 2
        category: functional
        
      - id: func_03
        name: "Analiză director - găsește fișiere"
        command: "./fsaudit.sh /tmp/e01_test"
        expect:
          exit_code: 0
          output_contains: ["documents", "images"]
        points: 5
        category: functional
        
      - id: func_04
        name: "Raportare fișiere mari"
        command: "./fsaudit.sh /tmp/e01_test --large 10M 2>/dev/null || ./fsaudit.sh /tmp/e01_test -l 10M"
        expect:
          output_contains: ["large.pdf", "50"]
          output_not_contains: ["script.sh"]
        points: 5
        category: functional
        
      - id: func_05
        name: "Top directoare după dimensiune"
        command: "./fsaudit.sh /tmp/e01_test --top 5 2>/dev/null || ./fsaudit.sh /tmp/e01_test"
        expect:
          output_contains: ["documents"]
          output_matches_regex: "[0-9]+\\s*(MB|KB|GB|M|K|G)"
        points: 5
        category: functional
        
      - id: func_06
        name: "Statistici pe extensii"
        command: "./fsaudit.sh /tmp/e01_test --stats 2>/dev/null || ./fsaudit.sh /tmp/e01_test -s"
        expect:
          output_contains: [".txt", ".png", ".pdf"]
          output_matches_regex: "\\.(txt|pdf|png).*[0-9]+"
        points: 5
        category: functional
        
      - id: func_07
        name: "Audit permisiuni - detectează 777"
        command: "./fsaudit.sh /tmp/e01_test --permissions 2>/dev/null || ./fsaudit.sh /tmp/e01_test -p"
        expect:
          output_contains: ["777", "world", "writable", "script.sh"]
        points: 5
        category: functional
        
      - id: func_08
        name: "Recursivitate implicită"
        command: "./fsaudit.sh /tmp/e01_test 2>&1 | grep -c 'documents\\|images\\|code'"
        expect:
          output_matches_regex: "[3-9]|[1-9][0-9]+"
        points: 5
        category: functional
        
      - id: func_09
        name: "Director inexistent - eroare corectă"
        command: "./fsaudit.sh /nonexistent_directory_xyz 2>&1"
        expect:
          exit_code: "!= 0"
          stderr_or_stdout_contains: ["error", "Error", "not found", "nu există", "does not exist"]
        points: 5
        category: functional

    # === FUNCȚIONAL OPȚIONAL (20 puncte) ===
    functional_optional:
      - id: opt_01
        name: "Export CSV"
        command: "./fsaudit.sh /tmp/e01_test --format csv -o /tmp/out.csv 2>/dev/null; cat /tmp/out.csv"
        expect:
          file_exists: "/tmp/out.csv"
          file_contains_pattern: ".*,.*,.*"
        points: 5
        category: optional
        
      - id: opt_02
        name: "Export JSON"
        command: "./fsaudit.sh /tmp/e01_test --format json -o /tmp/out.json 2>/dev/null; cat /tmp/out.json"
        expect:
          file_exists: "/tmp/out.json"
          file_is_valid_json: true
        points: 5
        category: optional
        
      - id: opt_03
        name: "Detectare duplicate (opțional)"
        command: "./fsaudit.sh /tmp/e01_test --duplicates 2>/dev/null || ./fsaudit.sh /tmp/e01_test -d 2>/dev/null"
        expect:
          output_contains: ["dup1.txt", "dup2.txt"]
        points: 5
        category: optional
        may_not_exist: true
        
      - id: opt_04
        name: "Fișiere vechi (opțional)"
        command: "./fsaudit.sh /tmp/e01_test --older-than 365 2>/dev/null"
        expect:
          output_contains: ["old.txt"]
        points: 5
        category: optional
        may_not_exist: true

    # === ERROR HANDLING (10 puncte) ===
    error_handling:
      - id: err_01
        name: "Argument invalid"
        command: "./fsaudit.sh --invalid-flag-xyz 2>&1"
        expect:
          exit_code: "!= 0"
        points: 3
        category: error_handling
        
      - id: err_02
        name: "Director fără permisiuni"
        setup: "mkdir -p /tmp/noaccess && chmod 000 /tmp/noaccess"
        command: "./fsaudit.sh /tmp/noaccess 2>&1"
        expect:
          exit_code: "!= 0"
          stderr_or_stdout_contains: ["permission", "denied", "access"]
        cleanup: "chmod 755 /tmp/noaccess; rm -rf /tmp/noaccess"
        points: 4
        category: error_handling
        
      - id: err_03
        name: "Fișier în loc de director"
        command: "./fsaudit.sh /tmp/e01_test/documents/large.pdf 2>&1"
        expect:
          exit_code: "!= 0"
          stderr_or_stdout_contains: ["directory", "director", "not a directory"]
        points: 3
        category: error_handling

    # === CALITATE COD (10 puncte) ===
    code_quality:
      - id: qual_01
        name: "Modularitate - cel puțin 3 funcții"
        command: "grep -c '^[a-z_]*()' src/fsaudit.sh 2>/dev/null || grep -c '^[a-z_]*()' fsaudit.sh"
        expect:
          output_matches_regex: "[3-9]|[1-9][0-9]+"
        points: 5
        category: code_quality
        
      - id: qual_02
        name: "Comentarii prezente"
        command: "grep -c '^#' src/fsaudit.sh 2>/dev/null || grep -c '^#' fsaudit.sh"
        expect:
          output_matches_regex: "[5-9]|[1-9][0-9]+"
        points: 3
        category: code_quality
        
      - id: qual_03
        name: "Nu folosește variabile nedeclarate în mod periculos"
        command: "shellcheck -S warning src/fsaudit.sh 2>&1 | grep -c 'SC2154' || echo 0"
        expect:
          output_matches_regex: "^[0-2]$"
        points: 2
        category: code_quality

  cleanup:
    - "rm -rf /tmp/e01_test /tmp/out.csv /tmp/out.json"

  # CE NU POATE FI EVALUAT AUTOMAT
  manual_evaluation_required:
    - criterion: "Claritatea output-ului"
      reason: "Subiectiv - depinde de preferințe vizuale"
      workaround: "Verificăm doar că output-ul conține informațiile necesare"
      impact: "5% din scor"
      
    - criterion: "Calitatea documentației README"
      reason: "Necesită înțelegere semantică a conținutului"
      workaround: "Verificăm doar lungimea minimă"
      impact: "2% din scor"
      
    - criterion: "Eleganța codului"
      reason: "Subiectiv"
      workaround: "Folosim metrici obiective (funcții, comentarii)"
      impact: "3% din scor"
```

---

## E02: Log Analyzer

```yaml
e02_log_analyzer:
  metadata:
    project_id: E02
    name: "Log Analyzer"
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 100
    auto_evaluable_percent: 90

  setup:
    commands:
      - |
        # Creare log syslog standard
        cat > /tmp/e02_syslog.log << 'EOF'
        Jan 20 10:15:30 server sshd[1234]: Failed password for root from 192.168.1.100
        Jan 20 10:15:31 server sshd[1234]: Accepted password for admin from 192.168.1.50
        Jan 20 10:16:00 server kernel: Out of memory: Kill process 5678
        Jan 20 10:16:30 server cron[999]: (root) CMD (/usr/local/bin/backup.sh)
        Jan 20 10:17:00 server sshd[1235]: Failed password for invalid user test
        Jan 20 10:18:00 server nginx[2000]: 192.168.1.1 - - "GET /index.html" 200
        Jan 20 10:19:00 server nginx[2000]: 192.168.1.1 - - "GET /admin" 403
        Jan 20 10:20:00 server systemd[1]: Started Daily apt upgrade
        EOF
        
        # Creare log cu levels explicit
        cat > /tmp/e02_levels.log << 'EOF'
        2025-01-20 10:00:00 [ERROR] Database connection failed
        2025-01-20 10:00:01 [INFO] Retrying connection···
        2025-01-20 10:00:02 [WARN] Connection slow
        2025-01-20 10:00:03 [ERROR] Connection timeout
        2025-01-20 10:00:04 [INFO] Fallback to secondary
        2025-01-20 10:00:05 [DEBUG] Query: SELECT * FROM users
        2025-01-20 10:00:06 [INFO] Service started successfully
        2025-01-20 10:00:07 [ERROR] Disk space low
        EOF
        
        # Log gol pentru edge case
        touch /tmp/e02_empty.log
        
        # Log mare pentru performance
        for i in $(seq 1 10000); do
          echo "Jan 20 10:00:$((i % 60)) server app[$i]: Log entry $i" >> /tmp/e02_large.log
        done

  tests:
    structural:
      - id: struct_01
        name: "Script principal există"
        command: "test -f src/loganalyzer.sh || test -f loganalyzer.sh"
        points: 3
        
      - id: struct_02
        name: "README prezent"
        command: "test -f README.md"
        points: 2

    static:
      - id: static_01
        name: "ShellCheck clean"
        command: "shellcheck -S error src/*.sh 2>/dev/null || shellcheck -S error *.sh"
        points: 5

    functional_core:
      - id: func_01
        name: "Parsare syslog - extrage câmpuri"
        command: "./loganalyzer.sh /tmp/e02_syslog.log"
        expect:
          output_contains: ["sshd", "kernel", "nginx"]
        points: 5
        
      - id: func_02
        name: "Filtrare după proces/serviciu"
        command: "./loganalyzer.sh /tmp/e02_syslog.log --service sshd 2>/dev/null || ./loganalyzer.sh /tmp/e02_syslog.log -s sshd"
        expect:
          output_contains: ["sshd", "Failed", "Accepted"]
          output_not_contains: ["nginx", "kernel"]
        points: 5
        
      - id: func_03
        name: "Filtrare după nivel (ERROR)"
        command: "./loganalyzer.sh /tmp/e02_levels.log --level ERROR 2>/dev/null || ./loganalyzer.sh /tmp/e02_levels.log -l ERROR"
        expect:
          output_contains: ["Database", "timeout", "Disk"]
          output_not_contains: ["INFO", "DEBUG", "started"]
        points: 5
        
      - id: func_04
        name: "Statistici niveluri"
        command: "./loganalyzer.sh /tmp/e02_levels.log --stats"
        expect:
          output_matches_regex: "ERROR.*3|3.*ERROR"
          output_matches_regex: "INFO.*3|3.*INFO"
        points: 5
        
      - id: func_05
        name: "Filtrare temporală --since"
        command: "./loganalyzer.sh /tmp/e02_syslog.log --since '10:17:00' 2>/dev/null"
        expect:
          output_contains: ["nginx", "systemd"]
          output_not_contains: ["kernel", "cron"]
        points: 5
        
      - id: func_06
        name: "Căutare pattern/grep"
        command: "./loganalyzer.sh /tmp/e02_syslog.log --grep 'Failed' 2>/dev/null || ./loganalyzer.sh /tmp/e02_syslog.log -g 'Failed'"
        expect:
          output_contains: ["Failed password"]
          line_count: 2
        points: 5
        
      - id: func_07
        name: "Contorizare per sursă"
        command: "./loganalyzer.sh /tmp/e02_syslog.log --count-by service 2>/dev/null || ./loganalyzer.sh /tmp/e02_syslog.log --stats"
        expect:
          output_contains: ["sshd", "nginx"]
          output_matches_regex: "[0-9]+"
        points: 5
        
      - id: func_08
        name: "Output formatat"
        command: "./loganalyzer.sh /tmp/e02_syslog.log | head -5"
        expect:
          output_is_formatted: true  # Verifică că nu e raw dump
        points: 5

    functional_optional:
      - id: opt_01
        name: "Export JSON"
        command: "./loganalyzer.sh /tmp/e02_levels.log --format json"
        expect:
          output_is_valid_json: true
        points: 5
        may_not_exist: true
        
      - id: opt_02
        name: "Top N entries"
        command: "./loganalyzer.sh /tmp/e02_large.log --top 10 2>/dev/null || ./loganalyzer.sh /tmp/e02_large.log -n 10"
        expect:
          line_count_max: 15
        points: 5

    error_handling:
      - id: err_01
        name: "Fișier inexistent"
        command: "./loganalyzer.sh /nonexistent.log 2>&1"
        expect:
          exit_code: "!= 0"
        points: 3
        
      - id: err_02
        name: "Fișier gol"
        command: "./loganalyzer.sh /tmp/e02_empty.log 2>&1"
        expect:
          exit_code: 0
          output_contains: ["empty", "no entries", "0"]
        points: 3
        
      - id: err_03
        name: "Nivel invalid"
        command: "./loganalyzer.sh /tmp/e02_levels.log --level INVALID_LEVEL 2>&1"
        expect:
          exit_code: "!= 0"
        points: 2

    performance:
      - id: perf_01
        name: "Procesare 10k linii < 5 secunde"
        command: "time -p ./loganalyzer.sh /tmp/e02_large.log --stats 2>&1"
        expect:
          execution_time_max: 5
        points: 5

  manual_evaluation_required:
    - criterion: "Formatare output human-readable"
      reason: "Subiectiv ce înseamnă 'citibil'"
      impact: "5%"
      
    - criterion: "Suport formate log non-standard"
      reason: "Prea multe variații posibile"
      impact: "5%"
```

---

## E03: Bulk File Organizer

```yaml
e03_bulk_file_organizer:
  metadata:
    project_id: E03
    name: "Bulk File Organizer"
    difficulty: EASY
    estimated_test_time: 5m
    total_points: 100
    auto_evaluable_percent: 95

  setup:
    commands:
      - |
        mkdir -p /tmp/e03_source
        # Fișiere pe extensii
        touch /tmp/e03_source/{doc1,doc2,doc3}.txt
        touch /tmp/e03_source/{photo1,photo2}.jpg
        touch /tmp/e03_source/{video1}.mp4
        touch /tmp/e03_source/{script1,script2}.sh
        touch /tmp/e03_source/noextension
        
        # Fișiere cu date diferite
        touch -d "2023-01-15" /tmp/e03_source/old_2023.txt
        touch -d "2024-06-20" /tmp/e03_source/mid_2024.txt
        touch -d "2025-01-10" /tmp/e03_source/new_2025.txt
        
        # Fișiere cu dimensiuni diferite
        dd if=/dev/zero of=/tmp/e03_source/small.bin bs=1K count=10 2>/dev/null
        dd if=/dev/zero of=/tmp/e03_source/medium.bin bs=1M count=5 2>/dev/null
        dd if=/dev/zero of=/tmp/e03_source/large.bin bs=1M count=50 2>/dev/null
        
        # Conflict test
        echo "version1" > /tmp/e03_source/conflict.txt
        mkdir -p /tmp/e03_dest/txt
        echo "version2" > /tmp/e03_dest/txt/conflict.txt

  tests:
    functional_core:
      - id: func_01
        name: "Organizare după extensie"
        setup: "rm -rf /tmp/e03_dest; mkdir /tmp/e03_dest"
        command: "./organizer.sh /tmp/e03_source /tmp/e03_dest --by extension"
        expect:
          dir_exists: ["/tmp/e03_dest/txt", "/tmp/e03_dest/jpg", "/tmp/e03_dest/mp4"]
          file_exists: "/tmp/e03_dest/txt/doc1.txt"
          file_count: {"/tmp/e03_dest/txt": 3, "/tmp/e03_dest/jpg": 2}
        points: 10
        
      - id: func_02
        name: "Organizare după dată (an)"
        setup: "rm -rf /tmp/e03_dest; mkdir /tmp/e03_dest; cp /tmp/e03_source/*.txt /tmp/e03_source_date/"
        command: "./organizer.sh /tmp/e03_source /tmp/e03_dest --by date"
        expect:
          dir_exists_pattern: "/tmp/e03_dest/202[345]"
        points: 10
        
      - id: func_03
        name: "Organizare după dimensiune"
        setup: "rm -rf /tmp/e03_dest; mkdir /tmp/e03_dest"
        command: "./organizer.sh /tmp/e03_source /tmp/e03_dest --by size"
        expect:
          dir_exists_pattern: "/tmp/e03_dest/(small|medium|large|<1MB|1-10MB|>10MB)"
        points: 10
        
      - id: func_04
        name: "Dry-run nu mută fișiere"
        setup: "rm -rf /tmp/e03_dest"
        command: "./organizer.sh /tmp/e03_source /tmp/e03_dest --by extension --dry-run"
        expect:
          file_still_exists: "/tmp/e03_source/doc1.txt"
          dir_not_exists: "/tmp/e03_dest/txt"
          output_contains: ["would", "dry", "DRY"]
        points: 10
        
      - id: func_05
        name: "Undo/Rollback funcționează"
        setup: |
          rm -rf /tmp/e03_dest; mkdir /tmp/e03_dest
          ./organizer.sh /tmp/e03_source /tmp/e03_dest --by extension
        command: "./organizer.sh --undo"
        expect:
          file_exists: "/tmp/e03_source/doc1.txt"
        points: 10
        
      - id: func_06
        name: "Gestionare conflicte (rename/skip)"
        setup: |
          rm -rf /tmp/e03_dest; mkdir -p /tmp/e03_dest/txt
          echo "existing" > /tmp/e03_dest/txt/doc1.txt
        command: "./organizer.sh /tmp/e03_source /tmp/e03_dest --by extension 2>&1"
        expect:
          # Fie redenumește (doc1_1.txt), fie sare, fie întreabă
          exit_code: 0
          one_of:
            - file_exists: "/tmp/e03_dest/txt/doc1_1.txt"
            - output_contains: ["skip", "conflict", "exists"]
        points: 10

    error_handling:
      - id: err_01
        name: "Sursă inexistentă"
        command: "./organizer.sh /nonexistent /tmp/dest --by extension 2>&1"
        expect:
          exit_code: "!= 0"
        points: 5
        
      - id: err_02
        name: "Criteriu invalid"
        command: "./organizer.sh /tmp/e03_source /tmp/dest --by invalid_criterion 2>&1"
        expect:
          exit_code: "!= 0"
        points: 5

  manual_evaluation_required:
    - criterion: "Logica de naming pentru conflicte"
      reason: "Multiple strategii valide (suffix numeric, timestamp, etc.)"
      impact: "3%"
```

---

## E04: System Health Reporter

```yaml
e04_system_health_reporter:
  metadata:
    project_id: E04
    name: "System Health Reporter"
    difficulty: EASY
    estimated_test_time: 3m
    total_points: 100
    auto_evaluable_percent: 85

  tests:
    functional_core:
      - id: func_01
        name: "Raport CPU"
        command: "./health.sh --cpu"
        expect:
          output_matches_regex: "[0-9]+\\.?[0-9]*\\s*%"
        points: 10
        
      - id: func_02
        name: "Raport memorie"
        command: "./health.sh --memory"
        expect:
          output_matches_regex: "[0-9]+\\s*(MB|GB|KB)"
          output_contains_one_of: ["used", "free", "total", "disponibil"]
        points: 10
        
      - id: func_03
        name: "Raport disc"
        command: "./health.sh --disk"
        expect:
          output_contains: ["/"]
          output_matches_regex: "[0-9]+%"
        points: 10
        
      - id: func_04
        name: "Raport complet"
        command: "./health.sh --all 2>/dev/null || ./health.sh"
        expect:
          output_contains_all: ["CPU", "Memory", "Disk"]
        points: 10
        
      - id: func_05
        name: "Culori ANSI pentru alerte"
        command: "./health.sh --all"
        expect:
          output_contains_ansi_codes: true
        points: 5
        
      - id: func_06
        name: "Monitorizare rețea"
        command: "./health.sh --network 2>/dev/null"
        expect:
          output_matches_regex: "(eth|lo|enp|wlan|inet|RX|TX)"
        points: 5
        may_not_exist: true
        
      - id: func_07
        name: "Status servicii"
        command: "./health.sh --services 2>/dev/null"
        expect:
          output_contains_one_of: ["running", "active", "stopped"]
        points: 5
        may_not_exist: true

  manual_evaluation_required:
    - criterion: "Lizibilitatea output-ului"
      reason: "Formatarea și organizarea vizuală sunt subiective"
      impact: "10%"
      
    - criterion: "Relevanța informațiilor afișate"
      reason: "Depinde de contextul de utilizare"
      impact: "5%"
```

---

## E05: Config File Manager

```yaml
e05_config_file_manager:
  metadata:
    project_id: E05
    name: "Config File Manager"  
    difficulty: EASY
    estimated_test_time: 4m
    total_points: 100
    auto_evaluable_percent: 90

  setup:
    commands:
      - |
        # Config de test
        cat > /tmp/e05_test.conf << 'EOF'
        # Server configuration
        server_name=localhost
        port=8080
        debug=true
        max_connections=100
        EOF

  tests:
    functional_core:
      - id: func_01
        name: "Backup config"
        command: "./configmgr.sh backup /tmp/e05_test.conf"
        expect:
          exit_code: 0
          backup_created_pattern: "/tmp/e05_test.conf.*backup|~/.configmgr/"
        points: 10
        
      - id: func_02
        name: "Listare versiuni"
        setup: |
          ./configmgr.sh backup /tmp/e05_test.conf
          echo "port=9090" >> /tmp/e05_test.conf
          ./configmgr.sh backup /tmp/e05_test.conf
        command: "./configmgr.sh list /tmp/e05_test.conf"
        expect:
          line_count_min: 2
          output_matches_regex: "(v|version|#)?[0-9]+"
        points: 10
        
      - id: func_03
        name: "Restaurare versiune"
        command: "./configmgr.sh restore /tmp/e05_test.conf --version 1"
        expect:
          file_contains: {"/tmp/e05_test.conf": "port=8080"}
          file_not_contains: {"/tmp/e05_test.conf": "port=9090"}
        points: 10
        
      - id: func_04
        name: "Diff între versiuni"
        command: "./configmgr.sh diff /tmp/e05_test.conf"
        expect:
          output_contains: ["8080", "9090"]
          output_contains_one_of: ["-", "+", "<", ">", "changed"]
        points: 10
        
      - id: func_05
        name: "Diff cu versiune specifică"
        command: "./configmgr.sh diff /tmp/e05_test.conf --v1 1 --v2 2 2>/dev/null || ./configmgr.sh diff /tmp/e05_test.conf 1 2"
        expect:
          output_contains: ["port"]
        points: 10

    error_handling:
      - id: err_01
        name: "Config inexistent"
        command: "./configmgr.sh backup /nonexistent.conf 2>&1"
        expect:
          exit_code: "!= 0"
        points: 5
        
      - id: err_02
        name: "Versiune inexistentă"
        command: "./configmgr.sh restore /tmp/e05_test.conf --version 999 2>&1"
        expect:
          exit_code: "!= 0"
        points: 5
```

---

## Sumar E01-E05: Ce NU Poate Fi Evaluat Automat

| Proiect | Criteriu Neevaluabil | Impact | Motiv |
|---------|---------------------|--------|-------|
| **E01** | Claritate output | 5% | Subiectiv |
| **E01** | Calitate README | 2% | Necesită înțelegere semantică |
| **E02** | Format output human-readable | 5% | Preferințe personale |
| **E02** | Suport formate log nestandardizate | 5% | Prea multe variații |
| **E03** | Strategie conflicte | 3% | Multiple abordări valide |
| **E04** | Lizibilitate output | 10% | Subiectiv |
| **E04** | Relevanță informații | 5% | Context-dependent |
| **E05** | Organizare backup storage | 5% | Opțiuni multiple valide |

**Total neevaluabil automat pentru EASY: ~5-15% per proiect**
