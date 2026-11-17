-- MypeInventario | PostgreSQL 16 | Paso 6: datos sintéticos reproducibles
-- 100 registros por participante x 5 participantes = 500 en las tablas principales (AJUSTAR :n si el grupo es distinto).
-- Ejecutar en base limpia, DESPUÉS de crear tablas y procedimientos, y ANTES de la fragmentación.
SET search_path TO mype, public;
\set n 500
INSERT INTO comerciante(nombres,apellidos,dni,email,telefono_whatsapp,nombre_negocio,ruc,plan_suscripcion,estado)
SELECT 'Comerciante'||g,'Prueba','7'||lpad(g::text,7,'0'),'comerciante'||g||'@example.test','900'||lpad(g::text,6,'0'),'Tienda Demo '||g,
       CASE WHEN g%3=0 THEN '10'||lpad(g::text,9,'0') END,(ARRAY['PRUEBA','BASICO','ESTANDAR','PRO'])[g%4+1],'ACTIVO'
FROM generate_series(1,:n) g;
INSERT INTO categoria(nombre,descripcion) SELECT x,'Categoría de prueba '||x FROM (VALUES('Ropa'),('Calzado'),('Bazar'),('Accesorios'),('Hogar')) v(x);
INSERT INTO proveedor(razon_social,ruc,telefono,email,direccion,es_mayorista)
SELECT 'Proveedor Demo '||g,'20'||lpad(g::text,9,'0'),'910'||lpad(g::text,6,'0'),'proveedor'||g||'@example.test','Lima',CASE WHEN g%4=0 THEN 'N' ELSE 'S' END FROM generate_series(1,:n) g;
INSERT INTO producto_item(id_comerciante,id_categoria,id_proveedor,nombre,descripcion,marca,estado)
SELECT g,((g-1)%5)+1,g,'Producto Demo '||g,'Registro sintético para pruebas','Marca '||(g%10),'ACTIVO' FROM generate_series(1,:n) g;
INSERT INTO variante_sku(id_producto,codigo_sku,codigo_barras,talla,color,precio_compra,precio_venta,stock_actual,stock_minimo,estado)
SELECT g,'SKU-'||lpad(g::text,4,'0'),'775'||lpad(g::text,10,'0'),(ARRAY['S','M','L','XL'])[g%4+1],(ARRAY['Negro','Blanco','Azul','Rojo'])[g%4+1],
       10+(g%20),15+(g%30),(g%12),5,'ACTIVO' FROM generate_series(1,:n) g;
INSERT INTO venta_punto(id_comerciante,fe_venta,total,metodo_pago,canal,estado)
SELECT g,CURRENT_TIMESTAMP-(g*7||' hours')::interval,0,(ARRAY['EFECTIVO','YAPE','PLIN','TARJETA','TRANSFERENCIA'])[g%5+1],(ARRAY['TIENDA','ECOMMERCE','WHATSAPP'])[g%3+1],'REGISTRADA'
FROM generate_series(1,:n) g;
-- El trigger tg_detalle_subtotal calcula subtotal; luego se consolida el total de cada venta
INSERT INTO detalle_venta(id_venta,id_sku,cantidad,precio_unitario,subtotal) SELECT g,g,1+(g%3),15+(g%30),0 FROM generate_series(1,:n) g;
UPDATE venta_punto v SET total = d.subtotal FROM detalle_venta d WHERE d.id_venta = v.id_venta;
-- Verificación de volumen
SELECT 'COMERCIANTE' tabla,COUNT(*) FROM comerciante UNION ALL SELECT 'CATEGORIA',COUNT(*) FROM categoria UNION ALL SELECT 'PROVEEDOR',COUNT(*) FROM proveedor
UNION ALL SELECT 'PRODUCTO_ITEM',COUNT(*) FROM producto_item UNION ALL SELECT 'VARIANTE_SKU',COUNT(*) FROM variante_sku
UNION ALL SELECT 'VENTA_PUNTO',COUNT(*) FROM venta_punto UNION ALL SELECT 'DETALLE_VENTA',COUNT(*) FROM detalle_venta;
