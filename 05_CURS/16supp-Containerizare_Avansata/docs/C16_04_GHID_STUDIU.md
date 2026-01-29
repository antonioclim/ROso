# Ghid Studiu — Containerizare

## Linux Namespaces
| Namespace | Izolează |
|-----------|----------|
| PID | Process IDs |
| Network | Network stack |
| Mount | Filesystem mounts |
| User | UID/GID |
| UTS | Hostname |
| IPC | IPC resources |
| Cgroup | Cgroup root |

## Cgroups v2
```bash
# Limitare memorie
echo 512M > /sys/fs/cgroup/mygroup/memory.max

# Limitare CPU (50% of 1 core)
echo "50000 100000" > /sys/fs/cgroup/mygroup/cpu.max

# Vezi utilizare
cat /sys/fs/cgroup/mygroup/memory.current
```

## Container Minimal
```bash
# Creează namespace-uri noi
unshare --mount --uts --ipc --net --pid --fork /bin/bash
```
