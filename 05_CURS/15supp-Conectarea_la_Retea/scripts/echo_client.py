#!/usr/bin/env python3
"""
Client TCP Echo - Demonstrație Model Socket BSD
Sisteme de Operare | ASE București - CSIE | 2025-2026

Concepte ilustrate:
- Conectare la server TCP
- Ciclul client: socket() → connect() → send/recv → close()
- Timeout și tratarea erorilor de conexiune

Utilizare:
    python3 echo_client.py [host] [port]
    
Exemple:
    python3 echo_client.py                    # localhost:9000
    python3 echo_client.py 192.168.1.100      # 192.168.1.100:9000
    python3 echo_client.py 192.168.1.100 8080 # 192.168.1.100:8080
"""

import socket
import sys
from datetime import datetime

# Configurare implicită
DEFAULT_HOST = '127.0.0.1'
DEFAULT_PORT = 9000
BUFFER_SIZE = 4096
CONNECT_TIMEOUT = 10  # secunde


def log_message(level: str, message: str) -> None:
    """Afișare mesaj cu timestamp."""
    timestamp = datetime.now().strftime('%H:%M:%S')
    print(f"[{timestamp}] [{level}] {message}")


def run_client(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT) -> None:
    """
    Client TCP interactiv pentru testare server echo.
    
    Conectează la serverul specificat și permite trimiterea
    de mesaje interactive din consolă.
    
    Args:
        host: Adresa IP a serverului
        port: Portul serverului
    """
    log_message("INFO", f"Conectare la {host}:{port}...")
    
    # Creare socket TCP
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Setare timeout pentru conectare
    client_socket.settimeout(CONNECT_TIMEOUT)
    
    try:
        # Inițiere conexiune TCP (three-way handshake)
        client_socket.connect((host, port))
        
        # După conectare, eliminăm timeout-ul pentru operații interactive
        client_socket.settimeout(None)
        
        # Obținere informații despre conexiune
        local_addr = client_socket.getsockname()
        log_message("CONN", f"Conectat! Endpoint local: {local_addr[0]}:{local_addr[1]}")
        
        print("\n" + "=" * 60)
        print("  CLIENT ECHO INTERACTIV")
        print("  Introduceți mesaje pentru a le trimite serverului.")
        print("  Tastați 'quit' sau 'exit' pentru a încheia.")
        print("  Tastați 'stats' pentru statistici conexiune.")
        print("=" * 60 + "\n")
        
        messages_sent = 0
        bytes_sent = 0
        bytes_received = 0
        
        while True:
            try:
                # Citire input de la utilizator
                user_input = input(">>> ")
                
                # Comenzi speciale
                if user_input.lower() in ('quit', 'exit', 'q'):
                    log_message("INFO", "Închidere conexiune...")
                    break
                    
                if user_input.lower() == 'stats':
                    print(f"\n  Statistici conexiune:")
                    print(f"  - Mesaje trimise: {messages_sent}")
                    print(f"  - Bytes trimiși: {bytes_sent}")
                    print(f"  - Bytes primiți: {bytes_received}")
                    print()
                    continue
                
                if not user_input:
                    continue
                
                # Codificare și trimitere
                data = user_input.encode('utf-8')
                client_socket.sendall(data)
                bytes_sent += len(data)
                messages_sent += 1
                
                log_message("SEND", f"Trimis {len(data)} bytes")
                
                # Așteptare răspuns
                response = client_socket.recv(BUFFER_SIZE)
                
                if not response:
                    log_message("WARN", "Server a închis conexiunea")
                    break
                
                bytes_received += len(response)
                
                # Decodificare și afișare răspuns
                response_text = response.decode('utf-8', errors='replace')
                log_message("RECV", f"Echo: \"{response_text}\" ({len(response)} bytes)")
                
            except KeyboardInterrupt:
                print()  # Linie nouă după ^C
                log_message("INFO", "Întrerupere de la utilizator")
                break
                
    except socket.timeout:
        log_message("ERR", f"Timeout la conectare ({CONNECT_TIMEOUT}s)")
        sys.exit(1)
    except ConnectionRefusedError:
        log_message("ERR", f"Conexiune refuzată - serverul nu rulează pe {host}:{port}")
        sys.exit(1)
    except ConnectionResetError:
        log_message("ERR", "Conexiune resetată de server")
        sys.exit(1)
    except OSError as e:
        log_message("ERR", f"Eroare rețea: {e}")
        sys.exit(1)
    finally:
        client_socket.close()
        log_message("INFO", "Conexiune închisă")
        print(f"\nSumar: {messages_sent} mesaje, {bytes_sent} bytes trimiși, {bytes_received} bytes primiți")


def main():
    """Punct de intrare principal cu parsare argumente."""
    host = DEFAULT_HOST
    port = DEFAULT_PORT
    
    # Parsare argumente
    if len(sys.argv) >= 2:
        host = sys.argv[1]
    
    if len(sys.argv) >= 3:
        try:
            port = int(sys.argv[2])
            if not (1 <= port <= 65535):
                raise ValueError("Port în afara intervalului 1-65535")
        except ValueError as e:
            print(f"Eroare: port invalid - {e}")
            print(f"Utilizare: {sys.argv[0]} [host] [port]")
            sys.exit(1)
    
    run_client(host, port)


if __name__ == '__main__':
    main()