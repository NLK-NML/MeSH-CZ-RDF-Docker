# Updated:   2026-01-29

FROM alpine:3.23.3

ENV LANG=C.UTF-8

# Install dependencies
RUN apk add --no-cache bash curl openjdk21-jdk rsync tar

# Jena and Fuseki versions
ENV JENA_VERSION=5.6.0
ENV JENA_HOME=/apache-jena
ENV FUSEKI_HOME=/apache-jena-fuseki
ENV FUSEKI_BASE=/jena-data
ENV PATH="${JENA_HOME}/bin:${FUSEKI_HOME}:${PATH}"

# Download and extract Jena + Fuseki
RUN curl -sL https://downloads.apache.org/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz | tar -xzf - -C /tmp && \
    curl -sL https://downloads.apache.org/jena/binaries/apache-jena-fuseki-${JENA_VERSION}.tar.gz | tar -xzf - -C /tmp && \
    mv /tmp/apache-jena-${JENA_VERSION} ${JENA_HOME} && \
    mv /tmp/apache-jena-fuseki-${JENA_VERSION} ${FUSEKI_HOME}

# Create directory structure
RUN mkdir -p ${FUSEKI_BASE}/configuration \
             ${FUSEKI_BASE}/databases \
             ${FUSEKI_BASE}/imports \
             ${FUSEKI_BASE}/indexes

RUN chmod -R 777 ${FUSEKI_BASE}

WORKDIR ${FUSEKI_BASE}

# Expose the Fuseki port
EXPOSE 3030
