// MypeInventario | MongoDB 7 | Fragmentación (sharding). Requiere clúster: config servers + mongos + >= 2 shards. NO funciona en standalone.
// Conectar a mongos:  mongosh "mongodb://mongos:27017"
sh.enableSharding('mypeinventario');
// Criterio 1: catalogo_producto -> clave HASHED de comerciante_id. Distribuye las tiendas uniformemente y evita "hot shard";
// las consultas por tienda se resuelven en un solo shard (targeted query) porque filtran por comerciante_id.
// OJO: en una colección fragmentada todo índice ÚNICO debe tener la clave de shard como prefijo; el único I1 (producto_id) de
// 2. Indices.js lo impide. Se reemplaza por uno NO único (la unicidad del id la garantiza la PK de PostgreSQL, de donde proviene).
db.getSiblingDB('mypeinventario').catalogo_producto.dropIndex({ producto_id: 1 });
db.getSiblingDB('mypeinventario').catalogo_producto.createIndex({ producto_id: 1 });
db.getSiblingDB('mypeinventario').catalogo_producto.createIndex({ comerciante_id: 'hashed' });
sh.shardCollection('mypeinventario.catalogo_producto', { comerciante_id: 'hashed' });
// Criterio 2: promocion -> clave por rango compuesta (comerciante_id, promo_id): permite zonas por comerciante y búsqueda por rango.
db.getSiblingDB('mypeinventario').promocion.createIndex({ comerciante_id: 1, promo_id: 1 });   // índice de soporte (colección ya con datos)
sh.shardCollection('mypeinventario.promocion', { comerciante_id: 1, promo_id: 1 });
// perfil_comerciante es pequeña (1 doc por tienda): se deja SIN fragmentar en el shard primario.
// Comprobar: sh.status(); db.catalogo_producto.getShardDistribution();
