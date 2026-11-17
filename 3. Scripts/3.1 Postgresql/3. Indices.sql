-- MypeInventario | PostgreSQL 16 | Paso 3: índices con justificación técnica
-- Las PK y UNIQUE ya crean índices B-tree automáticamente. PostgreSQL NO indexa las FK: se indexan aquí las de uso frecuente.
SET search_path TO mype;

-- IX1. FK de PRODUCTO_ITEM -> COMERCIANTE. B-tree.
-- Justificación: el catálogo siempre se consulta "por tienda" (WHERE id_comerciante = ?). Sin índice cada consulta
-- haría Seq Scan; además acelera DELETE/UPDATE en COMERCIANTE (verificación de la FK).
CREATE INDEX ix_producto_comerciante ON producto_item (id_comerciante);

-- IX2. Catálogo filtrado por categoría y estado. B-tree compuesto (categoria, estado).
-- Justificación: la pantalla de catálogo filtra por ambos campos; el orden (igualdad, igualdad) permite usar el índice
-- también cuando solo se filtra por id_categoria (prefijo izquierdo).
CREATE INDEX ix_producto_categoria_estado ON producto_item (id_categoria, estado);

-- IX3. Lectura de caja por código de barras. B-tree PARCIAL (solo SKU activos con código).
-- Justificación: el escaneo de código de barras exige respuesta < 50 ms; el filtro parcial descarta SKU inactivos o sin
-- código, reduciendo el tamaño del índice y el costo de mantenimiento en escrituras.
CREATE INDEX ix_sku_barras_activo ON variante_sku (codigo_barras) WHERE estado = 'ACTIVO' AND codigo_barras IS NOT NULL;

-- IX4. Detección de stock bajo. B-tree PARCIAL sobre la expresión de brecha (stock_actual - stock_minimo).
-- Justificación: fn_stock_bajo() filtra stock_actual <= stock_minimo; solo una fracción pequeña de SKU cumple,
-- por lo que un índice parcial es mucho más selectivo que uno completo.
CREATE INDEX ix_sku_stock_bajo ON variante_sku (id_producto, stock_actual) WHERE estado = 'ACTIVO' AND stock_actual <= stock_minimo;

-- IX5. Ventas por tienda y fecha. B-tree compuesto con INCLUDE (índice cubriente).
-- Justificación: los reportes diarios/mensuales leen id_comerciante + rango de fe_venta y suman total/canal;
-- INCLUDE permite Index Only Scan sin visitar la tabla.
CREATE INDEX ix_venta_com_fecha ON venta_punto (id_comerciante, fe_venta DESC) INCLUDE (total, canal, estado);

-- IX6. BRIN sobre fe_venta. Justificación: las ventas se insertan en orden cronológico, por lo que la correlación física
-- es alta; un BRIN ocupa miles de veces menos espacio que un B-tree para barridos por rango amplio (cierres anuales).
CREATE INDEX brin_venta_fecha ON venta_punto USING BRIN (fe_venta);

-- IX7. FK de DETALLE_VENTA -> VARIANTE_SKU. B-tree. Justificación: historial de ventas por SKU y verificación de FK.
-- (La FK id_venta ya queda cubierta por la UNIQUE (id_venta, id_sku)).
CREATE INDEX ix_detalle_sku ON detalle_venta (id_sku);

-- Verificación de uso (ejemplo): EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM fn_stock_bajo(10);
-- Estadísticas: ANALYZE; SELECT relname, indexrelname, idx_scan FROM pg_stat_user_indexes WHERE schemaname='mype';
