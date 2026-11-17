-- Evidencias para el informe. Antes, en terminal:  docker exec -it cass1 nodetool status   (3 nodos en estado UN)
DESCRIBE KEYSPACE mypeinventario;               -- muestra NetworkTopologyStrategy / datacenter1: 3
CONSISTENCY ONE;                                -- escritura aceptada por 1 réplica; las demás se actualizan de forma ASÍNCRONA
INSERT INTO mypeinventario.alertas_por_comerciante_estado (id_comerciante,estado,fe_generacion,id_alerta,id_sku,stock_actual,stock_minimo,canal_notificacion)
VALUES (999,'PENDIENTE',toTimestamp(now()),now(),1,2,5,'PUSH');
-- Dónde viven las réplicas:  docker exec -it cass1 nodetool getendpoints mypeinventario alertas_por_comerciante_estado '999:PENDIENTE'
CONSISTENCY QUORUM;                             -- lectura con 2 de 3 réplicas
SELECT * FROM mypeinventario.alertas_por_comerciante_estado WHERE id_comerciante=999 AND estado='PENDIENTE';
-- Tolerancia a fallos: docker stop cass3  -> las consultas con QUORUM siguen funcionando; al volver, hinted handoff/repair ponen al día:
--   docker exec -it cass3 nodetool repair mypeinventario
