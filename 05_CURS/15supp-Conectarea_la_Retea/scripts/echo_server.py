#!/usr/bin/env python3
"""
Server TCP Echo - Demonstrație Model Socket BSD
Sisteme de Operare | ASE București - CSIE | 2025-2026

Concepte ilustrate:
- Crearea și configurarea socket-urilor TCP
- Ciclul de viață: socket() → bind() → listen() → accept() → recv/send → close()
- Opțiuni socket (SO_REUSEADDR)
- Tratarea conexiunilor multiple secvențial

Utilizare:
    python3 echo_server.py [port]
    
Testare:
    nc localhost 9000
    # sau
    python3 echo_client.py
"""

import socket
import sys
import signal
from datetime import datetime
from typing import Tuple

# Configurare implicită
DEFAULT_HOST = '0.0.0.0'  # Ascultă pe toate interfețele
DEFAULT_PORT = 9000
BUFFER_SIZE = 4096
BACKLOG = 5  # Număr maxim conexiuni în coada de așteptare


def log_message(level: str, message: str) -> None:
    """Afișare mesaj cu timestamp."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] [{level}] {message}")


def handle_client(client_socket: socket.socket, client_addr: Tuple[str, int]) -> None:
    """
    Procesare conexiune client.
    
    Primește date de la client și le retransmite (echo).
    Continuă până când clientul închide conexiunea.
    
    Args:
        client_socket: Socket-ul pentru comunicare cu clientul
        client_addr: Tuple (IP, port) identificând clientul
    """
    client_ip, client_port = client_addr
    log_message("CONN", f"Conexiune acceptată de la {client_ip}:{client_port}")
    
    bytes_received = 0
    messages_count = 0
    
    try:
        while True:
            # Recepție date
            # recv() blochează până când date sunt disponibile sau conexiunea se închide
            data = client_socket.recv(BUFFER_SIZE)
            
            if not data:
                # Conexiune închisă de client (recv returnează bytes gol)
                log_message("DISC", f"Client {client_ip}:{client_port} deconectat")
                break
            
            bytes_received += len(data)
            messages_count += 1
            
            # Decodificare pentru afișare (presupunem UTF-8)
            try:
                message = data.decode('utf-8').strip()
                log_message("RECV", f"De la {client_ip}: \"{message}\" ({len(data)} bytes)")
            except UnicodeDecodeError:
                log_message("RECV", f"De la {client_ip}: <date binare> ({len(data)} bytes)")
            
            # Echo: retransmitere date primite
            # sendall() garantează trimiterea completă (spre deosebire de send())
            client_socket.sendall(data)
            log_message("SEND", f"Echo trimis către {client_ip}")
            
    except ConnectionResetError:
        log_message("WARN", f"Conexiune resetată de {client_ip}:{client_port}")
    except BrokenPipeError:
        log_message("WARN", f"Pipe întrerupt pentru {client_ip}:{client_port}")
    finally:
        log_message("STAT", f"Statistici {client_ip}: {messages_count} mesaje, {bytes_received} bytes")


def run_server(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT) -> None:
    """
    Pornire server TCP echo.
    
    Creează un socket, îl asociază cu adresa specificată și intră
    în bucla principală de acceptare a conexiunilor.
    
    Args:
        host: Adresa IP pentru ascultare
        port: Portul pentru ascultare
    """
    # Creare socket TCP
    # AF_INET = familia de adrese IPv4
    # SOCK_STREAM = socket orientat pe conexiune (TCP)
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # SO_REUSEADDR permite reutilizarea portului imediat după închidere
    # Fără această opțiune, portul rămâne în starea TIME_WAIT (~60s)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Asociere socket cu adresă și port
        server_socket.bind((host, port))
        
        # Activare mod ascultare
        # backlog specifică lungimea cozii de conexiuni pendinte
        server_socket.listen(BACKLOG)
        
        log_message("INFO", f"Server echo pornit pe {host}:{port}")
        log_message("INFO", f"Backlog: {BACKLOG} conexiuni, Buffer: {BUFFER_SIZE} bytes")
        log_message("INFO", "Apăsați Ctrl+C pentru oprire")
        
        # Bucla principală
        while True:
            try:
                # accept() blochează până când o conexiune este disponibilă
                # Returnează un NOU socket pentru comunicare și adresa clientului
                # Socket-ul original continuă să asculte pentru noi conexiuni
                client_socket, client_addr = server_socket.accept()
                
                # Context manager asigură închiderea corectă a socket-ului
                with client_socket:
                    handle_client(client_socket, client_addr)
                    
            except KeyboardInterrupt:
                raise  # Re-aruncă pentru tratare în finally
                
    except OSError as e:
        log_message("ERR", f"Eroare socket: {e}")
        sys.exit(1)
    finally:
        server_socket.close()
        log_message("INFO", "Server oprit")


def signal_handler(signum, frame):
    """Handler pentru semnale de terminare."""
    log_message("INFO", "Semnal de terminare primit")
    sys.exit(0)


def main():
    """Punct de intrare principal."""
    # Înregistrare handler pentru SIGINT (Ctrl+C) și SIGTERM
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Parsare argument opțional pentru port
    port = DEFAULT_PORT
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
            if not (1 <= port <= 65535):
                raise ValueError("Port în afara intervalului valid")
        except ValueError as e:
            print(f"Eroare: port invalid - {e}")
            print(f"Utilizare: {sys.argv[0]} [port]")
            sys.exit(1)
    
    run_server(port=port)


if __name__ == '__main__':
    main()