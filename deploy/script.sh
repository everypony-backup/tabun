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
        *)                  usage;;
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
        --project tabun \
        --type trunk \
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
EOT
exit 0;
}

sync_container() {
    local NAME="$1"
    local CONTAINER_NAME=${NAME}-${TYPE}
    local PROJECT_NAME=${PROJECT}-${TYPE}

    local LINK_DEST=${DESTINATION}/${PROJECT_NAME}/${CONTAINER_NAME}.latest

    ${VAGGA} _build ${CONTAINER_NAME}

    VERSION=`${VAGGA} _version_hash --short ${CONTAINER_NAME}`
    echo "Got version: ${VERSION}"

    echo "Copying image to server"
    rsync -a \
        --info=progress2 \
        --checksum \
        -e "ssh -o TCPKeepAlive=yes -o ServerAliveInterval=5 -p $PORT" \
        --link-dest=${LINK_DEST}/ \
        .vagga/${CONTAINER_NAME}/ \
        ${USER}@${SERVER}:${DESTINATION}/${PROJECT_NAME}/${CONTAINER_NAME}.${VERSION}

    echo "Link as latest image ${CONTAINER_NAME}.${VERSION} -> ${LINK_DEST}"
    ssh ${USER}@${SERVER} -p ${PORT} ln -sfn ${CONTAINER_NAME}.${VERSION} ${LINK_DEST}
}

generate_config() {
    local NAME="$1"
    local CFG="$2"
    local CONTAINER_NAME=${NAME}-${TYPE}

    ${VAGGA} _build ${CONTAINER_NAME}

    VERSION=`${VAGGA} _version_hash --short ${CONTAINER_NAME}`

    cat <<END | tee -a ${CFG}
${NAME}:
    kind: Daemon
    instances: 1
    config: /lithos/${NAME}.yaml
    image: ${CONTAINER_NAME}.${VERSION}
END
}

deploy(){
    local PROJECT_NAME=${PROJECT}-${TYPE}
    echo "Create dir, if neccessary"
    ssh ${USER}@${SERVER} -p ${PORT} mkdir -vp ${DESTINATION}/${PROJECT_NAME}

    for CONTAINER in ${CONTAINERS}; do
        echo "Syncing container ${CONTAINER}"
        echo "===================="
        sync_container ${CONTAINER}
        echo "===================="
    done

    local CONFIG_FILE=$(mktemp)

    for CONTAINER in ${CONTAINERS}; do
        echo "Generating config for ${CONTAINER}"
        echo "===================="
        generate_config ${CONTAINER} ${CONFIG_FILE}
        echo "===================="
    done

    if [ "$DRY_RUN" = "true" ]; then
        echo "Skipped version switch"
    else
        echo "Copy configuration from ${CONFIG_FILE} to server"
        scp -P ${PORT} ${CONFIG_FILE} ${USER}@${SERVER}:/tmp/
        echo "Switch to new config"
        ssh -t ${USER}@${SERVER} -p ${PORT} sudo lithos_switch ${PROJECT_NAME} ${CONFIG_FILE}
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
