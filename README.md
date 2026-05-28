# 🚀 PokéDelivery – DevOps CI/CD Projekt

## 📌 Projektübersicht

PokéDelivery ist ein DevOps-Bootcamp-Projekt, in dem eine serverlose REST-API für Pokémon-Daten entwickelt, getestet, automatisiert bereitgestellt und überwacht wird.

Die Anwendung stellt Informationen zu einzelnen Pokémon über einen HTTP-Endpunkt bereit.

---

# 🌐 API Endpoint

```http
GET /api/pokemon/{name}
```

## Beispiel

```http
GET /api/pokemon/pikachu
```

## Finaler Endpoint

```bash
https://salmane-poke-func.azurewebsites.net/api/pokemon/{name}
```

## Beispielaufruf

```bash
https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

---

# 🎯 Ziel des Projekts

Ziel des Projekts ist der Aufbau einer realitätsnahen DevOps-Architektur mit:

- GitHub Versionsverwaltung
- Pull-Request Workflow
- GitHub Actions Continuous Integration
- Jenkins Continuous Deployment
- Docker Compose Infrastruktur
- Custom Jenkins Agent
- Terraform Infrastructure as Code
- Azure Functions Deployment
- Azure Application Insights Monitoring

---

# 🏗️ Architekturübersicht

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
   | Terraform
   v
Azure Infrastructure
   |
   | func publish
   v
Azure Function App
   |
   | Monitoring
   v
Application Insights
```

---

# ⚙️ Eingesetzte Technologien

| Technologie | Zweck |
|---|---|
| GitHub | Versionsverwaltung |
| GitHub Actions | Continuous Integration |
| Jenkins | Continuous Deployment |
| Docker | Containerisierung |
| Docker Compose | Multi-Container Setup |
| Terraform | Infrastructure as Code |
| Azure Functions | Serverless API |
| Azure CLI | Azure Deployment |
| Application Insights | Monitoring |
| Ansible | Infrastrukturautomatisierung |

---

# 📂 Repository-Struktur

```text
Poke-delivery-Praxis-Projekt/
│
├── api/
│   ├── getPokemon/
│   │   ├── index.js
│   │   ├── function.json
│   │   └── test.js
│   ├── host.json
│   ├── package.json
│   └── package-lock.json
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── ansible/
│   ├── inventory
│   └── playbook.yml
│
├── docs/
│
├── docker-compose.yml
├── Dockerfile.agent
└── README.md
```

---

# 🌱 Branching-Strategie

```text
main       → stabiler Branch
develop    → Integrationsbranch
feature/*  → Feature-Branches
```

Änderungen werden ausschließlich über Pull Requests integriert.

---

# 🔄 Continuous Integration

Die CI-Pipeline läuft über GitHub Actions.

## Ablauf

```text
Pull Request / Push
   |
   v
GitHub Actions
   |
   v
npm install / npm ci
   |
   v
npm test
```

## Testausgabe

```bash
getPokemon unit test passed
```

---

# 🚀 Continuous Deployment mit Jenkins

```text
Checkout Code
   |
Install Dependencies
   |
Run Tests
   |
Build
   |
Terraform Apply
   |
Deploy to Azure
```

---

# 🔧 Jenkins Pipeline

## Code Checkout

```groovy
checkout([
  \$class: 'GitSCM',
  branches: [[name: '*/main']],
  userRemoteConfigs: [[
    url: 'https://github.com/Salmane-dev1/Poke-delivery-Praxis-Projekt.git'
  ]],
  extensions: [[\$class: 'CleanBeforeCheckout']]
])
```

## Dependencies installieren

```groovy
dir('api') {
    sh 'npm install'
}
```

## Tests ausführen

```groovy
dir('api') {
    sh 'npm test'
}
```

## Terraform ausführen

```groovy
dir('terraform') {
    sh """
    terraform init

    terraform import azurerm_resource_group.rg \
    /subscriptions/<subscription-id>/resourceGroups/poke-delivery-rg || true

    terraform apply -auto-approve
    """
}
```

## Deployment nach Azure

```groovy
dir('api') {
    sh """
    func azure functionapp publish salmane-poke-func --javascript --force
    """
}
```

---

# 🔐 Authentifizierung mit Azure

```text
Credential ID: azure-sp
```

```groovy
withCredentials([usernamePassword(
    credentialsId: 'azure-sp',
    usernameVariable: 'AZ_CLIENT_ID',
    passwordVariable: 'AZ_CLIENT_SECRET'
)])
```

---

# 🏗️ Infrastructure as Code mit Terraform

## Resource Group

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "poke-delivery-rg"
  location = "Germany West Central"
}
```

## Storage Account

```hcl
resource "azurerm_storage_account" "storage" {
  name                     = "pokedelivery\${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

---

# 📊 Monitoring und Observability

Azure Application Insights überwacht:

- Request Rate
- Request Duration
- Failure Rate
- Exceptions
- Logs
- Live Metrics

---

# 🐳 Docker Compose Setup

```bash
docker compose up -d
```

## Beispiel docker-compose.yml

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
    restart: always

  agent1:
    image: jenkins-agent-azure
    container_name: jenkins-agent-1
    environment:
      - JENKINS_URL=http://jenkins:8080
      - JENKINS_AGENT_NAME=agent1
      - JENKINS_SECRET=\${AGENT1_SECRET}
      - JENKINS_WEB_SOCKET=true
    depends_on:
      - jenkins
    restart: always
```

---

# 🛠️ Aufgetretene Probleme und Lösungen

| Problem | Lösung |
|---|---|
| Agent offline | Agent Secret aktualisiert |
| az: not found | Azure CLI installiert |
| func: not found | Azure Functions Core Tools installiert |
| terraform: not found | Terraform installiert |
| Resource Group existiert | terraform import genutzt |

---

# 📚 Was ich gelernt habe

- CI/CD Architektur verstehen
- Jenkins Agent Prinzip
- Docker Compose Infrastruktur
- Terraform State Management
- Azure Functions Deployment
- Monitoring mit Application Insights
- Infrastructure as Code

---

# ✅ Aktueller Projektstatus

| Bereich | Status |
|---|---|
| REST API | ✅ |
| GitHub Repository | ✅ |
| GitHub Actions CI | ✅ |
| Jenkins CD | ✅ |
| Docker Compose | ✅ |
| Terraform IaC | ✅ |
| Azure Deployment | ✅ |
| Monitoring | ✅ |

---

# ▶️ Projekt ausführen

## Jenkins Umgebung starten

```bash
docker compose up -d
```

## Jenkins öffnen

```text
http://localhost:8080
```

## Pipeline starten

```text
pokedelivery-cd → Build Now
```

---

# 🧪 API testen

```bash
curl https://salmane-poke-func.azurewebsites.net/api/pokemon/pikachu
```

---

# 🏁 Fazit

Das Projekt zeigt eine vollständige End-to-End DevOps-Umsetzung einer serverlosen Cloud-Anwendung.

Das System kombiniert:

- Codeverwaltung
- Continuous Integration
- Continuous Deployment
- Containerisierung
- Infrastructure as Code
- Cloud Deployment
- Monitoring
- Observability

Dadurch wurde eine produktionsnahe DevOps-Architektur aufgebaut.
