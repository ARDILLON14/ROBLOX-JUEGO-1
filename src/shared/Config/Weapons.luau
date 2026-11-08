--!strict
--[[
	Armas concretas (GDD v1 §5, aprobado): 2 tipos × 3 rarezas = 6 objetos con solo 2 modelos base.
	La rareza solo cambia el daño y el aspecto, no la forma de jugar.
]]

export type Rarity = "Common" | "Rare" | "Epic"

export type RarityConfig = {
	DamageMultiplier: number,
	NameKey: string,
	Color: Color3, -- color del texto en el inventario y tinte de la hoja
	Glow: boolean, -- hoja brillante (material Neon)
}

export type Weapon = {
	Type: string, -- clave en Config/WeaponTypes
	Rarity: Rarity,
	NameKey: string,
}

local Rarities: { [Rarity]: RarityConfig } = {
	Common = {
		DamageMultiplier = 1,
		NameKey = "Rarity_Common",
		Color = Color3.fromRGB(220, 225, 235),
		Glow = false,
	},
	Rare = {
		DamageMultiplier = 1.25,
		NameKey = "Rarity_Rare",
		Color = Color3.fromRGB(90, 160, 255),
		Glow = false,
	},
	Epic = {
		DamageMultiplier = 1.5,
		NameKey = "Rarity_Epic",
		Color = Color3.fromRGB(190, 110, 255),
		Glow = true,
	},
}

local Weapons: { [string]: Weapon } = {
	Katana_Common = { Type = "Katana", Rarity = "Common", NameKey = "Weapon_Katana_Common" },
	Katana_Rare = { Type = "Katana", Rarity = "Rare", NameKey = "Weapon_Katana_Rare" },
	Katana_Epic = { Type = "Katana", Rarity = "Epic", NameKey = "Weapon_Katana_Epic" },
	Greatsword_Common = { Type = "Greatsword", Rarity = "Common", NameKey = "Weapon_Greatsword_Common" },
	Greatsword_Rare = { Type = "Greatsword", Rarity = "Rare", NameKey = "Weapon_Greatsword_Rare" },
	Greatsword_Epic = { Type = "Greatsword", Rarity = "Epic", NameKey = "Weapon_Greatsword_Epic" },
}

-- Orden en que se muestran en el inventario.
local DisplayOrder = {
	"Katana_Common",
	"Katana_Rare",
	"Katana_Epic",
	"Greatsword_Common",
	"Greatsword_Rare",
	"Greatsword_Epic",
}

return {
	Weapons = Weapons,
	Rarities = Rarities,
	DisplayOrder = DisplayOrder,
	DefaultWeapon = "Katana_Common",
}
