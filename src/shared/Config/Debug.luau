--!strict
-- Interruptores de depuración. Ponlos en false antes de publicar.

local Debug = {
	LogInput = true, -- muestra en Output cada acción pulsada
	LogCombat = true, -- muestra en Output ataques, golpes, esquivas y bloqueos
	GiveAllWeapons = true, -- da las 6 armas al entrar (para probar el inventario; el juego real las da con misiones y botín)
	SpawnTrainingDummy = true, -- crea un muñeco de práctica al iniciar el servidor
	TrainingDummyPosition = Vector3.new(-14, 3, 12), -- zona de entrenamiento del campamento
	DummyXPPerHit = 0, -- XP por golpe al muñeco (solo para probar la subida de nivel; 0 = desactivado)
	SpawnTestEnemies = true, -- si el mapa no tiene puntos "EnemySpawn", crea uno de prueba
	TestEnemySpawnPosition = Vector3.new(30, 1, -30),
	LogData = true, -- mensajes de carga y guardado de datos
	MasteryMultiplier = 1, -- multiplica la maestría ganada (pon 20 para probar los rangos rápido; 1 = normal)
	BossHealthMultiplier = 1, -- multiplica la vida del jefe (pon 0.1 para probarlo rápido; 1 = normal)
	LogEnemies = true, -- mensajes de aparición y derrota de enemigos
}

return table.freeze(Debug)
