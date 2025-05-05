# Updated: 2025-05-06

# Set default build argument
ARG MESH_YEAR=2025

FROM openjdk:21-slim

# Re-declare ARG after FROM
ARG MESH_YEAR

# Install dependencies and clean up
RUN echo "Installing required components ..." && \
    apt-get update && \
    apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Define environment variables for Jena and Fuseki
ENV JENA_VERSION=5.4.0
ENV JENA_HOME=apache-jena-${JENA_VERSION}
ENV FUSEKI_HOME=apache-jena-fuseki-${JENA_VERSION}
ENV FUSEKI_BASE=/fuseki
ENV PATH="${JENA_HOME}/bin:${PATH}"

RUN mkdir -p ${FUSEKI_BASE}/databases ${FUSEKI_BASE}/configuration ${FUSEKI_BASE}/indexes

# Download and extract Apache Jena and Fuseki
RUN echo "Downloading Jena and Fuseki ..." && \
    curl -L -o jena.zip https://downloads.apache.org/jena/binaries/${JENA_HOME}.zip && \
    curl -L -o fuseki.zip https://downloads.apache.org/jena/binaries/${FUSEKI_HOME}.zip && \
    unzip jena.zip && \
    unzip fuseki.zip && \
    rm jena.zip fuseki.zip

# Download RDF data using MESH_YEAR
RUN echo "Downloading MeSH-CZ RDF data ..." && \
    curl -L -o meshcz.nq.gz "https://github.com/NLK-NML/MeSH-CZ-RDF/releases/download/${MESH_YEAR}/meshcz.nq.gz"

# Download TTL configuration file using MESH_YEAR
RUN echo "Downloading TTL configuration ..." && \
    curl -L -o ${FUSEKI_BASE}/configuration/meshcz.ttl "https://raw.githubusercontent.com/NLK-NML/MeSH-CZ-RDF/refs/heads/main/${MESH_YEAR}/meshcz.ttl"

# Load data into TDB2
RUN echo "Loading data ..." && \
    ${JENA_HOME}/bin/tdb2.tdbloader --loc=${FUSEKI_BASE}/databases/meshcz meshcz.nq.gz

# Index the database
RUN echo "Indexing the database ..." && \
    java --add-modules jdk.incubator.vector -cp ${FUSEKI_HOME}/fuseki-server.jar jena.textindexer --desc=${FUSEKI_BASE}/configuration/meshcz.ttl

# Expose default Fuseki port
EXPOSE 3030

# Start Fuseki server
CMD ["sh", "-c", "${FUSEKI_HOME}/fuseki-server"]
