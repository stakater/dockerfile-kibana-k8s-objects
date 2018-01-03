# Dockerfile for submitting kibana objects to ES

This docker image is responsible for submitting index-pattern, search, visualizations, dashboards and anything kibana related, to Elasticsearch. 

### NOTE:
Currently WIP, the objects in `./objects` folder are not compatible with ES & Kibana 6.1. They need to be converted according to the new syntax

## How to run 
```
docker run -it stakater/kibana-k8s-objects
```

### Additional Options:

#### Environment variables:

`ELASTICSEARCH_URL`: URL of Elasticsearch (default: `http://localhost:9200`)

`RETRY_LIMIT`: Number of tries to connect to Elasticsearch before failing (default: `10`)

### Specifying custom objects:

* Volume map the directory `/kibana-objects` to a directory which contains json for your templates, and the correct folder structure.
* The folder structure of `/kibana-objects` directory is important for the `put-objects.sh` to work properly. It should be as follows: 
    * /kibana-objects
        * /_template
        * /dashboard
        * /index-pattern
        * /search
        * /visualization
