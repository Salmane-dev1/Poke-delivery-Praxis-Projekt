# PokéDelivery – DevOps Praxisprojekt

PokéDelivery ist ein DevOps-Praxisprojekt mit einer serverlosen REST-API auf Basis von **Azure Functions** und **Node.js**.

Die Anwendung stellt Pokémon-Informationen über einen HTTP-Endpunkt bereit und wird mit einer vollständigen DevOps-Pipeline entwickelt, getestet, automatisch deployed und überwacht.

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

Ziel des Projekts ist der Aufbau einer praxisnahen DevOps-Architektur mit:

- GitHub Versionsverwaltung
- Branching-Strategie mit Pull Requests
- GitHub Actions für Continuous Integration
- Jenkins für Continuous Deployment
- automatisiertem Jenkins-Start über Bash-Skript
- Docker Compose für lokale Infrastruktur
- Custom Jenkins Agent
- Terraform für Infrastructure as Code auf Azure
- stabilem Terraform Provider Handling im Jenkins-Agent
- Azure Functions als serverlose Laufzeitumgebung
- Azure Application Insights für Cloud Observability
- Prometheus, Blackbox Exporter und Grafana für API-Monitoring

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
- **Azure CLI** – Authentifizierung und Deployment nach Azure
- **Azure Functions Core Tools** – Publishing der Function App
- **Ansible** – Automatisierung der Infrastrukturumgebung
- **Prometheus** – Metriken sammeln
- **Blackbox Exporter** – HTTP-Checks gegen die Azure Function API
- **Grafana** – Visualisierung der Monitoring-Daten
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
├── start.sh                     # Startet Docker Compose und triggert Jenkins automatisch
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

Die CD-Pipeline wird mit Jenkins umgesetzt. Jenkins läuft lokal als Docker-Container und nutzt einen Custom Jenkins Agent für Build-, Test-, Terraform- und Deployment-Schritte.

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

Der Job wird nicht mehr manuell über **Build Now** gestartet, sondern automatisch durch das Startskript `start.sh` ausgelöst.

---

## Automatisierter Start mit `start.sh`

Damit die lokale DevOps-Umgebung reproduzierbar gestartet werden kann, wurde ein Bash-Skript erstellt.

Das Skript übernimmt folgende Aufgaben:

1. Start der gesamten Docker-Compose-Umgebung
2. Laden der Jenkins-Zugangsdaten aus `.env`
3. Warten, bis Jenkins erreichbar ist
4. Abrufen eines Jenkins CSRF-Crumbs
5. Automatisches Auslösen des Jenkins Jobs `pokedelivery-cd`

### Startbefehl

```bash
./start.sh
```

Dadurch werden automatisch gestartet:

- Jenkins
- Jenkins Agent
- Prometheus
- Blackbox Exporter
- Grafana
- Jenkins CD Pipeline

### Inhalt der `.env` Datei

Die Datei `.env` enthält lokale Secrets und darf nicht in GitHub committed werden.

```env
AGENT1_SECRET=<jenkins-agent-secret>
JENKINS_USER=selaouni
JENKINS_API_TOKEN=<jenkins-api-token>
JENKINS_JOB_NAME=pokedelivery-cd
```

### Wichtig

Die `.env` Datei muss in `.gitignore` stehen:

```gitignore
.env
```

### Beispiel `start.sh`

```bash
#!/bin/bash

set -e

echo "======================================"
echo "Starting PokéDelivery DevOps Stack"
echo "======================================"

echo "Starting Docker Compose services..."
docker compose up -d

echo "Loading environment variables from .env..."

if [ -f .env ]; then
  set -a
  source .env
  set +a
else
  echo "ERROR: .env file not found."
  exit 1
fi

if [ -z "$JENKINS_USER" ]; then
  echo "ERROR: JENKINS_USER is missing in .env"
  exit 1
fi

if [ -z "$JENKINS_API_TOKEN" ]; then
  echo "ERROR: JENKINS_API_TOKEN is missing in .env"
  exit 1
fi

if [ -z "$JENKINS_JOB_NAME" ]; then
  echo "ERROR: JENKINS_JOB_NAME is missing in .env"
  exit 1
fi

JENKINS_URL="http://localhost:8080"

echo "Waiting for Jenkins to become reachable..."

until curl -s "$JENKINS_URL/login" > /dev/null; do
  echo "Jenkins is not ready yet. Waiting 10 seconds..."
  sleep 10
done

echo "Jenkins is reachable."

echo "Waiting additional 30 seconds for Jenkins initialization..."
sleep 30

echo "Getting Jenkins crumb..."

CRUMB=$(curl -s   --user "$JENKINS_USER:$JENKINS_API_TOKEN"   "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)")

if [ -z "$CRUMB" ]; then
  echo "ERROR: Could not get Jenkins crumb."
  echo "Check your Jenkins username or API token."
  exit 1
fi

echo "Triggering Jenkins job: $JENKINS_JOB_NAME"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}"   -X POST   "$JENKINS_URL/job/$JENKINS_JOB_NAME/build"   --user "$JENKINS_USER:$JENKINS_API_TOKEN"   -H "$CRUMB")

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
  echo "Jenkins job triggered successfully."
else
  echo "ERROR: Jenkins job trigger failed."
  echo "HTTP status code: $HTTP_CODE"
  echo "Check if the Jenkins job name is correct."
  exit 1
fi

echo "======================================"
echo "PokéDelivery environment is running."
echo "Jenkins job was started automatically."
echo "======================================"
```

### Skript ausführbar machen

```bash
chmod +x start.sh
```

### Ergebnis

