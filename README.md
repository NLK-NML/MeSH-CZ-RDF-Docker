# Publish MeSH-CZ using SPARQL server
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

### Build the image

     docker build -t fuseki:meshcz .

### Re-build the image

     docker build -t fuseki:meshcz . --no-cache --build-arg MESH_YEAR=2025

### Run the container - debug

     docker-compose up

Press CTRL+C to stop

### Run the container as service

     docker-compose up -d

### Stop the container

     docker-compose down

### Debug

     docker exec -it fuseki-meshcz sh

# Run some queries

http://127.0.0.1:3030/#/dataset/meshcz/query

```
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#>
PREFIX owl:  <http://www.w3.org/2002/07/owl#>
PREFIX meshv:  <http://id.nlm.nih.gov/mesh/vocab#>
PREFIX mesh:   <http://id.nlm.nih.gov/mesh/>
PREFIX text:   <http://jena.apache.org/text#>
PREFIX meshx:  <http://mesh.medvik.cz/link/>
PREFIX mesht:  <http://www.medvik.cz/schema/mesh/vocab/#>

SELECT ?s ?p ?o
WHERE {
  ?s ?p ?o .
}
LIMIT 10
```




