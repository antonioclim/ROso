# Specificații Teste Detaliate - Proiecte MEDIUM (M01-M15)

## Notă Generală

Proiectele MEDIUM au complexitate mai mare și necesită:
- Sandbox cu mai multe utilitare instalate
- Timp de execuție mai lung (timeout 60-120s per test)
- Setup mai complex (servicii mock, rețea simulată)
- Teste de integrare pe lângă cele unitare

---

## M01: Incremental Backup System

```yaml
m01_incremental_backup:
  metadata:
    project_id: M01
    total_points: 100
    auto_evaluable_percent: 90
    estimated_test_time: 12m
    required_tools: [tar, gzip, bzip2, xz, sha256sum, cron]

  setup:
    commands:
      - |
        # Structură de test
        mkdir -p /tmp/m01_source/{docs,images,code}
        echo "document 1" > /tmp/m01_source/docs/file1.txt
        echo "document 2" > /tmp/m01_source/docs/file2.txt
        dd if=/dev/urandom of=/tmp/m01_source/images/photo.jpg bs=1K count=100 2>/dev/null
        echo '#!/bin/bash\necho hello' > /tmp/m01_source/code/script.sh
        mkdir -p /tmp/m01_backup
        
        # Fișiere pentru excludere
        touch /tmp/m01_source/docs/temp.tmp
        mkdir -p /tmp/m01_source/.cache
        echo "cache" > /tmp/m01_source/.cache/data

  tests:
    # === BACKUP COMPLET (20 puncte) ===
    backup_full:
      - id: full_01
        name: "Backup complet creează arhivă"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n test"
        expect:
          exit_code: 0
          file_exists_pattern: "/tmp/m01_backup/*full*.tar*"
        points: 8
        timeout: 60
        
      - id: full_02
        name: "Arhiva conține toate fișierele"
        command: "tar -tzf /tmp/m01_backup/*full*.tar.gz 2>/dev/null | wc -l"
        expect:
          output_matches_regex: "[4-9]|[1-9][0-9]+"
        points: 6
        
      - id: full_03
        name: "Checksum generat"
        command: "test -f /tmp/m01_backup/*full*.sha256 && echo exists"
        expect:
          output_contains: "exists"
        points: 6

    # === BACKUP INCREMENTAL (20 puncte) ===
    backup_incremental:
      - id: incr_01
        name: "Detectează fișiere modificate"
        setup: |
          ./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n test
          sleep 1
          echo "modified" >> /tmp/m01_source/docs/file1.txt
          touch /tmp/m01_source/docs/new_file.txt
        command: "./backup.sh incremental -s /tmp/m01_source -d /tmp/m01_backup -n test"
        expect:
          exit_code: 0
          output_contains_one_of: ["2 files", "modified", "new_file"]
        points: 10
        
      - id: incr_02
        name: "Arhiva incrementală mai mică decât full"
        command: |
          full_size=$(stat -c%s /tmp/m01_backup/*full*.tar.* 2>/dev/null | head -1)
          incr_size=$(stat -c%s /tmp/m01_backup/*incr*.tar.* 2>/dev/null | head -1)
          [ "$incr_size" -lt "$full_size" ] && echo "smaller"
        expect:
          output_contains: "smaller"
        points: 10

    # === COMPRESIE (10 puncte) ===
    compression:
      - id: comp_01
        name: "Compresie gzip"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress gzip -n gzip_test"
        expect:
          file_exists_pattern: "*.tar.gz"
        points: 3
        
      - id: comp_02
        name: "Compresie bzip2"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress bzip2 -n bz2_test"
        expect:
          file_exists_pattern: "*.tar.bz2"
        points: 3
        
      - id: comp_03
        name: "Compresie xz"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup --compress xz -n xz_test"
        expect:
          file_exists_pattern: "*.tar.xz"
        points: 4

    # === RESTAURARE (15 puncte) ===
    restore:
      - id: rest_01
        name: "Restaurare completă"
        command: |
          ./backup.sh restore $(ls /tmp/m01_backup/*full* | head -1 | xargs basename | cut -d. -f1) -o /tmp/m01_restored
        expect:
          exit_code: 0
          dir_exists: "/tmp/m01_restored"
          file_exists: "/tmp/m01_restored/docs/file1.txt"
        points: 8
        
      - id: rest_02
        name: "Restaurare selectivă"
        command: "./backup.sh restore BACKUP_ID -f docs/file1.txt -o /tmp/m01_selective"
        expect:
          file_exists: "/tmp/m01_selective/docs/file1.txt"
          file_not_exists: "/tmp/m01_selective/images/photo.jpg"
        points: 7

    # === ROTAȚIE (15 puncte) ===
    rotation:
      - id: rot_01
        name: "Păstrează N backup-uri"
        setup: |
          for i in $(seq 1 10); do
            ./backup.sh full -s /tmp/m01_source -d /tmp/m01_backup -n "rot_$i"
            sleep 1
          done
        command: "./backup.sh prune --keep-daily 3"
        expect:
          backup_count_max: 3
        points: 8
        
      - id: rot_02
        name: "Rotație păstrează cele mai noi"
        command: "ls -t /tmp/m01_backup/*full* | head -3"
        expect:
          output_contains: ["rot_10", "rot_9", "rot_8"]
        points: 7

    # === VERIFICARE INTEGRITATE (5 puncte) ===
    integrity:
      - id: int_01
        name: "Verify corect pentru arhivă validă"
        command: "./backup.sh verify $(ls /tmp/m01_backup/*full* | head -1)"
        expect:
          exit_code: 0
          output_contains_one_of: ["OK", "valid", "verified"]
        points: 3
        
      - id: int_02
        name: "Verify detectează corupție"
        setup: "truncate -s 100 /tmp/m01_backup/corrupt.tar.gz"
        command: "./backup.sh verify /tmp/m01_backup/corrupt.tar.gz 2>&1"
        expect:
          exit_code: "!= 0"
          output_contains_one_of: ["corrupt", "invalid", "failed"]
        points: 2

    # === SCHEDULING (5 puncte) ===
    scheduling:
      - id: sched_01
        name: "Generare cron job"
        command: "./backup.sh schedule on --cron '0 3 * * *' 2>&1; crontab -l"
        expect:
          output_contains: ["backup", "0 3"]
        points: 5

    # === ERROR HANDLING (5 puncte) ===
    errors:
      - id: err_01
        name: "Sursă inexistentă"
        command: "./backup.sh full -s /nonexistent -d /tmp/backup 2>&1"
        expect:
          exit_code: "!= 0"
        points: 3
        
      - id: err_02
        name: "Destinație fără permisiuni"
        setup: "mkdir -p /tmp/noaccess && chmod 000 /tmp/noaccess"
        command: "./backup.sh full -s /tmp/m01_source -d /tmp/noaccess 2>&1"
        expect:
          exit_code: "!= 0"
        points: 2

  manual_evaluation_required:
    - criterion: "Eficiența algoritmului incremental"
      reason: "Necesită analiză manuală a strategiei (timestamp vs checksum)"
      impact: "5%"
      
    - criterion: "Robustețea la întreruperi"
      reason: "Dificil de testat automat (kill în timpul backup)"
      impact: "3%"
      
    - criterion: "Calitatea logging-ului"
      reason: "Subiectiv ce nivel de detaliu e optim"
      impact: "2%"
```

