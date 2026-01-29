#!/bin/bash
set -e

if [ -z "$DATASET_NAME" ]; then
  echo "ERROR: DATASET_NAME environment variable is not set"
  exit 1
fi

DATASET_PATH="/data/$DATASET_NAME"

# Move into dataset folder
cd "$DATASET_PATH"

DATASET_FILE="${DATASET_NAME}.ttl.gz"

if [ ! -f "$DATASET_FILE" ] || [ "${REFRESH_DATA:-0}" = "1" ]; then
  echo "Downloading dataset $DATASET_FILE ..."
  qlever get-data --log-level WARNING
  echo "Downloading dataset $DATASET_FILE Finished!"
else
  echo "Dataset file $DATASET_FILE already exists."
fi

# Check if the QLever index file exists
INDEX_FILE="${DATASET_NAME}.index.spo"

if [ ! -f "$INDEX_FILE" ] || [ "${REFRESH_STORE:-0}" = "1" ]; then
  echo "Building index in $DATASET_PATH ..."
  qlever index --system native --overwrite-existing --log-level WARNING
  # --text-index from_literals
  echo "Building index in $DATASET_PATH Finished!"
else
  echo "Index file $INDEX_FILE already exists."
fi

# Pass through any command from docker-compose (server or UI)
exec "$@"
