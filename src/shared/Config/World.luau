--!strict
--[[
	Mundo: fogatas y Fragmentos de Amanecer (GDD v1 §9, aprobado).
	Cada región futura añadirá sus filas aquí sin tocar el código (arquitectura aprobada, Entrega 2A §4.4).
]]

export type CampfireInfo = { NameKey: string, Order: number }
export type FragmentInfo = { LoreKey: string, Order: number }

local World = {
	Campfires = {
		Camp = { NameKey = "Campfire_Camp", Order = 1 },
		Verge = { NameKey = "Campfire_Verge", Order = 2 },
		Ruins = { NameKey = "Campfire_Ruins", Order = 3 },
		Hollow = { NameKey = "Campfire_Hollow", Order = 4 },
		Heart = { NameKey = "Campfire_Heart", Order = 5 },
	} :: { [string]: CampfireInfo },

	Fragments = {
		F01 = { LoreKey = "Lore_F01", Order = 1 },
		F02 = { LoreKey = "Lore_F02", Order = 2 },
		F03 = { LoreKey = "Lore_F03", Order = 3 },
		F04 = { LoreKey = "Lore_F04", Order = 4 },
		F05 = { LoreKey = "Lore_F05", Order = 5 },
		F06 = { LoreKey = "Lore_F06", Order = 6 },
		F07 = { LoreKey = "Lore_F07", Order = 7 },
		F08 = { LoreKey = "Lore_F08", Order = 8 },
		F09 = { LoreKey = "Lore_F09", Order = 9 },
		F10 = { LoreKey = "Lore_F10", Order = 10 },
	} :: { [string]: FragmentInfo },

	FragmentXP = 100, -- bonus fijo de XP por Fragmento
	CampfireRange = 12, -- distancia para usar el viaje rápido
	CombatLockTime = 8, -- segundos sin recibir daño para poder viajar
}

return World
