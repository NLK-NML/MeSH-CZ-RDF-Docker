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

### Build

     docker build -t fuseki:mesh-2025 .

### Re-build

     docker build -t fuseki:mesh-2025 . --no-cache

### Run

     docker run --rm -p 3030:3030 fuseki:mesh-2025 --name fuseki-test

### Debug

     docker exec -it fuseki-test sh