---

## M02: Process Lifecycle Monitor

```yaml
m02_process_lifecycle_monitor:
  metadata:
    project_id: M02
    total_points: 100
    auto_evaluable_percent: 85
    estimated_test_time: 10m
    required_tools: [ps, top, /proc filesystem]

  tests:
    process_monitoring:
      - id: mon_01
        name: "Monitorizare după PID"
        setup: "sleep 300 & echo $!"
        command: "./procmon.sh status $SETUP_PID"
        expect:
          output_contains: ["sleep", "300"]
        points: 10
        cleanup: "kill $SETUP_PID 2>/dev/null"
        
      - id: mon_02
        name: "Monitorizare după nume"
        setup: "sleep 300 &"
        command: "./procmon.sh status sleep"
        expect:
          output_contains: "sleep"
          output_matches_regex: "PID.*[0-9]+"
        points: 10
        
      - id: mon_03
        name: "Monitorizare după pattern"
        setup: "bash -c 'exec -a my_custom_process sleep 300' &"
        command: "./procmon.sh status 'my_custom'"
        expect:
          output_contains: "my_custom"
        points: 5

    resource_tracking:
      - id: res_01
        name: "Afișare CPU usage"
        setup: "yes > /dev/null & PID=$!"
        command: "./procmon.sh status $PID"
        expect:
          output_matches_regex: "[0-9]+\\.?[0-9]*\\s*%"
        points: 10
        cleanup: "kill $PID"
        
      - id: res_02
        name: "Afișare memorie"
        setup: "python3 -c 'x=[0]*1000000; import time; time.sleep(60)' &"
        command: "./procmon.sh status $!"
        expect:
          output_matches_regex: "[0-9]+\\s*(MB|KB|M|K)"
        points: 10

    process_tree:
      - id: tree_01
        name: "Afișare arbore"
        setup: "bash -c 'sleep 300 &' &"
        command: "./procmon.sh tree $$"
        expect:
          output_contains: ["bash", "sleep"]
          output_matches_regex: "[├└│]"
        points: 15

    event_detection:
      - id: evt_01
        name: "Detectare exit proces"
        setup: "(sleep 2; exit 0) &"
        command: "./procmon.sh watch $! --duration 5 2>&1"
        expect:
          output_contains_one_of: ["exit", "terminated", "stopped"]
        points: 10
        timeout: 10
        
      - id: evt_02
        name: "Alertare CPU threshold"
        setup: "yes > /dev/null &"
        command: "./procmon.sh watch $! --cpu-alert 50 --duration 3 2>&1"
        expect:
          output_contains_one_of: ["alert", "threshold", "exceeded"]
        points: 10
        cleanup: "kill $!"

  manual_evaluation_required:
    - criterion: "Acuratețea măsurătorilor CPU"
      reason: "Variază în funcție de load sistem"
      impact: "5%"
      
    - criterion: "Calitatea dashboard-ului"
      reason: "UX subiectiv"
      impact: "10%"
```

