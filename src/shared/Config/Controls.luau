--!strict
--[[
	Controls
	El juego solo conoce ACCIONES ("LightAttack", "Block"...), nunca teclas.
	Aquí se decide qué tecla activa cada acción. En el futuro, los botones táctiles
	activarán las mismas acciones sin tocar el combate.
]]

export type Binding = {
	PC: { EnumItem }, -- teclas (Enum.KeyCode) o botones del ratón (Enum.UserInputType)
}

local Actions: { [string]: Binding } = {
	LightAttack = { PC = { Enum.UserInputType.MouseButton1 } },
	HeavyAttack = { PC = { Enum.UserInputType.MouseButton2 } },
	Block = { PC = { Enum.KeyCode.F } },
	Dodge = { PC = { Enum.KeyCode.Q } },
	Skill = { PC = { Enum.KeyCode.Z } },
	Ultimate = { PC = { Enum.KeyCode.X } },
	UsePotion = { PC = { Enum.KeyCode.One } },
	Inventory = { PC = { Enum.KeyCode.Tab } },
	Journal = { PC = { Enum.KeyCode.J } },
	FreeCursor = { PC = { Enum.KeyCode.LeftAlt } }, -- mantener para liberar el ratón
}

return {
	Actions = Actions,
}
