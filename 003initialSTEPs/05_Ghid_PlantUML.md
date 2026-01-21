# Ghid: diagrame PlantUML în kit

Kitul folosește PlantUML pentru a păstra diagramele ca text (versionabil în Git) și pentru a genera imagini (PNG) atunci când ai nevoie de ele în fișe/slide-uri.

## 1. Unde găsești diagramele

- Pentru fiecare săptămână: `SO_Saptamana_XX/diagrame/*.puml` (unde există)
- Conveții comune: `diagrame_common/` (skin, culori, stiluri)

## 2. Generarea diagramelor (PNG)

În rădăcina kitului:
```bash
python3 generate_diagrams.py --output ./_rendered_diagrams
```

Observație:
- scriptul poate descărca automat PlantUML JAR (necesită Internet);
- alternativ, poți furniza `--jar /cale/catre/plantuml.jar`.

## 3. Recomandări didactice

- pentru curs: include diagrama „mare” (o vedere de ansamblu);
- pentru laborator: include diagrama „de flux” (pașii, stările, tranzițiile);
- păstrează diagrama în `.puml` ca sursă, imaginea ca derivat.

Data ediției: **10 ianuarie 2026**
