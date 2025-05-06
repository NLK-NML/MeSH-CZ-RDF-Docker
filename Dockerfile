# Updated:  2025-05-06
# syntax=docker/dockerfile:1
# Build image with: docker build -t fuseki:meshcz .

FROM openjdk:21-slim

ARG MESH_YEAR=2025
ENV MESH_YEAR=${MESH_YEAR}

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Jena and Fuseki versions
ENV JENA_VERSION=5.4.0
ENV JENA_HOME=apache-jena-${JENA_VERSION}
ENV FUSEKI_HOME=apache-jena-fuseki-${JENA_VERSION}
ENV FUSEKI_BASE=/fuseki
ENV PATH="${JENA_HOME}/bin:${FUSEKI_HOME}:${PATH}"
ENV JAVA_OPTIONS="-Xms8G -Xmx8G"
ENV JVM_ARGS="-Xmx8G"

# Create directory structure
RUN mkdir -p ${FUSEKI_BASE}/databases/meshcz \
             ${FUSEKI_BASE}/indexes \
             ${FUSEKI_BASE}/_imports \
             ${FUSEKI_BASE}/configuration

RUN chmod -R 777 ${FUSEKI_BASE}

WORKDIR ${FUSEKI_BASE}

# Download and extract Jena + Fuseki
RUN curl -L -o jena.zip https://downloads.apache.org/jena/binaries/${JENA_HOME}.zip && \
    curl -L -o fuseki.zip https://downloads.apache.org/jena/binaries/${FUSEKI_HOME}.zip && \
    unzip jena.zip && unzip fuseki.zip && rm jena.zip fuseki.zip

# Download RDF data and TTL config
RUN curl -L -o _imports/meshcz.nq.gz "https://github.com/NLK-NML/MeSH-CZ-RDF/releases/download/${MESH_YEAR}/meshcz.nq.gz" && \
    curl -L -o configuration/meshcz.ttl "https://raw.githubusercontent.com/NLK-NML/MeSH-CZ-RDF/refs/heads/main/${MESH_YEAR}/meshcz.ttl"

# Load RDF into Fuseki and Index the database
RUN tdb2.tdbloader  \
    --loc=databases/meshcz _imports/meshcz.nq.gz && \
    java --add-modules jdk.incubator.vector \
    -cp ${FUSEKI_HOME}/fuseki-server.jar jena.textindexer \
    --desc=configuration/meshcz.ttl && \
	rm _imports/meshcz.nq.gz

# Expose the Fuseki port
EXPOSE 3030

# Run Fuseki using the baked configuration
#CMD ["sh", "-c", "fuseki-server", "--config=configuration/meshcz.ttl", "--ping"]
CMD ["sh", "-c", "exec java $JVM_ARGS --add-modules jdk.incubator.vector -jar $FUSEKI_HOME/fuseki-server.jar --config=configuration/meshcz.ttl"]

