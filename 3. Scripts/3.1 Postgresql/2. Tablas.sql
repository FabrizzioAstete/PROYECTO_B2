-- MypeInventario | PostgreSQL 16 | Paso 2: tablas (dominio CATÁLOGO + VENTAS)
-- Conectado a mypeinventario.
SET search_path TO mype;

-- COMERCIANTE: Dueño de tienda MYPE suscrito a la plataforma (cliente del SaaS)
CREATE TABLE COMERCIANTE (
  id_comerciante       INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombres              VARCHAR(80) NOT NULL,
  apellidos            VARCHAR(80) NOT NULL,
  dni                  CHAR(8) NOT NULL,
  email                VARCHAR(120) NOT NULL,
  telefono_whatsapp    VARCHAR(15) NOT NULL,
  nombre_negocio       VARCHAR(120) NOT NULL,
  ruc                  VARCHAR(11),
  plan_suscripcion     VARCHAR(10) DEFAULT 'PRUEBA' NOT NULL,
  estado               VARCHAR(10) DEFAULT 'ACTIVO' NOT NULL,
  fe_registro          TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT pk_comerciante PRIMARY KEY (id_comerciante),
  CONSTRAINT uk_comerciant_dni UNIQUE (dni),
  CONSTRAINT uk_comerciant_email UNIQUE (email),
  CONSTRAINT uk_comerciant_ruc UNIQUE (ruc),
  CONSTRAINT ck_comer_plan CHECK (plan_suscripcion IN ('PRUEBA','BASICO','ESTANDAR','PRO')),
  CONSTRAINT ck_comer_estado CHECK (estado IN ('ACTIVO','SUSPENDIDO','BAJA'))
);

-- CATEGORIA: Clasificación de productos
CREATE TABLE CATEGORIA (
  id_categoria         INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre               VARCHAR(60) NOT NULL,
  descripcion          VARCHAR(200),
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uk_categoria_nombre UNIQUE (nombre)
);

-- PROVEEDOR: Proveedor que abastece a los comerciantes
CREATE TABLE PROVEEDOR (
  id_proveedor         INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  razon_social         VARCHAR(120) NOT NULL,
  ruc                  VARCHAR(11) NOT NULL,
  telefono             VARCHAR(15),
  email                VARCHAR(120),
  direccion            VARCHAR(200),
  es_mayorista         CHAR(1) DEFAULT 'S' NOT NULL,
  CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor),
  CONSTRAINT uk_proveedor_ruc UNIQUE (ruc),
  CONSTRAINT ck_prov_mayorista CHECK (es_mayorista IN ('S','N'))
);

-- PRODUCTO_ITEM: Producto base del catálogo de un comerciante
CREATE TABLE PRODUCTO_ITEM (
  id_producto          INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_comerciante       INTEGER NOT NULL,
  id_categoria         INTEGER NOT NULL,
  id_proveedor         INTEGER,
  nombre               VARCHAR(120) NOT NULL,
  descripcion          VARCHAR(300),
  marca                VARCHAR(60),
  estado               VARCHAR(10) DEFAULT 'ACTIVO' NOT NULL,
  fe_creacion          TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT pk_producto_item PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_ite_comerciante FOREIGN KEY (id_comerciante) REFERENCES COMERCIANTE (id_comerciante),
  CONSTRAINT fk_producto_ite_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIA (id_categoria),
  CONSTRAINT fk_producto_ite_proveedor FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR (id_proveedor),
  CONSTRAINT ck_prod_estado CHECK (estado IN ('ACTIVO','INACTIVO'))
);

-- VARIANTE_SKU: Variante vendible (talla/color) con precio y stock
CREATE TABLE VARIANTE_SKU (
  id_sku               INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_producto          INTEGER NOT NULL,
  codigo_sku           VARCHAR(30) NOT NULL,
  codigo_barras        VARCHAR(20),
  talla                VARCHAR(10),
  color                VARCHAR(30),
  precio_compra        NUMERIC(10,2) NOT NULL,
  precio_venta         NUMERIC(10,2) NOT NULL,
  stock_actual         INTEGER DEFAULT 0 NOT NULL,
  stock_minimo         INTEGER DEFAULT 5 NOT NULL,
  estado               VARCHAR(10) DEFAULT 'ACTIVO' NOT NULL,
  CONSTRAINT pk_variante_sku PRIMARY KEY (id_sku),
  CONSTRAINT uk_sku_prod_cod UNIQUE (id_producto, codigo_sku),
  CONSTRAINT fk_variante_sku_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO_ITEM (id_producto),
  CONSTRAINT ck_sku_pcompra CHECK (precio_compra >= 0),
  CONSTRAINT ck_sku_pventa CHECK (precio_venta >= 0),
  CONSTRAINT ck_sku_stock CHECK (stock_actual >= 0),
  CONSTRAINT ck_sku_stockmin CHECK (stock_minimo >= 0),
  CONSTRAINT ck_sku_estado CHECK (estado IN ('ACTIVO','INACTIVO'))
);

-- VENTA_PUNTO: Cabecera de venta en punto de venta, ecommerce o WhatsApp
CREATE TABLE VENTA_PUNTO (
  id_venta             INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_comerciante       INTEGER NOT NULL,
  fe_venta             TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  total                NUMERIC(12,2) NOT NULL,
  metodo_pago          VARCHAR(15) NOT NULL,
  canal                VARCHAR(15) DEFAULT 'TIENDA' NOT NULL,
  estado               VARCHAR(10) DEFAULT 'REGISTRADA' NOT NULL,
  CONSTRAINT pk_venta_punto PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_punto_comerciante FOREIGN KEY (id_comerciante) REFERENCES COMERCIANTE (id_comerciante),
  CONSTRAINT ck_venta_total CHECK (total >= 0),
  CONSTRAINT ck_venta_pago CHECK (metodo_pago IN ('EFECTIVO','YAPE','PLIN','TARJETA','TRANSFERENCIA')),
  CONSTRAINT ck_venta_canal CHECK (canal IN ('TIENDA','ECOMMERCE','WHATSAPP')),
  CONSTRAINT ck_venta_estado CHECK (estado IN ('REGISTRADA','ANULADA'))
);

-- DETALLE_VENTA: Líneas de cada venta
CREATE TABLE DETALLE_VENTA (
  id_detalle           INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_venta             INTEGER NOT NULL,
  id_sku               INTEGER NOT NULL,
  cantidad             INTEGER NOT NULL,
  precio_unitario      NUMERIC(10,2) NOT NULL,
  subtotal             NUMERIC(12,2) NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_detalle),
  CONSTRAINT uk_det_venta_sku UNIQUE (id_venta, id_sku),
  CONSTRAINT fk_detalle_vent_venta FOREIGN KEY (id_venta) REFERENCES VENTA_PUNTO (id_venta),
  CONSTRAINT fk_detalle_vent_sku FOREIGN KEY (id_sku) REFERENCES VARIANTE_SKU (id_sku),
  CONSTRAINT ck_det_cantidad CHECK (cantidad > 0),
  CONSTRAINT ck_det_precio CHECK (precio_unitario >= 0)
);
