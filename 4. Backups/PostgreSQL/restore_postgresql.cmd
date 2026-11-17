@echo off
REM Restauración de PRUEBA (no pisa producción). Crear antes:  CREATE DATABASE mypeinventario_prueba;
set "PG_BIN=C:\Program Files\PostgreSQL\16\bin"
set "ARCHIVO=%1"
if "%ARCHIVO%"=="" (echo Uso: restore_postgresql.cmd C:\backups\postgres\mype_full_FECHA.backup & exit /b 1)
"%PG_BIN%\pg_restore.exe" -U postgres -h localhost -p 5432 -d mypeinventario_prueba --clean --if-exists --no-owner "%ARCHIVO%"
"%PG_BIN%\psql.exe" -U postgres -d mypeinventario_prueba -c "SELECT COUNT(*) FROM mype.venta_punto;"
