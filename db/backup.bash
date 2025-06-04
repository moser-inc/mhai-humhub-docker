#!/bin/bash

set -e
# Get the directory where the script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Construct the path to ../backups relative to the script location
BACKUPS_DIR="$SCRIPT_DIR/../backups"

DATE=$(date +"%Y-%m-%d-%H%M%S-%Z")
ENV_NAME="production"

INSTANCE_NAMES=("humhub_mw" "humhub_irn" "humhub_ican" "humhub_ispn" "humhub_icaada" "humhub_infancyonward" "humhub_inalliancepse")

for INSTANCE_NAME in "${INSTANCE_NAMES[@]}"; do
  DB_NAME="${INSTANCE_NAME}_${ENV_NAME}"

  DB_OUT_PATH="${BACKUPS_DIR}/${DB_NAME}-${DATE}.sql.gz"
  FILES_OUT_PATH="${BACKUPS_DIR}/${DB_NAME}-files-${DATE}.zip"

  echo "$(date +"%Y-%m-%d %H:%M:%S") Beginning backup for $DB_OUT_PATH"
  docker compose exec db mariadb-dump --defaults-extra-file=/host/db/db_creds.cnf "$DB_NAME" | gzip -c > "$DB_OUT_PATH"

  echo "$(date +"%Y-%m-%d %H:%M:%S") Beginning backup for $FILES_OUT_PATH"
  docker compose exec "$INSTANCE_NAME" zip -rq - /var/lib/humhub/ > "$FILES_OUT_PATH"

  echo "$(date +"%Y-%m-%d %H:%M:%S") Uploading to S3"
  /usr/local/bin/aws --profile mhai s3 cp "$DB_OUT_PATH" "s3://mhai-humhub-mw-backups/$INSTANCE_NAME/$(basename "$DB_OUT_PATH")"
  /usr/local/bin/aws --profile mhai s3 cp "$FILES_OUT_PATH" "s3://mhai-humhub-mw-files-backups/$INSTANCE_NAME/$(basename "$FILES_OUT_PATH")"

  # Clean up old backups
  ls -tp "${BACKUPS_DIR}/${DB_NAME}"*.sql.gz | grep -v '/$' | tail -n +5 | xargs -I {} rm -- {}
  ls -tp "${BACKUPS_DIR}/${DB_NAME}"*.zip | grep -v '/$' | tail -n +5 | xargs -I {} rm -- {}
done