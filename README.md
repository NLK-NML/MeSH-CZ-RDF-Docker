# Publishing MeSH-CZ-RDF using a SPARQL server
Container support for MeSH-CZ-RDF

> Work in progress ...

This quide uses Apache Jena Fuseki server - https://jena.apache.org/documentation/fuseki2/index.html

## Prerequisites

Install the following tools if not available on your system.

### Git

https://git-scm.com/

### Docker Desktop

https://www.docker.com/products/docker-desktop/

## Clone or download this repo into a dir
- ie. MeSH-CZ-RDF-Docker

      git clone https://github.com/NLK-NML/MeSH-CZ-RDF-Docker.git

## Start Docker Desktop

### Bootstrap

     docker-compose -f docker-compose.yml build

### Rebuild with specific versions

     docker-compose -f docker-compose.yml build --build-arg JENA_VERSION=5.4.0 --build-arg MESH_YEAR=2025

### Run

     docker-compose -f docker-compose.yml run --rm --service-ports fuseki

### Debug

     docker run --rm -it fuseki sh
