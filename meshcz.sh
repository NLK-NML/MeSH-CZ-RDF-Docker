#!/bin/sh
JENA_VERSION="${JENA_VERSION:-5.4.0}"
echo "Using Jena version: ${JENA_VERSION}"

# Check if curl is already installed to avoid re-installing it
if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  apt-get update -qq && apt-get install -y --no-install-recommends curl
fi

# Download the Jena tools jar if it's not already present
if [ ! -f "fuseki/tools/fuseki-server.jar" ]; then
  echo "Downloading Jena tools..."
  curl -L -o fuseki/tools/fuseki-server.jar "https://repo1.maven.org/maven2/org/apache/jena/jena-fuseki-server/${JENA_VERSION}/jena-fuseki-server-${JENA_VERSION}.jar"
fi

echo "Loading dataset..."
java -cp fuseki/tools/fuseki-server.jar tdb2.tdbloader --loc=fuseki/databases/meshcz fuseki/_imports/meshcz.nq.gz

echo "Running text indexer..."
java -cp fuseki/tools/fuseki-server.jar jena.textindexer --desc=fuseki/configuration/meshcz.ttl
