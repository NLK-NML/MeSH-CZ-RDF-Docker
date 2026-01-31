#!/bin/bash
set -e
set -o pipefail

if [ -z "$DATASETS" ]; then
  echo "ERROR: DATASETS environment variable is not set"
  exit 1
fi

if [ -z "$QLEVER_BASE" ]; then
  echo "ERROR: QLEVER_BASE environment variable is not set"
  exit 1
fi

# Optional: host persistence paths
HOST_IN=${HOST_IN:-/host-data}       # read-only host data copy
HOST_OUT=${HOST_OUT:-/host-data-out} # write-back after loading

IFS=';' read -r -a datasets <<< "$DATASETS"

echo "HOST_PLATFORM: $HOST_PLATFORM"
echo "Datasets to process: $DATASETS"
echo "QLEVER_BASE path: $QLEVER_BASE"

command -v qlever >/dev/null || { echo "ERROR: qlever not found"; exit 1; }

for dbn in "${datasets[@]}"; do

  DATASET_PATH="${QLEVER_BASE}/${dbn}"
  DATASET_FILE=${dbn}.ttl.gz

  echo "Processing dataset: $DATASET_PATH"

  mkdir -p "$DATASET_PATH"

  cp -r "/qlever-config/${dbn}/." "$DATASET_PATH/" || {
    echo "ERROR: Failed to copy files for $dbn" >&2
    exit 1
  }

  # ------------------------------------------
  # Copy existing host data if host is Windows
  # ------------------------------------------
  if [ "${HOST_PLATFORM}" = "WINDOWS" ]; then
      if [ -d "${HOST_IN}/databases/${dbn}" ]; then
        echo "Copying database $dbn from host..."
        rsync -a --info=progress2 "${HOST_IN}/${dbn}/" "${DATASET_PATH}/"
      fi
  fi

  pushd "$DATASET_PATH" >/dev/null

  # Download if missing or refresh requested
  if [ ! -f "$DATASET_FILE" ] || [ "${REFRESH_DATA:-0}" = "1" ]; then
      echo "Downloading dataset $dbn ..."
      qlever get-data --log-level WARNING
      echo "Downloading dataset $dbn Finished!"
      DATASET_NEW=1
  else
      DATASET_NEW=0
  fi

  if [ "${REFRESH_STORE:-0}" = "1" ] || [ "${DATASET_NEW}" = "1" ]; then
    echo "Building index in $DATASET_PATH ..."
    qlever index --system native --overwrite-existing --log-level WARNING
    # --text-index from_literals
    echo "Building index in $DATASET_PATH Finished!"
  fi

  # ---------------------------------------
  # Copy back to host if if host is Windows
  # ---------------------------------------
  if [ "${HOST_PLATFORM}" = "WINDOWS" ]; then
    if [ -d "$HOST_OUT" ]; then
      echo "Persisting QLever data back to host..."
      rsync -a --info=progress2 "$DATASET_PATH/" "$HOST_OUT/${dbn}/"
    fi
  fi

  popd >/dev/null

done

echo "Staging complete. Container will exit now."
