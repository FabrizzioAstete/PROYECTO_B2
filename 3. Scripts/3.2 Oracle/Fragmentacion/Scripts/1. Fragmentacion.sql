-- MypeInventario | Oracle 19c/21c | Fragmentación horizontal
-- Criterio: RANGE por FE_MOVIMIENTO con INTERVAL de 1 mes sobre MOVIMIENTO_INVENTARIO (definido en 2. Tablas.sql).
-- El kardex es la tabla de mayor crecimiento; las consultas y la depuración son por periodo, así que cada mes es un fragmento
-- (partición) que se crea AUTOMÁTICAMENTE al llegar el primer dato del mes. Índice LOCAL IX_MOV_SKU_FECHA.
-- Fragmentos: P_INICIAL (< 2026-01-01) + una partición SYS_Pnnn por mes.
-- Ejecutar DESPUÉS de 6. Data.sql, conectado como MYPE_OWNER.
-- Estadísticas necesarias para que NUM_ROWS no salga vacío (comentario en línea aparte: un '--' tras EXEC rompe el bloque PL/SQL)
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'MOVIMIENTO_INVENTARIO');
SELECT PARTITION_NAME, HIGH_VALUE, NUM_ROWS FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'MOVIMIENTO_INVENTARIO' ORDER BY PARTITION_POSITION;
-- Poda de particiones (el plan debe mostrar PARTITION RANGE SINGLE / ITERATOR):
EXPLAIN PLAN FOR SELECT * FROM MOVIMIENTO_INVENTARIO WHERE FE_MOVIMIENTO >= TIMESTAMP '2026-10-01 00:00:00' AND FE_MOVIMIENTO < TIMESTAMP '2026-11-01 00:00:00';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Consulta de una partición concreta (nombre real según el SELECT anterior):
-- SELECT COUNT(*) FROM MOVIMIENTO_INVENTARIO PARTITION FOR (TIMESTAMP '2026-10-15 00:00:00');
-- Mantenimiento: archivar un fragmento antiguo
-- ALTER TABLE MOVIMIENTO_INVENTARIO DROP PARTITION FOR (TIMESTAMP '2026-01-15 00:00:00') UPDATE INDEXES;
