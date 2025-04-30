#!/bin/bash

set -e
# Get the directory where the script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Construct the path to ../backups relative to the script location
BACKUPS_DIR="$SCRIPT_DIR/../backups"

DATE=$(date +"%Y-%m-%d-%H%M%S")
ENV_NAME="production"

INSTANCE_NAMES=("humhub_mw")

for INSTANCE_NAME in "${INSTANCE_NAMES[@]}"; do
  DB_NAME="${INSTANCE_NAME}_${ENV_NAME}"

  DB_OUT_PATH="${BACKUPS_DIR}/${DB_NAME}-${DATE}.sql.gz"
  FILES_OUT_PATH="${BACKUPS_DIR}/${DB_NAME}-files-${DATE}.zip"

  echo "Beginning backup for $DB_OUT_PATH"
  docker compose exec db mariadb-dump --defaults-extra-file=/host/db/db_creds.cnf "$DB_NAME" | gzip -c > "$DB_OUT_PATH"

  echo "Beginning backup for $FILES_OUT_PATH"
  docker compose exec "$INSTANCE_NAME" zip -rq - /var/lib/humhub/ > "$FILES_OUT_PATH"

  /usr/local/bin/aws --profile mhai s3 cp "$DB_OUT_PATH" s3://mhai-humhub-mw-backups/
  /usr/local/bin/aws --profile mhai s3 cp "$FILES_OUT_PATH" s3://mhai-humhub-mw-files-backups/

  # Clean up old backups
  ls -tp "${BACKUPS_DIR}/${DB_NAME}"*.sql.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
  ls -tp "${BACKUPS_DIR}/${DB_NAME}"*.zip | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
done