# Jurnal de modificări

Toate modificările notabile ale acestui proiect vor fi documentate în acest fișier.

Formatul este bazat pe [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), iar acest proiect urmează [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-01-29

### Adăugat
- A fost adăugat folderul cu date‑mostră: `resources/sample_data/`
- Au fost adăugate suite de teste în `tests/` care acoperă `grep`, `sed`, `awk` și pipeline‑uri.

### Modificat
- Arhiva română a fost actualizată: traducere completă și sincronizare de fișiere.
- Datele‑mostră au fost sanitizate (fără e‑mailuri reale).

### Reparat
- Corecturi minore de tipar și link‑uri.

## [1.1.0] - 2025-01-21

### Adăugat
- Document cu exerciții de verificare live (fără notițe): `docs/S04_11_LIVE_VERIFICATION_EXERCISES.md`
- Bancă de întrebări pentru verificare orală: `homework/S04_05_ORAL_VERIFICATION.md`
- Scripturi lipsă în `scripts/bash/`:
  - `S04_01_setup_homework.sh`
  - `S04_04_generate_personalised_data.sh`
  - `S04_06_similarity_checker.sh`
- Suită de teste „grep mastery”.

### Modificat
- Exercițiile de regex au fost rafinate pentru a evidenția ERE vs BRE.
- Formatarea „cheat sheet” a fost îmbunătățită (A4, prietenos pentru tipărire).

## [1.0.0] - 2025-01-15

### Adăugat
- Lansarea inițială a Seminarului 04: `grep`, `sed`, `awk`, regex.
- Exerciții, teste, resurse și schelet pentru teme.
- Configurație de bază CI și linting.
- Slide‑uri și cheat sheet HTML.

*Menținut de: ing. dr. Antonio Clim*
