-- MypeInventario | Oracle 19c/21c | Paso 7: respaldo lógico con Data Pump (ver 4. Backups/Oracle para los .cmd)
-- Estrategia: Data Pump diario del esquema + RMAN semanal (físico) en un servidor con ARCHIVELOG.
-- Como SYS/SYSTEM en el PDB (crear antes la carpeta física C:\oracle_backups\mypeinventario en el SERVIDOR):
CREATE OR REPLACE DIRECTORY DIR_BACKUP AS 'C:\oracle_backups\mypeinventario';
GRANT READ, WRITE ON DIRECTORY DIR_BACKUP TO MYPE_OWNER;
-- Comprobar: SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM DBA_DIRECTORIES WHERE DIRECTORY_NAME='DIR_BACKUP';
