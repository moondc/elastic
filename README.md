# elasticsearch

### To Regenerate a new password
1. username is "elastic"
1. `docker exec -ti <container_id> /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`

### For first time setup
1. Remove the volume arguments in ./build_and_deploy.sh
1. Run `./build_and_deploy.sh`
1. SSH into the system
1. Grab the container_id `docker ps`
1. Copy the files to our shared volume dir `docker cp <container_id>:/usr/share/elastic/config /var/elastic`
1. Stop and remove the container `docker stop <container_id> && docker container rm <container_id>`
1. Re-add the volume arguments in ./build_and_deploy.sh
1. Re-run `./build_and_deploy`

This wasn't tested e2e but should theoretically work.  Check the old readme if these don't work

### Issues
Cert will expire in 3 years, I can probably find a way to automate the renewal
- look into a volume mount for the certs and look in the usr/share/elasticsearch/bin directory for a tool to renew