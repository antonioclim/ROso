# Sisteme de Operare - Modul Suplimentar: Containerizare Avansată

> **by Revolvix** | ASE București - CSIE | Anul I, Semestrul 2 | 2025-2026  
> **Relevanță industrială**: Competență obligatorie pentru roluri DevOps/SRE/Cloud Engineer

---

## Obiectivele Modulului

1. **Diferențiezi** la nivel arhitectural virtualizarea clasică de containerizare
2. **Explici** mecanismele kernel care fundamentează izolarea containerelor
3. **Configurezi** manual namespace-uri și cgroups pentru a înțelege funcționarea Docker
4. **Construiești** un container minimal fără Docker, folosind doar primitive sistem
5. **Analizezi** componentele stivei de runtime OCI (containerd, runc)
6. **Evaluezi** compromisurile de securitate și performanță ale containerizării

---

## Context Aplicativ: De ce containerele domină infrastructura modernă?

Datele din industrie confirmă o transformare profundă: peste 90% din organizațiile cloud-native utilizează containere în producție, iar 96% dintre acestea folosesc sau evaluează Kubernetes. Cererea de specialiști depășește dramatic oferta — 93% dintre managerii de recrutare raportează dificultăți în găsirea candidaților cu competențe adecvate în containerizare și orchestrare.