---

## M03-M15: Template Comun

Pentru concizie, prezint pattern-ul comun și specificul fiecărui proiect:

```yaml
# Template MEDIUM
medium_project_template:
  test_categories:
    structural: 10%
    static_analysis: 10%
    functional_core: 40%
    functional_optional: 15%
    error_handling: 10%
    performance: 5%
    code_quality: 5%
    documentation: 5%

  common_tests:
    - "help_flag"
    - "version_flag"
    - "no_args_usage"
    - "shellcheck_clean"
    - "exit_codes_correct"
    - "handles_invalid_input"

# Specificități per proiect:

m03_service_health_watchdog:
  key_tests:
    - "check_systemd_service_status"
    - "check_tcp_port_open"
    - "daemon_mode_pidfile"
    - "alert_on_service_down"
    - "auto_restart_with_cooldown"
  docker_requirements:
    - "systemd sau mock servicii"
    - "porturi TCP pentru verificare"
  hard_to_automate:
    - "Calitatea alertelor email (necesită SMTP mock)"
    - "Comportament sub load real"

m04_network_security_scanner:
  key_tests:
    - "ping_sweep_localhost"
    - "port_scan_tcp_connect"
    - "port_range_parsing"
    - "parallel_scan_performance"
    - "json_html_report_generation"
    - "banner_grabbing"
  docker_requirements:
    - "Network isolation"
    - "Porturi deschise pentru test"
  hard_to_automate:
    - "Acuratețea identificării serviciilor"
    - "Corelarea cu vulnerabilități reale"
  security_note: "Rulează doar pe 127.0.0.1 în sandbox"

m05_deployment_pipeline:
  key_tests:
    - "detect_project_type_node"
    - "detect_project_type_python"
    - "atomic_deploy_symlink"
    - "rollback_to_previous"
    - "health_check_post_deploy"
  docker_requirements:
    - "Node.js, Python instalate"
    - "Structură releases/"
  hard_to_automate:
    - "Integrare cu CI/CD real"
    - "Blue-green deployment complet"

m06_resource_usage_historian:
  key_tests:
    - "collect_cpu_metrics"
    - "collect_memory_metrics"
    - "store_in_sqlite"
    - "generate_ascii_graph"
    - "generate_report"
  docker_requirements:
    - "SQLite"
    - "Grafice ASCII (sau verificare pattern)"
  hard_to_automate:
    - "Acuratețea trend prediction"
    - "Calitatea vizualizărilor"

m07_security_audit_framework:
  key_tests:
    - "audit_empty_passwords"
    - "audit_uid_zero_users"
    - "audit_world_writable_files"
    - "audit_suid_files"
    - "audit_ssh_config"
    - "report_severity_levels"
  docker_requirements:
    - "Fișiere de test cu probleme de securitate cunoscute"
  hard_to_automate:
    - "Relevanța recomandărilor"
    - "False positives în context real"

m08_disk_storage_manager:
  key_tests:
    - "analyze_disk_usage"
    - "find_large_files"
    - "cleanup_temp_files"
    - "cleanup_old_logs"
    - "detect_duplicates"
    - "threshold_alerts"
  docker_requirements:
    - "Fișiere test de dimensiuni diverse"
  hard_to_automate:
    - "Siguranța operațiilor de ștergere"
    - "Predicția spațiu (necesită date istorice)"

m09_scheduled_tasks_manager:
  key_tests:
    - "add_cron_task"
    - "add_systemd_timer"
    - "list_tasks_all_sources"
    - "remove_task"
    - "execution_history"
  docker_requirements:
    - "cron daemon"
    - "systemd (sau mock)"
  hard_to_automate:
    - "Validarea expresiilor cron complexe"
    - "Integrarea cu systemd real"

m10_process_tree_analyzer:
  key_tests:
    - "build_process_tree"
    - "detect_zombie_processes"
    - "detect_orphan_processes"
    - "aggregate_by_user"
    - "export_dot_format"
  docker_requirements:
    - "/proc filesystem"
    - "Graphviz pentru validare DOT"
  hard_to_automate:
    - "Acuratețea detecției anomaliilor în context real"

m11_memory_forensics_tool:
  key_tests:
    - "parse_meminfo"
    - "analyze_process_memory"
    - "parse_memory_maps"
    - "detect_memory_leak_pattern"
    - "snapshot_compare"
  docker_requirements:
    - "/proc/meminfo, /proc/[pid]/maps"
    - "Proces cu memory leak simulat"
  hard_to_automate:
    - "Acuratețea detecției leak-urilor reale"
    - "Diferențierea leak vs utilizare legitimă"

m12_file_integrity_monitor:
  key_tests:
    - "create_baseline"
    - "detect_modified_file"
    - "detect_new_file"
    - "detect_deleted_file"
    - "inotify_watch_mode"
    - "alert_on_change"
  docker_requirements:
    - "inotify-tools"
    - "sha256sum"
  hard_to_automate:
    - "Performance cu multe fișiere"
    - "False positives (fișiere legitime modificate)"

m13_log_aggregator:
  key_tests:
    - "tail_multiple_files"
    - "parse_syslog_format"
    - "parse_json_logs"
    - "filter_by_level"
    - "alert_on_pattern"
    - "rate_limit_alerts"
  docker_requirements:
    - "journalctl (sau mock)"
    - "Multiple log files"
  hard_to_automate:
    - "Parsare formate log non-standard"
    - "Calitatea corelărilor"

m14_environment_config_manager:
  key_tests:
    - "load_environment_with_inheritance"
    - "template_variable_substitution"
    - "encrypt_secret"
    - "decrypt_secret"
    - "diff_environments"
    - "validate_required_vars"
  docker_requirements:
    - "OpenSSL"
  hard_to_automate:
    - "Securitatea implementării criptare"
    - "Validare business logic în config"

m15_parallel_execution_engine:
  key_tests:
    - "parallel_execution_workers"
    - "respect_concurrency_limit"
    - "timeout_per_job"
    - "progress_bar_display"
    - "retry_failed_jobs"
    - "ordered_output"
  docker_requirements:
    - "Multiple CPU cores (sau simulare)"
  hard_to_automate:
    - "Corectitudinea sincronizării"
    - "Race conditions"
```

