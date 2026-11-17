-- MypeInventario | Cassandra | Paso 3: indexación con justificación técnica
USE mypeinventario;
-- En Cassandra el "índice principal" es la PARTITION KEY + CLUSTERING COLUMNS de cada tabla (ver 2. Tablas.cql):
--  * Partition key compuesta (id_comerciante, id_sku): reparte la carga y acota cada lectura a una partición.
--  * Clustering por fe_movimiento DESC: los registros recientes se leen primero sin ordenar en memoria.
-- Índice secundario SOLO para columnas de baja cardinalidad consultadas SIEMPRE junto a la partition key (nunca solo):
CREATE INDEX IF NOT EXISTS ix_alerta_canal ON alertas_por_comerciante_estado (canal_notificacion);
-- Justificación: filtra la bandeja de una tienda por canal (PUSH/WHATSAPP/EMAIL, 3 valores). En Cassandra 5.0 se recomienda SAI:
--   CREATE CUSTOM INDEX IF NOT EXISTS ix_alerta_canal_sai ON alertas_por_comerciante_estado (canal_notificacion) USING 'StorageAttachedIndex';
-- NO se crean índices secundarios sobre 'canal' de ventas: se resolvió con la tabla ventas_por_canal_mes (denormalización).
