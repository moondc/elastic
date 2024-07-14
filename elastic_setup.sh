#!/bin/bash
ssh $PI_USER@$DB_IP << 'EOF'

container_id=$(docker ps -qf "name=elasticsearch")
sudo docker cp -a "$container_id":/usr/share/elasticsearch/config /var/elasticsearch
docker stop "$container_id"
docker container rm "$container_id"

EOF