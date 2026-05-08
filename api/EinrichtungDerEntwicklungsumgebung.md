# Azure Functions: Pokémon API Deployment Guide

Diese Dokumentation beschreibt die vollständige Einrichtung der Entwicklungsumgebung, den lokalen Workflow und das Deployment der Node.js-basierten Pokémon-API auf Microsoft Azure – optimiert für **Windows** und **Ubuntu/Linux**.

---

## 📂 Projektstruktur & Pfad
Alle Befehle müssen im Stammverzeichnis der API ausgeführt werden.

**Lokaler Basispfad:** `.../Poke-delivery-Praxis-Projekt/api`

---

## 🛠 1. Installation der Umgebung

Wähle die Anleitung passend zu deinem Betriebssystem:

### A) Windows (via PowerShell)
# Azure CLI installieren
winget install -e --id Microsoft.AzureCLI

# Node.js LTS installieren
winget install -e --id OpenJS.NodeJS.LTS

# Azure Functions Core Tools installieren
npm install -g azure-functions-core-tools@4 --unsafe-perm true

### B) Ubuntu / Linux (via Terminal)
# 1. Node.js & npm installieren
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Microsoft Repository & Azure CLI installieren
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# 3. Azure Functions Core Tools installieren
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install azure-functions-core-tools-4

### Gemeinsame VS Code Erweiterungen (beide Systeme)
# Azure Tools Extension Pack
code --install-extension ms-vscode.vscode-node-azure-pack

# NPM Intellisense
code --install-extension christian-kohler.npm-intellisense

---

## 💻 2. Lokaler Workflow & Test

1. **In das Verzeichnis navigieren:**
   - Windows: `cd C:\Pfad\zu\deinem\Projekt\api`
   - Ubuntu: `cd ~/Pfad/zu/deinem/Projekt/api`

2. **Abhängigkeiten installieren:**
   npm install

3. **Lokalen Server starten:**
   func start

4. **Test-Endpunkt:**
   Lokal erreichbar unter: `http://localhost:7071/api/getPokemon?name=bulbasaur`

---

## ☁️ 3. Azure Cloud Deployment

### Schritt 1: Authentifizierung
Die Anmeldung erfolgt über die spezifische Tenant-ID deines Azure-Accounts:
az login --tenant <DEINE_TENANT_ID>

### Schritt 2: Azure Infrastruktur erstellen (Einmalig)
Bevor der Code veröffentlicht werden kann, müssen die Ressourcen in Azure existieren (via CLI oder Azure Portal):

# 1. Ressourcengruppe erstellen
az group create --name <RESOURCE_GROUP_NAME> --location <REGION>

# 2. Storage Account erstellen (Name muss weltweit eindeutig sein)
az storage account create --name <STORAGE_NAME> --location <REGION> --resource-group <RESOURCE_GROUP_NAME> --sku Standard_LRS

# 3. Function App erstellen
az functionapp create --resource-group <RESOURCE_GROUP_NAME> --consumption-plan-location <REGION> --runtime node --runtime-version 18 --functions-version 4 --name <DEIN_FUNCTION_APP_NAME> --storage-account <STORAGE_NAME>

### Schritt 3: Veröffentlichung (Deployment)
Führe diesen Befehl im `api`-Ordner aus, um deinen Code auf die bestehende Function App hochzuladen:
func azure functionapp publish <DEIN_FUNCTION_APP_NAME>

---

## 🚀 4. Live API-Endpunkt
Nach dem Deployment ist die Funktion unter der von Azure generierten URL erreichbar:

**URL-Format:** `https://<app-name>.azurewebsites.net/api/getPokemon`

---

## 📋 5. Konfigurations-Übersicht (Anonymisiert)

| Eigenschaft | Wert |
| :--- | :--- |
| **Projekt-Typ** | Azure Functions (Node.js) |
| **Unterstützte OS** | Windows 10/11, Ubuntu 20.04+ |
| **Azure Region** | <Deine-Azure-Region> (z.B. Canada Central) |
| **App Name** | <Dein-Eindeutiger-App-Name> |
| **Tenant ID** | <Anonymisierte-Tenant-ID> |

---

> **Wichtiger Hinweis:** Bei jeder Änderung am Quellcode (z.B. in der `index.js`) muss der Befehl `func azure functionapp publish` erneut ausgeführt werden, um die Änderungen in der Cloud zu aktivieren. Die Infrastruktur (Schritt 2) muss dabei nicht erneut erstellt werden.