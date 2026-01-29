# Ghid Studiu — Virtualizare

## Hypervisor Types
| Type 1 (Bare-metal) | Type 2 (Hosted) |
|---------------------|-----------------|
| Direct pe hardware | Pe un OS gazdă |
| VMware ESXi, Xen | VirtualBox, VMware WS |
| Performanță mai bună | Mai ușor de instalat |

## Tehnici de Virtualizare
- **Full**: Guest nu știe că e virtualizat
- **Para**: Guest modificat pentru eficiență
- **HW-assisted**: VT-x/AMD-V, ring -1 pentru hypervisor

## Containere vs VM
| Aspect | Container | VM |
|--------|-----------|-----|
| Kernel | Shared | Separate |
| Overhead | ~MB | ~GB |
| Boot time | ms | minute |
| Izolare | Process-level | Hardware-level |

## Mecanisme Container (Linux)
- **Namespaces**: PID, Network, Mount, User, IPC, UTS
- **Cgroups**: CPU, Memory, I/O limits
