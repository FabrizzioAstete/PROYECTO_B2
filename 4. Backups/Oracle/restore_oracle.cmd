@echo off
REM Restauración de PRUEBA hacia otro esquema (crear antes MYPE_OWNER_TEST con cuota). Uso: restore_oracle.cmd mype_FECHA.dmp
impdp SYSTEM/%ORA_PWD%@XEPDB1 directory=DIR_BACKUP dumpfile=%1 logfile=mype_imp.log remap_schema=MYPE_OWNER:MYPE_OWNER_TEST
REM Validar:  SELECT COUNT(*) FROM MYPE_OWNER_TEST.MOVIMIENTO_INVENTARIO;
