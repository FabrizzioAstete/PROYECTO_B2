#!/usr/bin/env bash
# MypeInventario | MongoDB | Paso 7: respaldo y restauración (ver 4. Backups/MongoDB para la versión .cmd de Windows)
# Estrategia: mongodump diario comprimido (gzip) + oplog en réplica set para recuperación a un punto en el tiempo (PITR).
set -euo pipefail
STAMP=$(date +%Y%m%d_%H%M); DEST=./backups/mongo_$STAMP; URI="mongodb://usr_backup:${MYPE_PWD_BK:?definir MYPE_PWD_BK}@localhost:27017/?authSource=admin&directConnection=true"
# directConnection=true: el replica set de Docker anuncia hosts internos (mongo1, mongo2...) que no se resuelven desde el host.
mongodump --uri="$URI" --db=mypeinventario --gzip --out="$DEST"
# Para PITR (respaldo de TODA la instancia + oplog) NO se puede usar --db: mongodump --uri="$URI" --gzip --oplog --out="$DEST"_pitr
# Restauración de prueba a otra base (no pisa producción):
# mongorestore --uri="$URI" --gzip --nsFrom='mypeinventario.*' --nsTo='mypeinventario_restore.*' "$DEST/mypeinventario"
# Verificación: mongosh --eval "db.getSiblingDB('mypeinventario_restore').catalogo_producto.countDocuments()"
