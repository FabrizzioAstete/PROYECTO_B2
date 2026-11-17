// MypeInventario | MongoDB | Paso 2: índices con justificación técnica
use('mypeinventario');
// I1. Único (producto_id): identidad lógica del producto, evita duplicados al cargar desde PostgreSQL.
db.catalogo_producto.createIndex({ producto_id: 1 }, { unique: true });
// I2. Compuesto ESR (Equality, Sort, Range): comerciante_id (=), estado (=), categoria. Cubre el listado de catálogo por tienda/categoría.
db.catalogo_producto.createIndex({ comerciante_id: 1, estado: 1, categoria: 1 });
// I3. Multikey sobre variantes.sku: búsqueda por SKU dentro del arreglo embebido (lectura en caja).
db.catalogo_producto.createIndex({ 'variantes.sku': 1 });
// I4. Parcial: solo productos ACTIVOS con variantes de stock; reduce tamaño y costo de escritura.
db.catalogo_producto.createIndex({ comerciante_id: 1, 'variantes.stock_actual': 1 }, { partialFilterExpression: { estado: 'ACTIVO' } });
// I5. Único por comerciante en perfil (1 perfil por tienda).
db.perfil_comerciante.createIndex({ comerciante_id: 1 }, { unique: true });
// I6. Compuesto plan + canales de notificación para segmentación de campañas.
db.perfil_comerciante.createIndex({ plan: 1, 'notificaciones.canales': 1 });
// I7. Promociones por tienda, estado y vigencia (consulta "vigentes hoy").
db.promocion.createIndex({ comerciante_id: 1, estado: 1, 'vigencia.hasta': 1 });
// I8. TTL: elimina automáticamente promociones vencidas 90 días después de su fecha fin (campo Date 'expira_en').
db.promocion.createIndex({ expira_en: 1 }, { expireAfterSeconds: 7776000 });
// Verificación: db.catalogo_producto.find({comerciante_id:1,estado:'ACTIVO'}).explain('executionStats').queryPlanner.winningPlan
