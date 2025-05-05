# Publishing MeSH-CZ-RDF using a SPARQL server
Container support for MeSH-CZ-RDF

> Work in progress ...

This quide uses Apache Jena Fuseki server - https://jena.apache.org/documentation/fuseki2/index.html

## Prerequisites

Install the following tools if not available on your system.

### curl

https://curl.se/download.html

### Git

https://git-scm.com/

### Docker Desktop

https://www.docker.com/products/docker-desktop/

## Clone this repo into a dir 
- ie. MeSH-CZ-RDF-Docker

      git clone https://github.com/NLK-NML/MeSH-CZ-RDF-Docker.git

## Get the MeSH-CZ-RDF dataset

https://github.com/NLK-NML/MeSH-CZ-RDF/blob/main/2025/MeSH-CZ_2025.nq.gz

- place it in the **MeSH-CZ-RDF-Docker/_imports** subdir and
- rename it to: **meshcz.nq.gz**

## Get Jena Fuseki Docker files

https://github.com/apache/jena/tree/main/jena-fuseki2/jena-fuseki-docker

Download the important files with curl - run:

```
curl --ssl-no-revoke -O https://raw.githubusercontent.com/apache/jena/main/jena-fuseki2/jena-fuseki-docker/Dockerfile
curl --ssl-no-revoke -O https://raw.githubusercontent.com/apache/jena/main/jena-fuseki2/jena-fuseki-docker/download.sh
curl --ssl-no-revoke -O https://raw.githubusercontent.com/apache/jena/main/jena-fuseki2/jena-fuseki-docker/entrypoint.sh
curl --ssl-no-revoke -O https://raw.githubusercontent.com/apache/jena/main/jena-fuseki2/jena-fuseki-docker/log4j2.properties
curl --ssl-no-revoke -O https://raw.githubusercontent.com/apache/jena/main/jena-fuseki2/jena-fuseki-docker/pom.xml
```

# Start Docker Desktop

## Build:

     docker-compose -f docker-compose.yml build --build-arg JENA_VERSION=5.4.0

## Import MeSH-CZ dataset

	docker-compose run --rm --service-ports fuseki-init

## Run:

     docker-compose run --rm --service-ports fuseki









