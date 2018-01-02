#!/bin/bash

set -exo pipefail

retries=${RETRY_LIMIT:-10};
ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-http://localhost:9200}

if [ -n "${ELASTICSEARCH_SERVICE_NAME}" ]; then
    SVC_HOST=${ELASTICSEARCH_SERVICE_NAME}_SERVICE_HOST
    SVC_PORT=${ELASTICSEARCH_SERVICE_NAME}_SERVICE_PORT
    ELASTICSEARCH_URL=http://${!SVC_HOST}:${!SVC_PORT}
fi

# Wait for ES to start up properly
until $(curl -s -f -o /dev/null --connect-timeout 1 -m 1 --head ${ELASTICSEARCH_URL}); do
    sleep 0.1;
    retries=$(($retries-1))
    
    if [[ ${retries} -eq 0 ]]; 
    then 
        echo "Cannot connect to Elasticsearch at ${ELASTICSEARCH_URL}: Retry limit reached";
        exit 1;
    fi
done

if ! [ $(curl -s -f -o /dev/null ${ELASTICSEARCH_URL}/.kibana) ]; then
    #curl -s -f -XPUT -d@/kibana-template.json "${ELASTICSEARCH_URL}/_template/kibana"

    type="_template"
    typefolder="/kibana-objects/${type}"

    # Submit templates _template
    echo "Processing type $type"
    for fullfile in $typefolder/*.json; do
      filename=$(basename "$fullfile")
      name="${filename%.*}"

      if [ "$name" != "*" ]; then
        echo "Processing file $fullfile with name: $name"
        curl -vvv -H "Content-Type: application/json" -s -f -XPUT -d@/${fullfile} "${ELASTICSEARCH_URL}/${type}/${name}"
      fi
    done

    # Submit rest of the objects
    # i.e the type folders in `objects` other than previous type `_template`

    # order needed? 
    declare -a arr=("index-pattern" "search" "visualization" "dashboard")
    # objects_except_template=$(ls | grep -v ${type} | tr '\n' ' ')
    # IFS_BACKUP=IFS;
    # IFS=" ";
    # declare -a arr=($objects_except_template)
    # IFS=IFS_BACKUP;

    for type in "${arr[@]}"
    do
      typefolder="/kibana-objects/${type}"

      echo "Processing type $type"
      for fullfile in $typefolder/*.json; do
        filename=$(basename "$fullfile")
        name="${filename%.*}"

        if [ "$name" != "*" ]; then
          echo "Processing file $fullfile with name: $name"
          curl -vvv -H "Content-Type: application/json" -s -f -XPUT -d@/${fullfile} "${ELASTICSEARCH_URL}/.kibana/${type}/${name}"
        fi
      done
    done
fi

sleep infinity