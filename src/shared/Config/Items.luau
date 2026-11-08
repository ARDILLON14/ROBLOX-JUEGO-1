--!strict
-- Objetos (GDD v1 §8.1, aprobado).

local Items = {
	SapPotion = {
		NameKey = "Item_SapPotion",
		HealFraction = 0.4, -- cura el 40 % de la vida máxima
		Cooldown = 10,
		Max = 10,
	},
}

return table.freeze(Items)
