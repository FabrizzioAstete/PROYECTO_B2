-- MypeInventario | PostgreSQL 16 | Paso 4: funciones, procedimientos y triggers
SET search_path TO mype, public;

-- F1. Stock bajo por comerciante (o de todos si NULL)
CREATE OR REPLACE FUNCTION fn_stock_bajo(p_id_comerciante INTEGER DEFAULT NULL)
RETURNS TABLE (id_comerciante INTEGER, id_sku INTEGER, producto VARCHAR, codigo_sku VARCHAR, stock_actual INTEGER, stock_minimo INTEGER)
LANGUAGE sql STABLE AS $$
  SELECT p.id_comerciante, v.id_sku, p.nombre, v.codigo_sku, v.stock_actual, v.stock_minimo
  FROM mype.producto_item p JOIN mype.variante_sku v ON v.id_producto = p.id_producto
  WHERE v.estado = 'ACTIVO' AND v.stock_actual <= v.stock_minimo
    AND (p_id_comerciante IS NULL OR p.id_comerciante = p_id_comerciante)
  ORDER BY p.id_comerciante, v.stock_actual;
$$;
-- Uso: SELECT * FROM mype.fn_stock_bajo(10);

-- F2. Ventas por canal en un rango de fechas (pregunta de negocio: ¿qué canal vende más?)
CREATE OR REPLACE FUNCTION fn_ventas_por_canal(p_id_comerciante INTEGER, p_desde TIMESTAMP, p_hasta TIMESTAMP)
RETURNS TABLE (canal VARCHAR, nro_ventas BIGINT, importe NUMERIC)
LANGUAGE sql STABLE AS $$
  SELECT v.canal, COUNT(*), COALESCE(SUM(v.total),0)
  FROM mype.venta_punto v
  WHERE v.id_comerciante = p_id_comerciante AND v.estado = 'REGISTRADA'
    AND v.fe_venta >= p_desde AND v.fe_venta < p_hasta
  GROUP BY v.canal ORDER BY 3 DESC;
$$;
-- Uso: SELECT * FROM mype.fn_ventas_por_canal(1,'2026-01-01','2027-01-01');

-- F3. Ticket promedio de un comerciante
CREATE OR REPLACE FUNCTION fn_ticket_promedio(p_id_comerciante INTEGER)
RETURNS NUMERIC LANGUAGE sql STABLE AS $$
  SELECT COALESCE(ROUND(AVG(total),2),0) FROM mype.venta_punto WHERE id_comerciante = p_id_comerciante AND estado='REGISTRADA';
$$;

-- T1. Trigger: calcula y valida el subtotal de cada línea de venta
CREATE OR REPLACE FUNCTION fn_tg_detalle_subtotal() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.subtotal := ROUND(NEW.cantidad * NEW.precio_unitario, 2);
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS tg_detalle_subtotal ON mype.detalle_venta;
CREATE TRIGGER tg_detalle_subtotal BEFORE INSERT OR UPDATE OF cantidad, precio_unitario ON mype.detalle_venta
FOR EACH ROW EXECUTE FUNCTION fn_tg_detalle_subtotal();

-- P1. Registrar una venta con varias líneas. Descuenta stock con bloqueo de fila (evita sobreventa concurrente).
-- p_items: JSON  [{"id_sku":1,"cantidad":2},{"id_sku":5,"cantidad":1}]
CREATE OR REPLACE PROCEDURE sp_registrar_venta(
  p_id_comerciante INTEGER, p_metodo_pago VARCHAR, p_canal VARCHAR, p_items JSONB, INOUT p_id_venta INTEGER DEFAULT NULL)
LANGUAGE plpgsql AS $$
DECLARE it JSONB; v_sku INTEGER; v_cant INTEGER; v_precio NUMERIC; v_stock INTEGER; v_total NUMERIC := 0;
BEGIN
  IF jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'La venta debe incluir al menos una línea';
  END IF;
  INSERT INTO mype.venta_punto(id_comerciante, metodo_pago, canal, total) VALUES (p_id_comerciante, p_metodo_pago, p_canal, 0)
  RETURNING id_venta INTO p_id_venta;
  FOR it IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_sku := (it->>'id_sku')::INTEGER; v_cant := (it->>'cantidad')::INTEGER;
    SELECT precio_venta, stock_actual INTO v_precio, v_stock FROM mype.variante_sku WHERE id_sku = v_sku AND estado='ACTIVO' FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'SKU % inexistente o inactivo', v_sku; END IF;
    IF v_stock < v_cant THEN RAISE EXCEPTION 'Stock insuficiente para SKU % (disponible %, solicitado %)', v_sku, v_stock, v_cant; END IF;
    INSERT INTO mype.detalle_venta(id_venta, id_sku, cantidad, precio_unitario, subtotal) VALUES (p_id_venta, v_sku, v_cant, v_precio, 0);
    UPDATE mype.variante_sku SET stock_actual = stock_actual - v_cant WHERE id_sku = v_sku;
    v_total := v_total + v_cant * v_precio;
  END LOOP;
  UPDATE mype.venta_punto SET total = v_total WHERE id_venta = p_id_venta;
END; $$;
-- Uso: CALL mype.sp_registrar_venta(1,'YAPE','TIENDA','[{"id_sku":1,"cantidad":1}]'::jsonb);

-- P2. Anular venta y devolver stock
CREATE OR REPLACE PROCEDURE sp_anular_venta(p_id_venta INTEGER) LANGUAGE plpgsql AS $$
BEGIN
  UPDATE mype.venta_punto SET estado='ANULADA' WHERE id_venta = p_id_venta AND estado='REGISTRADA';
  IF NOT FOUND THEN RAISE EXCEPTION 'Venta % no existe o ya fue anulada', p_id_venta; END IF;
  UPDATE mype.variante_sku v SET stock_actual = v.stock_actual + d.cantidad
  FROM mype.detalle_venta d WHERE d.id_venta = p_id_venta AND d.id_sku = v.id_sku;
END; $$;
-- Uso: CALL mype.sp_anular_venta(1);
