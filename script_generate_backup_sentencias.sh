#!/usr/bin/env bash
#
# Creando copia de ElasticSearch cluster con snapshots
# 26/07/20  josefc9512@gmail.com
#
# Es necesitas el binario jq
# descargar desde https://stedolan.github.io/jq/
# sudo apt-get install jq
# *alternativa*yum install jq

# Modo cron
CRON=0

# Limite las instantáneas guardadas en el directorio de respaldo
LIMIT=30

# Nombre de nuestro repositorio de instantáneas
MYBACKUP="backups"

# Nombre del anfitrion
HOST=$(hostname)

# Snapshot nombre único basado en tiempo
SNAPDATE=$(date +%Y%m%d%H%M%S)

# Creando el backup
if [ "$CRON" = true ]; then
    curl -XPUT "${HOST}:9200/_snapshot/${MYBACKUP}/$SNAPDATE?wait_for_completion=true"  -H 'Content-Type: application/json' -d '{
         "indices": "sentencias",
         "ignore_unavailable": true,
         "include_global_state": false
        }
    }'
else
    curl -XPUT "${HOST}:9200/_snapshot/${MYBACKUP}/$SNAPDATE?wait_for_completion=true&pretty=true" -H 'Content-Type: application/json' -d '{
         "indices": "sentencias",
         "ignore_unavailable": true,
         "include_global_state": false
        }
    }'
fi

## Removiendo viejos backups
# Obteniendo el listado de backups
SNAPSHOTS=$(curl -s -XGET "${HOST}:9200/_snapshot/${MYBACKUP}/_all" | jq -r ".snapshots[:-${LIMIT}][].snapshot")

echo $SNAPSHOTS

# Recorriendo la lista y eliminand los que excedan
for SNAPSHOT in $SNAPSHOTS
do
    echo "Deleting snapshot: $SNAPSHOT"
    if [[ $CRON ]]; then
        curl -s -XDELETE "${HOST}:9200/_snapshot/${MYBACKUP}/$SNAPSHOT"
    else
        curl -s -XDELETE "${HOST}:9200/_snapshot/${MYBACKUP}/$SNAPSHOT?pretty=true"
    fi
done
