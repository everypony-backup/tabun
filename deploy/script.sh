#!/bin/bash

set -e

while [ $# -gt 0 ]
do
    case "$1" in
        -p|--project)       PROJECT=$2; shift;;
        -d|--destination)   DESTINATION=$2; shift;;
        -c|--containers)    CONTAINERS=$2; shift;;
        -t|--type)          TYPE=$2; shift;;
        -s|--server)        SERVER=$2; shift;;
        -P|--port)          PORT=$2; shift;;
        -u|--user)          USER=$2; shift;;
        -x|--dry-run)       DRY_RUN=true; ;;
        -h|--help)          usage;;
        *)                  break;;
    esac
    shift
done

VAGGA=${VAGGA:-vagga}
PORT=${PORT:-22}
DRY_RUN=${DRY_RUN:-false}
TYPE=${TYPE:-production}

usage(){
cat <<'EOT'
Simple deploy script

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
   -c, --containers     Containers list
   -t, --type           Environment type (trunk/production/testing/etc.)
   -s, --server         Server to deploy
   -P, --port           SSH port
   -u, --user           SSH user
   -x, --dry-run        Switch or not app wersion after deploy
   -h, --help           Show this help
EOT
exit 0;
}

sync_container() {
    local NAME="$1"
    local CONTAINER_NAME=${NAME}-deploy
    local LINK_DEST=${DESTINATION}/${PROJECT}/${CONTAINER_NAME}.latest

    ${VAGGA} _build ${CONTAINER_NAME}

    VERSION=`${VAGGA} _version_hash --short ${CONTAINER_NAME}`
    echo "Got version: ${VERSION}"

    echo "Copying image to server"
    rsync -a \
        --info=progress2 \
        --checksum \
        -e "ssh -p $PORT" \
        --link-dest=${LINK_DEST}/ \
        .vagga/${CONTAINER_NAME}/ \
        ${USER}@${SERVER}:${DESTINATION}/${PROJECT}/${CONTAINER_NAME}.${VERSION}

    echo "Link as latest image ${CONTAINER_NAME}.${VERSION} -> ${LINK_DEST}"
    ssh ${USER}@${SERVER} -p ${PORT} ln -sfn ${CONTAINER_NAME}.${VERSION} ${LINK_DEST}

    echo "Generated config"
    echo
    cat <<END | ssh ${USER}@${SERVER} -p ${PORT} tee -a ${DESTINATION}/${PROJECT}/config.yaml
${NAME}:
    kind: Daemon
    instances: 1
    config: /lithos/${TYPE}/${NAME}.yaml
    image: ${CONTAINER_NAME}.${VERSION}
END
}

deploy(){
    echo "Create dir, if neccessary"
    ssh ${USER}@${SERVER} -p ${PORT} mkdir -vp ${DESTINATION}/${PROJECT}

    echo "Remove old config"
    ssh ${USER}@${SERVER} -p ${PORT} rm -vf ${DESTINATION}/${PROJECT}/config.yaml

    for CONTAINER in ${CONTAINERS}; do
        echo "Syncing ${CONTAINER}"
        echo "===================="
        sync_container ${CONTAINER}
        echo "===================="
    done

    if [ "$DRY_RUN" = "true" ]; then
        echo "Skipped version switch"
    else
        echo "Switch to new config"
        ssh -t ${USER}@${SERVER} -p ${PORT} sudo lithos_switch ${PROJECT} ${DESTINATION}/${PROJECT}/config.yaml
    fi
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
