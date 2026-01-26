# Updated:   2026-01-26
# Build the image with:
# docker build -t meshcz-fuseki ./fuseki

FROM debian:stable-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ARG MESH_YEAR=2026
ENV MESH_YEAR=${MESH_YEAR}

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && curl -Lo /tmp/amazon-corretto.deb https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.deb \
    && apt-get install -y --no-install-recommends /tmp/amazon-corretto.deb \
    && rm /tmp/amazon-corretto.deb \
    && rm -rf /var/lib/apt/lists/*

# Jena and Fuseki versions
ENV JENA_VERSION=5.6.0
ENV JENA_HOME=apache-jena
ENV FUSEKI_HOME=apache-jena-fuseki
ENV FUSEKI_BASE=/fuseki
ENV PATH="${JENA_HOME}/bin:${FUSEKI_HOME}:${PATH}"
ENV JAVA_OPTIONS="-Xms8G -Xmx8G"
ENV JVM_ARGS="--add-modules jdk.incubator.vector --enable-native-access=ALL-UNNAMED"

# Create directory structure
RUN mkdir -p ${FUSEKI_BASE}/databases \
             ${FUSEKI_BASE}/indexes \
             ${FUSEKI_BASE}/_imports \
             ${FUSEKI_BASE}/configuration

RUN chmod -R 777 ${FUSEKI_BASE}

WORKDIR ${FUSEKI_BASE}

# Download and extract Jena + Fuseki
RUN curl -L -o jena.zip https://downloads.apache.org/jena/binaries/apache-jena-${JENA_VERSION}.zip && \
    curl -L -o fuseki.zip https://downloads.apache.org/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.zip && \
    unzip jena.zip && unzip fuseki.zip && \
    mv apache-jena-${JENA_VERSION} apache-jena && \
    mv apache-jena-fuseki-${JENA_VERSION} apache-jena-fuseki && \
    rm jena.zip fuseki.zip

# Download the data and Fuseki configs

COPY config/meshcz.ttl configuration/meshcz.ttl
COPY config/skosmos.ttl configuration/skosmos.ttl

# MeSH-CZ RDF
RUN curl -fL -o _imports/meshcz.ttl.gz "https://github.com/NLK-NML/MeSH-CZ-RDF/releases/download/${MESH_YEAR}/MeSH-CZ_${MESH_YEAR}.ttl.gz"

# Load the data into Fuseki and create indices
# MeSH-CZ RDF
RUN tdb2.tdbloader --loc=databases/meshcz _imports/meshcz.ttl.gz && \
    java -cp ${FUSEKI_HOME}/fuseki-server.jar jena.textindexer --desc=configuration/meshcz.ttl && \
    rm _imports/meshcz.ttl.gz

# MeSH-CZ SKOS
RUN curl -fL -o _imports/meshcz-skos.ttl.gz "https://github.com/NLK-NML/MeSH-CZ-RDF/releases/download/${MESH_YEAR}/MeSH-CZ_${MESH_YEAR}_SKOS.ttl.gz"

# MeSH-CZ SKOS
RUN tdb2.tdbloader --graph=http://mesh.medvik.cz/ --loc=databases/skosmos _imports/meshcz-skos.ttl.gz && \
    java -cp ${FUSEKI_HOME}/fuseki-server.jar jena.textindexer --desc=configuration/skosmos.ttl && \
    rm _imports/meshcz-skos.ttl.gz

# Expose the Fuseki port
EXPOSE 3030

# Run Fuseki using the baked configuration
CMD ["sh", "-c", "exec java $JVM_ARGS -jar $FUSEKI_HOME/fuseki-server.jar"]
