#!/usr/bin/env bash
set -e

APP="classes config engine templates index.php"

usage(){
cat <<'EOT'
Deploy Tabun

Usage:
    ./deploy.sh \
        --chroot /home/ep/tabun.everypony.ru \
        --static /home/ep/cdn.everypony.ru/www/static \
        --app-perms ep_tabun:ep_tabun \
        --static-perms ep:ep

Options:
   -h, --help           Show this message and exit
   -c, --chroot         Path to chroot
   -s, --static         Path to static dir
   -a, --app-perms      App files permissions
   -p, --static-perms   Static files permissions
EOT
exit 0;
}

clean_source () {
    git reset --hard
    git fetch
    git pull
    npm prune
    npm install
    npm run-script clean
}

deploy(){
    local APP_PATH=${CHROOT_PATH}/www

    echo "Sources cleanup"
    clean_source
    local APP_VER=$(git name-rev --tags --name-only $(git rev-parse HEAD))

    echo "Build static"
    npm run-script webpack:production
    local STATIC_VER=$(grep -Po '(?:"hash"):.*?[^\\]"' static/stats.json | perl -pe 's/"hash"://; s/"//g')
    rm static/stats.json

    echo "Remove app"
    rm -rf ${APP_PATH}/*
    echo "Clean temporary files"
    rm -rf ${CHROOT_PATH}/tmp/*
    echo "Clean smarty pre-compiled templates"
    rm -rf ${CHROOT_PATH}/var/smarty/*
    echo "Clean static bundles & files"
    rm -rf ${STATIC_PATH}/*

    echo "Deploy static"
    rsync -au static/ ${STATIC_PATH}
    cp -r frontend/images/local/ ${STATIC_PATH}

    echo "Deploy app"
    for chunk in ${APP}; do
        cp -r ${chunk} ${APP_PATH}
    done

    echo "Set static version to ${STATIC_VER}"
    sed -i "s/\$config\['misc'\]\['ver'\]\['front'\].*/\$config\['misc'\]\['ver'\]\['front'\] = '"${STATIC_VER}"';/g" ${CHROOT_PATH}/etc/config.stable.php
    echo "Set app version to ${APP_VER}"
    sed -i "s/\$config\['misc'\]\['ver'\]\['code'\].*/\$config\['misc'\]\['ver'\]\['code'\] = '"${APP_VER}"';/g" ${CHROOT_PATH}/etc/config.stable.php

    echo "Set owner and permissions"
    chown ${APP_PERMS} ${APP_PATH} -R
    chown ${STATIC_PERMS} ${STATIC_PATH} -R
    find ${APP_PATH} -type f | xargs chmod 440
    find ${STATIC_PATH} -type f | xargs chmod 440
    find ${APP_PATH} -type d | xargs chmod 550
    find ${STATIC_PATH} -type d | xargs chmod 550

    echo "Restart services"
    systemctl restart memcached
    systemctl reload php5-fpm

    echo "Sources cleanup"
    clean_source
}


[ $# -eq 0 ] && usage

while [ $# -gt 0 ]
do
    case "$1" in
        -c|--chroot) CHROOT_PATH=$2; shift;;
        -s|--static) STATIC_PATH=$2; shift;;
        -a|--app-perms) APP_PERMS=$2; shift;;
        -p|--static-perms) STATIC_PERMS=$2; shift;;
        -h|--help) usage;;
        *) break;;
    esac
    shift
done

if [ -z ${CHROOT_PATH+x} ] || [ -z ${STATIC_PATH+x} ] || [ -z ${APP_PERMS+x} ] || [ -z ${STATIC_PERMS+x} ]; then
    usage
else
    deploy
fi