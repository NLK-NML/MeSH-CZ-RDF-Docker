#!/bin/bash
set -e

# ----------------------------
# Environment validation
# ----------------------------
if [ -z "$MESH_YEAR" ]; then
  echo "ERROR: MESH_YEAR environment variable is not set"
  exit 1
fi

if [ -z "$DATASETS" ]; then
  echo "ERROR: DATASETS environment variable is not set"
  exit 1
fi

# Optional: host persistence paths
HOST_IN=${HOST_IN:-/host-data}       # read-only host data copy
HOST_OUT=${HOST_OUT:-/host-data-out} # write-back after loading

IFS=';' read -r -a datasets <<< "$DATASETS"

echo "HOST_PLATFORM: $HOST_PLATFORM"
echo "MESH_YEAR: $MESH_YEAR"
echo "Datasets to process: $DATASETS"
echo "FUSEKI_BASE path: $FUSEKI_BASE"
echo "FUSEKI_HOME path: $FUSEKI_HOME"

# ------------------------------------------
# Copy existing host data if host is Windows
# ------------------------------------------
if [ "${HOST_PLATFORM}" = "WINDOWS" ]; then
  for ds in "${datasets[@]}"; do
    IFS='|' read -r src dbn <<< "$ds"

    # Databases
    if [ -d "${HOST_IN}/databases/${dbn}" ]; then
      echo "Copying database '${dbn}' from host..."
      rsync -a --info=progress2 "${HOST_IN}/databases/${dbn}/" "${FUSEKI_BASE}/databases/${dbn}/"
    fi

    # Indexes
    if [ -d "${HOST_IN}/indexes/${dbn}" ]; then
      echo "Copying indexes '${dbn}' from host..."
      rsync -a --info=progress2 "${HOST_IN}/indexes/${dbn}/" "${FUSEKI_BASE}/indexes/${dbn}/"
    fi

    # Imports
    if [ -f "${HOST_IN}/imports/${src}.ttl.gz" ]; then
      echo "Copying dataset '${src}.ttl.gz' from host..."
      rsync -a --info=progress2 "${HOST_IN}/imports/${src}.ttl.gz" "${FUSEKI_BASE}/imports/"
    fi
  done
fi

# ---------------------------------
# Download/load datasets if missing
# ---------------------------------
for ds in "${datasets[@]}"; do
  IFS='|' read -r src dbn <<< "$ds"
  DATASET_FILE=${src}.ttl.gz
  DATASET_PATH=${FUSEKI_BASE}/imports/${DATASET_FILE}
  DATASET_URL="https://github.com/NLK-NML/MeSH-CZ-RDF/raw/refs/heads/main/meshcz/${MESH_YEAR}/${DATASET_FILE}"

  # Download if missing or refresh requested
  if [ ! -f "$DATASET_PATH" ] || [ "${REFRESH_DATA:-0}" = "1" ]; then
      echo "Downloading dataset $DATASET_URL"
      curl -fL -o "$DATASET_PATH" "$DATASET_URL"
      DATASET_NEW=1
  else
      DATASET_NEW=0
  fi

  DB_PATH=${FUSEKI_BASE}/databases/${dbn}
  IND_PATH=${FUSEKI_BASE}/indexes/${dbn}

  if [ -d "$DB_PATH" ] && ([ "${REFRESH_STORE:-0}" = "1" ] || [ "${DATASET_NEW}" = "1" ]); then
      echo "Cleaning $DB_PATH"
      rm -rf "$DB_PATH"
  fi

  if [ -d "$IND_PATH" ] && ([ "${REFRESH_STORE:-0}" = "1" ] || [ "${DATASET_NEW}" = "1" ]); then
      echo "Cleaning $IND_PATH"
      rm -rf "$IND_PATH"
  fi

  DB_FILE=${DB_PATH}/nodes.dat

  if [ ! -f "$DB_FILE" ] || [ "${REFRESH_STORE:-0}" = "1" ] || [ "${DATASET_NEW}" = "1" ]; then
    if [ "${src}" = "meshcz-skos" ] && [ "${dbn}" = "skosmos" ]; then
        DB_GRAPH="--graph=http://mesh.medvik.cz/"
    else
        DB_GRAPH=""
    fi
    echo "Loading dataset $src into $DB_PATH with graph $DB_GRAPH..."
    tdb2.tdbloader --loc="$DB_PATH" $DB_GRAPH "$DATASET_PATH"

    # Index the dataset using configuration
    DB_CONFIG=${FUSEKI_BASE}/configuration/${dbn}.ttl
    echo "Indexing dataset $dbn using configuration $DB_CONFIG..."
    java --add-modules=jdk.incubator.vector --enable-native-access=ALL-UNNAMED \
         -cp "${FUSEKI_HOME}/fuseki-server.jar" jena.textindexer --desc="$DB_CONFIG"
  fi
done

# ---------------------------------------
# Copy back to host if if host is Windows
# ---------------------------------------
if [ "${HOST_PLATFORM}" = "WINDOWS" ]; then
  if [ -d "$HOST_OUT" ]; then
    echo "Persisting databases, indexes, and imports back to host..."
    rsync -a --info=progress2 "$FUSEKI_BASE/databases/" "$HOST_OUT/databases/"
    rsync -a --info=progress2 "$FUSEKI_BASE/indexes/" "$HOST_OUT/indexes/"
    rsync -a --info=progress2 "$FUSEKI_BASE/imports/" "$HOST_OUT/imports/"
  fi
fi

echo "Staging complete. Container will exit now."
