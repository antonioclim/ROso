# Ghid Studiu — Threads

## Concepte Cheie

### Ce partajează threads?
- Code, data, heap
- File descriptors
- Signal handlers

### Ce NU partajează?
- Stack
- Registre
- Thread ID
- errno (thread-local)

### Modele Threading
| Model | Descriere | Exemplu |
|-------|-----------|---------|
| 1:1 | 1 user thread = 1 kernel thread | Linux, Windows |
| N:1 | N user threads = 1 kernel thread | Green threads |
| M:N | M user threads = N kernel threads | Go goroutines |

## POSIX Threads (pthreads)
```c
pthread_create(&tid, NULL, func, arg);
pthread_join(tid, &retval);
pthread_exit(retval);
```
