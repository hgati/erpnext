#!/bin/bash

# usage infomation
usage() {
    echo "Named volume backup & restore utility"
    echo "Usage: sudo frank.sh <backup|restore|delete> <options>"
}

# variable
STACK_NAME="s1"
BASE_BACKUP_DIR="/backup"
FOLDER_RETAIN_DAYS="7"

backup() {
	BACKUP_DATE=`date '+%Y-%m-%d-%H%M%S'`
	BACKUP_DIR="${BASE_BACKUP_DIR}/${BACKUP_DATE}"

	# put output of docker volume into name_volumes array
	# -q quiet will show only name
	# -f filter will filter name with STACK_NAME
	mapfile -t NAME_VOLUMES < <(docker volume ls -q -f "name=${STACK_NAME}_")
	if [[ ${#NAME_VOLUMES[@]} -eq 0 ]]; then
		echo "Error: Not found volume"
		return 0
	fi

	# make folder
	mkdir -p ${BACKUP_DIR}
	if [[ ! -d ${BACKUP_DIR} ]]; then
		echo "Error: Cannot create folder"
		return 0
	fi

	# backup
	echo "Starting backup ${BACKUP_DATE}"
	# loop through array
	for NAME_VOLUME in "${NAME_VOLUMES[@]}"
	do
		echo "Backing up ${NAME_VOLUME}"
		# backup docker volume using loomchild/volume-backup docker image
		docker run --rm \
		-v ${NAME_VOLUME}:/volume \
		-v ${BACKUP_DIR}:/backup \
		loomchild/volume-backup \
		backup \
		${NAME_VOLUME}
	done
	cp "${BASE_BACKUP_DIR}/backup_logs.txt" "${BACKUP_DIR}/logs.txt"
	return 1
}

restore() {
	BACKUP_DIR="${BASE_BACKUP_DIR}/${BACKUP_FOLDER}"

	# check folder
	if [[ ! -d ${BACKUP_DIR} ]]; then
		echo "Error: Folder not found"
		return 0
	fi

	# get file in backup into array
	shopt -s extglob nullglob
	TAR_VOLUMES=(${BACKUP_DIR}/*.tar.bz2)
	shopt -u extglob nullglob
	if [[ ${#TAR_VOLUMES[@]} -eq 0 ]]; then
		echo "Error: TAR file not found"
		return 0
	fi

	# restore
	echo "Starting restore"
	# loop through array
	for TAR_VOLUME in "${TAR_VOLUMES[@]}"
	do
		echo "Restoring ${TAR_VOLUME}"
		FILE=$(basename -- "${TAR_VOLUME}")
		FILE_NAME="${FILE%%.*}"
		# restore docker volume using loomchild/volume-backup docker image
		cat ${TAR_VOLUME} | docker run -i --rm \
		-v ${FILE_NAME}:/volume \
		loomchild/volume-backup \
		restore \
		-
	done
	return 1
}

delete() {
	# get folder name in base_backup_dir
	shopt -s extglob nullglob
	BACKUP_FOLDER_NAMES=(${BASE_BACKUP_DIR}/*/)
	shopt -u extglob nullglob

	# loop through folder
	for FOLDER_PATH in "${BACKUP_FOLDER_NAMES[@]}"
	do
		FOLDER_NAME=$(basename -- "${FOLDER_PATH}")
		FOLDER_DATE=${FOLDER_NAME:0:10}
		FOLDER_AGE=$(datediff ${FOLDER_DATE})
		if [[ "${FOLDER_AGE}" -gt "${FOLDER_RETAIN_DAYS}" ]]; then
			# never delete folder younger that 3 days
			if [[ "${FOLDER_AGE}" -gt "3" ]]; then
				echo "Delete folder ${FOLDER_PATH}"
				sudo rm -rf "${FOLDER_PATH}"
			fi
		fi
	done
	return 1
}

datediff() {
	# calculate date diff
	# Usage: datediff "2018-07-15" "2018-07-01"

	D1=$(date -d "$1" +%s)
	# if there're only one arguments it will calculate datediff from today
	if [[ -z $2 ]]; then
		D2=$(date +%s)
	else
		D2=$(date -d "$2" +%s)
	fi

	# return value in days
	echo $(( ((D1-D2) > 0 ? (D1-D2) : (D2-D1)) / 86400 ))
}

# command
case $1 in
	"backup")
		backup > "${BASE_BACKUP_DIR}/backup_logs.txt"
		;;
	"restore")
		if [[ -z $2 ]]; then
			echo "Error: Specify folder name"
			echo "Usage: sudo frank.sh restore 2018-07-20-161800"
		else
			BACKUP_FOLDER=$2
			restore
		fi
		;;
	"delete")
		delete > "${BASE_BACKUP_DIR}/delete_logs.txt"
		;;
	*)
		usage
		;;
esac