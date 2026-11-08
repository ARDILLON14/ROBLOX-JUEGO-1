--!strict
--[[
	Misiones (GDD v1 §8.2, aprobado). Añadir una misión = añadir una fila (decisión B2).
	Flujo: hablar con quien la da (Available) → cumplir el objetivo (Active) → volver a hablar (ReadyToTurnIn) → recompensa.
	Tipos de objetivo de momento: "HitDummy" (golpear al muñeco) y "Defeat" (derrotar enemigos de un tipo).
]]

export type Quest = {
	NameKey: string,
	ObjectiveKey: string, -- texto del objetivo; puede usar {progress} y {count}
	Giver: string, -- NpcId de quien la da y la recibe
	Type: "HitDummy" | "Defeat",
	Target: string?, -- EnemyId para "Defeat"
	Count: number,
	RewardXP: number,
	RewardPotions: number,
	Next: string?, -- siguiente misión (nil = fin de lo disponible)
	DialogStartKey: string,
	DialogActiveKey: string,
	DialogDoneKey: string,
}

local Quests: { [string]: Quest } = {
	Q01 = {
		NameKey = "Quest_Q01_Name",
		ObjectiveKey = "Quest_Q01_Objective",
		Giver = "Ilen",
		Type = "HitDummy",
		Count = 5,
		RewardXP = 60,
		RewardPotions = 1,
		Next = "Q02",
		DialogStartKey = "Dialog_Q01_Start",
		DialogActiveKey = "Dialog_Q01_Active",
		DialogDoneKey = "Dialog_Q01_Done",
	},
	Q02 = {
		NameKey = "Quest_Q02_Name",
		ObjectiveKey = "Quest_Q02_Objective",
		Giver = "Ilen",
		Type = "Defeat",
		Target = "Thornling",
		Count = 6,
		RewardXP = 120,
		RewardPotions = 2,
		Next = nil, -- Q03 llegará después del slice vertical
		DialogStartKey = "Dialog_Q02_Start",
		DialogActiveKey = "Dialog_Q02_Active",
		DialogDoneKey = "Dialog_Q02_Done",
	},
}

return Quests
