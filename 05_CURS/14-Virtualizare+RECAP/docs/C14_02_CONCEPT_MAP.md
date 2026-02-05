# Hartă Conceptuală — Virtualizare

```
              ┌──────────────────┐
              │  VIRTUALIZARE    │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Hypervisor│    │  Tehnici    │     │Containere│
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│Type 1   │     │Full virt    │     │Namespaces│
│(bare    │     │Para virt    │     │Cgroups  │
│ metal)  │     │HW assisted  │     │Shared   │
│Type 2   │     │(VT-x/AMD-V) │     │ kernel  │
│(hosted) │     └─────────────┘     └─────────┘
└─────────┘

VM vs CONTAINER:
┌──────────────────────────────────────────────┐
│         VM                 CONTAINER          │
│  ┌─────────────┐      ┌─────────────┐        │
│  │    App      │      │    App      │        │
│  ├─────────────┤      ├─────────────┤        │
│  │  Guest OS   │      │  Libs only  │        │
│  ├─────────────┤      └──────┬──────┘        │
│  │ Hypervisor  │             │               │
│  └──────┬──────┘      Shared │ kernel        │
│         │                    │               │
│  ┌──────┴──────┐      ┌──────┴──────┐        │
│  │   Host OS   │      │   Host OS   │        │
│  └─────────────┘      └─────────────┘        │
│                                              │
│  Izolare: Strong       Izolare: Medium       │
│  Overhead: High        Overhead: Low         │
└──────────────────────────────────────────────┘
```