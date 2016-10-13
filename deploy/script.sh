#!/bin/bash

set -ex

CONTAINERS=( redis )

while [ $# -gt 0 ]
do
    case "$1" in
        -p|--project)       PROJECT=$2; shift;;
        -d|--destination)   DESTINATION=$2; shift;;
        -c|--containers)    CONTAINERS=$2; shift;;
        -s|--server)        SERVER=$2; shift;;
        -P|--port)          PORT=$2; shift;;
        -u|--user)          USER=$2; shift;;
        -h|--help)          usage;;
        *)                  break;;
    esac
    shift
done

VAGGA=${VAGGA:-vagga}
PORT=${PORT:-22}

usage(){
cat <<'EOT'
Deploy script

Usage:
    ./script.sh \
        --project tabun-trunk \
        --destination /srv/images \
        --server staging.everypony.ru \
        --user deploy \
        --containers "redis app python mysql"

Options:
   -p, --project        Project instance
   -d, --destination    Path to images on server
   -s, --server         Server to deploy
   -P, --port           SSH port
   -u, --user           SSH user
   -h, --help           Show this help
EOT
exit 0;
}

deploy(){
    echo "$PROJECT will be deployed on $SERVER to $DESTINATION"
    echo
    echo "Containers:"
    for CONTAINER in ${CONTAINERS}; do
        echo "    > $CONTAINER"
    done
}

if  [ -z ${PROJECT+x} ] ||
    [ -z ${SERVER+x} ] ||
    [ -z ${USER+x} ] ||
    [ -z ${CONTAINERS+x} ] ||
    [ -z ${DESTINATION+x} ]; then
    usage
else
    deploy
fi
