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

CRUMB=$(curl -s \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

if [ -z "$CRUMB" ]; then
  echo "ERROR: Could not get Jenkins crumb."
  echo "Check your Jenkins username or API token."
  exit 1
fi

echo "Triggering Jenkins job: $JENKINS_JOB_NAME"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  "$JENKINS_URL/job/$JENKINS_JOB_NAME/build" \
  --user "$JENKINS_USER:$JENKINS_API_TOKEN" \
  -H "$CRUMB")

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
