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

  echo "$(date +"%Y-%m-%d %H:%M:%S") Beginning backup for $DB_OUT_PATH"
  docker compose exec db mariadb-dump --defaults-extra-file=/host/db/db_creds.cnf "$DB_NAME" | gzip -c > "$DB_OUT_PATH"

  echo "$(date +"%Y-%m-%d %H:%M:%S") Beginning AWS S3 sync for $INSTANCE_NAME files"
  docker compose exec "$INSTANCE_NAME" aws s3 sync /var/lib/humhub/ s3://mhai-humhub-mw-files-backups/"$INSTANCE_NAME"/

  echo "$(date +"%Y-%m-%d %H:%M:%S") Uploading to S3"
  /usr/local/bin/aws --profile mhai s3 cp "$DB_OUT_PATH" "s3://mhai-humhub-mw-backups/$INSTANCE_NAME/$(basename "$DB_OUT_PATH")"

  # Clean up old backups
  echo "$(date +"%Y-%m-%d %H:%M:%S") Cleaning up old backups of ${DB_NAME}"
  ls -tp "${BACKUPS_DIR}/${DB_NAME}"*.sql.gz | grep -v '/$' | tail -n +5 | xargs -I {} rm -- {}
done