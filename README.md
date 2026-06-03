# PokéDelivery – DevOps Praxisprojekt

PokéDelivery ist ein DevOps-Praxisprojekt mit einer serverlosen REST-API auf Basis von **Azure Functions** und **Node.js**.

Die Anwendung stellt Pokémon-Informationen über einen HTTP-Endpunkt bereit und wird mit einer vollständigen DevOps-Pipeline entwickelt, getestet, automatisiert bereitgestellt und überwacht.

---

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

Ziel des Projekts ist der Aufbau einer praxisnahen, reproduzierbaren DevOps-Architektur mit:

- GitHub Versionsverwaltung
- Branching-Strategie mit Pull Requests
- GitHub Actions für Continuous Integration
- Jenkins für Continuous Deployment
- Jenkins Configuration as Code
- Jenkins Job DSL für automatische Job-Erstellung
- Pipeline as Code mit `Jenkinsfile`
- rollenbasiertem Zugriff auf Jenkins
- automatisiertem Jenkins-Agent
- automatisiertem Start über `start.sh`
- Docker Compose für lokale Infrastruktur
- Terraform für Infrastructure as Code auf Azure
- Azure Functions als serverlose Laufzeitumgebung
- Azure Application Insights für Cloud Observability
- Prometheus, Blackbox Exporter und Grafana für Metriken
- Loki und Promtail für zentrale Container-Logs
- Grafana Provisioning für Data Sources und Dashboards

---

## Technologie-Stack

- **Node.js 20** – Laufzeitumgebung für die API
- **Azure Functions** – Serverlose REST-API
- **GitHub** – Source Control und Pull Requests
- **GitHub Actions** – Continuous Integration
- **Jenkins** – Continuous Deployment
- **Jenkins Configuration as Code** – Jenkins-Konfiguration als Code
- **Job DSL** – Automatische Erstellung des Jenkins Jobs
- **Docker** – Containerisierung
- **Docker Compose** – Orchestrierung der lokalen DevOps- und Monitoring-Umgebung
- **Terraform** – Infrastructure as Code für Azure
- **Azure CLI** – Authentifizierung und Deployment nach Azure
- **Azure Functions Core Tools** – Publishing der Function App
- **Prometheus** – Metriken sammeln
- **Blackbox Exporter** – HTTP-Checks gegen die Azure Function API
- **Grafana** – Visualisierung von Metriken und Logs
- **Loki** – Zentrale Log-Speicherung
- **Promtail** – Einsammeln von Docker-Container-Logs
- **Azure Application Insights** – Cloud Monitoring und Observability
- **Bash** – Automatisierung des lokalen Startprozesses

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
├── jenkins/                     # Jenkins Configuration as Code
│   ├── plugins.txt              # Jenkins Plugins als Code
│   ├── casc/
│   │   └── jenkins.yaml          # Jenkins Security, Credentials, Nodes und Jobs
│   ├── jobs/
│   │   └── pokedelivery-cd.groovy # Job DSL für Jenkins Pipeline Job
│   └── agent/
│       └── start-agent.sh        # Automatische Agent-Verbindung
│
├── grafana/                     # Grafana Provisioning
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml   # Prometheus und Loki Data Sources
│       └── dashboards/
│           ├── dashboards.yml
│           └── pokedelivery-monitoring.json
│
├── monitoring/                  # Monitoring-Konfiguration
│   ├── blackbox/
│   │   └── blackbox.yml
│   ├── loki/
│   │   └── loki-config.yml
│   └── promtail/
│       └── promtail-config.yml
│
├── Jenkinsfile                  # Jenkins Pipeline as Code
├── Dockerfile.jenkins           # Custom Jenkins Controller Image
├── Dockerfile.agent             # Custom Jenkins Agent Image
├── docker-compose.yml           # Lokale DevOps- und Monitoring-Umgebung
├── prometheus.yml               # Prometheus Scrape-Konfiguration
├── start.sh                     # Startet Stack und triggert Jenkins automatisch
├── .env.example                 # Vorlage für lokale Umgebungsvariablen
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
   | Monitoring / Observability
   v
