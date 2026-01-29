#!/bin/bash
set -e

if [ -z "$MESH_YEAR" ]; then
  echo "ERROR: MESH_YEAR environment variable is not set"
  exit 1
fi

if [ -z "$DATASETS" ]; then
  echo "ERROR: DATASETS environment variable is not set"
  exit 1
fi

IFS=';' read -r -a datasets <<< "$DATASETS"

for ds in "${datasets[@]}"; do
  IFS='|' read -r src dbn <<< "$ds"
  DATASET_URL=https://github.com/NLK-NML/MeSH-CZ-RDF/raw/refs/heads/main/meshcz/${MESH_YEAR}/${src}.ttl.gz
  DATASET_FILE=${src}.ttl.gz
  DATASET_PATH=${FUSEKI_BASE}/imports/${DATASET_FILE}

  if [ ! -f "$DATASET_PATH" ] || [ "${REFRESH_DATA:-0}" = "1" ]; then
    echo "Downloading dataset $DATASET_URL"
    curl -fL -o $DATASET_PATH "$DATASET_URL"
  fi

  DB_PATH=${FUSEKI_BASE}/databases/${dbn}

  if [ ! -d "$DB_PATH" ] || [ "${REFRESH_STORE:-0}" = "1" ]; then
    tdb2.tdbloader --loc=${DB_PATH} ${FUSEKI_BASE}/imports/${src}.ttl.gz
    echo "Indexing started ..."
    java --add-modules jdk.incubator.vector -cp ${FUSEKI_HOME}/fuseki-server.jar jena.textindexer --desc=${FUSEKI_BASE}/configuration/${dbn}.ttl
  fi

done

# Pass through any command from docker-compose (server or UI)
exec "$@"
