--!strict
-- Interruptores de depuración. Ponlos en false antes de publicar.

local Debug = {
	LogInput = true, -- muestra en Output cada acción pulsada
	LogCombat = true, -- muestra en Output ataques, golpes, esquivas y bloqueos
	StartingWeaponType = "Katana", -- arma con la que apareces: "Katana" o "Greatsword" (temporal hasta el inventario)
}

return table.freeze(Debug)