Application Insights + Prometheus + Grafana + Loki
```

---

## Reproduzierbarer Start der Umgebung

Die gesamte lokale DevOps- und Monitoring-Umgebung wird über das Skript `start.sh` gestartet.

### Startbefehl

```bash
./start.sh
```

Das Skript übernimmt automatisch:

1. Laden der lokalen Umgebungsvariablen aus `.env`
2. Build der benötigten Docker Images
3. Start aller Docker-Compose-Services
4. Warten auf Jenkins
5. Warten auf die automatische Jenkins-Konfiguration
6. Warten auf den Jenkins-Agent
7. Abrufen eines gültigen Jenkins CSRF-Crumbs mit Session-Cookie
8. Automatisches Starten des Jenkins Jobs `pokedelivery-cd`

Dadurch ist kein manueller Klick auf **Build Now** notwendig.

---

## Reproduzierbarkeit nach Löschen der Volumes

Das Projekt ist so aufgebaut, dass die Umgebung auch nach einem vollständigen Löschen der Docker Volumes wieder automatisch aufgebaut werden kann.

```bash
docker compose down -v --remove-orphans
./start.sh
```

Nach diesem Rebuild werden automatisch wiederhergestellt:

- Jenkins Plugins
- Jenkins Benutzer
- rollenbasierte Berechtigungen
- Jenkins Credentials
- Jenkins Node `agent1`
- Jenkins Job `pokedelivery-cd`
- Jenkins Agent-Verbindung
- Grafana Data Sources
- Grafana Dashboard
- Prometheus, Loki, Promtail und Blackbox Exporter
- automatischer Start der CD-Pipeline

Dadurch ist das Projekt auch auf einer anderen Maschine reproduzierbar startbar.

---

## Umgebungsvariablen und Secrets

Echte Secrets werden nicht im Repository gespeichert. Dafür wird lokal eine `.env` Datei verwendet.

Als Vorlage dient:

```bash
cp .env.example .env
```

Die `.env` Datei enthält unter anderem:

```env
JENKINS_ADMIN_USER=selaouni
JENKINS_ADMIN_PASSWORD=change-me

JENKINS_MANAGER_USER=manager
JENKINS_MANAGER_PASSWORD=change-me

JENKINS_DEVELOPER_USER=developer
JENKINS_DEVELOPER_PASSWORD=change-me

JENKINS_JOB_NAME=pokedelivery-cd

