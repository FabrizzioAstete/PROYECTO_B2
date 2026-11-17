# MypeInventario – Base de Datos 2 · Segundo entregable (avance 50 %)

Sistema de inventario y ventas para MYPE con **persistencia políglota**: cada motor guarda tablas/colecciones **complementarias (no iguales)**.

| Motor | Dominio | Objetos |
|---|---|---|
| PostgreSQL 16 | Catálogo y ventas | COMERCIANTE, CATEGORIA, PROVEEDOR, PRODUCTO_ITEM, VARIANTE_SKU, VENTA_PUNTO, DETALLE_VENTA |
| Oracle 19c/21c | Abastecimiento, pagos, kardex, alertas, auditoría | ORDEN_COMPRA, DETALLE_ORDEN_COMPRA, PAGO_VENTA, MOVIMIENTO_INVENTARIO, ALERTA_REABASTECIMIENTO, AUDITORIA_PRECIO |
| MongoDB 7 | Documentos flexibles | catalogo_producto, perfil_comerciante, promocion |
| Cassandra 4.1/5 | Series de tiempo y eventos | kardex_por_sku, ventas_por_comerciante_dia, ventas_por_canal_mes, alertas_por_comerciante_estado |

Los ids de PostgreSQL se usan como **referencias lógicas** en los otros motores (no hay FK entre motores). Los datos son sintéticos: los ids coinciden en forma, pero no todos los atributos (p. ej. categoría o totales) son idénticos entre motores.

## Estructura del repositorio
```
BASE DE DATOS 2
├─ 1. Informe          (Informe_Base_Datos.docx / .pdf; espacios amarillos = capturas por insertar)
├─ 2. Anexos          (Project_Charter, Diccionario_datos.xlsx, Arquitectura_distribuida.png)
├─ 3. Scripts
│   ├─ 3.1 Postgresql  (1..7 + DiagramaLogico.png + Fragmentacion/Scripts)
│   ├─ 3.2 Oracle      (1..7 + DiagramaLogico.png + Fragmentacion/Scripts)
│   ├─ 3.3 MongoDB     (1..7 + Replicacion/Scripts + Fragmentacion/Scripts)
│   └─ 3.4 Cassandra   (1..7 + Replicacion/Scripts)
└─ 4. Backups          (PostgreSQL, Oracle, MongoDB, Cassandra)
```

## ORDEN DE EJECUCIÓN (por motor)
El número del archivo = orden de ejecución. Fragmentación va **después** de la data.

**PostgreSQL**: `1. Base_datos.sql` (desde `postgres`) → `\c mypeinventario` → `2. Tablas` → `3. Indices` → `4. Procedure_Functions` → `5. Usuario` → `6. Data` → `Fragmentacion/Scripts/1. Fragmentacion.sql` → `7. Backups_Restore.sql` + `4. Backups/PostgreSQL`.

**Oracle** (SYS en el PDB): `1. Base_datos.sql` → (como `MYPE_OWNER`) `2. Tablas` → `3. Indices` → `4. Procedure_Functions` → (como SYS) `5. Usuario` → (como `MYPE_OWNER`) `6. Data` → `Fragmentacion/Scripts/1. Fragmentacion.sql` → (SYS) `7. Backups_Restore.sql` + `4. Backups/Oracle`.

**MongoDB** (`mongosh`): `1. Base_datos.js` → `2. Indices.js` → `6. Data.js` → `3. Consultas_Negocio.js` → `5. Usuario.js` (requiere autenticación habilitada) → `Replicacion/Scripts` (docker compose + `1`, `2`) → `Fragmentacion/Scripts` (solo en clúster con mongos) → `7. Backups_Restore.sh`.

**Cassandra** (`cqlsh`): `1. Base_datos.cql` → `2. Tablas.cql` → `3. Indices.cql` → `6. Data.cql` → `4. Consultas_Negocio.cql` → `5. Usuario.cql` (requiere PasswordAuthenticator) → `Replicacion/Scripts` → `7. Backups_Restore.sh`.

## Integrantes y volumen de datos
Grupo de **5 integrantes** → 100 registros por participante = 500 en las tablas principales de cada motor (verificado en los scripts de data).
Lista de evidencias a capturar: ver `CAPTURAS.md`.

## Convenciones
- Oracle: identificadores en **MAYÚSCULAS sin comillas**; solo las contraseñas van entre comillas dobles.
- PostgreSQL: minúsculas; cuentas con `CREATE ROLE … LOGIN PASSWORD` (convención PG 16).
- Diccionario: `NULL`/`NOT NULL`; DEFAULT vacío se escribe `N/A`.
- Contraseñas de los scripts son de ejemplo: cambiarlas. Backups usan variables de entorno.
- Datos: 100 registros por participante × 5 participantes = 500 (ajustar `N`/`:n` si el grupo es distinto).
- Replicación/sharding **solo se declaran probados con capturas reales** del clúster (docker-compose incluidos).
