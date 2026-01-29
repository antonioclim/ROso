# E05: Config File Manager

> **Nivel:** EASY | **Timp estimat:** 15-20 ore | **Componente:** Bash only

---

## Descriere

Dezvoltă un tool pentru gestionarea fișierelor de configurare: backup, restaurare, diff, validare și versionare simplă. Ideal pentru administrarea configurărilor de sistem.

---

## Obiective de Învățare

- Gestionare fișiere de configurare
- Diff și patch
- Versionare simplă (snapshots)
- Validare sintaxă configurări

---

## Cerințe Funcționale

### Obligatorii

1. **Backup configurări** - salvare cu timestamp în director dedicat
2. **Restaurare** - revenire la versiune anterioară
3. **Diff** - comparație între versiuni sau cu fișier curent
4. **Listare versiuni** - istoric pentru un fișier
5. **Grupare** - profile de configurare (dev, prod, etc.)

### Opționale

6. **Validare** - verificare sintaxă pentru formate cunoscute (ini, yaml, json)
7. **Template-uri** - generare configurări din template
8. **Sync** - sincronizare între mașini
9. **Encryption** - backup criptat pentru configurări sensibile

---

## Interfață

```bash
./config_manager.sh <command> [opțiuni]

Comenzi:
  backup <file>           Salvează versiune curentă
  restore <file> [ver]    Restaurează versiune (default: ultima)
  list <file>             Listează versiuni disponibile
  diff <file> [ver1] [ver2]  Compară versiuni
  validate <file>         Verifică sintaxă
  profile save <name>     Salvează set de configurări
  profile load <name>     Încarcă profil

Opțiuni globale:
  -h, --help              Afișează ajutor
  -d, --dir DIR           Director backup (default: ~/.config_backups)
  -v, --verbose           Output detaliat

Exemple:
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
║              CONFIG FILE MANAGER                                 ║
╚══════════════════════════════════════════════════════════════════╝

$ ./config_manager.sh list /etc/nginx/nginx.conf

📁 Versions for: /etc/nginx/nginx.conf
──────────────────────────────────────────────────────────────────
Ver   Date                 Size      Hash (first 8)
───────────────────────────────────────────────────────────────────
v5    2025-01-20 14:30     2.3 KB    a1b2c3d4    [current]
v4    2025-01-18 10:15     2.1 KB    e5f6g7h8
v3    2025-01-15 09:00     2.0 KB    i9j0k1l2
v2    2025-01-10 16:45     1.9 KB    m3n4o5p6
v1    2025-01-05 11:20     1.8 KB    q7r8s9t0    [initial]

Total: 5 versions, 10.1 KB storage used

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

Changes: +3 lines, -0 lines
```

---

## Structura Recomandată

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
│   └── validators/         # scripturi validare per format
│       ├── ini.sh
│       ├── yaml.sh
│       └── json.sh
└── tests/
```

---

## Hints Implementare

```bash
# Structură backup
BACKUP_DIR="$HOME/.config_backups"
# /etc/nginx/nginx.conf -> ~/.config_backups/etc/nginx/nginx.conf/
# v1_20250105_112000_a1b2c3d4.conf
# v2_20250110_164500_m3n4o5p6.conf

# Hash pentru identificare rapidă
get_hash() {
    sha256sum "$1" | cut -c1-8
}

# Validare JSON
validate_json() {
    python3 -m json.tool "$1" >/dev/null 2>&1
}
```

---

## Criterii Evaluare

| Criteriu | Pondere |
|----------|---------|
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
