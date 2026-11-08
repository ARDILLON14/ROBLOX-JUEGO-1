--!strict
-- Interruptores de depuración. Ponlos en false antes de publicar.

local Debug = {
	LogInput = true, -- muestra en Output cada acción pulsada
	LogCombat = true, -- muestra en Output ataques, golpes, esquivas y bloqueos
	StartingWeaponType = "Katana", -- arma con la que apareces: "Katana" o "Greatsword" (temporal hasta el inventario)
	SpawnTrainingDummy = true, -- crea un muñeco de práctica al iniciar el servidor
	TrainingDummyPosition = Vector3.new(-14, 3, 12), -- zona de entrenamiento del campamento
	DummyXPPerHit = 0, -- XP por golpe al muñeco (solo para probar la subida de nivel; 0 = desactivado)
	SpawnTestEnemies = true, -- si el mapa no tiene puntos "EnemySpawn", crea uno de prueba
	TestEnemySpawnPosition = Vector3.new(30, 1, -30),
	LogData = true, -- mensajes de carga y guardado de datos
	LogEnemies = true, -- mensajes de aparición y derrota de enemigos
}

return table.freeze(Debug)
