# PokéDelivery – DevOps Praxisprojekt

PokéDelivery ist ein DevOps-Praxisprojekt mit einer serverlosen REST-API auf Basis von **Azure Functions** und **Node.js**.

Die Anwendung stellt Pokémon-Informationen über einen HTTP-Endpunkt bereit und wird mit einer vollständigen DevOps-Pipeline entwickelt, getestet, deployed und überwacht.

## API Endpoint

```http
GET /api/pokemon/{name}
```

### Beispiel

```http
GET /api/pokemon/pikachu
```

### Finaler Azure Endpoint

```text
https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

---

## Ziel des Projekts

Ziel des Projekts ist der Aufbau einer praxisnahen DevOps-Architektur mit:

- GitHub Versionsverwaltung
- Branching-Strategie mit Pull Requests
- GitHub Actions für Continuous Integration
- Jenkins für Continuous Deployment
- Docker Compose für lokale Infrastruktur
- Custom Jenkins Agent
- Terraform für Infrastructure as Code auf Azure
- Azure Functions als serverlose Laufzeitumgebung
- Azure Application Insights für Cloud Observability
- Prometheus, Blackbox Exporter und Grafana für zusätzliches API-Monitoring

---

## Technologie-Stack

- **Node.js 20** – Laufzeitumgebung für die API
- **Azure Functions** – Serverlose REST-API
- **GitHub** – Source Control und Pull Requests
- **GitHub Actions** – Continuous Integration
- **Jenkins** – Continuous Deployment
- **Docker** – Containerisierung
- **Docker Compose** – Orchestrierung der lokalen DevOps- und Monitoring-Umgebung
- **Terraform** – Infrastructure as Code für Azure
- **Ansible** – Automatisierung der Infrastrukturumgebung
- **Prometheus** – Metriken sammeln
- **Blackbox Exporter** – HTTP-Checks gegen die Azure Function API
- **Grafana** – Visualisierung der Monitoring-Daten
- **Azure Application Insights** – Cloud Monitoring und Observability

---

## Projektstruktur

```text
.
├── api/                         # Azure Function App mit Node.js
│   ├── getPokemon/              # HTTP Function für Pokémon-Daten
│   ├── host.json
│   ├── package.json
│   └── package-lock.json
│
├── .github/workflows/           # GitHub Actions CI Pipeline
│   └── ci.yml
│
├── ansible/                     # Ansible Automatisierung
│   ├── inventory
│   └── playbook.yml
│
├── bruno/                       # API Tests mit Bruno
│
├── docs/                        # Projektdokumentation
│
├── terraform/                   # Azure Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── monitoring/                  # Monitoring-Konfiguration
│   └── blackbox/
│       └── blackbox.yml
│
├── docker-compose.yml           # Jenkins, Agent, Prometheus, Grafana, Blackbox Exporter
├── prometheus.yml               # Prometheus Scrape-Konfiguration
├── Dockerfile.agent             # Custom Jenkins Agent Image
└── README.md
```

---

## Architekturübersicht

```text
Developer
   |
   | git push / pull request
   v
GitHub Repository
   |
   | CI
   v
GitHub Actions
   |
   | Tests erfolgreich
   v
Jenkins CD Pipeline
   |
   | Terraform + Azure Functions Deployment
   v
Azure Infrastructure
   |
   | Monitoring
   v
Application Insights + Prometheus/Grafana
```

---

## Continuous Integration mit GitHub Actions

Die CI-Pipeline läuft automatisch bei Pull Requests und Pushes auf die definierten Branches.

### CI-Schritte

```text
Checkout Repository
   |
Setup Node.js 20
   |
npm ci
   |
npm test
```

Die CI-Konfiguration befindet sich unter:

```text
.github/workflows/ci.yml
```

---

## Continuous Deployment mit Jenkins

Die CD-Pipeline wird mit Jenkins umgesetzt.

### CD-Ablauf

```text
Checkout Code
   |
Install Dependencies
   |
Run Tests
   |
Terraform Apply
   |
Deploy to Azure Function App
```

Jenkins läuft lokal über Docker Compose. Zusätzlich wird ein Custom Jenkins Agent verwendet, der die benötigten Tools für Azure, Terraform und Deployment enthält.

---

## Infrastructure as Code mit Terraform

Terraform wird genutzt, um die benötigte Azure-Infrastruktur bereitzustellen und reproduzierbar zu verwalten.

Beispiele für verwaltete Ressourcen:

- Resource Group
- Storage Account
- Azure Function App
- Application Insights

Die Terraform-Dateien befinden sich im Ordner:

```text
terraform/
```

---

## Monitoring mit Prometheus, Blackbox Exporter und Grafana

Zusätzlich zu Azure Application Insights wird die PokéDelivery API mit Prometheus und Grafana überwacht.

Da Azure Functions nicht automatisch einen klassischen `/metrics` Endpunkt bereitstellen, wird der **Blackbox Exporter** verwendet. Dieser prüft die API von außen über HTTP.

### Monitoring-Architektur

```text
Grafana
   |
   v
