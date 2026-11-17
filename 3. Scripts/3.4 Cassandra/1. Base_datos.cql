-- MypeInventario | Cassandra 4.1/5.0 | Paso 1: keyspace (cqlsh)
-- Replicación: NetworkTopologyStrategy, 3 réplicas en datacenter1. Replicación asíncrona entre réplicas, consistencia ajustable por consulta.
CREATE KEYSPACE IF NOT EXISTS mypeinventario
  WITH replication = {'class':'NetworkTopologyStrategy','datacenter1':3} AND durable_writes = true;
