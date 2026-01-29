# Resurse Suplimentare

> **Sisteme de Operare** | ASE București - CSIE
> Seminar 6: CAPSTONE Projects

---

## Cuprins

```
resurse/
├── README.md           # Acest fișier
├── systemd/            # Fișiere systemd service/timer
│   ├── monitor.service
│   ├── backup.service
│   └── backup.timer
├── templates/          # Template-uri pentru scripturi
│   └── bash_script_template.sh
└── examples/           # Exemple și referințe
    └── cron_examples.txt
```

---

## Sistemd

### Instalare Servicii

```bash
# Copiază fișierele service
sudo cp systemd/*.service /etc/systemd/system/
sudo cp systemd/*.timer /etc/systemd/system/

# Reîncarcă systemd
sudo systemctl daemon-reload

# Activează și pornește monitor
sudo systemctl enable monitor.service
sudo systemctl start monitor.service

# Activează și pornește timer-ul de backup
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

### Comenzi Utile

```bash
# Status serviciu
sudo systemctl status monitor.service

# Log-uri
sudo journalctl -u monitor.service -f

# Restart
sudo systemctl restart monitor.service

# Listare timer-uri
sudo systemctl list-timers

# Verificare timer
sudo systemctl status backup.timer
```

### Customizare

Editează fișierele `.service` înainte de instalare pentru:
- Ajustare căi (`WorkingDirectory`, `ExecStart`)
- Modificare variabile de mediu (`Environment`)
- Schimbare user/group (`User`, `Group`)
- Ajustare limită resurse (`MemoryMax`, `CPUQuota`)

---

## Templates

### Bash Script Template

Template-ul `bash_script_template.sh` include:
- Strict mode (`set -euo pipefail`)
- Logging cu culori și nivele
- Parsing argumente (short și long options)
- Help/usage generation
- Cleanup cu trap
- Validare input
- Suport pentru configurare din fișier

#### Utilizare

```bash
# Copiază template-ul
cp templates/bash_script_template.sh ~/proiect/my_script.sh

# Editează și personalizează
vim ~/proiect/my_script.sh

# Fă executabil
chmod +x ~/proiect/my_script.sh
```

---

## Exemple

### Cron Jobs

Fișierul `examples/cron_examples.txt` conține:
- Explicație format crontab
- Exemple pentru Monitor, Backup, Deployer
- Patterns solide (cu lock, timeout, logging)
- Sfaturi pentru debugging

---

## Referințe Externe

### Documentație Oficială
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [Cron Manual](https://man7.org/linux/man-pages/man5/crontab.5.html)

### Ghiduri și Tutoriale
- [Bash Style Guide (Google)](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) - Static analysis tool
- [Explain Shell](https://explainshell.com/) - Explică comenzi shell

### Unelte Utile
- **ShellCheck**: `apt install shellcheck`
- **bat**: `apt install bat` - cat cu syntax highlighting
- **fzf**: `apt install fzf` - fuzzy finder
- **jq**: `apt install jq` - JSON processor

---

## Utilizare în Proiecte

### Exemplu: Setup Monitor cu Systemd

```bash
# 1. Instalează proiectul
cd /opt
sudo git clone <repo> capstone
cd capstone/monitor

# 2. Verifică dependințele
./check_dependencies.sh

# 3. Testează manual
./monitor.sh --all

# 4. Copiază și editează service file
sudo cp ../resurse/systemd/monitor.service /etc/systemd/system/
sudo vim /etc/systemd/system/monitor.service
# Ajustează WorkingDirectory și ExecStart

# 5. Activează
sudo systemctl daemon-reload
sudo systemctl enable monitor.service
sudo systemctl start monitor.service

# 6. Verifică
sudo systemctl status monitor.service
sudo journalctl -u monitor.service -f
```

### Exemplu: Setup Backup cu Timer

```bash
# 1. Copiază fișierele
sudo cp ../resurse/systemd/backup.service /etc/systemd/system/
sudo cp ../resurse/systemd/backup.timer /etc/systemd/system/

# 2. Editează pentru setup-ul tău
sudo vim /etc/systemd/system/backup.service

# 3. Activează timer-ul (nu service-ul direct)
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# 4. Verifică programarea
sudo systemctl list-timers | grep backup

# 5. Test manual (opțional)
sudo systemctl start backup.service
sudo journalctl -u backup.service
```

---

*Resurse pentru Sisteme de Operare | ASE București - CSIE*
