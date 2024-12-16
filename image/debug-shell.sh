#!/bin/bash

CONTAINER_IMAGE_NAME="humhub/humhub-dev"

# Find containers running with the specified image base name (ignoring the tag)
CONTAINER_IDS=$(docker ps --format "{{.ID}} {{.Image}}" | grep -E "^.+ ${CONTAINER_IMAGE_NAME}(:.+)?$" | awk '{print $1}')

# Check if any containers are running with the specified image name
if [ -z "$CONTAINER_IDS" ]; then
    echo "Error: No container running with image '${CONTAINER_IMAGE_NAME}'."
    exit 1
fi

# Count the number of containers
CONTAINER_COUNT=$(echo "$CONTAINER_IDS" | wc -l)

if [ "$CONTAINER_COUNT" -gt 1 ]; then
    echo "Error: Multiple containers are running with image '${CONTAINER_IMAGE_NAME}'."
    exit 1
fi

# Exactly one container is running, execute the PHP script inside it
CONTAINER_ID=$(echo "$CONTAINER_IDS" | head -n 1)

echo "Executing PHP script in container '${CONTAINER_ID}'..."
docker exec -it "$CONTAINER_ID" /bin/bash