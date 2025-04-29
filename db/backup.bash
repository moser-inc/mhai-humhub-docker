#!/bin/bash

set -e
# Get the directory where the script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Construct the path to ../backups relative to the script location
BACKUPS_DIR="$SCRIPT_DIR/../backups"

DATE=`date +"%Y-%m-%d-%H%M%S"`

DB_NAMES=("humhub_mw_production")

for DB_NAME in "${DB_NAMES[@]}"; do

  OUT_PATH="${BACKUPS_DIR}/${DB_NAME}-${DATE}.sql.gz"
  echo "Beginning backup for ${OUT_PATH}"
  docker compose exec db mariadb-dump --defaults-extra-file=/host/db/db_creds.cnf ${DB_NAME} | gzip -c > $OUT_PATH

  ls -tp ${BACKUPS_DIR}/${DB_NAME}*.sql.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}

  /usr/local/bin/aws --profile mhai s3 cp $OUT_PATH s3://mhai-humhub-mw-backups/

done