AZ_CLIENT_ID=your-azure-client-id
AZ_CLIENT_SECRET=your-azure-client-secret
AZURE_TENANT_ID=your-azure-tenant-id
```

Die Datei `.env` ist in `.gitignore` eingetragen und darf nicht committed werden.

---

## Security und rollenbasierter Zugriff

Der Zugriff auf Jenkins ist authentifiziert und rollenbasiert umgesetzt.

Die Benutzer und Berechtigungen werden über Jenkins Configuration as Code in `jenkins/casc/jenkins.yaml` definiert.

| Benutzer | Zugriff |
|---|---|
| anonymous | Kein Zugriff |
| manager | Nur lesender Zugriff |
| developer | Vollzugriff |
| admin user | Vollzugriff |

### Umsetzung

- Anonyme Benutzer erhalten keine Berechtigungen.
- Der Manager-Benutzer kann Jenkins, Jobs, Views und Agent-Status lesen.
- Der Manager-Benutzer kann keine Builds starten und keine Konfiguration ändern.
- Der Developer-Benutzer erhält administrativen Zugriff.
- Der Admin-Benutzer bleibt ebenfalls Administrator.
- Passwörter werden aus `.env` geladen und nicht im Repository gespeichert.

Damit erfüllt das Projekt die Anforderungen an authentifizierten und rollenbasierten Zugriff auf das Continuous-Deployment-System.

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

Die CD-Pipeline wird mit Jenkins umgesetzt. Jenkins läuft als Docker-Container und nutzt einen Custom Jenkins Agent für Build-, Test-, Terraform- und Deployment-Schritte.

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

### Jenkins Job

Der Jenkins Job heißt:

```text
pokedelivery-cd
```

Der Job wird automatisch über Job DSL erstellt und verwendet das `Jenkinsfile` aus dem Repository.

---

## Jenkins Configuration as Code

Jenkins wird möglichst vollständig als Code konfiguriert.

### Bestandteile

- `Dockerfile.jenkins` baut das Jenkins Controller Image.
- `jenkins/plugins.txt` installiert benötigte Jenkins Plugins.
- `jenkins/casc/jenkins.yaml` definiert Security, Benutzer, Rollen, Credentials und Nodes.
- `jenkins/jobs/pokedelivery-cd.groovy` erstellt den Pipeline Job automatisch.
- `Jenkinsfile` beschreibt die eigentliche CD-Pipeline.

Dadurch gehen Jenkins-Konfigurationen nach `docker compose down -v` nicht dauerhaft verloren, sondern werden beim nächsten Start wieder aus dem Repository aufgebaut.

---

## Automatischer Jenkins Agent

Der Jenkins Agent wird ebenfalls automatisiert gestartet.

Früher wurde ein festes Agent Secret in `.env` benötigt. Das ist nach einem vollständigen Rebuild problematisch, weil Jenkins neue Agent-Secrets erzeugt.

Die aktuelle Lösung verwendet:

```text
jenkins/agent/start-agent.sh
```

Das Skript wartet auf Jenkins, ruft das aktuelle Agent Secret über die Jenkins API ab und verbindet den Agent automatisch als `agent1`.

Dadurch ist kein manuell gepflegtes `AGENT1_SECRET` mehr notwendig.

---

## Docker Compose Umgebung

Die lokale DevOps- und Monitoring-Umgebung wird über Docker Compose betrieben.

### Services

- Jenkins Controller
- Jenkins Agent
- Prometheus
- Blackbox Exporter
- Grafana
- Loki
- Promtail

### Volumes

- `jenkins_home` für Jenkins-Daten
- `prometheus_data` für Prometheus-Daten
- `grafana_data` für Grafana-Daten
- `loki_data` für Loki-Logs

### Wichtige Befehle

```bash
./start.sh
```

```bash
docker compose down
```

```bash
docker compose down -v --remove-orphans
```

Der Befehl mit `-v` löscht Volumes. Das Projekt kann danach über `./start.sh` wieder vollständig aus Code aufgebaut werden.

---

## Infrastructure as Code mit Terraform

Terraform wird genutzt, um die Azure-Infrastruktur reproduzierbar zu verwalten.

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

## Terraform Provider Handling im Jenkins-Agent

Während der Jenkins-CD-Pipeline kam es beim Schritt `terraform init` zu Problemen beim Zugriff auf die Terraform Registry.

### Ursache

Terraform lädt Provider standardmäßig aus dem Internet. In containerisierten CI/CD-Umgebungen können Netzwerk-, DNS- oder Timeout-Probleme auftreten.

### Lösung

Im Jenkins-Agent wird ein lokaler Terraform Provider Mirror aufgebaut. Die benötigten Provider werden in einer Terraform-konformen Ordnerstruktur abgelegt und über `.terraformrc` referenziert.

Wichtige Punkte:

- Provider werden gezielt heruntergeladen.
- Provider-Versionen müssen exakt passen.
- Terraform wird auf lokale Provider konfiguriert.
- `.terraform.lock.hcl` wird vor `terraform init` entfernt, um Checksum-Konflikte mit manuell bereitgestellten Providern zu vermeiden.

Dadurch läuft `terraform init` stabil im Jenkins-Agent.

---

## Monitoring und Observability

Das Monitoring besteht aus Metriken und Logs.

### Metriken

Prometheus sammelt:

- Jenkins-Metriken über `/prometheus`
- API-Verfügbarkeit über den Blackbox Exporter

Grafana visualisiert diese Metriken in einem Dashboard.

### Logs

Promtail sammelt Docker-Container-Logs und sendet diese an Loki. Grafana zeigt die Logs zentral über Loki an.

---

## Monitoring-Architektur

```text
Grafana
   |
   +-------------------+
   |                   |
Prometheus            Loki
   |                   |
   |                Promtail
   |                   |
Jenkins Metrics    Docker Logs
Blackbox Checks
   |
Azure Function API
```

---

## Prometheus und Blackbox Exporter

Da Azure Functions keinen nativen Prometheus `/metrics` Endpunkt bereitstellen, wird der Blackbox Exporter verwendet.

Der überwachte Endpoint lautet:

```text
https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

