#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/pgadmin3.docker
docker volume create pgadmin
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker stop pgadmin3 || echo $?
docker rm pgadmin3 || echo $?
docker run \
    --detach \
    --env DISPLAY=:0.0 \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --env XAUTHORITY=/home/.Xauthority \
    --hostname pgadmin3 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/tmp/.X11-unix,destination=/tmp/.X11-unix,readonly \
    --mount type=volume,source=pgadmin,destination=/home \
    --name pgadmin3 \
    --network docker \
    ghcr.io/rekgrpth/pgadmin3.docker
