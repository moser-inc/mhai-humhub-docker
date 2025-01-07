#!/bin/bash

HUMHUB_IMAGE_NAME="humhub/humhub-dev"
MARIADB_IMAGE_NAME="mariadb"

# Function to load environment variables
load_env() {
  if [ ! -f ".env" ]; then
    echo "Error: The .env file was not found."
    exit 1
  fi
  source .env
  DB_USER="$HUMHUB_DOCKER_DB_USER"
  DB_PASSWORD="$HUMHUB_DOCKER_DB_PASSWORD"
  DB_NAME="humhub"

  if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Database user or password is not defined in the .env file."
    exit 1
  fi
}

local container_id
load_container_id() {
    local container_ids
    local IMAGE_NAME="$1"

    # Find containers running with the specified image base name (ignoring the tag)
    container_ids=$(docker ps --format "{{.ID}} {{.Image}}" | grep -E "^.+ ${IMAGE_NAME}(:.+)?$" | awk '{print $1}')

    # Check if any containers are running with the specified image name
    if [ -z "$container_ids" ]; then
        echo "Error: No container running with image '${IMAGE_NAME}'."
        exit 1
    fi

    # Count the number of containers
    CONTAINER_COUNT=$(echo "$container_ids" | wc -l)

    if [ "$CONTAINER_COUNT" -gt 1 ]; then
        echo "Error: Multiple containers are running with image '${IMAGE_NAME}'."
        exit 1
    fi

    container_id=$(echo "$container_ids" | head -n 1)
}



# Function to import a database
command_import_db() {
    load_container_id "$MARIADB_IMAGE_NAME"
    local sql_file="$1"

    if [ ! -f "$sql_file" ]; then
      echo "Error: The file $sql_file does not exist."
      exit 1
    fi

    echo "WARNING: The database $DB_NAME will be dropped and re-imported. Continue? (y/n)"
    read -r confirm
    if [[ "$confirm" != "y" ]]; then
      echo "Action aborted."
      exit 0
    fi

    echo "Dropping the database $DB_NAME in container $container_id ..."
    docker exec -i "$container_id" /bin/mariadb -u "$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

    if [ $? -ne 0 ]; then
      echo "Error: Dropping or creating the database failed."
      exit 1
    fi

    echo "Starting import into the container $container_id ..."
    cat "$sql_file" | docker exec -i "$container_id" /bin/mariadb -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"

    if [ $? -eq 0 ]; then
      echo "Database import completed successfully."
    else
      echo "Error: Database import failed."
      exit 1
    fi
}

# Function to export a database
command_export_db() {
    load_container_id "$MARIADB_IMAGE_NAME"
    local sql_file="$1"

    echo "Exporting the database $DB_NAME from container $MARIADB_CONTAINER to $sql_file ..."
    docker exec "$container_id" /bin/mariadb-dump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$sql_file"

    if [ $? -eq 0 ]; then
      echo "Database export completed successfully."
    else
      echo "Error: Database export failed."
      exit 1
    fi
}

command_debug_shell() {
    load_container_id "$HUMHUB_IMAGE_NAME"

    echo "Executing PHP script in container '${container_id}'..."
    docker exec -it "$container_id" /bin/bash
   
}

command_mariadb_shell() {
  load_container_id "$MARIADB_IMAGE_NAME"

  echo "Executing MariaDB shell in container '${container_id}'..."
  docker exec -it "$container_id" /bin/mariadb -u "$DB_USER" -p"$DB_PASSWORD"
}


#------------------------------------------------------------------------------------------

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <import-db|export-db|debug-shell|mariadb-shell> [path_to_sql_file]"
  exit 1
fi

COMMAND="$1"

load_env

case "$COMMAND" in
  import-db)
    if [ "$#" -lt 2 ]; then
      echo "Error: SQL file is required for import."
      exit 1
    fi
    SQL_FILE="$2"
    command_import_db "$SQL_FILE"
    ;;
  export-db)
    if [ "$#" -lt 2 ]; then
      echo "Error: SQL file is required for export."
      exit 1
    fi
    SQL_FILE="$2"
    command_export_db "$SQL_FILE"
    ;;
  mariadb-shell)
    command_mariadb_shell
    ;;
  debug-shell)
    command_debug_shell
    ;;
  *)
    echo "Error: Unknown command $COMMAND."
    exit 1
    ;;
esac
