-- MypeInventario | Oracle 19c/21c | Paso 2: tablas (dominio ABASTECIMIENTO, PAGOS, KARDEX, ALERTAS, AUDITORÍA)
-- Complementa a PostgreSQL (catálogo y ventas): NO repite sus tablas. Las columnas marcadas como 'ref. lógica' apuntan a ids de
-- PostgreSQL (arquitectura distribuida: no hay FK entre motores; la consistencia la garantiza la aplicación / carga ETL).
-- Conectado como MYPE_OWNER.

-- ORDEN_COMPRA: Orden de compra a proveedores (abastecimiento)
CREATE TABLE ORDEN_COMPRA (
  id_orden             NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_comerciante       NUMBER(10) NOT NULL,
  id_proveedor         NUMBER(10) NOT NULL,
  fe_orden             TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  fe_recepcion         TIMESTAMP,
  total                NUMBER(12,2) DEFAULT 0 NOT NULL,
  estado               VARCHAR2(10) DEFAULT 'BORRADOR' NOT NULL,
  CONSTRAINT pk_orden_compra PRIMARY KEY (id_orden),
  CONSTRAINT ck_oc_estado CHECK (estado IN ('BORRADOR','ENVIADA','RECIBIDA','ANULADA')),
  CONSTRAINT ck_oc_total CHECK (total >= 0)
);

-- DETALLE_ORDEN_COMPRA: Líneas de la orden de compra
CREATE TABLE DETALLE_ORDEN_COMPRA (
  id_detalle_oc        NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_orden             NUMBER(10) NOT NULL,
  id_sku               NUMBER(10) NOT NULL,
  cantidad             NUMBER(10) NOT NULL,
  costo_unitario       NUMBER(10,2) NOT NULL,
  subtotal             NUMBER(12,2) NOT NULL,
  CONSTRAINT pk_detalle_orden_compra PRIMARY KEY (id_detalle_oc),
  CONSTRAINT fk_detalle_orde_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_COMPRA (id_orden),
  CONSTRAINT ck_doc_cant CHECK (cantidad > 0),
  CONSTRAINT ck_doc_costo CHECK (costo_unitario >= 0)
);

-- PAGO_VENTA: Cobros asociados a ventas (conciliación financiera)
CREATE TABLE PAGO_VENTA (
  id_pago              NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_venta             NUMBER(10) NOT NULL,
  id_comerciante       NUMBER(10) NOT NULL,
  metodo_pago          VARCHAR2(15) NOT NULL,
  monto                NUMBER(12,2) NOT NULL,
  nro_operacion        VARCHAR2(30),
  fe_pago              TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  estado               VARCHAR2(12) DEFAULT 'CONFIRMADO' NOT NULL,
  CONSTRAINT pk_pago_venta PRIMARY KEY (id_pago),
  CONSTRAINT ck_pago_estado CHECK (estado IN ('CONFIRMADO','PENDIENTE','RECHAZADO')),
  CONSTRAINT ck_pago_monto CHECK (monto >= 0)
);

-- MOVIMIENTO_INVENTARIO: Kardex de entradas/salidas/ajustes (tabla particionada por mes)
CREATE TABLE MOVIMIENTO_INVENTARIO (
  id_movimiento        NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_sku               NUMBER(10) NOT NULL,
  id_orden             NUMBER(10),
  id_venta             NUMBER(10),
  tipo_movimiento      VARCHAR2(10) NOT NULL,
  motivo               VARCHAR2(15) NOT NULL,
  cantidad             NUMBER(10) NOT NULL,
  fe_movimiento        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  observacion          VARCHAR2(200),
  CONSTRAINT pk_movimiento_inventario PRIMARY KEY (id_movimiento),
  CONSTRAINT fk_movimiento_i_orden FOREIGN KEY (id_orden) REFERENCES ORDEN_COMPRA (id_orden),
  CONSTRAINT ck_mov_tipo CHECK (tipo_movimiento IN ('ENTRADA','SALIDA','AJUSTE')),
  CONSTRAINT ck_mov_motivo CHECK (motivo IN ('COMPRA','VENTA','DEVOLUCION','MERMA','AJUSTE')),
  CONSTRAINT ck_mov_cantidad CHECK (cantidad > 0)
) PARTITION BY RANGE (fe_movimiento) INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(PARTITION p_inicial VALUES LESS THAN (TIMESTAMP '2026-01-01 00:00:00'));

-- ALERTA_REABASTECIMIENTO: Alertas de stock bajo generadas por el sistema
CREATE TABLE ALERTA_REABASTECIMIENTO (
  id_alerta            NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_sku               NUMBER(10) NOT NULL,
  id_comerciante       NUMBER(10) NOT NULL,
  fe_generacion        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  stock_al_generar     NUMBER(10) NOT NULL,
  stock_minimo         NUMBER(10) NOT NULL,
  canal_notificacion   VARCHAR2(10) DEFAULT 'PUSH' NOT NULL,
  estado               VARCHAR2(10) DEFAULT 'PENDIENTE' NOT NULL,
  fe_atencion          TIMESTAMP,
  CONSTRAINT pk_alerta_reabastecimiento PRIMARY KEY (id_alerta),
  CONSTRAINT ck_alerta_canal CHECK (canal_notificacion IN ('PUSH','WHATSAPP','EMAIL')),
  CONSTRAINT ck_alerta_estado CHECK (estado IN ('PENDIENTE','ENVIADA','ATENDIDA'))
);

-- AUDITORIA_PRECIO: Historial de cambios de precio de venta
CREATE TABLE AUDITORIA_PRECIO (
  id_auditoria         NUMBER(10) GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_sku               NUMBER(10) NOT NULL,
  precio_anterior      NUMBER(10,2) NOT NULL,
  precio_nuevo         NUMBER(10,2) NOT NULL,
  usuario_bd           VARCHAR2(30) DEFAULT USER NOT NULL,
  fe_cambio            TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  motivo               VARCHAR2(100),
  CONSTRAINT pk_auditoria_precio PRIMARY KEY (id_auditoria),
  CONSTRAINT ck_aud_precios CHECK (precio_anterior >= 0 AND precio_nuevo >= 0)
);