### Wichtige Prometheus Queries

```promql
probe_success
```

```promql
probe_duration_seconds
```

```promql
probe_http_status_code
```

### Jenkins CI/CD Metriken

```promql
sum(jenkins_node_online_value)
```

```promql
sum(jenkins_executor_count_value)
```

```promql
sum(jenkins_executor_free_value)
```

```promql
sum(jenkins_executor_in_use_value)
```

---

## Grafana Provisioning

Grafana wird automatisch über Provisioning konfiguriert.

### Data Sources

Die Datei `grafana/provisioning/datasources/datasources.yml` erstellt automatisch:

- Prometheus
- Loki

### Dashboard

Das Dashboard wird über folgende Datei automatisch geladen:

```text
grafana/provisioning/dashboards/pokedelivery-monitoring.json
```

Das Dashboard enthält Panels für:

- API Availability
- API Response Time
- HTTP Status Code
- Jenkins Online Nodes
- Jenkins Executors
- Jenkins Free Executors
- Jenkins Busy Executors
- Central Container Logs

---

## Lokale URLs

```text
Jenkins:           http://localhost:8080
Prometheus:        http://localhost:9090
Grafana:           http://localhost:3000
Blackbox Exporter: http://localhost:9115
Loki:              http://localhost:3100
Promtail:          http://localhost:9080
```

---

## API lokal testen

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
| Branching und Pull Requests | ✅ umgesetzt |
| GitHub Actions CI | ✅ umgesetzt |
| Jenkins CD | ✅ umgesetzt |
| Jenkins Configuration as Code | ✅ umgesetzt |
| Jenkins Job DSL | ✅ umgesetzt |
| Pipeline as Code | ✅ umgesetzt |
| Automatischer Jenkins Agent | ✅ umgesetzt |
| Rollenbasierter Jenkins-Zugriff | ✅ umgesetzt |
| Secrets außerhalb des Repositories | ✅ umgesetzt |
| Automatischer Start mit `start.sh` | ✅ umgesetzt |
| Docker Compose | ✅ umgesetzt |
| Terraform IaC | ✅ umgesetzt |
| Terraform Provider Mirror Fix | ✅ umgesetzt |
| Azure Deployment | ✅ umgesetzt |
| Azure Application Insights | ✅ umgesetzt |
| Prometheus Monitoring | ✅ umgesetzt |
| Blackbox Exporter | ✅ umgesetzt |
| Grafana Dashboard Provisioning | ✅ umgesetzt |
| Loki und Promtail Logs | ✅ umgesetzt |
| Rebuild nach `docker compose down -v` | ✅ umgesetzt |

---

## Was ich gelernt habe

- Aufbau einer serverlosen REST-API mit Azure Functions
- CI mit GitHub Actions
- CD mit Jenkins
- Jenkins Configuration as Code
- Jenkins Job DSL
- Pipeline as Code mit `Jenkinsfile`
- rollenbasierte Jenkins-Security
- sichere Verwaltung von Secrets über `.env`
- automatisierte Jenkins-Agent-Verbindung
- Docker Compose für reproduzierbare Infrastruktur
- Terraform für Azure Infrastructure as Code
- Behebung von Terraform Provider Registry Problemen
- Monitoring mit Prometheus und Grafana
- externe API-Prüfung mit Blackbox Exporter
- zentrale Logs mit Loki und Promtail
- Grafana Provisioning für Data Sources und Dashboards
- vollständiger Rebuild der Umgebung nach gelöschten Volumes

---

## Fazit

PokéDelivery zeigt eine vollständige End-to-End DevOps-Umsetzung einer serverlosen Cloud-Anwendung.

Das Projekt kombiniert:

- Softwareentwicklung
- Versionsverwaltung
- Continuous Integration
- Continuous Deployment
- Security und rollenbasierten Zugriff
- Containerisierung
- Infrastructure as Code
- automatisierte Jenkins-Konfiguration
- Cloud Deployment
- Monitoring
- zentrale Logs
- Observability

Die Umgebung kann nach einem vollständigen Löschen der Docker Volumes oder auf einer neuen Maschine über `./start.sh` reproduzierbar wieder aufgebaut werden. Damit wurde eine produktionsnahe DevOps-Architektur umgesetzt.
