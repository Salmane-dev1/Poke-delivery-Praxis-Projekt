# PokéDelivery – DevOps Praxisprojekt

PokéDelivery ist eine serverlose REST‑API auf Basis von **Azure Functions (Node.js)**.
Die API stellt Pokémon‑Informationen über einen klar definierten HTTP‑Endpunkt bereit:

GET /pokemon/{name}

Das Projekt dient als **DevOps‑Praxisprojekt** und fokussiert sich auf:
- sauberes Git‑Branching
- automatisierte Tests
- Continuous Integration mit GitHub Actions
- späteres Continuous Deployment mit Jenkins
## Technologie‑Stack

- **Node.js 20** – Laufzeitumgebung für die API
- **Azure Functions** – Serverlose Ausführung der REST‑API
- **GitHub** – Source Control & Pull Requests
- **GitHub Actions** – Continuous Integration (CI)
- **Jenkins** – Continuous Deployment (geplant)
- **Docker** – Containerisierung von CI/CD‑ und Monitoring‑Komponenten
- **Terraform** – Infrastructure as Code für Azure (geplant)
- **Prometheus & Grafana** – Monitoring und Visualisierung (geplant)
- **Azure Application Insights** – Observability für die Azure Function (geplant)
## Projektstruktur

```text
.
├── api/                 # Azure Function (Node.js)
│   ├── getPokemon/      # HTTP Function GET /pokemon/{name}
│   ├── package.json     # NPM Konfiguration & Scripts
│   └── package-lock.json
│
├── docs/                # Projektdokumentation
│   ├── branching.md     # Branching‑Strategie
│   └── ci.md            # CI‑Dokumentation (wird ergänzt)
│
├── .github/workflows/   # GitHub Actions CI
│   └── ci.yml
│
├── README.md            # Projektübersicht (diese Datei)
└── bootcamp-template/   # Bootcamp‑Vorgaben

## Lokale Ausführung

Voraussetzungen:
- Node.js **Version 20**
- npm
- Linux‑Umgebung (z. B. WSL2 mit Ubuntu)

### Abhängigkeiten installieren

```bash
cd api
npm ci
## Azure fuction lokal starten 
npm start 
Die Function ist danach lokal erreichbar unter:
http://localhost:7071/api/pokemon/pikachu

## Tests

Die API enthält einen **CI‑tauglichen Unit Test**, bei dem externe API‑Aufrufe gemockt werden.
Dadurch sind die Tests reproduzierbar und unabhängig von externen Diensten.

### Tests lokal ausführen

```bash
cd api
npm test
###Continuous Integration (CI)
Die Continuous Integration wird mit **GitHub** Actions umgesetzt.
##CI‑Trigger
Die Pipeline startet automatisch bei:

Pull Requests auf develop und main
Pushes auf develop und main

##CI‑Schritte

Repository auschecken
Node.js 20 einrichten
Abhängigkeiten mit npm ci installieren
Unit Tests mit npm test ausführen

Die CI‑Konfiguration befindet sich in:
.github/workflows/ci.yml
Detaillierte Informationen zur CI sind in docs/ci.md dokumentiert.


## Continuous Deployment Setup

The CD pipeline is implemented using Jenkins with a multi-agent architecture.

- Jenkins runs in Docker
- Two agents execute pipeline stages
- Docker Compose is used for orchestration
- Ansible automates environment startup

This setup ensures reproducibility and scalability.

