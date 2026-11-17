// MypeInventario | MongoDB | Paso 6: datos sintéticos — 100 por participante x 5 = 500 por colección principal (AJUSTAR N)
use('mypeinventario');
const N = 500;
const cats = ['Ropa','Calzado','Bazar','Accesorios','Hogar'], tallas=['S','M','L','XL'], colores=['Negro','Blanco','Azul','Rojo'];
const prods = [], perf = [], promos = [];
for (let g = 1; g <= N; g++) {
  prods.push({ producto_id: NumberInt(g), comerciante_id: NumberInt(((g-1) % 100) + 1), nombre: 'Producto Demo ' + g, categoria: cats[g % 5],
    marca: 'Marca ' + (g % 10), estado: 'ACTIVO', etiquetas: ['demo', cats[g % 5].toLowerCase()], atributos: { material: g % 2 ? 'algodón' : 'poliéster' },
    proveedor: { proveedor_id: NumberInt(g), razon_social: 'Proveedor Demo ' + g },
    variantes: [ { sku: 'SKU-' + String(g).padStart(4,'0'), talla: tallas[g % 4], color: colores[g % 4], precio_venta: 15 + (g % 30), stock_actual: NumberInt(g % 12), stock_minimo: NumberInt(5) } ],
    fe_creacion: new Date() });
  perf.push({ comerciante_id: NumberInt(g), nombre_negocio: 'Tienda Demo ' + g, plan: ['PRUEBA','BASICO','ESTANDAR','PRO'][g % 4],
    notificaciones: { canales: g % 2 ? ['PUSH','WHATSAPP'] : ['PUSH','EMAIL'], hora_resumen: '08:00' },
    horario_atencion: [ { dia:'LUN-SAB', desde:'09:00', hasta:'20:00' } ], meta_mensual: 3000 + (g % 10) * 500, sucursales: [ { nombre:'Principal', distrito:'Lima' } ] });
  const ini = new Date(Date.now() - (g % 20) * 86400000), fin = new Date(Date.now() + ((g % 30) + 1) * 86400000);
  promos.push({ promo_id: NumberInt(g), comerciante_id: NumberInt(((g-1) % 100) + 1), nombre: 'Promo ' + g, tipo: ['PORCENTAJE','MONTO','2X1'][g % 3], valor: 5 + (g % 15),
    vigencia: { desde: ini, hasta: fin }, skus: ['SKU-' + String(g).padStart(4,'0')], canales: g % 2 ? ['TIENDA','WHATSAPP'] : ['ECOMMERCE'],
    estado: g % 10 === 0 ? 'PAUSADA' : 'ACTIVA', expira_en: fin });
}
db.catalogo_producto.insertMany(prods); db.perfil_comerciante.insertMany(perf); db.promocion.insertMany(promos);
print('catalogo_producto:', db.catalogo_producto.countDocuments(), ' perfil_comerciante:', db.perfil_comerciante.countDocuments(), ' promocion:', db.promocion.countDocuments());
