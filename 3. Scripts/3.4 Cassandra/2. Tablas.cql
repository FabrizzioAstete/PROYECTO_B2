-- MypeInventario | Cassandra | Paso 2: tablas orientadas a consulta (una tabla por pregunta de negocio)
-- Dominio COMPLEMENTARIO a MongoDB (catálogo/perfil/promociones): aquí van series de tiempo y eventos de alto volumen de escritura.
USE mypeinventario;

-- T1. Kardex por SKU: historial de movimientos de un SKU, el más reciente primero.
CREATE TABLE IF NOT EXISTS kardex_por_sku (
  id_comerciante int, id_sku int, fe_movimiento timestamp, id_movimiento timeuuid,
  tipo_movimiento text, motivo text, cantidad int, saldo_resultante int, observacion text,
  PRIMARY KEY ((id_comerciante, id_sku), fe_movimiento, id_movimiento)
) WITH CLUSTERING ORDER BY (fe_movimiento DESC, id_movimiento DESC);

-- T2. Ventas por comerciante y día (partición diaria: evita particiones ilimitadas).
CREATE TABLE IF NOT EXISTS ventas_por_comerciante_dia (
  id_comerciante int, fecha_dia date, fe_venta timestamp, id_venta int, canal text, metodo_pago text, total decimal, nro_items int,
  PRIMARY KEY ((id_comerciante, fecha_dia), fe_venta, id_venta)
) WITH CLUSTERING ORDER BY (fe_venta DESC, id_venta ASC);

-- T3. Ventas por canal y mes (permite SUM/COUNT dentro de UNA partición para "¿cuánto vende cada canal?").
CREATE TABLE IF NOT EXISTS ventas_por_canal_mes (
  id_comerciante int, anio_mes text, canal text, fe_venta timestamp, id_venta int, total decimal,
  PRIMARY KEY ((id_comerciante, anio_mes, canal), fe_venta, id_venta)
) WITH CLUSTERING ORDER BY (fe_venta DESC, id_venta ASC);

-- T4. Alertas por comerciante y estado (bandeja de alertas activas).
CREATE TABLE IF NOT EXISTS alertas_por_comerciante_estado (
  id_comerciante int, estado text, fe_generacion timestamp, id_alerta timeuuid, id_sku int, stock_actual int, stock_minimo int, canal_notificacion text,
  PRIMARY KEY ((id_comerciante, estado), fe_generacion, id_alerta)
) WITH CLUSTERING ORDER BY (fe_generacion DESC, id_alerta ASC);
