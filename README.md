# elasticsearch

### To Regenerate a new password
1. username is "elastic"
1. `docker exec -ti <container_id> /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`

### For first time setup
1. Remove the volume arguments in ./build_and_deploy.sh
1. Run `./build_and_deploy.sh`
1. Run `./elastic_setup.sh`
1. Revert the volume arguments from step 1
1. Run `./build_and_deploy.sh`

### Issues
Cert will expire in 3 years, I can probably find a way to automate the renewal
- look into a volume mount for the certs and look in the usr/share/elasticsearch/bin directory for a tool to renew