--!strict
--[[
	Datos guardados de cada jugador (Entrega 2B §1, aprobada).
	ProfileStore rellena automáticamente los campos que falten (Reconcile) con estos valores.
	Si cambia la FORMA de los datos: subir CURRENT_VERSION en DataService y escribir la migración.
]]

local DataTemplate = {
	DataVersion = 1,
	Level = 1,
	XP = 0,
	Affinity = {
		Selected = "", -- "" hasta elegir a nivel 5; luego "Fire" o "Lightning"
		Mastery = { Fire = 0, Lightning = 0 },
	},
	Inventory = {
		Weapons = { "Katana_Common" },
		EquippedWeapon = "Katana_Common",
		Potions = 0,
	},
	Cosmetics = {
		Owned = {} :: { string },
		EquippedTitle = "",
		EquippedAura = "",
	},
	Quests = {
		ActiveId = "Q01",
		Progress = 0,
		Completed = {} :: { [string]: boolean },
	},
	Fragments = {} :: { [string]: boolean },
	Campfires = { Camp = true } :: { [string]: boolean },
	LastCampfire = "Camp",
	Settings = {
		Language = "auto",
		ShowOthersDamage = true,
	},
	Meta = {
		FirstJoin = 0,
		PlayTime = 0,
	},
}

export type Data = typeof(DataTemplate)

return DataTemplate
