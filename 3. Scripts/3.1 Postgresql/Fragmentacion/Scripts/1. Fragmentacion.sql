-- MypeInventario | PostgreSQL 16 | Fragmentación horizontal por rango de fecha (particionamiento declarativo)
-- Criterio: fe_venta. Las consultas de negocio siempre acotan por periodo (cierre diario/mensual); el optimizador
-- aplica "partition pruning" y lee solo el fragmento necesario. Se mantiene una proyección particionada para no
-- alterar PK/FK del modelo transaccional (una FK hacia una tabla particionada exige incluir la clave de partición).
-- Ejecutar DESPUÉS de 6. Data.sql.
SET search_path TO mype, public;
CREATE TABLE IF NOT EXISTS venta_punto_frag (
  id_venta INTEGER NOT NULL, id_comerciante INTEGER NOT NULL, fe_venta TIMESTAMP NOT NULL,
  total NUMERIC(12,2) NOT NULL, canal VARCHAR(15) NOT NULL, metodo_pago VARCHAR(15) NOT NULL,
  PRIMARY KEY (id_venta, fe_venta)
) PARTITION BY RANGE (fe_venta);
-- Fragmentos: F1 histórico, F2..F5 trimestres de 2026, F6 año 2027, DEFAULT por seguridad
CREATE TABLE IF NOT EXISTS venta_frag_hist  PARTITION OF venta_punto_frag FOR VALUES FROM (MINVALUE)      TO ('2026-01-01');
CREATE TABLE IF NOT EXISTS venta_frag_2026q1 PARTITION OF venta_punto_frag FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');
CREATE TABLE IF NOT EXISTS venta_frag_2026q2 PARTITION OF venta_punto_frag FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');
CREATE TABLE IF NOT EXISTS venta_frag_2026q3 PARTITION OF venta_punto_frag FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');
CREATE TABLE IF NOT EXISTS venta_frag_2026q4 PARTITION OF venta_punto_frag FOR VALUES FROM ('2026-10-01') TO ('2027-01-01');
CREATE TABLE IF NOT EXISTS venta_frag_2027   PARTITION OF venta_punto_frag FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE TABLE IF NOT EXISTS venta_frag_otros  PARTITION OF venta_punto_frag DEFAULT;
CREATE INDEX IF NOT EXISTS ix_venta_frag_com_fecha ON venta_punto_frag (id_comerciante, fe_venta);

-- Carga/refresco de la proyección (idempotente)
CREATE OR REPLACE PROCEDURE sp_refrescar_fragmentos() LANGUAGE sql AS $$
  INSERT INTO mype.venta_punto_frag(id_venta,id_comerciante,fe_venta,total,canal,metodo_pago)
  SELECT id_venta,id_comerciante,fe_venta,total,canal,metodo_pago FROM mype.venta_punto
  ON CONFLICT (id_venta, fe_venta) DO NOTHING;
$$;
CALL sp_refrescar_fragmentos();

-- Comprobaciones (capturar para el informe)
-- Filas por fragmento:  SELECT tableoid::regclass AS fragmento, COUNT(*) FROM mype.venta_punto_frag GROUP BY 1 ORDER BY 1;
-- Pruning (debe leer 1 solo fragmento): EXPLAIN SELECT * FROM mype.venta_punto_frag WHERE fe_venta >= '2026-10-01' AND fe_venta < '2027-01-01';
