#!/usr/bin/env bash

CURR_DIR_NAME=${PWD##*/}
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-${CURR_DIR_NAME}}"

docker() {
    if [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        export MSYS_NO_PATHCONV=1
        ("docker.exe" "$@")
        export MSYS_NO_PATHCONV=0
    else
        ("docker" "$@")
    fi
}

usage() {
    echo "Named volume backup & restore utility"
    echo "Usage: do <backup|restore>"
    exit
}

_backup() {
    docker volume ls

    docker-compose stop frappe mariadb

    echo Starting backup
    [[ -d backups ]] || mkdir backups
    docker run -v ${PROJECT_NAME}_frappe-apps-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-apps-volumes
    docker run -v ${PROJECT_NAME}_frappe-logs-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-logs-volumes
    docker run -v ${PROJECT_NAME}_frappe-sites-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-sites-volumes
    docker run -v ${PROJECT_NAME}_mariadb-data-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_mariadb-data-volumes
    echo Finished backup

    docker-compose start frappe mariadb
}

_restore() {
    docker volume ls

    docker-compose stop frappe mariadb

    echo Starting restore
    [[ -d backups ]] || mkdir backups
    docker run -v ${PROJECT_NAME}_frappe-apps-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-apps-volumes
    docker run -v ${PROJECT_NAME}_frappe-logs-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-logs-volumes
    docker run -v ${PROJECT_NAME}_frappe-sites-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-sites-volumes
    docker run -v ${PROJECT_NAME}_mariadb-data-volumes:/volume -v $(pwd)/backups:/backups --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_mariadb-data-volumes
    echo Finished restore

    docker-compose start frappe mariadb
}

sleep 1

if [ $# -ne 1 ]; then
    usage
fi

OPERATION=$1

case "$OPERATION" in
"backup" )
_backup
;;
"restore" )
_restore
;;
* )
usage
;;
esac