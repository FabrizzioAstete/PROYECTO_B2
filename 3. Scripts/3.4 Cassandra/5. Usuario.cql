-- MypeInventario | Cassandra | Paso 5: administración de usuarios y roles
-- Requiere en cassandra.yaml:  authenticator: PasswordAuthenticator  y  authorizer: CassandraAuthorizer  (reiniciar nodos).
-- Primer ingreso:  cqlsh -u cassandra -p cassandra   -> luego cambiar la clave del superusuario por defecto:
ALTER ROLE cassandra WITH PASSWORD = 'Cambiar_SuperUser#2026';
CREATE ROLE IF NOT EXISTS rol_operador WITH LOGIN = false;
CREATE ROLE IF NOT EXISTS rol_analista WITH LOGIN = false;
CREATE ROLE IF NOT EXISTS rol_soporte  WITH LOGIN = false;
GRANT SELECT ON KEYSPACE mypeinventario TO rol_operador;
GRANT MODIFY ON KEYSPACE mypeinventario TO rol_operador;
GRANT SELECT ON KEYSPACE mypeinventario TO rol_analista;
GRANT SELECT ON TABLE mypeinventario.alertas_por_comerciante_estado TO rol_soporte;
GRANT MODIFY ON TABLE mypeinventario.alertas_por_comerciante_estado TO rol_soporte;
CREATE ROLE IF NOT EXISTS usr_operador WITH PASSWORD = 'Cambiar_Operador#2026' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS usr_analista WITH PASSWORD = 'Cambiar_Analista#2026' AND LOGIN = true;
CREATE ROLE IF NOT EXISTS usr_soporte  WITH PASSWORD = 'Cambiar_Soporte#2026'  AND LOGIN = true;
CREATE ROLE IF NOT EXISTS usr_backup   WITH PASSWORD = 'Cambiar_Backup#2026'   AND LOGIN = true;
GRANT rol_operador TO usr_operador;
GRANT rol_analista TO usr_analista;
GRANT rol_soporte  TO usr_soporte;
GRANT SELECT ON KEYSPACE mypeinventario TO usr_backup;   -- nodetool snapshot se ejecuta en el SO; este rol solo lee para verificaciones
-- Verificación: LIST ROLES;  LIST ALL PERMISSIONS OF rol_operador;
