-- MypeInventario | Oracle 19c/21c | Paso 3: índices con justificación técnica (conectado como MYPE_OWNER)
-- Oracle crea índices automáticos para PK/UNIQUE; las FK NO se indexan solas (riesgo de bloqueos TM al borrar/actualizar el padre).

-- IX1. B-tree en DETALLE_ORDEN_COMPRA(ID_ORDEN): FK frecuente (listar líneas de una orden) y evita bloqueo de tabla al modificar ORDEN_COMPRA.
CREATE INDEX IX_DOC_ORDEN ON DETALLE_ORDEN_COMPRA (ID_ORDEN);
-- IX2. B-tree compuesto en ORDEN_COMPRA(ID_COMERCIANTE, ESTADO, FE_ORDEN): bandeja "órdenes pendientes de recibir por tienda".
CREATE INDEX IX_OC_COM_EST_FECHA ON ORDEN_COMPRA (ID_COMERCIANTE, ESTADO, FE_ORDEN);
-- IX3. B-tree en DETALLE_ORDEN_COMPRA(ID_SKU): historial de costos de compra por SKU.
CREATE INDEX IX_DOC_SKU ON DETALLE_ORDEN_COMPRA (ID_SKU);
-- IX4. Índice LOCAL en el kardex particionado (ID_SKU, FE_MOVIMIENTO): consulta típica = historial de un SKU en un rango de fechas.
-- LOCAL = un segmento de índice por partición; permite poda de particiones y mantenimiento (DROP/MERGE) sin reconstruir todo.
CREATE INDEX IX_MOV_SKU_FECHA ON MOVIMIENTO_INVENTARIO (ID_SKU, FE_MOVIMIENTO) LOCAL;
-- IX5. B-tree en MOVIMIENTO_INVENTARIO(ID_ORDEN): FK hacia ORDEN_COMPRA (trazabilidad de entradas).
CREATE INDEX IX_MOV_ORDEN ON MOVIMIENTO_INVENTARIO (ID_ORDEN);
-- IX6. Índice basado en función: bandeja de alertas ACTIVAS. Solo indexa filas pendientes/enviadas (el resto da NULL y no entra al B-tree),
-- por lo que el índice permanece pequeño aunque el histórico de alertas atendidas crezca.
CREATE INDEX IX_ALERTA_ACTIVA ON ALERTA_REABASTECIMIENTO (CASE WHEN ESTADO IN ('PENDIENTE','ENVIADA') THEN ID_COMERCIANTE END,
                                                         CASE WHEN ESTADO IN ('PENDIENTE','ENVIADA') THEN FE_GENERACION END);
-- IX7. B-tree en PAGO_VENTA(ID_VENTA): conciliación pago <-> venta (join con ids de PostgreSQL).
CREATE INDEX IX_PAGO_VENTA ON PAGO_VENTA (ID_VENTA);
-- IX8. B-tree compuesto PAGO_VENTA(ID_COMERCIANTE, FE_PAGO): cierre de caja por tienda y fecha.
CREATE INDEX IX_PAGO_COM_FECHA ON PAGO_VENTA (ID_COMERCIANTE, FE_PAGO);
-- IX9. B-tree AUDITORIA_PRECIO(ID_SKU, FE_CAMBIO): línea de tiempo de precios de un SKU.
CREATE INDEX IX_AUD_SKU_FECHA ON AUDITORIA_PRECIO (ID_SKU, FE_CAMBIO);

-- Verificación: EXEC DBMS_STATS.GATHER_SCHEMA_STATS('MYPE_OWNER');
--   SELECT index_name, partitioned, status FROM user_indexes ORDER BY 1;
--   EXPLAIN PLAN FOR SELECT * FROM MOVIMIENTO_INVENTARIO WHERE ID_SKU=10 AND FE_MOVIMIENTO >= TIMESTAMP '2026-10-01 00:00:00';
--   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
