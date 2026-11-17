@echo off
setlocal
REM MypeInventario - PostgreSQL 16 (Windows). Definir antes la variable de entorno PGPASSWORD (no escribir claves en el script).
set "PG_BIN=C:\Program Files\PostgreSQL\16\bin"
set "BACKUP_DIR=C:\backups\postgres"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmm"') do set "STAMP=%%i"
REM 1) Lógico completo (formato custom, comprimido)
"%PG_BIN%\pg_dump.exe" -U usr_backup -h localhost -p 5432 -d mypeinventario -F c -Z 6 -f "%BACKUP_DIR%\mype_full_%STAMP%.backup" || exit /b 1
REM 2) Solo esquema (para documentar/recrear estructura)
"%PG_BIN%\pg_dump.exe" -U usr_backup -h localhost -p 5432 -d mypeinventario -s -f "%BACKUP_DIR%\mype_esquema_%STAMP%.sql" || exit /b 1
REM 3) Tablas transaccionales (más cambiantes)
"%PG_BIN%\pg_dump.exe" -U usr_backup -h localhost -p 5432 -d mypeinventario -F c -t mype.venta_punto -t mype.detalle_venta -t mype.variante_sku -f "%BACKUP_DIR%\mype_transaccional_%STAMP%.backup" || exit /b 1
REM 4) Físico (base para PITR; requiere wal_level=replica y rol con REPLICATION)
"%PG_BIN%\pg_basebackup.exe" -U usr_backup -h localhost -D "%BACKUP_DIR%\base_%STAMP%" -F t -z -P
echo Backups finalizados en %BACKUP_DIR%
endlocal
