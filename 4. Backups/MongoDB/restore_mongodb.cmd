@echo off
REM Restauración de PRUEBA a otra base. Uso: restore_mongodb.cmd C:\backups\mongo\mongo_FECHA
mongorestore --uri="mongodb://usr_backup:%MYPE_PWD_BK%@localhost:27017/?authSource=admin&directConnection=true" --gzip --nsFrom="mypeinventario.*" --nsTo="mypeinventario_restore.*" "%1\mypeinventario"
