# E05: Manager Fișiere Configurație

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Doar Bash

---

## Descriere

Dezvoltă un instrument pentru gestionarea fișierelor de configurație: backup, restaurare, diff, validare și versionare simplă. Ideal pentru administrarea configurațiilor de sistem.

---

## Obiective de Învățare

- Gestionare fișiere configurație
- Diff și patch
- Versionare simplă (snapshot-uri)
- Validare sintaxă configurație

---

## Cerințe Funcționale

### Obligatorii (pentru nota de trecere)

1. **Backup configurație** - salvare cu timestamp în director dedicat
2. **Restaurare** - revenire la versiune anterioară
3. **Diff** - comparare între versiuni sau cu fișier curent
4. **Listare versiuni** - istoric pentru un fișier
5. **Grupare** - profile configurație (dev, prod, etc.)

### Opționale (pentru punctaj complet)

6. **Validare** - verificare sintaxă pentru formate cunoscute (ini, yaml, json)
7. **Șabloane** - generare configurații din template
8. **Sincronizare** - sincronizare între mașini
9. **Criptare** - backup criptat pentru configurații sensibile

---

## Interfață

```bash
./config_manager.sh <command> [options]

Commands:
  backup <file>           Save current version
  restore <file> [ver]    Restore version (default: latest)
  list <file>             List available versions
  diff <file> [ver1] [ver2]  Compare versions
  validate <file>         Check syntax
  profile save <n>        Save configuration set
  profile load <n>        Load profile

Global options:
  -h, --help              Display help
  -d, --dir DIR           Backup directory (default: ~/.config_backups)
  -v, --verbose           Detailed output

Examples:
  ./config_manager.sh backup /etc/nginx/nginx.conf
  ./config_manager.sh list /etc/nginx/nginx.conf
  ./config_manager.sh diff /etc/nginx/nginx.conf v2 v5
  ./config_manager.sh restore /etc/nginx/nginx.conf v3
  ./config_manager.sh profile save production
```

---

## Exemplu Output

```
╔══════════════════════════════════════════════════════════════════╗
║              MANAGER FIȘIERE CONFIGURAȚIE                        ║
╚══════════════════════════════════════════════════════════════════╝

$ ./config_manager.sh list /etc/nginx/nginx.conf

📁 Versiuni pentru: /etc/nginx/nginx.conf
──────────────────────────────────────────────────────────────────
Ver   Dată                 Mărime    Hash (primele 8)
───────────────────────────────────────────────────────────────────
v5    2025-01-20 14:30     2.3 KB    a1b2c3d4    [curent]
v4    2025-01-18 10:15     2.1 KB    e5f6g7h8
v3    2025-01-15 09:00     2.0 KB    i9j0k1l2
v2    2025-01-10 16:45     1.9 KB    m3n4o5p6
v1    2025-01-05 11:20     1.8 KB    q7r8s9t0    [inițial]

Total: 5 versiuni, 10.1 KB stocare folosită

$ ./config_manager.sh diff /etc/nginx/nginx.conf v4 v5

📊 Diff: v4 → v5
──────────────────────────────────────────────────────────────────
--- v4 (2025-01-18 10:15)
+++ v5 (2025-01-20 14:30)
@@ -12,6 +12,8 @@
    server_name example.com;
+    # Added SSL configuration
+    ssl_certificate /etc/ssl/cert.pem;
+    ssl_certificate_key /etc/ssl/key.pem;
    location / {

Modificări: +3 linii, -0 linii
```

---

## Structură Recomandată

```
E05_Config_File_Manager/
├── src/
│   ├── config_manager.sh
│   └── lib/
│       ├── backup.sh
│       ├── restore.sh
│       ├── diff.sh
│       ├── validate.sh
│       └── profiles.sh
├── etc/
│   └── validators/         # validation scripts per format
│       ├── ini.sh
│       ├── yaml.sh
│       └── json.sh
└── tests/
```

---

## Indicii de Implementare

```bash
# Backup structure
BACKUP_DIR="$HOME/.config_backups"
# /etc/nginx/nginx.conf -> ~/.config_backups/etc/nginx/nginx.conf/
# v1_20250105_112000_a1b2c3d4.conf
# v2_20250110_164500_m3n4o5p6.conf

# Hash for quick identification
get_hash() {
    sha256sum "$1" | cut -c1-8
}

# JSON validation
validate_json() {
    python3 -m json.tool "$1" >/dev/null 2>&1
}
```

---

## Criterii de Evaluare

| Criteriu | Pondere |
|-----------|--------|
| Backup funcțional | 15% |
| Restaurare | 15% |
| Diff corect | 15% |
| Listare versiuni | 10% |
| Profile | 10% |
| Validare (opțional) | 5% |
| Calitate cod | 15% |
| Teste | 10% |
| Documentație | 5% |

---

*Proiect EASY | Sisteme de Operare | ASE-CSIE*
