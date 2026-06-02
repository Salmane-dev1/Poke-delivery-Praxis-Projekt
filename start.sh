#!/bin/bash

set -e

echo "======================================"
echo "Starting PokéDelivery DevOps Stack"
echo "======================================"

echo "Loading environment variables from .env..."

if [ -f .env ]; then
  set -a
  source .env
  set +a
else
  echo "ERROR: .env file not found."
  echo "Create .env from .env.example and fill required values."
  exit 1
fi

if [ -z "$JENKINS_ADMIN_USER" ]; then
  echo "ERROR: JENKINS_ADMIN_USER is missing in .env"
  exit 1
fi

if [ -z "$JENKINS_ADMIN_PASSWORD" ]; then
  echo "ERROR: JENKINS_ADMIN_PASSWORD is missing in .env"
  exit 1
fi

if [ -z "$JENKINS_JOB_NAME" ]; then
  echo "ERROR: JENKINS_JOB_NAME is missing in .env"
  exit 1
fi

if [ -z "$AZ_CLIENT_ID" ]; then
  echo "ERROR: AZ_CLIENT_ID is missing in .env"
  exit 1
fi

if [ -z "$AZ_CLIENT_SECRET" ]; then
  echo "ERROR: AZ_CLIENT_SECRET is missing in .env"
  exit 1
fi

if [ -z "$AZURE_TENANT_ID" ]; then
  echo "ERROR: AZURE_TENANT_ID is missing in .env"
  exit 1
fi

echo "Building and starting Docker Compose services..."
docker compose up -d --build

JENKINS_URL="http://localhost:8080"

echo "Waiting for Jenkins to become reachable..."

until curl -s "$JENKINS_URL/login" > /dev/null; do
  echo "Jenkins is not reachable yet. Waiting 10 seconds..."
  sleep 10
done

echo "Jenkins is reachable."

echo "Waiting for Jenkins Configuration as Code and Job DSL initialization..."

MAX_RETRIES=30
RETRY_COUNT=0

until curl -s \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  "$JENKINS_URL/job/$JENKINS_JOB_NAME/api/json" > /dev/null; do

  RETRY_COUNT=$((RETRY_COUNT + 1))

  if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "ERROR: Jenkins job '$JENKINS_JOB_NAME' was not created in time."
    echo "Check Jenkins logs:"
    echo "docker compose logs jenkins"
    exit 1
  fi

  echo "Jenkins job '$JENKINS_JOB_NAME' not ready yet. Waiting 10 seconds..."
  sleep 10
done

echo "Jenkins job '$JENKINS_JOB_NAME' exists."

echo "Waiting for Jenkins agent to connect..."

MAX_RETRIES=30
RETRY_COUNT=0

until curl -s \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  "$JENKINS_URL/computer/agent1/api/json" | grep -q '"offline":false'; do

  RETRY_COUNT=$((RETRY_COUNT + 1))

  if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "ERROR: Jenkins agent 'agent1' did not come online in time."
    echo "Check agent logs:"
    echo "docker compose logs agent1"
    exit 1
  fi

  echo "Jenkins agent 'agent1' not online yet. Waiting 10 seconds..."
  sleep 10
done

echo "Jenkins agent 'agent1' is online."

echo "Getting Jenkins crumb with session cookie..."

COOKIE_FILE="/tmp/jenkins-cookie.txt"

CRUMB=$(curl -s \
  -c "$COOKIE_FILE" \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [ -z "$CRUMB" ]; then
  echo "ERROR: Could not get Jenkins crumb."
  echo "Check Jenkins admin credentials."
  exit 1
fi

echo "Triggering Jenkins job: $JENKINS_JOB_NAME"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  "$JENKINS_URL/job/$JENKINS_JOB_NAME/build" \
  --user "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" \
  -b "$COOKIE_FILE" \
  -H "$CRUMB")

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
  echo "Jenkins job triggered successfully."
else
  echo "ERROR: Jenkins job trigger failed."
  echo "HTTP status code: $HTTP_CODE"
  echo "Check Jenkins job name and credentials."
  exit 1
fi

echo "======================================"
echo "PokéDelivery environment is running."
echo "Jenkins was configured as code."
echo "Jenkins agent connected automatically."
echo "Jenkins job was started automatically."
echo "======================================"
