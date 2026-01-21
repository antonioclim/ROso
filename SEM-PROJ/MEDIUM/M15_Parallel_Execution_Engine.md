# M15: Parallel Execution Engine

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

## Descriere
Engine pentru execuție paralelă de task-uri: job queue, worker pool, progress tracking și dependency management.

## Cerințe
1. **Job queue** - adăugare și management jobs
2. **Worker pool** - N workers configurabil
3. **Paralelism control** - limit concurrency
4. **Dependencies** - DAG de task-uri
5. **Progress** - tracking și afișare progres
6. **Retry** - la eșec, cu backoff
7. **Results** - colectare și agregare output
8. **Cancel** - oprire graceful

## Utilizare
```bash
./parallel.sh run tasks.txt --workers 4
./parallel.sh queue add "command" --after task1
./parallel.sh status
./parallel.sh cancel job_id
```

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
