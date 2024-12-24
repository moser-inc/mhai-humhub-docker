#!/bin/bash

# Check if the SQL file is passed as a parameter
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <path_to_sql_file>"
  exit 1
fi

SQL_FILE="$1"

# Check if the SQL file exists
if [ ! -f "$SQL_FILE" ]; then
  echo "Error: The file $SQL_FILE does not exist."
  exit 1
fi

# MariaDB container name
MARIADB_CONTAINER="humhub-mariadb"

# Check if the container is running
if ! docker ps --format "{{.Names}}" | grep -q "^$MARIADB_CONTAINER$"; then
  echo "Error: The container $MARIADB_CONTAINER is not running."
  exit 1
fi

# Read .env file
if [ ! -f ".env" ]; then
  echo "Error: The .env file was not found."
  exit 1
fi

source .env

DB_USER="$HUMHUB_DOCKER_DB_USER"
DB_PASSWORD="$HUMHUB_DOCKER_DB_PASSWORD"
DB_NAME="humhub"

# Check if variables are set
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Error: Database user or password is not defined in the .env file."
  exit 1
fi

# Get user confirmation
echo "WARNING: The database \"$DB_NAME\" will be dropped and re-imported. Continue? (y/n)"
read -r CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "Action aborted."
  exit 0
fi

# Drop the database
echo "Dropping the database \"$DB_NAME\" in container \"$MARIADB_CONTAINER\" ..."
docker exec -i "$MARIADB_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ $? -ne 0 ]; then
  echo "Error: Dropping or creating the database failed."
  exit 1
fi

# Import the SQL file
echo "Starting import into the container $MARIADB_CONTAINER ..."
cat "$SQL_FILE" | docker exec -i "$MARIADB_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"

if [ $? -eq 0 ]; then
  echo "Database import completed successfully."
else
  echo "Error: Database import failed."
  exit 1
fi
