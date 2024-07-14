#!/bin/bash
#Exit immediately on error
set -e

# Set script vars
DOCKER_TAG="elasticsearch"
HOST=$DB_IP

ssh "$PI_USER@$HOST" "sudo mkdir -p /var/elasticsearch/data" || true
ssh "$PI_USER@$HOST" "sudo chmod 777 /var/elasticsearch/data" || true
ssh "$PI_USER@$HOST" "sudo mkdir -p /var/elasticsearch/config" || true
ssh "$PI_USER@$HOST" "sudo chmod 777 /var/elasticsearch/config" || true

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
ssh "$PI_USER@$HOST" "docker run -d --network host -e ES_JAVA_OPTS='-Xms1g -Xmx1g' -v /var/elasticsearch/data:/usr/share/elasticsearch/data -v /var/elasticsearch/config:/usr/share/elasticsearch/config --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""
# ssh "$PI_USER@$HOST" "docker run -d --network host -e ES_JAVA_OPTS='-Xms1g -Xmx1g' --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

echo "Removing dangling images"
ssh "$PI_USER@$HOST" 'docker image rm $(docker images -f "dangling=true" -q)'
