#!/bin/bash

set -e

echo "======================================"
echo "Starting Jenkins Agent"
echo "======================================"

JENKINS_URL="${JENKINS_URL:-http://jenkins:8080}"
JENKINS_AGENT_NAME="${JENKINS_AGENT_NAME:-agent1}"
JENKINS_AGENT_WORKDIR="${JENKINS_AGENT_WORKDIR:-/home/jenkins/agent}"

echo "Jenkins URL: $JENKINS_URL"
echo "Agent name: $JENKINS_AGENT_NAME"
echo "Agent workdir: $JENKINS_AGENT_WORKDIR"

echo "Waiting for Jenkins to become reachable..."

until curl -s "$JENKINS_URL/login" > /dev/null; do
  echo "Jenkins is not ready yet. Waiting 10 seconds..."
  sleep 10
done

echo "Jenkins is reachable."

echo "Waiting additional 30 seconds for Jenkins Configuration as Code..."
sleep 30

echo "Fetching Jenkins agent secret..."

AGENT_SECRET=$(curl -s \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  "$JENKINS_URL/computer/$JENKINS_AGENT_NAME/jenkins-agent.jnlp" \
  | sed -n 's/.*<argument>\([a-f0-9]*\)<\/argument>.*/\1/p' \
  | head -n 1)

if [ -z "$AGENT_SECRET" ]; then
  echo "ERROR: Could not fetch Jenkins agent secret."
  echo "Check Jenkins admin credentials and whether agent '$JENKINS_AGENT_NAME' exists."
  exit 1
fi

echo "Agent secret fetched successfully."

echo "Starting Jenkins inbound agent..."

exec java -jar /usr/share/jenkins/agent.jar \
  -url "$JENKINS_URL" \
  -secret "$AGENT_SECRET" \
  -name "$JENKINS_AGENT_NAME" \
  -webSocket \
  -workDir "$JENKINS_AGENT_WORKDIR"
