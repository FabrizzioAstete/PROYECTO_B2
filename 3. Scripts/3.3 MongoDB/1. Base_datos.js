// MypeInventario | MongoDB 7 | Paso 1: base y colecciones con validación $jsonSchema (mongosh)
// Dominio COMPLEMENTARIO: documentos flexibles (catálogo con variantes embebidas, perfil de negocio, promociones).
// No repite las tablas de Cassandra (eventos/series de tiempo) ni las de PostgreSQL/Oracle.
use('mypeinventario');
db.createCollection('catalogo_producto', { validator: { $jsonSchema: {
  bsonType:'object', required:['producto_id','comerciante_id','nombre','categoria','estado','variantes'],
  properties:{ producto_id:{bsonType:'int'}, comerciante_id:{bsonType:'int'}, nombre:{bsonType:'string'}, categoria:{bsonType:'string'},
    marca:{bsonType:'string'}, estado:{enum:['ACTIVO','INACTIVO']}, etiquetas:{bsonType:'array'}, atributos:{bsonType:'object'},
    proveedor:{bsonType:'object'},
    variantes:{bsonType:'array', minItems:1, items:{bsonType:'object', required:['sku','precio_venta','stock_actual','stock_minimo'],
      properties:{ sku:{bsonType:'string'}, talla:{bsonType:'string'}, color:{bsonType:'string'},
        precio_venta:{bsonType:['double','int','decimal'], minimum:0}, stock_actual:{bsonType:'int', minimum:0}, stock_minimo:{bsonType:'int', minimum:0}}}}}}}});
db.createCollection('perfil_comerciante', { validator: { $jsonSchema: {
  bsonType:'object', required:['comerciante_id','nombre_negocio','plan'],
  properties:{ comerciante_id:{bsonType:'int'}, nombre_negocio:{bsonType:'string'}, plan:{enum:['PRUEBA','BASICO','ESTANDAR','PRO']},
    notificaciones:{bsonType:'object'}, horario_atencion:{bsonType:'array'}, meta_mensual:{bsonType:['double','int','decimal']}, sucursales:{bsonType:'array'}}}}});
db.createCollection('promocion', { validator: { $jsonSchema: {
  bsonType:'object', required:['promo_id','comerciante_id','nombre','tipo','valor','vigencia','estado'],
  properties:{ promo_id:{bsonType:'int'}, comerciante_id:{bsonType:'int'}, nombre:{bsonType:'string'}, tipo:{enum:['PORCENTAJE','MONTO','2X1']},
    valor:{bsonType:['double','int']}, vigencia:{bsonType:'object', required:['desde','hasta']}, skus:{bsonType:'array'}, canales:{bsonType:'array'}, estado:{enum:['ACTIVA','PAUSADA','VENCIDA']}}}}});
print(db.getCollectionNames());
