#!/usr/bin/env bash
# MypeInventario | Cassandra | Paso 7: respaldo y restauración por snapshots (ejecutar EN CADA NODO). Ver 4. Backups/Cassandra.
# Estrategia: snapshot completo semanal + incremental_backups=true (cassandra.yaml) para copias entre snapshots.
set -euo pipefail
TAG="mype_$(date +%Y%m%d_%H%M)"
nodetool flush mypeinventario
nodetool snapshot -t "$TAG" mypeinventario           # crea enlaces duros en data/<keyspace>/<tabla>/snapshots/$TAG
nodetool listsnapshots
# Copiar a almacenamiento externo (ejemplo): rsync -a /var/lib/cassandra/data/mypeinventario/*/snapshots/$TAG backup-host:/backups/cassandra/$TAG/
# Restauración de UNA tabla (nodo detenido o con tabla truncada en entorno de prueba):
#   1) TRUNCATE mypeinventario.kardex_por_sku;   (cqlsh)
#   2) copiar los .db del snapshot a data/mypeinventario/kardex_por_sku-<uuid>/
#   3) nodetool refresh mypeinventario kardex_por_sku
# Limpieza: nodetool clearsnapshot -t "$TAG" mypeinventario
