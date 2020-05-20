#!/bin/sh -ex

#docker build --tag rekgrpth/pgadmin3 .
#docker push rekgrpth/pgadmin3
docker stop pgadmin3 || echo $?
docker rm pgadmin3 || echo $?
docker pull rekgrpth/pgadmin3
docker volume create pgadmin3
docker network create --opt com.docker.network.bridge.name=docker docker || echo $?
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
    --mount type=bind,source=$HOME/.Xauthority,destination=/home/.Xauthority,readonly \
    --mount type=volume,source=pgadmin3,destination=/home \
    --name pgadmin3 \
    --network docker \
    rekgrpth/pgadmin3
