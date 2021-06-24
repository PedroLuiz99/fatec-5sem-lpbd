#!/bin/bash

set -euo pipefail

main(){
    now=$(date "+%Y%m%d_%H%M%S")

    export PGPASSWORD="${POSTGRES_PASSWORD}"
    logfile="${BACKUP_LOCATION}/backup_log_${now}.log"
    mkdir -p "${BACKUP_LOCATION}"

    echo "Starting backup..." | tee -a "${logfile}"
    pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" | gzip -c > "${BACKUP_LOCATION}/dump_${POSTGRES_DB}_${now}.dump.gz"
    unset PGPASSWORD
    echo "Backup finished!" | tee -a "${logfile}"

    if [[ -z "${RETENTION:=""}" ]]; then
        echo "Retention not configured, skip backup rotation..." | tee -a "${logfile}"
    else
        echo "Rotating backups older than ${RETENTION} days..." | tee -a "${logfile}"
        find ${BACKUP_LOCATION} -type f -ctime +${RETENTION} -print -delete
    fi
    echo "Done!" | tee -a "${logfile}"
    echo -e "\n------\n" | tee -a "${logfile}"
}

main