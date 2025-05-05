# Updated: 2025-05-05

ARG MESH_YEAR=2025
ARG DATA_URL=https://github.com/NLK-NML/MeSH-CZ-RDF/releases/download/${MESH_YEAR}/meshcz.nq.gz

FROM openjdk:21-slim
ARG DATA_URL

RUN echo "Installing required components ..."
RUN apt-get update && \
    apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

ENV JENA_VERSION=5.4.0
ENV JENA_HOME=apache-jena-${JENA_VERSION}
ENV FUSEKI_HOME=apache-jena-fuseki-${JENA_VERSION}

# Download and extract Apache Jena and Fuseki
RUN echo "Downloading Jena ..." && \
    curl -L -o jena.zip https://downloads.apache.org/jena/binaries/${JENA_HOME}.zip && \
    unzip jena.zip && \
    rm jena.zip

# Download and extract Apache Jena Fuseki
RUN echo "Downloading Fuseki ..." && \
    curl -L -o fuseki.zip https://downloads.apache.org/jena/binaries/${FUSEKI_HOME}.zip && \
    unzip fuseki.zip && \
    rm fuseki.zip

# Add Jena binaries to PATH
ENV PATH="${JENA_HOME}/bin:${PATH}"

# Download RDF data
RUN echo "Downloading MeSH-CZ RDF data ..." && \
    mkdir -p /_imports && \
    curl -L -o /_imports/meshcz.nq.gz "$DATA_URL"

# Load data into TDB2
RUN echo "Loading data ..." && \
    ${JENA_HOME}/bin/tdb2.tdbloader --loc=/databases/meshcz /_imports/meshcz.nq.gz

# Index database
RUN echo "Indexing database ..." && \
    java --add-modules jdk.incubator.vector \
    -cp ${FUSEKI_HOME}/fuseki-server.jar \
    jena.textindexer \
    --desc=/configuration/meshcz.ttl || true

EXPOSE 3030

CMD ["sh", "-c", "${FUSEKI_HOME}/fuseki-server"]
