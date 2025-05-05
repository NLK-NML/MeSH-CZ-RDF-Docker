# Publishing MeSH-CZ-RDF using a SPARQL server
Container support for MeSH-CZ-RDF

> Work in progress ...

This quide uses Apache Jena Fuseki server - https://jena.apache.org/documentation/fuseki2/index.html

## Prerequisites

Install the following tools if not available on your system.

### Docker Desktop

https://www.docker.com/products/docker-desktop/

## Copy this repo
- into a directory **MeSH-CZ-RDF-Docker**

### Download

https://github.com/NLK-NML/MeSH-CZ-RDF-Docker/archive/refs/heads/main.zip

### Clone using Git

      git clone https://github.com/NLK-NML/MeSH-CZ-RDF-Docker.git

## Start Docker Desktop

### Bootstrap

     docker-compose -f docker-compose.yml build

### Run

     docker-compose -f docker-compose.yml run --rm --service-ports fuseki

### Rebuild with specific versions

     docker-compose -f docker-compose.yml build --no-cache --build-arg JENA_VERSION=5.4.0 --build-arg MESH_YEAR=2025

### Debug

     docker-compose -f docker-compose.yml run --rm -it fuseki sh
