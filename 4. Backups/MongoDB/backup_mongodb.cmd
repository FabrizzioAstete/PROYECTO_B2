@echo off
REM MypeInventario - MongoDB. Definir MYPE_PWD_BK en el entorno. Requiere mongodb-database-tools en el PATH.
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmm"') do set "STAMP=%%i"
mongodump --uri="mongodb://usr_backup:%MYPE_PWD_BK%@localhost:27017/?authSource=admin&directConnection=true" --db=mypeinventario --gzip --out="C:\backups\mongo\mongo_%STAMP%"
