--!strict
-- Interruptores de depuración. Ponlos en false antes de publicar.

local Debug = {
	LogInput = true, -- muestra en Output cada acción pulsada
	LogCombat = true, -- muestra en Output ataques, golpes, esquivas y bloqueos
	StartingWeaponType = "Katana", -- arma con la que apareces: "Katana" o "Greatsword" (temporal hasta el inventario)
	SpawnTrainingDummy = true, -- crea un muñeco de práctica al iniciar el servidor
	TrainingDummyPosition = Vector3.new(0, 3, -15),
}

return table.freeze(Debug)
