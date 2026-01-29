# Ghid Studiu — Kernel Programming

## Comenzi Module
```bash
insmod module.ko     # Încarcă
rmmod module         # Descarcă
modprobe module      # Cu dependențe
lsmod                # Listează
dmesg                # Vezi printk output
```

## Character Device Driver
```c
static struct file_operations fops = {
    .owner = THIS_MODULE,
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
};

// Înregistrare
register_chrdev(MAJOR, "mydev", &fops);
```

## Diferențe Kernel vs Userspace
| Kernel | Userspace |
|--------|-----------|
| printk() | printf() |
| kmalloc() | malloc() |
| No libc | Full libc |
| No floating point | FP OK |
| Crash = panic | Crash = segfault |

## eBPF
- Sandboxed programs in kernel
- Verified before loading
- Use cases: tracing, networking, security
