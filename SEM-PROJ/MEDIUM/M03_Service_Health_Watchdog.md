# M03: Service Health Watchdog

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

## Descriere
Watchdog pentru monitorizarea serviciilor sistemului cu health checks configurabile, auto-recovery și notificări.

## Cerințe Obligatorii
1. **Health checks** - HTTP, TCP, process, custom script
2. **Configurare servicii** - fișier YAML/INI cu servicii monitorizate
3. **Auto-recovery** - restart automat servicii căzute
4. **Notificări** - email, webhook, Slack
5. **Dashboard** - status toate serviciile
6. **Escalare** - niveluri de alertare (warn → critical)
7. **Istoric** - uptime și evenimente per serviciu

## Opționale
8. **Dependency tracking** - servicii dependente
9. **Graceful restart** - cu drain connections
10. **Metrics export** - pentru Grafana/Prometheus

## Utilizare
```bash
./watchdog.sh start|stop|status|check <service>
./watchdog.sh --daemon              # Mod daemon
./watchdog.sh --config services.yml # Configurare custom
```

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