Această realitate nu este accidentală. Containerele rezolvă probleme fundamentale ale livrării software: elimină divergențele între mediile de dezvoltare și producție („works on my machine"), permit scalare orizontală rapidă, și standardizează împachetarea aplicațiilor indiferent de limbajul sau framework-ul utilizat. Pentru un absolvent de informatică, înțelegerea mecanismelor subiacente — nu doar utilizarea comenzilor Docker — constituie diferențiatorul între un operator și un inginer capabil să diagnosticheze și optimizeze sisteme complexe.

---

## Conținut Modul (Suplimentar)

### 1. Anatomia Izolării: VM vs Container

Virtualizarea și containerizarea urmăresc același obiectiv — izolarea încărcăturilor de lucru — dar prin mecanisme fundamental diferite.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       VIRTUALIZARE CLASICĂ                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                        │
│  │  Aplicație A │ │  Aplicație B │ │  Aplicație C │                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Bins/Libs  │ │   Bins/Libs  │ │   Bins/Libs  │                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Guest OS   │ │   Guest OS   │ │   Guest OS   │    ← Kernel separat    │
│  │   (Ubuntu)   │ │   (CentOS)   │ │   (Debian)   │       pentru fiecare   │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘                        │
│         │                │                │                                 │
│         └────────────────┼────────────────┘                                 │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                        HYPERVISOR                                   │    │
│  │              (VMware ESXi / KVM / Hyper-V / Xen)                    │    │
│  │     Emulare hardware completă: CPU virtual, memorie, NIC, disk     │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                      HOST OS (sau bare-metal)                       │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                         HARDWARE FIZIC                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  Overhead: ~1-2 GB RAM / VM, boot time: minute                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONTAINERIZARE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                        │
│  │  Aplicație A │ │  Aplicație B │ │  Aplicație C │                        │
│  ├──────────────┤ ├──────────────┤ ├──────────────┤                        │
│  │   Bins/Libs  │ │   Bins/Libs  │ │   Bins/Libs  │    ← Doar diferențele  │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘       (overlay FS)     │
│         │                │                │                                 │
│         └────────────────┼────────────────┘                                 │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                    CONTAINER RUNTIME                                │    │
│  │                  (containerd / CRI-O / podman)                      │    │
│  │         Gestionează namespaces, cgroups, image layers               │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                      HOST OS (Linux Kernel)                         │    │
│  │   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │    │
│  │   │ Namespaces  │  │   cgroups   │  │  seccomp    │                │    │
│  │   │ (izolare)   │  │  (limite)   │  │(syscall flt)│                │    │
│  │   └─────────────┘  └─────────────┘  └─────────────┘                │    │
│  └───────────────────────┬────────────────────────────────────────────┘    │
│                          │                                                  │
│  ┌───────────────────────┴────────────────────────────────────────────┐    │
│  │                         HARDWARE FIZIC                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  Overhead: ~MB RAM / container, boot time: milisecunde                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 1.1. Comparație Detaliată

| Aspect | Mașină Virtuală | Container |
|--------|-----------------|-----------|
| **Izolare** | Completă (hardware virtualizat) | Proces (kernel partajat) |
| **Kernel** | Propriu pentru fiecare VM | Partajat cu gazda |
| **Boot time** | 30s - minute | Milisecunde |
| **Dimensiune imagine** | GB (include OS complet) | MB (doar aplicație + deps) |
| **Overhead memorie** | ~1-2 GB / VM | ~10-100 MB / container |
| **Densitate** | ~10-20 VM / server | ~100-1000 containere / server |
| **Securitate** | Izolare hardware | Izolare kernel (mai slabă) |
| **Portabilitate** | Legată de hypervisor | OCI standard universal |
| **Cazuri de utilizare** | Multi-tenancy, OS diferite | Microservicii, CI/CD |

---

### 2. Linux Namespaces — Fundamentul Izolării

Namespace-urile constituie mecanismul kernel prin care containerele obțin iluzia unui sistem propriu. Fiecare tip de namespace izolează o categorie specifică de resurse.

#### 2.1. Cele 8 Tipuri de Namespaces

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LINUX NAMESPACES                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   PID (pid)     │    │   NET (net)     │    │   MNT (mnt)     │         │
│  │                 │    │                 │    │                 │         │
│  │ Izolare arbore  │    │ Izolare stivă   │    │ Izolare punct   │         │
│  │ procese; PID 1  │    │ rețea: interf., │    │ montare; vede   │         │
│  │ în container e  │    │ rute, iptables, │    │ propriul FS     │         │
│  │ procesul init   │    │ socket-uri      │    │ root            │         │
│  │                 │    │                 │    │                 │         │
│  │ Adăugat: 2.6.24 │    │ Adăugat: 2.6.29 │    │ Adăugat: 2.4.19 │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   UTS (uts)     │    │   IPC (ipc)     │    │  USER (user)    │         │
│  │                 │    │                 │    │                 │         │
│  │ Izolare hostname│    │ Izolare IPC:    │    │ Mapare UID/GID; │         │
│  │ și domainname;  │    │ semafoare,      │    │ root în cont.   │         │
│  │ fiecare cont.   │    │ message queues, │    │ poate fi non-   │         │
│  │ are identitate  │    │ shared memory   │    │ root pe gazdă   │         │
│  │                 │    │                 │    │                 │         │
│  │ Adăugat: 2.6.19 │    │ Adăugat: 2.6.19 │    │ Adăugat: 3.8    │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                                │
│  │  CGROUP (cgroup)│    │   TIME (time)   │                                │
│  │                 │    │                 │                                │
│  │ Izolare vedere  │    │ Izolare ceas    │                                │
│  │ ierarhie cgroups│    │ sistem; cont.   │                                │
│  │ proprie; pt.    │    │ poate avea timp │                                │
│  │ containere      │    │ diferit de gazdă│                                │
│  │ nested          │    │                 │                                │
│  │ Adăugat: 4.6    │    │ Adăugat: 5.6    │                                │
│  └─────────────────┘    └─────────────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 2.2. Demonstrație Practică: Creare Namespace Manual

```bash
# Vizualizare namespaces ale procesului curent
ls -la /proc/$$/ns/

# Output exemplu:
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 cgroup -> 'cgroup:[4026531835]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 ipc -> 'ipc:[4026531839]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 mnt -> 'mnt:[4026531840]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 net -> 'net:[4026531992]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 pid -> 'pid:[4026531836]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 user -> 'user:[4026531837]'
# lrwxrwxrwx 1 root root 0 Jan 15 10:00 uts -> 'uts:[4026531838]'

# Creare proces în namespace PID nou
sudo unshare --pid --fork --mount-proc bash

# În noul shell:
ps aux
# Veți vedea doar procesul bash cu PID 1!

# Verificare diferență namespace
echo "Namespace PID în container: $(readlink /proc/$$/ns/pid)"
# Comparați cu valoarea de pe gazdă
```

#### 2.3. Crearea unui „Container" Manual

Următoarea secvență demonstrează cum să creați un mediu izolat folosind doar utilitare sistem, fără Docker:

```bash
#!/bin/bash
# mini_container.sh - Container minimal folosind unshare

set -e

# Directorul care va deveni root filesystem pentru container
ROOTFS="/tmp/mini_rootfs"

# Pregătire root filesystem minimal (folosind debootstrap sau alpine)
prepare_rootfs() {
    echo "[*] Pregătire rootfs..."
    mkdir -p "$ROOTFS"/{bin,lib,lib64,proc,sys,dev,tmp,etc}
    
    # Copiere binare esențiale
    cp /bin/bash "$ROOTFS/bin/"
    cp /bin/ls "$ROOTFS/bin/"
    cp /bin/cat "$ROOTFS/bin/"
    cp /bin/ps "$ROOTFS/bin/"
    
    # Copiere biblioteci necesare (ldd pentru a afla dependențele)
    for bin in bash ls cat ps; do
        ldd /bin/$bin 2>/dev/null | grep -o '/lib[^ ]*' | while read lib; do
            cp --parents "$lib" "$ROOTFS/" 2>/dev/null || true
        done
    done
    
    # Creare /etc/passwd minimal
    echo "root:x:0:0:root:/root:/bin/bash" > "$ROOTFS/etc/passwd"
}

# Lansare container
run_container() {
    echo "[*] Lansare container..."
    
    # unshare creează namespace-uri noi
    # --pid: PID namespace nou
    # --mount: mount namespace nou
    # --uts: UTS namespace (hostname)
    # --ipc: IPC namespace
    # --net: network namespace (dezactivat aici pentru simplitate)
    # --fork: necesar pentru PID namespace
    # --mount-proc: montează /proc în noul namespace
    
    unshare \
        --pid \
        --mount \
        --uts \
        --ipc \
        --fork \
        -- /bin/bash -c "
            # Setare hostname
            hostname container-demo
            
            # Pivot root - schimbă root filesystem
            mount --bind $ROOTFS $ROOTFS
            cd $ROOTFS
            mkdir -p old_root
            pivot_root . old_root
            
            # Montare sisteme de fișiere speciale
            mount -t proc proc /proc
            mount -t sysfs sysfs /sys
            
            # Unmount vechiul root
            umount -l /old_root
            rmdir /old_root
            
            # Lansare shell
            exec /bin/bash
        "
}

# Curățare
cleanup() {
    echo "[*] Curățare..."
    rm -rf "$ROOTFS"
}

# Main
case "${1:-run}" in
    prepare)
        prepare_rootfs
        ;;
    run)
        prepare_rootfs
        run_container
        cleanup
        ;;
    clean)
        cleanup
        ;;
    *)
        echo "Utilizare: $0 {prepare|run|clean}"
        ;;
esac
```

---

### 3. Control Groups (cgroups) — Limitare Resurse

Dacă namespace-urile oferă *izolare* (ce vede un proces), cgroups oferă *limite* (cât poate consuma).

#### 3.1. Arhitectura cgroups v2

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CGROUPS v2 HIERARCHY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              /sys/fs/cgroup (unified hierarchy)             │
│                                      │                                       │
│                    ┌─────────────────┼─────────────────┐                    │
│                    │                 │                 │                    │
│              ┌─────┴─────┐     ┌─────┴─────┐     ┌─────┴─────┐              │
│              │  system   │     │   user    │     │  docker   │              │
│              │ .slice    │     │ .slice    │     │  (dacă    │              │
│              │           │     │           │     │  există)  │              │
│              └─────┬─────┘     └─────┬─────┘     └─────┬─────┘              │
│                    │                 │                 │                    │
│              ┌─────┴─────┐     ┌─────┴─────┐     ┌─────┴─────┐              │
│              │ssh.service│     │user-1000  │     │ container │              │
│              │           │     │ .slice    │     │   abc123  │              │
│              └───────────┘     └───────────┘     └───────────┘              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           CONTROLLERE DISPONIBILE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    cpu      │  │   memory    │  │     io      │  │    pids     │        │
│  │             │  │             │  │             │  │             │        │
│  │ cpu.weight  │  │ memory.max  │  │ io.max      │  │ pids.max    │        │
│  │ cpu.max     │  │ memory.high │  │ io.weight   │  │ pids.current│        │
│  │ (quota)     │  │ memory.low  │  │ io.latency  │  │             │        │
│  │             │  │ memory.swap │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │
│  │   cpuset    │  │   rdma      │  │    hugetlb  │                         │
│  │             │  │             │  │             │                         │
│  │ cpuset.cpus │  │ rdma.max    │  │hugetlb.max  │                         │
│  │ cpuset.mems │  │ rdma.current│  │             │                         │
│  └─────────────┘  └─────────────┘  └─────────────┘                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 3.2. Operații Practice cu cgroups v2

```bash
# Verificare versiune cgroups
mount | grep cgroup
# cgroup2 on /sys/fs/cgroup type cgroup2 (rw,...)

# Listare controllere disponibile
cat /sys/fs/cgroup/cgroup.controllers
# cpu io memory pids

# Creare grup nou
sudo mkdir /sys/fs/cgroup/demo_group

# Activare controllere pentru grup
echo "+cpu +memory +pids" | sudo tee /sys/fs/cgroup/demo_group/cgroup.subtree_control

# Setare limite
# Limită memorie: 100 MB
echo "104857600" | sudo tee /sys/fs/cgroup/demo_group/memory.max

# Limită CPU: 50% dintr-un core (50000 / 100000)
echo "50000 100000" | sudo tee /sys/fs/cgroup/demo_group/cpu.max

# Limită număr procese
echo "10" | sudo tee /sys/fs/cgroup/demo_group/pids.max

# Adăugare proces în grup
echo $$ | sudo tee /sys/fs/cgroup/demo_group/cgroup.procs

# Verificare statistici
cat /sys/fs/cgroup/demo_group/memory.current
cat /sys/fs/cgroup/demo_group/cpu.stat
cat /sys/fs/cgroup/demo_group/pids.current

# Curățare (mutare procese înapoi și ștergere)
echo $$ | sudo tee /sys/fs/cgroup/cgroup.procs
sudo rmdir /sys/fs/cgroup/demo_group
```

#### 3.3. Efectul Limitelor în Practică

```bash
# Demonstrație: Proces care depășește limita de memorie

# Creare cgroup cu limită 50 MB
sudo mkdir -p /sys/fs/cgroup/memory_test
echo "52428800" | sudo tee /sys/fs/cgroup/memory_test/memory.max

# Script care alocă memorie progresiv
cat << 'EOF' > /tmp/memory_hog.py
#!/usr/bin/env python3
import time

data = []
chunk_size = 10 * 1024 * 1024  # 10 MB per iterație

print("Alocare memorie progresivă...")
try:
    while True:
        data.append('X' * chunk_size)
        print(f"Alocat: {len(data) * 10} MB")
        time.sleep(1)
except MemoryError:
    print("MemoryError: Limita cgroup atinsă!")
EOF

# Rulare în cgroup
echo $$ | sudo tee /sys/fs/cgroup/memory_test/cgroup.procs
python3 /tmp/memory_hog.py

# Observați că procesul este terminat (OOM killed) când atinge limita
```

---

### 4. Union Filesystems și Imaginile de Container

Imaginile de container sunt construite din straturi (layers), fiecare reprezentând o modificare incrementală. Acest model permite partajarea eficientă a datelor comune.

#### 4.1. Arhitectura Stratificată

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        IMAGINE DOCKER: python:3.11                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 5 (R/W): Container layer                    [WRITEABLE]        │  │
│  │ Modificări în runtime (fișiere temporare, logs)                      │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 4: pip install requests                     [READ-ONLY]        │  │
│  │ /usr/local/lib/python3.11/site-packages/requests/                    │  │
│  │ Dimensiune: ~2 MB                                                    │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 3: Python 3.11 binare                       [READ-ONLY]        │  │
│  │ /usr/local/bin/python3.11, /usr/local/lib/python3.11/                │  │
│  │ Dimensiune: ~50 MB                                                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 2: Dependențe build (gcc, make)             [READ-ONLY]        │  │
│  │ Dimensiune: ~100 MB                                                  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                   │                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ Layer 1: Debian base image                        [READ-ONLY]        │  │
│  │ /bin, /lib, /usr (sistem minimal)                                    │  │
│  │ Dimensiune: ~80 MB                                                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ════════════════════════════════════════════════════════════════════════  │
│                                                                             │
│  OVERLAY VIEW (ce vede containerul):                                       │
│  / ← uniune transparentă a tuturor straturilor                             │
│  ├── bin/      (din Layer 1)                                               │
│  ├── lib/      (din Layer 1 + 2)                                           │
│  ├── usr/      (din Layer 1 + 2 + 3)                                       │
│  │   └── local/lib/python3.11/                                             │
│  │       └── site-packages/requests/  (din Layer 4)                        │
│  └── tmp/      (scrieri în Layer 5)                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 4.2. OverlayFS în Practică

```bash
# Demonstrație OverlayFS - mecanismul folosit de Docker

# Creare structură directoare
mkdir -p /tmp/overlay_demo/{lower,upper,work,merged}

# Populare layer inferior (read-only)
echo "Fișier original din lower" > /tmp/overlay_demo/lower/original.txt
echo "Fișier care va fi modificat" > /tmp/overlay_demo/lower/modificabil.txt

# Montare overlay
sudo mount -t overlay overlay \
    -o lowerdir=/tmp/overlay_demo/lower,upperdir=/tmp/overlay_demo/upper,workdir=/tmp/overlay_demo/work \
    /tmp/overlay_demo/merged

# În merged vedem conținutul din lower
ls /tmp/overlay_demo/merged/

# Scriere în merged - apare în upper (Copy-on-Write)
echo "Conținut nou" > /tmp/overlay_demo/merged/fisier_nou.txt
echo "Modificat în upper" > /tmp/overlay_demo/merged/modificabil.txt

# Verificare: lower neschimbat, upper conține diferențele
cat /tmp/overlay_demo/lower/modificabil.txt     # "Fișier care va fi modificat"
cat /tmp/overlay_demo/upper/modificabil.txt     # "Modificat în upper"

# Ștergere în overlay creează "whiteout" în upper
rm /tmp/overlay_demo/merged/original.txt
ls -la /tmp/overlay_demo/upper/
# Veți vedea un fișier special (character device 0,0) pentru whiteout

# Demontare
sudo umount /tmp/overlay_demo/merged
```

---

### 5. Stiva de Runtime OCI

Open Container Initiative (OCI) standardizează formatul imaginilor și comportamentul runtime-urilor. Docker, podman și Kubernetes folosesc aceeași specificație.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         STIVA RUNTIME CONTAINERE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      INTERFAȚĂ UTILIZATOR                            │   │
│  │                                                                      │   │
│  │  ┌────────────┐   ┌────────────┐   ┌────────────┐                   │   │
│  │  │   docker   │   │   podman   │   │  nerdctl   │                   │   │
│  │  │    CLI     │   │    CLI     │   │    CLI     │                   │   │
│  │  └─────┬──────┘   └─────┬──────┘   └─────┬──────┘                   │   │
│  └────────┼────────────────┼────────────────┼──────────────────────────┘   │
│           │                │                │                               │
│           │                │                │                               │
│  ┌────────┼────────────────┼────────────────┼──────────────────────────┐   │
│  │        │       HIGH-LEVEL RUNTIME        │                          │   │
│  │        │                │                │                          │   │
│  │  ┌─────▼──────┐   ┌─────▼──────┐   ┌─────▼──────┐                   │   │
│  │  │  dockerd   │   │ (podman e  │   │ containerd │                   │   │
│  │  │  (daemon)  │   │  daemonless│   │   (CRI)    │                   │   │
│  │  └─────┬──────┘   │  - direct) │   └─────┬──────┘                   │   │
│  │        │          └────────────┘         │                          │   │
│  │        │                                 │                          │   │
│  │  ┌─────▼─────────────────────────────────▼──────┐                   │   │
│  │  │                 containerd                    │                   │   │
│  │  │     (container lifecycle management)          │                   │   │
│  │  │  • Image pull/push                           │                   │   │
│  │  │  • Container create/start/stop               │                   │   │
│  │  │  • Snapshot management                       │                   │   │
│  │  └───────────────────────┬──────────────────────┘                   │   │
│  └──────────────────────────┼──────────────────────────────────────────┘   │
│                             │                                               │
│  ┌──────────────────────────┼──────────────────────────────────────────┐   │
│  │                     LOW-LEVEL RUNTIME (OCI)                          │   │
│  │                          │                                           │   │
│  │  ┌───────────────────────▼───────────────────────┐                   │   │
│  │  │                      runc                      │                   │   │
│  │  │        (OCI reference implementation)          │                   │   │
│  │  │  • Parsează OCI runtime spec (config.json)    │                   │   │
│  │  │  • Creează namespaces, cgroups                │                   │   │
│  │  │  • Execută procesul containerului             │                   │   │
│  │  │  • Se termină după lansare (nu daemon)        │                   │   │
│  │  └───────────────────────┬───────────────────────┘                   │   │
│  │                          │                                           │   │
│  │  Alternative: crun (mai rapid), kata (VM-backed), gVisor (sandbox)  │   │
│  └──────────────────────────┼──────────────────────────────────────────┘   │
│                             │                                               │
│  ┌──────────────────────────▼──────────────────────────────────────────┐   │
│  │                       LINUX KERNEL                                    │   │
│  │                                                                       │   │
│  │   namespaces    cgroups    seccomp    capabilities    OverlayFS     │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 5.1. Investigarea Structurii Docker

```bash
# Locația imaginilor Docker
sudo ls /var/lib/docker/

# Structura:
# ├── containers/     # Metadate containere
# ├── image/          # Metadate imagini
# ├── overlay2/       # Straturi filesystem
# ├── network/        # Configurații rețea
# └── volumes/        # Volume persistente

# Inspectare straturi unei imagini
docker image inspect python:3.11-slim | jq '.[0].RootFS.Layers'

# Vedere containerd în acțiune
sudo ctr images list
sudo ctr containers list

# Inspectare config.json OCI (runtime spec)
# Pentru un container rulând:
docker inspect <container_id> | jq '.[0].HostConfig'
```

---

### 6. Securitate în Containerizare

Containerele partajează kernel-ul gazdei, ceea ce introduce considerații specifice de securitate.

#### 6.1. Vectori de Atac și Mitigări

| Vector | Risc | Mitigare |
|--------|------|----------|
| Kernel exploits | Container escape | Kernel actualizat, gVisor/kata |
| Privileged containers | Acces complet la gazdă | Evitare `--privileged` |
| Root în container | Escaladare | User namespaces, rootless |
| Imagini malițioase | Supply chain attack | Image scanning, semnare |
| Capabilities excesive | Escaladare privilegii | Drop capabilities |
| Syscalls periculoase | Kernel exploitation | Seccomp profiles |

#### 6.2. Best Practices

```bash
# Rulare ca non-root
docker run --user 1000:1000 nginx

# Filesystem read-only
docker run --read-only nginx

# Fără capabilities suplimentare
docker run --cap-drop=ALL nginx

# Seccomp profile restrictiv
docker run --security-opt seccomp=/path/to/profile.json nginx

# Limitare resurse
docker run --memory=256m --cpus=0.5 nginx

# Network isolation
docker run --network=none alpine
```

---

## Laborator/Seminar — Exerciții Practice

### Exercițiul 1: Explorare Namespace-uri

```bash
# Rulați un container
docker run -d --name test nginx

# Identificați PID-ul pe gazdă
docker inspect test --format '{{.State.Pid}}'

# Comparați namespace-urile
ls -la /proc/1/ns/          # init (PID 1 gazdă)
ls -la /proc/<pid>/ns/      # containerul nginx

# Intrați în namespace-urile containerului
sudo nsenter --target <pid> --mount --uts --ipc --net --pid bash
# Acum sunteți "în" container dar fără Docker CLI
```

### Exercițiul 2: Limite cgroups prin Docker

```bash
# Container cu limite
docker run -d --name limited --memory=100m --cpus=0.5 stress --vm 1 --vm-bytes 200M

# Observați OOM kill
docker logs limited
docker inspect limited --format '{{.State.OOMKilled}}'

# Verificați cgroup-ul creat
cat /sys/fs/cgroup/system.slice/docker-<container_id>.scope/memory.max
```

### Exercițiul 3: Construire Container de la Zero

Folosind scriptul din secțiunea 2.3, creați și rulați un container minimal fără Docker.

---

## Recapitulare Vizuală

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CONTAINERIZARE — SINTEZĂ                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  NAMESPACE                  CGROUPS                 OVERLAY FS              │
│  ──────────                 ───────                 ──────────              │
│  Ce vede procesul           Cât consumă             Cum arată FS            │
│                                                                             │
│  • pid    → arbore procese  • cpu → timp CPU        • Layers RO             │
│  • net    → stivă rețea     • memory → RAM          • Layer RW (CoW)        │
│  • mnt    → mount points    • io → bandă I/O        • Whiteouts             │
│  • uts    → hostname        • pids → nr procese                             │
│  • ipc    → semafoare                                                       │
│  • user   → UID mapping                                                     │
│                                                                             │
│  RUNTIME STACK              SECURITATE                                      │
│  ─────────────              ──────────                                      │
│  CLI (docker/podman)        • Capabilities drop                             │
│       ↓                     • Seccomp filtering                             │
│  containerd                 • User namespaces                               │
│       ↓                     • Read-only rootfs                              │
│  runc (OCI)                 • Resource limits                               │
│       ↓                                                                     │
│  Linux kernel                                                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Lecturi recomandate:                                                       │
│  • "Container Security" - Liz Rice (O'Reilly)                              │
│  • Linux man pages: namespaces(7), cgroups(7), capabilities(7)             │
│  • OCI Runtime Spec: github.com/opencontainers/runtime-spec                │
│  • Docker documentation: docs.docker.com/get-started/overview/             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Scripturi Incluse

| Fișier | Limbaj | Descriere |
|--------|--------|-----------|
| `scripts/mini_container.sh` | Bash | Container minimal fără Docker |
| `scripts/namespace_demo.py` | Python | Explorare namespace-uri programatic |
| `scripts/cgroup_monitor.py` | Python | Monitorizare limite cgroups în timp real |
| `scripts/layer_inspector.sh` | Bash | Inspectare straturi imagine Docker |


---

## Auto-evaluare

### Întrebări de verificare

1. **[REMEMBER]** Ce sunt namespace-urile Linux? Enumeră cel puțin 5 tipuri și ce izolează fiecare.
2. **[UNDERSTAND]** Explică cum funcționează cgroups. Cum limitezi memoria RAM disponibilă unui container?
3. **[ANALYSE]** Compară Docker cu LXC/LXD. Care oferă izolare mai bună? Care este mai ușor de folosit?

### Mini-provocare (opțional)

Creează un container Docker cu limită de memorie de 100MB și verifică cu `docker stats` că limita este respectată.

---


---


---

## Lectură Recomandată

### Resurse Obligatorii

**Documentație oficială Linux**
- [Kernel Docs - cgroups v2](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html) — Referința autoritară pentru cgroups
- [Kernel Docs - namespaces](https://www.kernel.org/doc/html/latest/admin-guide/namespaces/index.html)

**Docker Documentation**
- [Docker Overview](https://docs.docker.com/get-started/overview/) — Arhitectura Docker
- [Storage Drivers](https://docs.docker.com/storage/storagedriver/) — Cum funcționează overlay2

### Resurse Recomandate

**Linux man pages**
```bash
man 7 namespaces    # Toate tipurile de namespaces
man 7 cgroups       # Control groups overview
man 7 pid_namespaces
man 7 network_namespaces
man 2 unshare       # Syscall pentru creare namespaces
man 2 clone         # Syscall cu flag-uri CLONE_NEW*
```

**LWN.net - Namespaces Series**
- [Namespaces in operation, Part 1](https://lwn.net/Articles/531114/)
- Seria completă de 7 articole despre implementarea namespaces

### Resurse Video

- **Liz Rice - Containers From Scratch** (YouTube, ~30min)
  - Demonstrație live de creare container cu Go folosind namespaces/cgroups
  
- **Jérôme Petazzoni - Cgroups, namespaces, and beyond** (DockerCon)

### Proiecte pentru Studiu

- [Bocker](https://github.com/p8952/bocker) — Docker în 100 linii de Bash
- [containers-from-scratch](https://github.com/lizrice/containers-from-scratch) — Cod sursă de la talk-ul Liz Rice

### Specificații Standard

- [OCI Runtime Specification](https://github.com/opencontainers/runtime-spec) — Standardul pentru containere
- [OCI Image Specification](https://github.com/opencontainers/image-spec) — Format imagini container


---

## Nuanțe și Cazuri Speciale

### Ce NU am acoperit (limitări didactice)

- **User namespaces**: Mapare UID-uri pentru a rula containere ca non-root pe host.
- **Rootless containers**: Podman, containere fără privilegii root.
- **gVisor și Kata Containers**: Izolare mai puternică prin kernel separat (sandbox).

### Greșeli frecvente de evitat

1. **Docker socket mounted în container**: Permite escape din container (root pe host).
2. **Ignorarea cgroup limits**: Fără limite, un container poate afecta întregul host.
3. **Latest tag în producție**: Folosește versiuni specifice pentru reproducibilitate.

### Întrebări rămase deschise

- Vor înlocui WebAssembly containers containerele Linux pentru unele workloads?
- Cum va evolua standardul OCI pentru hardware accelerators?

## Privire înainte

**Continuare Opțională: C17supp — eBPF și Programare la Nivel Nucleu**

După ce ai înțeles cum funcționează containerele la nivel de kernel (namespaces, cgroups), următorul pas este observabilitatea avansată cu eBPF. Vei putea monitoriza containere în producție cu overhead minim.

**Pregătire recomandată:**
- Instalează `bpftrace` și `bcc-tools`
- Rulează `sudo bpftrace -l` pentru a vedea probe-urile disponibile

## Rezumat Vizual

```
┌─────────────────────────────────────────────────────────────────┐
│                    SĂPTĂMÂNA 16: CONTAINERE — RECAP             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CONTAINER = Izolare la nivel de OS (nu VM)                    │
│                                                                 │
│  NAMESPACES (izolare)                                           │
│  ├── PID: arbore de procese separat                            │
│  ├── NET: stack de rețea separat                               │
│  ├── MNT: filesystem mounts separate                           │
│  ├── UTS: hostname separat                                     │
│  ├── IPC: comunicare inter-procese separată                    │
│  └── USER: mapping UID/GID                                     │
│                                                                 │
│  CGROUPS (limitare resurse)                                     │
│  ├── CPU: procent sau shares                                   │
│  ├── Memory: limită hard/soft                                  │
│  ├── I/O: bandwidth disk                                       │
│  └── PIDs: număr maxim procese                                 │
│                                                                 │
│  DOCKER                                                         │
│  ├── Image: template read-only                                 │
│  ├── Container: instanță running                               │
│  └── Dockerfile: rețetă construire image                       │
│                                                                 │
│  💡 TAKEAWAY: Containere = namespaces + cgroups + filesystem   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Materiale dezvoltate de Revolvix pentru ASE București - CSIE*  
*Sisteme de Operare | Anul I, Semestrul 2 | 2025-2026*

---
