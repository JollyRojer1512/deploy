#!/bin/bash

if [ -z "$CONFIG_FILE" ]; then
  echo "ERROR: Необходимо передать переменную окружения CONFIG_FILE (например, dev или prod)."
  exit 1
fi

DEPLOY_CONFIG_FILE="./${CONFIG_FILE}.json"


if [ ! -f "$DEPLOY_CONFIG_FILE" ]; then
  echo "ERROR: Файл конфигурации $DEPLOY_CONFIG_FILE не найден."
  exit 1
fi

SERVICE_NAME=$(jq -r '.name' package.json)

PORT=$(jq -r '.APP_PORT' "$DEPLOY_CONFIG_FILE")
APP_NAME=$(jq -r '.APP_NAME' "$DEPLOY_CONFIG_FILE")
ENTRY_FILE=$(jq -r '.ENTRY_FILE' "$DEPLOY_CONFIG_FILE")
ENV_FILE=$(jq -r '.ENV_FILE' "$DEPLOY_CONFIG_FILE")

IMAGE_NAME="$SERVICE_NAME-$APP_NAME"

export PORT=$PORT
export IMAGE_NAME=$IMAGE_NAME
export SERVICE_NAME="$SERVICE_NAME"
export APP_NAME=$APP_NAME
export ENTRY_FILE=$ENTRY_FILE
export ENV_FILE=$ENV_FILE
export PROJECT_ROOT=$(pwd)

docker-compose -f deploy/docker-compose.yml stop
docker-compose -f deploy/docker-compose.yml rm -f

if docker images | grep -q "$IMAGE_NAME"; then
  docker rmi "$IMAGE_NAME"
fi

docker-compose -f deploy/docker-compose.yml build --build-arg ENTRY_FILE=$ENTRY_FILE

docker-compose -f deploy/docker-compose.yml up -d

docker-compose -f deploy/docker-compose.yml ps
