#!/bin/sh

# Make sure to add the following entry in /etc/default/grub:
#GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

# docker daemon --storage-driver=overlay
docker info
docker pull debian

# building:
docker build --cpu-shares=1 --cpuset-cpus="0-7" --cpuset-mems="0" --memory=8192g -t docker-w4m .
docker run --publish=8889:8889 --log-driver=syslog --volume=/vol:/vol:rw --cpuset-cpus="0-7" --cpuset-mems="0" --memory=8192g --name docker-w4m-run -i -t -d docker-w4m

# manually:
#docker run -P -i -t --name=docker-w4m debian /bin/bash
#docker ps -a
#docker commit docker-test
#docker rmi docker-test

