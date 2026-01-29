#!/usr/bin/env python3
"""
Generator de diagrame PNG din fișiere PlantUML - VERSIUNE CORECTATĂ
===================================================================
Script pentru cursul de Sisteme de Operare - ASE București CSIE

PROBLEMĂ REZOLVATĂ: !include paths care nu se rezolvau corect

Utilizare:
    python generate_diagrams_FIXED.py [--jar PATH] [--output DIR] [--dpi DPI]

Autor: Revolvix | ASE București - CSIE
"""

import os
import sys
import subprocess
import urllib.request
import argparse
import tempfile
import shutil
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configurație
PLANTUML_JAR_URL = "https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar"
PLANTUML_JAR_NAME = "plantuml.jar"
DEFAULT_DPI = 200
DEFAULT_OUTPUT_DIR = "output_png"

def check_java():
    """Verifică dacă Java este instalat."""
    try:
        result = subprocess.run(["java", "-version"], capture_output=True, text=True)
        return result.returncode == 0
    except FileNotFoundError:
        return False

def download_plantuml_jar(target_path: Path):
    """Descarcă PlantUML JAR dacă nu există."""
    if target_path.exists():
        print(f"✓ PlantUML JAR găsit: {target_path}")
        return True
    
    print(f"⬇ Descarc PlantUML JAR de la GitHub...")
    try:
        urllib.request.urlretrieve(PLANTUML_JAR_URL, target_path)
        print(f"✓ PlantUML JAR descărcat: {target_path}")
        return True
    except Exception as e:
        print(f"✗ Eroare la descărcare: {e}")
        return False

def find_puml_files(base_dir: Path) -> list:
    """Găsește toate fișierele .puml recursiv."""
    puml_files = []
    for root, dirs, files in os.walk(base_dir):
        dirs[:] = [d for d in dirs if d not in [DEFAULT_OUTPUT_DIR, '__pycache__', '.git']]
        for file in files:
            if file.endswith('.puml') and file != 'skin.puml':
                puml_files.append(Path(root) / file)
    return sorted(puml_files)

def find_skin_file(base_dir: Path) -> Path:
    """Găsește fișierul skin.puml."""
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file == 'skin.puml':
                return Path(root) / file
    return None

def preprocess_puml(puml_file: Path, skin_content: str = None) -> str:
    """
    Preprocesează un fișier PUML - REZOLVĂ PROBLEMA !include
    
    Strategia: Înlocuiește !include cu conținutul efectiv sau îl elimină
    """
    content = puml_file.read_text(encoding='utf-8', errors='ignore')
    
    # Elimină liniile !include (skin.puml e opțional, diagramele au stiluri inline)
    lines = content.split('\n')
    processed_lines = []
    
    for line in lines:
        # Skip liniile cu !include
        if line.strip().startswith('!include'):
            # Dacă avem skin_content, îl inserăm în loc de !include
            if skin_content and 'skin.puml' in line:
                processed_lines.append('\'  [skin.puml content inlined below]')
                processed_lines.append(skin_content)
            else:
                processed_lines.append(f"' REMOVED: {line.strip()}")
            continue
        processed_lines.append(line)
    
    return '\n'.join(processed_lines)