Nach dem Ausführen von `./start.sh` wird die gesamte Umgebung gestartet und der Jenkins Job automatisch ausgeführt. Ein manueller Klick auf **Build Now** ist nicht mehr notwendig.

---

## Docker Compose Umgebung

Die lokale DevOps- und Monitoring-Umgebung wird über Docker Compose betrieben.

### Services

- Jenkins Controller
- Jenkins Agent
- Prometheus
- Blackbox Exporter
- Grafana

### Persistente Volumes

Damit Daten nach einem Neustart nicht verloren gehen, werden Docker Volumes verwendet:

- `jenkins_home` für Jenkins Jobs, Plugins, Credentials und Konfiguration
- `prometheus_data` für Prometheus Metriken
- `grafana_data` für Grafana Dashboards und Data Sources

### Umgebung manuell starten

```bash
docker compose up -d
```

### Empfohlener Start

```bash
./start.sh
```

### Container prüfen

```bash
docker ps
```

### Umgebung stoppen

```bash
docker compose down
```

### Wichtig

Nicht verwenden, wenn Volumes erhalten bleiben sollen:

```bash
docker compose down -v
```

Der Parameter `-v` löscht die Docker Volumes und damit z. B. Grafana Dashboards oder Jenkins-Daten.

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

## Terraform Provider Problem und Lösung

Während der Jenkins-CD-Pipeline trat beim Schritt `terraform init` ein Problem auf.

Terraform wollte die benötigten Provider aus der offiziellen Terraform Registry laden:

```text
registry.terraform.io
```

Im Jenkins-Agent-Container kam es dabei zu Timeouts oder Registry-Problemen.

### Fehlermeldung

```text
Failed to query available provider packages
could not connect to registry.terraform.io
Client.Timeout exceeded while awaiting headers
```

### Ursache

Terraform lädt Provider standardmäßig während `terraform init` aus dem Internet. In Container-basierten CI/CD-Umgebungen kann dieser Zugriff durch Netzwerkprobleme, DNS-Probleme, Proxy-Einschränkungen oder Timeouts instabil sein.

### Lösung

Die Lösung war ein lokaler Terraform Provider Mirror im Jenkins-Agent.

Dabei werden die benötigten Provider manuell heruntergeladen und in der Terraform-konformen Ordnerstruktur abgelegt.

### Wichtige Punkte der Lösung

- Provider werden mit `curl` heruntergeladen
- Provider werden lokal im Jenkins-Agent gespeichert
- Terraform wird über `.terraformrc` gezwungen, lokale Provider zu verwenden
- Die Provider-Version muss exakt zur erwarteten Version passen
- Die `.terraform.lock.hcl` wird vor `terraform init` entfernt, um Checksum-Konflikte mit manuell geladenen Providern zu vermeiden

### Terraform Provider Mirror Beispiel

```bash
rm -f /home/jenkins/.terraformrc
rm -rf .terraform
rm -f .terraform.lock.hcl

mkdir -p /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/azurerm/3.117.1/linux_amd64
mkdir -p /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.9.0/linux_amd64

curl -L -o azurerm.zip https://releases.hashicorp.com/terraform-provider-azurerm/3.117.1/terraform-provider-azurerm_3.117.1_linux_amd64.zip
unzip -o azurerm.zip -d azurerm_tmp
mv azurerm_tmp/terraform-provider-azurerm_* /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/azurerm/3.117.1/linux_amd64/
rm -rf azurerm.zip azurerm_tmp

curl -L -o random.zip https://releases.hashicorp.com/terraform-provider-random/3.9.0/terraform-provider-random_3.9.0_linux_amd64.zip
unzip -o random.zip -d random_tmp
mv random_tmp/terraform-provider-random_* /home/jenkins/.terraform.d/plugins/registry.terraform.io/hashicorp/random/3.9.0/linux_amd64/
rm -rf random.zip random_tmp

cat > /home/jenkins/.terraformrc <<'EOF'
provider_installation {
  filesystem_mirror {
    path    = "/home/jenkins/.terraform.d/plugins"
    include = ["registry.terraform.io/hashicorp/*"]
  }

  direct {
    exclude = ["registry.terraform.io/hashicorp/*"]
  }
}
EOF

terraform init
```

### Ergebnis

Nach der Korrektur lief die Jenkins Pipeline erfolgreich grün durch. Terraform konnte initialisiert werden, `terraform apply` wurde ausgeführt und anschließend wurde die Azure Function erfolgreich deployed.

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
   +------------------> Jenkins /prometheus
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

### Prometheus Jobs

Prometheus sammelt zwei Arten von Metriken:

1. Jenkins-Metriken über den Job `jenkins`
2. API-Verfügbarkeit über den Job `poke-delivery-api`

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
| Automatischer Jenkins Start mit `start.sh` | ✅ umgesetzt |
| Docker Compose | ✅ umgesetzt |
| Docker Volumes für Persistenz | ✅ umgesetzt |
| Terraform IaC | ✅ umgesetzt |
| Terraform Provider Mirror Fix | ✅ umgesetzt |
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
- Automatisches Auslösen einer Jenkins Pipeline über die Jenkins REST API
- Nutzung von Jenkins API Token und CSRF Crumb
- Docker Compose für lokale Infrastruktur
- Persistente Docker Volumes für Jenkins, Prometheus und Grafana
- Custom Jenkins Agent Prinzip
- Infrastructure as Code mit Terraform
- Behebung von Terraform Provider Registry Problemen in CI/CD
- Aufbau eines lokalen Terraform Provider Mirrors
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
- automatisierten Pipeline-Start
- Containerisierung
- Infrastructure as Code
- Cloud Deployment
- Monitoring
- Observability

Damit wurde eine produktionsnahe DevOps-Architektur aufgebaut.
