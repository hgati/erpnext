#!/usr/bin/env bash


PROJECT_NAME="${COMPOSE_PROJECT_NAME:-default}"

usage() {
    echo "Named volume backup & restore utility"
    echo "Usage: do <backup|restore>"
    exit
}

_backup() {
    docker volume ls

    docker-compose stop frappe

    docker run -v ${PROJECT_NAME}_frappe-apps-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-apps-volumes
    docker run -v ${PROJECT_NAME}_frappe-logs-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-logs-volumes
    docker run -v ${PROJECT_NAME}_frappe-sites-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_frappe-sites-volumes
    docker run -v ${PROJECT_NAME}_mariadb-data-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        backup ${PROJECT_NAME}_mariadb-data-volumes

    docker-compose start frappe
}

_restore() {
    docker volume ls

    docker-compose stop frappe

    docker run -v ${PROJECT_NAME}_frappe-apps-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-apps-volumes
    docker run -v ${PROJECT_NAME}_frappe-logs-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-logs-volumes
    docker run -v ${PROJECT_NAME}_frappe-sites-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_frappe-sites-volumes
    docker run -v ${PROJECT_NAME}_mariadb-data-volumes:/volume -v $(pwd)/backup:/backup --rm loomchild/volume-backup \
        restore ${PROJECT_NAME}_mariadb-data-volumes

    docker-compose start frappe
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