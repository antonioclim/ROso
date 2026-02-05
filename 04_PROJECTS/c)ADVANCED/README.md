# Proiecte ADVANCED (A01-A03)

> **Dificultate:** ⭐⭐⭐⭐⭐ | **Timp:** 40-50 ore | **Componente:** Bash + C

---

## Privire Ansamblu

Proiectele avansate necesită integrare C și cunoștințe profunde OS. Sunt recomandate doar pentru studenți cu experiență prealabilă C și background solid în programare sisteme.

> ⚠️ **Avertisment instructor:** Aceste proiecte sunt cu adevărat dificile. Am văzut programatori experimentați care s-au luptat cu integrarea C. Dacă alegi un proiect ADVANCED, te înscrii pentru sesiuni lungi de debugging, segmentation faults și memory leaks. Recompensa este înțelegere profundă și o piesă impresionantă de portofoliu.

---

## Listă Proiecte

| ID | Nume | Componentă C | Provocare Cheie |
|----|------|-------------|---------------|
| A01 | Mini Job Scheduler | Priority queue (heap) | IPC, shared memory, semafoare POSIX |
| A02 | Interactive Shell Extension | Syntax highlighter | Gestionare terminal, secvențe ANSI |
| A03 | Distributed File Sync | Protocol rețea | Socket-uri, concurență, rezolvare conflicte |

---

## Prerequisite

Înainte să alegi un proiect ADVANCED, ar trebui să fii confortabil cu:

- **Programare C**: pointeri, malloc/free, structuri
- **API-uri POSIX**: fork, exec, wait, semnale
- **Gestionare memorie**: fără memory leaks, cleanup corespunzător
- **Makefile-uri**: compilare multi-fișier, linking

Dacă oricare dintre acestea îți par nefamiliare, ia în considerare un proiect MEDIUM în schimb.

---

## Cerințe Integrare C

Componenta ta C trebuie să:

1. Compileze cu `gcc -Wall -Wextra -pedantic` fără warning-uri
2. Treacă verificare memorie Valgrind cu zero leaks
3. Se integreze curat cu Bash via shared library sau subprocess
4. Includă un Makefile corespunzător pentru compilare

---

## Ce Vei Învăța

Completarea unui proiect ADVANCED te va învăța:

- Programare sisteme în C
- Comunicare inter-proces (IPC)
- Gestionare memorie și debugging
- Construire aplicații hibride Bash/C
- Gestionare erori nivel profesional

---

## Capcane Comune

1. **Subestimarea complexității C** — Bugetează 50% mai mult timp decât crezi
2. **Memory leaks** — Rulează Valgrind din prima zi, nu la sfârșit
3. **Race conditions** — Folosește primitive sincronizare corespunzătoare
4. **Debugging orbește** — Adaugă logging în codul C; debugging cu `printf` funcționează

---

## Poveste Adevărată

> În 2023, un student a ales A01 pentru că "arăta interesant." Nu mai scrisese C de doi ani. Au petrecut primele 30 ore doar amintindu-și cum funcționează pointerii. Au terminat proiectul, dar i-a costat somn și sănătate mintală. Când l-am întrebat dacă ar recomanda ADVANCED altora, a zis: "Doar dacă știu cu adevărat C."

---

## Abordare Recomandată

1. **Săptămâna 1-2**: Construiește și testează componenta C izolat
2. **Săptămâna 3**: Integrează C cu wrapper Bash
3. **Săptămâna 4**: Adaugă gestionare erori, logging, teste
4. **Săptămâna 5**: Documentație și finisări

Nu încerca să construiești totul deodată. Pune partea C să funcționeze mai întâi.

---

*Proiecte ADVANCED — OS Kit | Ianuarie 2025*
