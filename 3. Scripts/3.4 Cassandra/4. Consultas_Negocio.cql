-- MypeInventario | Cassandra | Paso 4: consultas que responden preguntas de negocio (tras 6. Data.cql)
USE mypeinventario;
-- Q1 ¿Cuáles fueron los últimos 10 movimientos del SKU 3 de la tienda 1 (trazabilidad / auditoría de stock)?
SELECT fe_movimiento, tipo_movimiento, motivo, cantidad, saldo_resultante FROM kardex_por_sku WHERE id_comerciante=1 AND id_sku=3 LIMIT 10;
-- Q2 ¿Qué vendió la tienda 1 el 2026-10-25 (cierre de caja del día)?
SELECT fe_venta, id_venta, canal, metodo_pago, total FROM ventas_por_comerciante_dia WHERE id_comerciante=1 AND fecha_dia='2026-10-25';
-- Q3 ¿Cuánto y cuántas ventas hizo la tienda 1 por WhatsApp en octubre de 2026?
SELECT COUNT(*) AS ventas, SUM(total) AS importe FROM ventas_por_canal_mes WHERE id_comerciante=1 AND anio_mes='2026-10' AND canal='WHATSAPP';
-- Q4 ¿Cuáles son las alertas pendientes más recientes de la tienda 1?
SELECT fe_generacion, id_sku, stock_actual, stock_minimo, canal_notificacion FROM alertas_por_comerciante_estado WHERE id_comerciante=1 AND estado='PENDIENTE' LIMIT 20;
-- Q5 ¿Qué alertas pendientes de la tienda 1 se notifican por WhatsApp? (usa el índice secundario junto a la partition key)
SELECT fe_generacion, id_sku FROM alertas_por_comerciante_estado WHERE id_comerciante=1 AND estado='PENDIENTE' AND canal_notificacion='WHATSAPP';