---

## Sumar M01-M15: Ce NU Poate Fi Evaluat Automat

| Proiect | Criteriu | Impact | Motiv Tehnic |
|---------|----------|--------|--------------|
| **M01** | Eficiența algoritmului incremental | 5% | Necesită analiză strategiei |
| **M01** | Robustețe la întreruperi | 3% | Dificil de simulat corect |
| **M02** | Calitatea dashboard-ului | 10% | UX subiectiv |
| **M02** | Acuratețe măsurători | 5% | Variază cu load-ul |
| **M03** | Alertare email/Slack | 5% | Necesită servicii externe |
| **M04** | Identificare servicii | 5% | Baze de date fingerprint |
| **M05** | Integrare CI/CD real | 5% | Infrastructură externă |
| **M06** | Calitate vizualizări | 8% | Estetică subiectivă |
| **M06** | Predicție trend | 5% | Necesită date istorice |
| **M07** | Relevanță recomandări | 10% | Context-dependent |
| **M08** | Siguranță ștergeri | 5% | Nu se poate testa fără risc |
| **M09** | Integrare systemd real | 5% | Necesită sistem complet |
| **M10** | Detecție anomalii reale | 5% | Context sistem de producție |
| **M11** | Detecție leak-uri reale | 10% | Necesită aplicații reale |
| **M12** | False positives | 5% | Depinde de workflow |
| **M13** | Parsare formate custom | 5% | Infinite variații |
| **M14** | Securitate criptare | 8% | Necesită audit security |
| **M15** | Race conditions | 5% | Nedeterministic |

**Total neevaluabil automat pentru MEDIUM: ~10-20% per proiect**
