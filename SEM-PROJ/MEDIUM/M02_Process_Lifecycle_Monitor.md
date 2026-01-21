# M02: Process Lifecycle Monitor

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

---

## Descriere

Tool avansat pentru monitorizarea ciclului de viață al proceselor: pornire, oprire, crash-uri, resurse consumate, ierarhie procese și alerting la anomalii.

---

## Cerințe

### Obligatorii
1. **Monitorizare procese specifice** - după PID, nume sau pattern
2. **Tracking resurse** - CPU, memorie, I/O, file descriptors
3. **Ierarhie procese** - vizualizare arbore (ppid, children)
4. **Detecție evenimente** - start, stop, crash, restart
5. **Alerting** - la threshold sau evenimente
6. **Istoric** - log cu evenimente și metrici
7. **Dashboard terminal** - vizualizare în timp real

### Opționale
8. **Auto-restart** - repornire procese critice
9. **Profiling** - analiza pattern-uri de utilizare
10. **Export metrici** - Prometheus format
11. **Corelație** - grupare procese relacionate

---

## Interfață

```bash
./procmon.sh [OPȚIUNI] <pid|name|pattern>

Opțiuni:
  -w, --watch             Mod monitorizare continuă
  -i, --interval SEC      Interval refresh (default: 5)
  -t, --tree              Afișează ierarhie
  --cpu-alert N           Alertă la CPU > N%
  --mem-alert N           Alertă la MEM > N%
  --on-crash CMD          Comandă la crash
  --auto-restart          Repornire automată la crash
  -l, --log FILE          Salvare log

Exemple:
  ./procmon.sh -w nginx
  ./procmon.sh --tree --cpu-alert 80 1234
  ./procmon.sh -w --auto-restart --on-crash "notify.sh" mysql
```

---

## Criterii Specifice

| Criteriu | Pondere |
|----------|---------|
| Monitorizare corectă | 20% |
| Tracking resurse | 15% |
| Ierarhie procese | 10% |
| Detecție evenimente | 15% |
| Alerting | 10% |
| Dashboard | 10% |
| Calitate cod + teste | 15% |
| Documentație | 5% |

---

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
