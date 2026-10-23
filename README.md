# Bastillion Docker (Multi-Arch)

[![Docker Multi-Arch](https://img.shields.io/badge/Architecture-amd64%20%7C%20arm64-blue.svg)](#)
[![Java 21](https://img.shields.io/badge/Java-21-orange.svg)](#)
[![Upstream](https://img.shields.io/badge/Upstream-Loophole--LLC%2FBastillion-brightgreen.svg)](https://github.com/Loophole-LLC/Bastillion)

Vollständig containerisiertes **Bastillion 6** (ehemals *KeyBox*) als schlankes Multi-Arch Docker Image (`linux/amd64` und `linux/arm64`) mit **automatischen Upstream-Builds** bei neuen GitHub-Releases.

---

## 🌟 Was ist Bastillion?

[Bastillion](https://github.com/Loophole-LLC/Bastillion) ist eine moderne, browserbasierte SSH-Konsole und ein zentrales SSH-Schlüsselverwaltungssystem:

* **Web-SSH-Terminal:** Volles xterm.js-Terminal im Webbrowser mit synchronisiertem Multi-Terminal-Broadcasting (Befehle parallel an mehrere Server gleichzeitig senden).
* **Zentrales Key-Management:** Bastillion erzeugt ein eigenes sicheres **Ed25519-Schlüsselpaar** und verteilt den Public Key automatisch auf registrierte Hosts. Benutzer müssen keine privaten Schlüssel mehr lokal verwalten.
* **Moderne Krypto:** Ab Version 6 voller Support für moderne SSH-Verfahren, Ed25519, moderne RSA-SHA2-Ciphers und SSH-Zertifikate.
* **Audit-Sicherheit:** Aufzeichnung aller SSH-Sitzungen zur lückenlosen Nachvollziehbarkeit.
* **Zwei-Faktor-Authentifizierung (2FA):** Integrierte 2FA via Google Authenticator, Authy oder Standard-TOTP-Apps.

---

## 🚀 Schnellstart

### Mit Docker Run

```bash
docker run -d \
  --name bastillion \
  -p 8080:8080 \
  -v bastillion_data:/data \
  -e CONFIG_DIR=/data \
  -e PORT=8080 \
  -e TLS_ENABLED=false \
  -e GEN_DB_PASS=true \
  bastillion-docker:latest
```

### Mit Docker Compose (inkl. Traefik)

Erstelle eine `docker-compose.yaml`:

```yaml
version: "3.8"

services:
  bastillion:
    image: bastillion-docker:latest
    container_name: bastillion
    hostname: bastillion
    restart: unless-stopped
    networks:
      bastillion_net:
        ipv4_address: 172.28.0.10
    volumes:
      - ./data:/data
    environment:
      - CONFIG_DIR=/data
      - PORT=8080
      - TLS_ENABLED=false
      - GEN_DB_PASS=true
      - CLIENT_IP_HEADER=X-Forwarded-For
      - TZ=Europe/Berlin
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.bastillion-http.rule=Host(`bastillion.example.com`)"
      - "traefik.http.routers.bastillion-http.entrypoints=web"
      - "traefik.http.routers.bastillion-http.middlewares=redirect-to-https@file"
      - "traefik.http.routers.bastillion.rule=Host(`bastillion.example.com`)"
      - "traefik.http.routers.bastillion.entrypoints=websecure"
      - "traefik.http.routers.bastillion.tls=true"
      - "traefik.http.routers.bastillion.tls.certresolver=letsencrypt"
      - "traefik.http.routers.bastillion.service=bastillion-svc"
      - "traefik.http.services.bastillion-svc.loadbalancer.server.port=8080"

networks:
  bastillion_net:
    name: bastillion.dockernetwork.local
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.28.0.0/24
          gateway: 172.28.0.1
          ip_range: 172.28.0.128/25
```

Starte den Dienst:
```bash
docker compose up -d
```

---

## 🔐 Ersteinrichtung & Sicherheit

Beim ersten Start ist der Standard-Zugang aktiv:

* **Benutzer:** `admin`
* **Passwort:** `changeme`

> [!IMPORTANT]
> **Sofortige Maßnahmen nach dem ersten Login:**
> 1. Passwort ändern unter **Settings → Change Password**.
> 2. Zwei-Faktor-Authentifizierung (TOTP) unter **Settings** für den Admin-Account aktivieren.

---

## ⚙️ Wichtige Umgebungsvariablen

| Variable | Standard | Beschreibung |
| :--- | :--- | :--- |
| `CONFIG_DIR` | `/data` | Zentraler Ordner für H2-Datenbank, Keystores und SSH-Schlüssel. |
| `PORT` | `8080` | Interner HTTP/HTTPS Listen-Port. |
| `TLS_ENABLED` | `false` | `false` für Betrieb hinter Reverse Proxy (Traefik/Nginx); `true` für direktes SSL. |
| `GEN_DB_PASS` | `true` | Erzeugt beim Erststart automatisch ein kryptografisch sicheres H2-DB-Passwort. |
| `CLIENT_IP_HEADER` | `X-Forwarded-For` | Liest die echte Client-IP aus dem Proxy-Header für Audit-Logs. |
| `KEY_MANAGEMENT` | `manage` | Modus für `authorized_keys` (`manage`, `append` oder `off`). |

---

## 💾 Backup & Wiederherstellung

Da Bastillion durch `CONFIG_DIR=/data` alle Zustände (H2-Datenbank, SSH-Keypair, Einstellungen) an einem Ort bündelt, reicht eine einfache Dateisicherung:

```bash
# Backup des Datenordners erstellen
tar -cpzf bastillion_backup_$(date +%Y%m%d_%H%M%S).tar.gz ./data
```

---

## 🔄 Automatisierter Release-Watcher

Dieses Repository nutzt CI/CD Actions, um alle 6 Stunden die offizielle [Loophole-LLC Bastillion Release API](https://github.com/Loophole-LLC/Bastillion/releases) abzufragen.

Sobald ein neues Upstream-Tag erscheint, baut die Pipeline vollautomatisch Multi-Arch Images (`linux/amd64` und `linux/arm64`) und pusht sie in die Container Registry.

---

## 📜 Lizenz

* Bastillion steht unter der **Prosperity Public License 3.0.0** von [Loophole, LLC](https://loophole.company/).
* Das Docker-Packaging und die CI/CD-Skripte sind unter der **Apache 2.0 Lizenz** veröffentlicht.
