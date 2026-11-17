// MypeInventario | MongoDB 7 | Paso 5: administración de usuarios y roles (RBAC)
// Requiere autenticación habilitada (security.authorization: enabled). Ejecutar como administrador:
//   mongosh -u admin -p --authenticationDatabase admin --file "5. Usuario.js"
// Las contraseñas se leen de variables de entorno; si no existen se usa un valor de ejemplo (CAMBIAR).
use('mypeinventario');
const col = (c, a) => ({ resource:{ db:'mypeinventario', collection:c }, actions:a });
db.createRole({ role:'mype_operador', roles:[], privileges:[ col('catalogo_producto',['find','insert','update']), col('perfil_comerciante',['find','insert','update']), col('promocion',['find','insert','update','remove']) ] });
db.createRole({ role:'mype_analista', roles:[], privileges:[ col('catalogo_producto',['find']), col('perfil_comerciante',['find']), col('promocion',['find']) ] });
db.createRole({ role:'mype_soporte',  roles:[], privileges:[ col('catalogo_producto',['find']), col('promocion',['find','update']) ] });
db.createUser({ user:'usr_operador', pwd: process.env.MYPE_PWD_OP || 'Cambiar_Operador#2026', roles:[{role:'mype_operador',db:'mypeinventario'}] });
db.createUser({ user:'usr_analista', pwd: process.env.MYPE_PWD_AN || 'Cambiar_Analista#2026', roles:[{role:'mype_analista',db:'mypeinventario'}] });
db.createUser({ user:'usr_soporte',  pwd: process.env.MYPE_PWD_SO || 'Cambiar_Soporte#2026',  roles:[{role:'mype_soporte', db:'mypeinventario'}] });
// Usuario para respaldos (rol integrado 'backup' y 'restore' en admin):
use('admin');
db.createUser({ user:'usr_backup', pwd: process.env.MYPE_PWD_BK || 'Cambiar_Backup#2026', roles:['backup','restore'] });
// Verificación: db.getUsers(); db.getRoles({showPrivileges:true})