Prometheus
   |
   v
Blackbox Exporter
   |
   v
Azure Function API
```

### Überwachter Endpoint

```text
https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

### Prometheus Job

Der Prometheus Job `poke-delivery-api` nutzt den Blackbox Exporter, um den API-Endpunkt regelmäßig zu prüfen.

### Verwendete Prometheus-Metriken

#### API Availability

```promql
probe_success
```

Bedeutung:

```text
1 = API erreichbar
0 = API nicht erreichbar
```

#### Response Time

```promql
probe_duration_seconds
```

Zeigt die Antwortzeit der API in Sekunden.

#### HTTP Status Code

```promql
probe_http_status_code
```

Erwarteter Wert:

```text
200
```

---

## Grafana Dashboard

In Grafana wurde ein Dashboard für die PokéDelivery API erstellt.

### Dashboard Panels

- **PokéDelivery API Availability**
  - Query: `probe_success`
- **PokéDelivery API Response Time**
  - Query: `probe_duration_seconds`
- **PokéDelivery HTTP Status Code**
  - Query: `probe_http_status_code`

Das Dashboard zeigt, ob die API erreichbar ist, wie schnell sie antwortet und welchen HTTP-Statuscode sie zurückgibt.

---

## Docker Compose Umgebung starten

Die lokale DevOps- und Monitoring-Umgebung wird mit Docker Compose gestartet.

```bash
docker compose up -d
```

Container prüfen:

```bash
docker ps
```

Umgebung stoppen:

```bash
docker compose down
```

---

## Lokale URLs

```text
Jenkins:           http://localhost:8080
Prometheus:        http://localhost:9090
Grafana:           http://localhost:3000
Blackbox Exporter: http://localhost:9115
```

---

## Prometheus prüfen

Prometheus Targets öffnen:

```text
http://localhost:9090/targets
```

Erwartete Jobs:

```text
jenkins
poke-delivery-api
```

Der Job `poke-delivery-api` sollte den Status `UP` haben.

---

## Grafana einrichten

Grafana öffnen:

```text
http://localhost:3000
```

Standard Login:

```text
Username: admin
Password: admin
```

Prometheus als Data Source hinzufügen:

```text
http://prometheus:9090
```

Wichtig: Innerhalb von Docker wird nicht `localhost`, sondern der Service-Name `prometheus` verwendet.

---

## API lokal testen

In den API-Ordner wechseln:

```bash
cd api
npm ci
npm test
```

Azure Function lokal starten:

```bash
npm start
```

Lokaler Testaufruf:

```text
http://localhost:7071/api/pokemon/pikachu
```

---

## API in Azure testen

```bash
curl https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

---

## Aktueller Projektstatus

| Bereich | Status |
|---|---|
| REST API | ✅ umgesetzt |
| GitHub Repository | ✅ umgesetzt |
| GitHub Actions CI | ✅ umgesetzt |
| Jenkins CD | ✅ umgesetzt |
| Docker Compose | ✅ umgesetzt |
| Terraform IaC | ✅ umgesetzt |
| Azure Deployment | ✅ umgesetzt |
| Azure Application Insights | ✅ umgesetzt |
| Prometheus Monitoring | ✅ umgesetzt |
| Blackbox Exporter | ✅ umgesetzt |
| Grafana Dashboard | ✅ umgesetzt |

---

## Was ich gelernt habe

- Aufbau einer serverlosen REST-API mit Azure Functions
- GitHub Branching und Pull Request Workflow
- CI mit GitHub Actions
- CD mit Jenkins
- Docker Compose für lokale Infrastruktur
- Custom Jenkins Agent Prinzip
- Infrastructure as Code mit Terraform
- Azure Deployment mit Function Apps
- Monitoring mit Azure Application Insights
- Externes API-Monitoring mit Prometheus Blackbox Exporter
- Grafana Dashboards für Availability, Response Time und HTTP Status Code

---

## Fazit

PokéDelivery zeigt eine vollständige End-to-End DevOps-Umsetzung einer serverlosen Cloud-Anwendung.

Das Projekt kombiniert:

- Softwareentwicklung
- Versionsverwaltung
- Continuous Integration
- Continuous Deployment
- Containerisierung
- Infrastructure as Code
- Cloud Deployment
- Monitoring
- Observability

Damit wurde eine produktionsnahe DevOps-Architektur aufgebaut.
