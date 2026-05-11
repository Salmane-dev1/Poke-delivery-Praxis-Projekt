FROM node:20-alpine

WORKDIR /app

# Abhängigkeiten
COPY api/package*.json ./
RUN npm ci

# Code kopieren
COPY api/ ./

# Azure Functions Emulator (einfacher HTTP-Server-Start)
# Wir starten die Function per func host innerhalb des Containers
RUN npm install -g azure-functions-core-tools@4 --unsafe-perm true

EXPOSE 7071

CMD ["func", "start", "--javascript"]
