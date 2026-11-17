// MypeInventario | MongoDB | Paso 3: consultas que responden preguntas de negocio (ejecutar después de 6. Data.js)
use('mypeinventario');
// Con 'mongosh --file' los cursores no se imprimen solos: show() los muestra (útil para las capturas del informe).
const show = (titulo, cursor) => { print('\n=== ' + titulo); cursor.forEach(d => printjson(d)); };
// Q1 ¿Qué variantes de la tienda 1 están por agotarse y cuánto falta para llegar al mínimo?
show('Q1 ¿Qué variantes de la tienda 1 están por agotarse y cuánto falta para llegar al mínimo?', db.catalogo_producto.aggregate([{$match:{comerciante_id:1,estado:'ACTIVO'}},{$unwind:'$variantes'},
 {$match:{$expr:{$lte:['$variantes.stock_actual','$variantes.stock_minimo']}}},
 {$project:{_id:0,producto:'$nombre',sku:'$variantes.sku',stock:'$variantes.stock_actual',faltante:{$subtract:['$variantes.stock_minimo','$variantes.stock_actual']}}}]));
// Q2 ¿Qué categorías concentran más capital inmovilizado en inventario (valor a precio de venta)?
show('Q2 ¿Qué categorías concentran más capital inmovilizado en inventario (valor a precio de venta)?', db.catalogo_producto.aggregate([{$match:{estado:'ACTIVO'}},{$unwind:'$variantes'},
 {$group:{_id:'$categoria',valor_inventario:{$sum:{$multiply:['$variantes.precio_venta','$variantes.stock_actual']}},unidades:{$sum:'$variantes.stock_actual'}}},
 {$sort:{valor_inventario:-1}}]));
// Q3 ¿Qué promociones vigentes hoy tiene la tienda 1 en el canal WHATSAPP?
show('Q3 ¿Qué promociones vigentes hoy tiene la tienda 1 en el canal WHATSAPP?', db.promocion.find({comerciante_id:1,estado:'ACTIVA',canales:'WHATSAPP',
 'vigencia.desde':{$lte:new Date()},'vigencia.hasta':{$gte:new Date()}},{_id:0,nombre:1,tipo:1,valor:1,skus:1}));
// Q4 ¿Qué productos en promoción activa están en riesgo de quedarse sin stock? ($lookup entre colecciones)
show('Q4 ¿Qué productos en promoción activa están en riesgo de quedarse sin stock? ($lookup entre colecciones)', db.promocion.aggregate([{$match:{estado:'ACTIVA'}},{$unwind:'$skus'},
 {$lookup:{from:'catalogo_producto',localField:'skus',foreignField:'variantes.sku',as:'prod'}},{$unwind:'$prod'},{$unwind:'$prod.variantes'},
 {$match:{$expr:{$and:[{$eq:['$prod.variantes.sku','$skus']},{$lte:['$prod.variantes.stock_actual','$prod.variantes.stock_minimo']}]}}},
 {$project:{_id:0,promocion:'$nombre',sku:'$skus',producto:'$prod.nombre',stock:'$prod.variantes.stock_actual'}},{$limit:20}]));
// Q5 ¿Cuántos comerciantes por plan aceptan alertas por WhatsApp (segmentación de campaña)?
show('Q5 ¿Cuántos comerciantes por plan aceptan alertas por WhatsApp (segmentación de campaña)?', db.perfil_comerciante.aggregate([{$match:{'notificaciones.canales':'WHATSAPP'}},{$group:{_id:'$plan',comerciantes:{$sum:1},meta_promedio:{$avg:'$meta_mensual'}}},{$sort:{comerciantes:-1}}]));
