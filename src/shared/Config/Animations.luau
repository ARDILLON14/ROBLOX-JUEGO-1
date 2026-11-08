--!strict
--[[
	IDs de las animaciones. Formato: "rbxassetid://123456789".
	Si un ID está vacío (""), el combate funciona igual pero sin animación (aparece un aviso en Output).
	Cómo crear y publicar las animaciones: docs/seccion-3/entrega-3.2-combate-local.md
]]

export type WeaponAnimations = {
	Light: { string }, -- golpes 1, 2 y 3 del combo
	Heavy: string,
	Finisher: string, -- si está vacío se usa Heavy
}

local Animations = {
	Weapons = {
		Katana = {
			Light = { "", "", "" },
			Heavy = "",
			Finisher = "",
		},
		Greatsword = {
			Light = { "", "", "" },
			Heavy = "",
			Finisher = "",
		},
	} :: { [string]: WeaponAnimations },
	Dodge = "",
	Block = "", -- debe publicarse con "Loop" activado
}

return Animations
