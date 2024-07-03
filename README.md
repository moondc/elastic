# elasticsearch

Running elasticsearch for the first time will auto generate a password.  Since we strive to do things running docker detached (-d) we will need to perform some additional steps to get things stable.

### Generate the local files you need
1. Hack things to get elasticsearch running on your system, you might be able to go into the build_and_deploy and remove the -volumes and remove the copy commands from the dockerfile then run ./build_and_deploy
1. SSH into the system
1. In the SSH terminal, get the running container_id `docker ps`
1. In the SSH terminal, create a temp location to store the file `sudo mkdir /usr/temp`
1. In the SSH terminal, give everything write access `sudo chmod 777 /usr/temp`
1. In the SSH terminal, docker copy to the local device system `docker cp <container name>:/usr/share/elasticsearch/config /usr/temp`
1. In a new terminal, copy the remote files to your localhost `scp -r pi@192.168.1.1:/usr/temp /this_repository/config`
1. In your local repo, clean up any extra folders that were created.  Your local directory should look like elastic/config/elasticsearch.keystore
1. In the SSH terminal, stop and remove the running container `docker stop <container_id> && docker container rm <container_id>
1. In the SSH terminal, delete the temp files from the remote host `rm -rf /usr/temp`

### Run elastic and create new passwords and tokens
Anytime a new container is created, these steps will need to be ran
1. In the local terminal, undo all changes to the repo and run ./build_and_deploy
1. In the SSH terminal, get the new container_id `docker ps`
1. In the SSH terminal, generate a new password `docker exec -ti <container_id> /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`
1. In the SSH terminal, create a new kibana enrollment token `docker exec -ti <container_id> /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana`

This wasn't tested e2e but should theoretically work.

### Issues
Cert will expire in 3 years, I can probably find a way to automate the renewal
- look into a volume mount for the certs and look in the usr/share/elasticsearch/bin directory for a tool to renew