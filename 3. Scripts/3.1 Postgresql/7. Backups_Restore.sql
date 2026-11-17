-- MypeInventario | PostgreSQL 16 | Paso 7: estrategia de respaldo (ver también 4. Backups/PostgreSQL)
-- Estrategia: (a) lógico diario con pg_dump -Fc; (b) físico semanal con pg_basebackup + archivado WAL para PITR.
-- Los comandos se ejecutan en terminal; este archivo deja los parámetros de servidor requeridos y las verificaciones.
-- 1) Parámetros para archivado WAL / PITR (postgresql.conf) — requieren reinicio:
--    wal_level = replica ; archive_mode = on ; archive_command = 'copy "%p" "C:\\backups\\wal\\%f"'
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET archive_mode = 'on';
-- 2) Rol dedicado a respaldo
CREATE ROLE usr_backup LOGIN REPLICATION PASSWORD 'Cambiar_Backup#2026';
GRANT pg_read_all_data TO usr_backup;
GRANT CONNECT ON DATABASE mypeinventario TO usr_backup;   -- imprescindible: en 5. Usuario.sql se revocó CONNECT a PUBLIC
-- 3) Verificación posterior a un restore de prueba (base mypeinventario_prueba):
--    SELECT COUNT(*) FROM mype.venta_punto;   -- debe coincidir con producción
