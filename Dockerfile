FROM eclipse-temurin:21-jre-alpine

# Metadaten
LABEL org.opencontainers.image.title="Bastillion"
LABEL org.opencontainers.image.description="Modern web-based SSH console and key management tool"
LABEL org.opencontainers.image.source="https://github.com/Loophole-LLC/Bastillion"
LABEL org.opencontainers.image.vendor="Loophole LLC / Community Docker Image"

# Build-Argument für Upstream-Version (Standard: 6.0.3)
ARG BASTILLION_VERSION=6.0.3

# Standard-Laufzeitumgebung
ENV CONFIG_DIR=/data \
    PORT=8080 \
    TLS_ENABLED=false \
    JAVA_TOOL_OPTIONS=-DGEN_DB_PASS=true \
    CLIENT_IP_HEADER=X-Forwarded-For

# Minimale Tools für Healthcheck & Netzwerkanfragen
RUN apk add --no-cache curl wget ca-certificates bash

# Unprivilegierten Benutzer anlegen (Sicherheit: Non-Root)
RUN addgroup -g 1000 bastillion && \
    adduser -D -u 1000 -G bastillion -s /bin/sh bastillion && \
    mkdir -p /opt/bastillion /data && \
    chown -R bastillion:bastillion /opt/bastillion /data

WORKDIR /opt/bastillion

# Executable Standalone JAR direkt aus offiziellem GitHub Release beziehen
ADD --chown=bastillion:bastillion \
    https://github.com/Loophole-LLC/Bastillion/releases/download/v${BASTILLION_VERSION}/bastillion-${BASTILLION_VERSION}.jar \
    /opt/bastillion/bastillion.jar

# Privilegien abgeben
USER bastillion

# Persistenter Datenspeicher (H2-DB, Keystores, SSH-Keypair, Konfiguration)
VOLUME ["/data"]

# HTTP-Port (8080 Standard bei TLS_ENABLED=false)
EXPOSE 8080 8443

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:${PORT}/ || exit 1

ENTRYPOINT ["java", "-jar", "/opt/bastillion/bastillion.jar"]
