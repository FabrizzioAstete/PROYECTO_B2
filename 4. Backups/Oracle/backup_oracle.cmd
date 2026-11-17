@echo off
REM MypeInventario - Oracle Data Pump. Requiere DIRECTORY DIR_BACKUP (ver 3.2 Oracle/7. Backups_Restore.sql). Definir ORA_PWD en el entorno.
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmm"') do set "STAMP=%%i"
expdp MYPE_OWNER/%ORA_PWD%@XEPDB1 schemas=MYPE_OWNER directory=DIR_BACKUP dumpfile=mype_%STAMP%.dmp logfile=mype_exp_%STAMP%.log
REM (Sin COMPRESSION=ALL: requiere licencia Advanced Compression y no existe en Oracle XE.)
REM Solo estructura:  expdp ... content=metadata_only
