# Ghid Studiu — Filesystem P1

## Inode Conține
- File type, permissions
- Owner (UID, GID)
- Size
- Timestamps (atime, mtime, ctime)
- Link count
- Pointers to data blocks

## Inode NU Conține
- File name (stored in directory)

## Hard vs Soft Links
| Hard Link | Soft Link |
|-----------|-----------|
| Same inode | Different inode |
| Can't cross FS | Can cross FS |
| Can't link dirs | Can link dirs |
| Target must exist | Target can be missing |

## Calcul Dimensiune Maximă
```
12 direct × 4KB = 48KB
1 single × 1024 × 4KB = 4MB
1 double × 1024 × 1024 × 4KB = 4GB
1 triple × 1024³ × 4KB = 4TB
```