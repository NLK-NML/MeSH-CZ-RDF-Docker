# Publish MeSH-CZ using SPARQL server

> Work in progress ... Feedback is kindly welcomed.

This quide deploys [Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/index.html) server in a standalone Docker container.

For production deployment is necessary:
- setup a proxy for the query endpoint and
- setup authorization for the Admin GUI using the proxy or
- setup [Fuseki Authentication](https://jena.apache.org/documentation/fuseki2/fuseki-data-access-control.html#authentication)

## Prerequisites

The fuseki:meshcz Docker image requires 8GB of RAM.
If your system does not have enough memory, modify in the Dockerfile accordingly:

     ENV JAVA_OPTIONS="-Xms8G -Xmx8G"
     ENV JVM_ARGS="-Xmx8G"

Install the following tools if not available on your system.

### Docker Desktop

https://www.docker.com/products/docker-desktop/

## Copy this repo
- into a directory - for example:   **MeSH-CZ-RDF-Docker**

- download:

https://github.com/NLK-NML/MeSH-CZ-RDF-Docker/archive/refs/heads/main.zip

- or clone using Git:

      git clone https://github.com/NLK-NML/MeSH-CZ-RDF-Docker.git

## Start Docker Desktop

When the Docker Desktop is running you can use the following commands.

### Build the image

     docker build -t fuseki:meshcz .

### Re-build the image

     docker build -t fuseki:meshcz . --no-cache
	 docker build -t fuseki:meshcz . --no-cache --build-arg MESH_YEAR=2026

### Run the container - debug

     docker-compose up

> Press CTRL+C to stop

### Run the container as service

     docker-compose up -d

### Stop the container

     docker-compose down

### Install the container

	 docker run -d -p 3030:3030 --name fuseki_meshcz_prod fuseki:meshcz

### Start/stop the container

	 docker start fuseki_meshcz_prod
	 docker stop fuseki_meshcz_prod

### Debug

     docker exec -it fuseki-meshcz sh

# Run some queries

## Prefixes

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
```

## Admin GUI

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

SELECT distinct ?label ?d ?type ?active ?val ?scn ?scnt ?ntx ?lockedBy {
{
SELECT distinct ?d ?type
WHERE {

      (?s ?score) text:query (mesht:queryDef "eye" 500) .

  OPTIONAL {
    BIND(?s as ?d)
    ?s rdf:type ?type .
    ?s rdfs:label ?label .
    FILTER(?type IN(meshv:TopicalDescriptor,meshv:GeographicalDescriptor,meshv:PublicationType,meshv:CheckTag,meshv:Qualifier))
    }
  OPTIONAL {
    ?d meshv:treeNumber ?s .
    ?d rdf:type ?type .
    ?d rdfs:label ?label .
    }
  OPTIONAL {
    ?c meshv:preferredTerm|meshv:term ?s .
    ?d meshv:preferredConcept|meshv:concept ?c .
    ?d rdf:type ?type .
    FILTER(?type IN(meshv:TopicalDescriptor,meshv:GeographicalDescriptor,meshv:PublicationType,meshv:CheckTag,meshv:Qualifier))
    ?c rdf:type ?ctype .
    FILTER(?ctype NOT IN(meshv:SCR_Anatomy, meshv:SCR_Disease, meshv:SCR_Chemical, meshv:SCR_Organism, meshv:SCR_Population, meshv:SCR_Protocol))
    }
  OPTIONAL {
    ?s rdf:type ?stype .
    ?d meshv:preferredConcept|meshv:concept ?s .
    ?d rdf:type ?type .
    FILTER(?stype IN(meshv:Concept))
    }
  OPTIONAL {
    ?c mesht:preferredTerm|mesht:term ?s .
    ?d meshv:preferredConcept|meshv:concept ?c .
    ?d rdf:type ?type .
    }
  OPTIONAL {
    ?d mesht:concept ?s .
    ?d rdf:type ?type .
    }
FILTER (BOUND(?d))
FILTER (?type IN(meshv:TopicalDescriptor,meshv:GeographicalDescriptor,meshv:PublicationType,meshv:CheckTag,meshv:Qualifier))
}
ORDER BY DESC(?score)
  }
  ?d rdfs:label ?label .
  FILTER ( lang(?label) = 'en' )
  ?d meshv:preferredConcept ?c .
  # Assume absence of meshv:active as true
  BIND(IF(EXISTS { ?d meshv:active false }, false, true) AS ?active) .
  OPTIONAL { ?d mesht:lockedBy ?lockedBy }
  OPTIONAL {
    ?c mesht:preferredTerm ?termID .
    ?termID mesht:prefLabel ?val
  }
  OPTIONAL {?c meshv:scopeNote ?scnv .
            BIND('YES' as ?scn)
           }
  OPTIONAL {?c mesht:scopeNote ?scntv
            BIND('YES' as ?scnt)
           }
} LIMIT 500

```

## Query endpoint

http://127.0.0.1:3030/meshcz/query

### Powershell

```
$endpoint = "http://127.0.0.1:3030/meshcz/query"

$query = @"
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
"@

curl -X POST `
  -H "Content-Type: application/sparql-query" `
  --data "$query" `
  $endpoint
```

### Shell

```
#!/bin/bash

ENDPOINT="http://127.0.0.1:3030/meshcz/query"

curl -X POST \
  -H "Content-Type: application/sparql-query" \
  --data-binary @- \
  "$ENDPOINT" <<EOF
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
EOF
```