def generate_png(puml_file: Path, jar_path: Path, output_dir: Path, dpi: int, skin_content: str = None) -> tuple:
    """
    Generează PNG dintr-un fișier PlantUML.
    
    Returnează: (success: bool, message: str)
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        # Preprocesează fișierul PUML
        processed_content = preprocess_puml(puml_file, skin_content)
        
        # Creează fișier temporar cu conținutul procesat
        with tempfile.NamedTemporaryFile(mode='w', suffix='.puml', delete=False, encoding='utf-8') as tmp:
            tmp.write(processed_content)
            tmp_path = tmp.name
        
        try:
            # Generează PNG din fișierul temporar
            cmd = [
                "java",
                "-DPLANTUML_LIMIT_SIZE=16384",
                "-jar", str(jar_path),
                "-tpng",
                f"-Sdpi={dpi}",
                "-o", str(output_dir.absolute()),
                tmp_path
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
            # Redenumește fișierul output să aibă numele original
            tmp_png = output_dir / (Path(tmp_path).stem + ".png")
            final_png = output_dir / (puml_file.stem + ".png")
            
            if tmp_png.exists():
                if final_png.exists():
                    final_png.unlink()
                tmp_png.rename(final_png)
            
            if result.returncode == 0 and final_png.exists():
                size = final_png.stat().st_size / 1024
                return (True, f"✓ {puml_file.name} → {final_png.name} ({size:.0f}KB)")
            else:
                error_msg = result.stderr[:200] if result.stderr else "PNG nu a fost generat"
                return (False, f"✗ {puml_file.name}: {error_msg}")
                
        finally:
            # Cleanup fișier temporar
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
            
    except subprocess.TimeoutExpired:
        return (False, f"✗ {puml_file.name}: Timeout (diagrama prea complexă?)")
    except Exception as e:
        return (False, f"✗ {puml_file.name}: {str(e)[:200]}")

def print_summary(results: list):
    """Afișează sumarul generării."""
    success = sum(1 for r in results if r[0])
    failed = len(results) - success
    
    print(f"\n{'='*60}")
    print(f"SUMAR GENERARE PNG")
    print(f"{'='*60}")
    print(f"  Total fișiere:  {len(results)}")
    print(f"  ✓ Generate:     {success}")
    print(f"  ✗ Eșuate:       {failed}")
    
    if failed > 0:
        print(f"\nFișiere cu erori:")
        for success_flag, msg in results:
            if not success_flag:
                print(f"  {msg}")

def main():
    parser = argparse.ArgumentParser(
        description="Generează diagrame PNG din fișiere PlantUML (versiune corectată)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple:
  python generate_diagrams_FIXED.py                    # Generează toate PNG-urile
  python generate_diagrams_FIXED.py --dpi 150          # DPI mai mic
  python generate_diagrams_FIXED.py --output ./images  # Director output custom
        """
    )
    
    parser.add_argument("--jar", type=Path, default=Path(__file__).parent / PLANTUML_JAR_NAME)
    parser.add_argument("--output", "-o", type=Path, default=Path(__file__).parent / DEFAULT_OUTPUT_DIR)
    parser.add_argument("--dpi", type=int, default=DEFAULT_DPI)
    parser.add_argument("--workers", "-j", type=int, default=4)
    parser.add_argument("--clean", action="store_true", help="Șterge output-ul existent")
    
    args = parser.parse_args()
    
    print("""
╔════════════════════════════════════════════════════════════════╗
║     SO Kit - Generator Diagrame PlantUML → PNG (FIXED)         ║
║                    ASE București - CSIE                        ║
╚════════════════════════════════════════════════════════════════╝
    """)
    
    # Verificări
    if not check_java():
        print("✗ Java nu este instalat!")
        sys.exit(1)
    print("✓ Java disponibil")
    
    if not download_plantuml_jar(args.jar):
        sys.exit(1)
    
    # Găsește fișierele
    base_dir = Path(__file__).parent
    puml_files = find_puml_files(base_dir)
    
    if not puml_files:
        print("✗ Nu am găsit fișiere .puml!")
        sys.exit(1)
    
    print(f"✓ Găsite {len(puml_files)} fișiere .puml")
    
    # Găsește skin.puml (opțional)
    skin_file = find_skin_file(base_dir)
    skin_content = None
    if skin_file:
        print(f"✓ skin.puml găsit: {skin_file}")
        skin_content = skin_file.read_text(encoding='utf-8', errors='ignore')
    else:
        print("⚠ skin.puml nu a fost găsit (se vor folosi stiluri default)")
    
    # Pregătește output
    if args.clean and args.output.exists():
        shutil.rmtree(args.output)
    args.output.mkdir(parents=True, exist_ok=True)
    
    # Generare
    print(f"\nGenerez PNG-uri (DPI={args.dpi})...")
    print("-" * 60)
    
    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {
            executor.submit(generate_png, f, args.jar, args.output, args.dpi, skin_content): f 
            for f in puml_files
        }
        
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(result[1])
    
    print_summary(results)
    
    print(f"""
{'='*60}
GATA! Diagramele sunt în: {args.output}
{'='*60}
    """)

if __name__ == "__main__":
    main()
