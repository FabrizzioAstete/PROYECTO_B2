// Evidencias para el informe (capturar cada salida)
// 1) En el PRIMARIO (mongo1): insertar un documento
use('mypeinventario'); db.prueba_replica.insertOne({ origen:'mongo1', ts:new Date() });
// 2) En un SECUNDARIO (docker exec -it mongo2 mongosh): habilitar lectura y leer -> replicación asíncrona (ligero retraso)
//    db.getMongo().setReadPref('secondaryPreferred'); db.getSiblingDB('mypeinventario').prueba_replica.find();
// 3) Retraso de replicación por miembro:
rs.printSecondaryReplicationInfo();
// 4) Consistencia configurable: w:1 (asíncrono hacia secundarios) vs w:'majority'
db.prueba_replica.insertOne({ modo:'w1' }, { writeConcern:{ w:1 } });
db.prueba_replica.insertOne({ modo:'majority' }, { writeConcern:{ w:'majority', wtimeout:5000 } });
// 5) Conmutación: docker stop mongo1  ->  rs.status() desde mongo2: se elige un nuevo PRIMARY (failover automático)
