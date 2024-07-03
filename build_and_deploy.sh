#!/bin/bash
#Exit immediately on error
set -e

# Set script vars
DOCKER_TAG="elastic"
HOST=$DB_IP

chmod -R a+rx ./config

ssh "$PI_USER@$HOST" "sudo mkdir -p /var/elastic/data" || true
ssh "$PI_USER@$HOST" "sudo chmod -R 777 /var/elastic/data" || true

ssh "$PI_USER@$HOST" "sudo mkdir -p /var/elastic/conf" || true
ssh "$PI_USER@$HOST" "sudo chmod -R 777 /var/elastic/conf" || true

echo "Setting builder to default"
docker buildx use default

echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG .

echo "Stopping old container"
ssh "$PI_USER@$HOST" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$HOST" "docker container rm $DOCKER_TAG " || true

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $HOST docker load

echo "Starting Container"
ssh "$PI_USER@$HOST" "docker run -d --network host -e ES_JAVA_OPTS='-Xms1g -Xmx1g' -v /var/elastic/data:/usr/share/elasticsearch/data --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

echo "Removing dangling images"
ssh "$PI_USER@$HOST" 'docker image rm $(docker images -f "dangling=true" -q)'
