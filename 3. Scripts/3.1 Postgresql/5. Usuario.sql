-- MypeInventario | PostgreSQL 16 | Paso 5: administración de usuarios y roles (principio de mínimo privilegio)
-- Convención PostgreSQL 16: CREATE ROLE ... LOGIN PASSWORD (CREATE USER es solo un alias).
-- Ejecutar conectado a mypeinventario como superusuario. Cambiar las contraseñas antes de un uso real.
REVOKE ALL ON DATABASE mypeinventario FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Roles de grupo (sin login)
CREATE ROLE rol_operador NOLOGIN;
CREATE ROLE rol_analista NOLOGIN;
CREATE ROLE rol_soporte  NOLOGIN;

GRANT USAGE ON SCHEMA mype TO rol_operador, rol_analista, rol_soporte;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA mype TO rol_operador;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA mype TO rol_operador;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA mype TO rol_operador;
GRANT SELECT ON ALL TABLES IN SCHEMA mype TO rol_analista;
GRANT EXECUTE ON FUNCTION mype.fn_stock_bajo(INTEGER), mype.fn_ventas_por_canal(INTEGER,TIMESTAMP,TIMESTAMP), mype.fn_ticket_promedio(INTEGER) TO rol_analista;
GRANT SELECT ON mype.comerciante, mype.producto_item, mype.variante_sku TO rol_soporte;

-- Cuentas de login (CREATE ROLE ... LOGIN PASSWORD)
CREATE ROLE usr_operador LOGIN PASSWORD 'Cambiar_Operador#2026' CONNECTION LIMIT 20;
CREATE ROLE usr_analista LOGIN PASSWORD 'Cambiar_Analista#2026' CONNECTION LIMIT 20;
CREATE ROLE usr_soporte  LOGIN PASSWORD 'Cambiar_Soporte#2026'  CONNECTION LIMIT 5;
GRANT CONNECT ON DATABASE mypeinventario TO usr_operador, usr_analista, usr_soporte;
GRANT rol_operador TO usr_operador;
GRANT rol_analista TO usr_analista;
GRANT rol_soporte  TO usr_soporte;

-- Privilegio por columna (PostgreSQL lo soporta de forma nativa): soporte solo corrige datos de contacto del comerciante.
GRANT UPDATE (telefono_whatsapp, email) ON mype.comerciante TO rol_soporte;

-- Privilegios para objetos futuros (ejecutar como el rol propietario de los objetos)
ALTER DEFAULT PRIVILEGES IN SCHEMA mype GRANT SELECT, INSERT, UPDATE ON TABLES TO rol_operador;
ALTER DEFAULT PRIVILEGES IN SCHEMA mype GRANT SELECT ON TABLES TO rol_analista;
ALTER DEFAULT PRIVILEGES IN SCHEMA mype GRANT USAGE, SELECT ON SEQUENCES TO rol_operador;

-- Verificación: \du   |  SELECT grantee, table_name, privilege_type FROM information_schema.table_privileges WHERE table_schema='mype';
