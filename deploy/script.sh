#!/bin/bash

set -ex

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

    # Build container
    ${VAGGA} _build ${CONTAINER_NAME}

    # Get version
    VERSION=`${VAGGA} _version_hash --short ${CONTAINER_NAME}`

    # Copy image to server
    rsync -a \
        --checksum \
        -e "ssh -p $PORT" \
        --link-dest=${LINK_DEST}/ \
        .vagga/${CONTAINER_NAME}/ \
        ${USER}@${SERVER}:${DESTINATION}/${PROJECT}/${CONTAINER_NAME}.${VERSION}

    # Link as latest image
    ssh ${USER}@${SERVER} -p ${PORT} ln -sfn ${CONTAINER_NAME}.${VERSION} ${LINK_DEST}

    # Add to config
    cat <<END | ssh ${USER}@${SERVER} -p ${PORT} tee -a ${DESTINATION}/${PROJECT}/config.yaml
${NAME}:
    kind: Daemon
    instances: 1
    config: /lithos/${TYPE}/${NAME}.yaml
    image: ${CONTAINER_NAME}.${VERSION}
END
}

deploy(){
    # Create dir, if neccessary
    ssh ${USER}@${SERVER} -p ${PORT} mkdir -p ${DESTINATION}/${PROJECT}

    # Remove old config
    ssh ${USER}@${SERVER} -p ${PORT} rm -f ${DESTINATION}/${PROJECT}/config.yaml

    # Sync each container
    for CONTAINER in ${CONTAINERS}; do
        sync_container ${CONTAINER}
    done

    # Switch to new config
    if [ "$DRY_RUN" = "true" ]; then
        echo "Skipped version switch"
    else
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
