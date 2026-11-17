-- MypeInventario | PostgreSQL 16 | Paso 1: base de datos y esquema
-- Ejecutar desde la base 'postgres' como superusuario. El CREATE DATABASE NO puede ir en una transacción.
-- Si la base existe: DROP DATABASE IF EXISTS mypeinventario;  (solo en entorno de pruebas)
CREATE DATABASE mypeinventario WITH ENCODING 'UTF8' TEMPLATE template0;
-- Luego conectarse:  \c mypeinventario
-- Y ejecutar lo siguiente dentro de la base nueva:
CREATE SCHEMA IF NOT EXISTS mype;
COMMENT ON SCHEMA mype IS 'MypeInventario - dominio transaccional: catálogo, comerciantes y ventas (complementa al dominio Oracle: abastecimiento, pagos, kardex y alertas)';
