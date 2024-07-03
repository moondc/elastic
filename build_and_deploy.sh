#!/bin/bash
#Exit immediately on error
set -e

chmod -R a+rx ./config

ssh "$PI_USER@$DB_IP" "sudo mkdir -p /var/elastic/data" || true
ssh "$PI_USER@$DB_IP" "sudo chmod -R 777 /var/elastic/data" || true

ssh "$PI_USER@$DB_IP" "sudo mkdir -p /var/elastic/conf" || true
ssh "$PI_USER@$DB_IP" "sudo chmod -R 777 /var/elastic/conf" || true

# Set script vars
DOCKER_TAG="elastic"

echo "Setting builder to default"
docker buildx use default

echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG .

echo "Stopping old container"
ssh "$PI_USER@$DB_IP" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$DB_IP" "docker container rm $DOCKER_TAG " || true

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $DB_IP docker load

echo "Starting Container"
ssh "$PI_USER@$DB_IP" "docker run -d --network host -m 1GB -v /var/elastic/data:/usr/share/elasticsearch/data --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

echo "Removing dangling images"
ssh "$PI_USER@$DB_IP" 'docker image rm $(docker images -f "dangling=true" -q)'
