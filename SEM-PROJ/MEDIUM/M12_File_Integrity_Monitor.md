# M12: File Integrity Monitor

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

## Descriere
Monitor pentru integritatea fișierelor: detecție modificări, alerting și audit trail pentru fișiere critice de sistem.

## Cerințe
1. **Baseline** - creare snapshot inițial (hash-uri)
2. **Verificare** - comparație cu baseline
3. **Alerting** - la orice modificare
4. **Monitorizare real-time** - folosind inotify
5. **Whitelist** - fișiere expected să se schimbe
6. **Raport** - ce s-a schimbat, când, cine
7. **Policy** - reguli per director

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
