// Ejecutar UNA vez desde el host:  docker exec -i mongo1 mongosh --quiet < "1. Iniciar_replica.js"   (o pegar en mongosh de mongo1)
rs.initiate({ _id:'rsMype', members:[ {_id:0, host:'mongo1:27017', priority:2}, {_id:1, host:'mongo2:27017', priority:1}, {_id:2, host:'mongo3:27017', priority:1} ] });
// Esperar ~10 s y comprobar PRIMARY / SECONDARY / SECONDARY:
rs.status().members.forEach(m => print(m.name + ' -> ' + m.stateStr));
