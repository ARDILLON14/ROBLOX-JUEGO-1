--!strict
--[[
	Mundo: fogatas y Fragmentos de Amanecer (GDD v1 §9, aprobado).
	Cada región futura añadirá sus filas aquí sin tocar el código (arquitectura aprobada, Entrega 2A §4.4).
]]

export type CampfireInfo = { NameKey: string, Order: number }
export type FragmentInfo = { LoreKey: string, Order: number }

-- Ambiente visual de cada zona (Atmosphere y corrección de color, solo en el cliente).
export type ZoneInfo = {
	NameKey: string,
	MinLevel: number?,
	MaxLevel: number?,
	IsBossArea: boolean?,
	AtmosphereDensity: number,
	AtmosphereColor: Color3,
	AtmosphereDecay: Color3,
	AtmosphereHaze: number,
	Tint: Color3,
	Saturation: number,
}

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

	Zones = {
		DawnCamp = {
			NameKey = "Campfire_Camp",
			AtmosphereDensity = 0.25,
			AtmosphereColor = Color3.fromRGB(217, 224, 204),
			AtmosphereDecay = Color3.fromRGB(140, 153, 128),
			AtmosphereHaze = 1,
			Tint = Color3.fromRGB(255, 250, 240),
			Saturation = 0.15,
		},
		EmeraldVerge = {
			NameKey = "Campfire_Verge",
			MinLevel = 1,
			MaxLevel = 5,
			AtmosphereDensity = 0.3,
			AtmosphereColor = Color3.fromRGB(199, 224, 199),
			AtmosphereDecay = Color3.fromRGB(102, 148, 107),
			AtmosphereHaze = 1.4,
			Tint = Color3.fromRGB(245, 255, 242),
			Saturation = 0.2,
		},
		AelithRuins = {
			NameKey = "Campfire_Ruins",
			MinLevel = 6,
			MaxLevel = 12,
			AtmosphereDensity = 0.33,
			AtmosphereColor = Color3.fromRGB(204, 204, 209),
			AtmosphereDecay = Color3.fromRGB(128, 128, 140),
			AtmosphereHaze = 1.6,
			Tint = Color3.fromRGB(247, 247, 255),
			Saturation = 0.08,
		},
		WitheredHollow = {
			NameKey = "Campfire_Hollow",
			MinLevel = 12,
			MaxLevel = 18,
			AtmosphereDensity = 0.42,
			AtmosphereColor = Color3.fromRGB(153, 128, 179),
			AtmosphereDecay = Color3.fromRGB(89, 64, 115),
			AtmosphereHaze = 2.5,
			Tint = Color3.fromRGB(235, 220, 255),
			Saturation = -0.05,
		},
		ForestHeart = {
			NameKey = "Campfire_Heart",
			IsBossArea = true,
			AtmosphereDensity = 0.38,
			AtmosphereColor = Color3.fromRGB(179, 140, 204),
			AtmosphereDecay = Color3.fromRGB(102, 64, 128),
			AtmosphereHaze = 2,
			Tint = Color3.fromRGB(242, 224, 255),
			Saturation = 0.05,
		},
	} :: { [string]: ZoneInfo },

	FragmentXP = 100, -- bonus fijo de XP por Fragmento
	CampfireRange = 12, -- distancia para usar el viaje rápido
	CombatLockTime = 8, -- segundos sin recibir daño para poder viajar
}

return World
