--!strict
--[[
	Misiones (GDD v1 §8.2, aprobado). Añadir una misión = añadir una fila y ponerla en Order (decisión B2).
	Flujo: hablar con quien la da (Available) → cumplir el objetivo (Active) → volver a hablar (ReadyToTurnIn) → recompensa.
	Tipos de objetivo:
	  "HitDummy"       golpear al muñeco de práctica
	  "Defeat"         derrotar enemigos de un tipo (Target = EnemyId)
	  "GoTo"           llegar a un punto del mapa (MarkerId = pieza con etiqueta "QuestMarker")
	  "ChooseAffinity" despertar una afinidad en el Santuario
	  "Collect"        conseguir objetos que sueltan los enemigos (CollectChance por enemigo derrotado)
]]

export type QuestType = "HitDummy" | "Defeat" | "GoTo" | "ChooseAffinity" | "Collect"

export type Quest = {
	NameKey: string,
	ObjectiveKey: string, -- texto del objetivo; puede usar {progress} y {count}
	Giver: string, -- NpcId de quien la da y la recibe
	Type: QuestType,
	Target: string?, -- EnemyId para "Defeat"
	MarkerId: string?, -- punto del mapa que se marca (GoTo / ChooseAffinity)
	Count: number,
	CollectChance: number?,
	RequiredLevel: number?,
	RewardXP: number,
	RewardPotions: number,
	RewardWeapon: string?, -- arma concreta
	RewardRareOfEquipped: boolean?, -- arma rara del tipo que llevas equipado
	DialogStartKey: string,
	DialogActiveKey: string,
	DialogDoneKey: string,
	DialogLockedKey: string?, -- si no tienes el nivel necesario
}

local List: { [string]: Quest } = {
	Q01 = {
		NameKey = "Quest_Q01_Name",
		ObjectiveKey = "Quest_Q01_Objective",
		Giver = "Ilen",
		Type = "HitDummy",
		Count = 5,
		RewardXP = 60,
		RewardPotions = 1,
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
		DialogStartKey = "Dialog_Q02_Start",
		DialogActiveKey = "Dialog_Q02_Active",
		DialogDoneKey = "Dialog_Q02_Done",
	},
	Q03 = {
		NameKey = "Quest_Q03_Name",
		ObjectiveKey = "Quest_Q03_Objective",
		Giver = "Ilen",
		Type = "GoTo",
		MarkerId = "VergeRuins",
		Count = 1,
		RewardXP = 150,
		RewardPotions = 0,
		DialogStartKey = "Dialog_Q03_Start",
		DialogActiveKey = "Dialog_Q03_Active",
		DialogDoneKey = "Dialog_Q03_Done",
	},
	Q04 = {
		NameKey = "Quest_Q04_Name",
		ObjectiveKey = "Quest_Q04_Objective",
		Giver = "Ilen",
		Type = "Defeat",
		Target = "Spitter",
		Count = 4,
		RewardXP = 200,
		RewardPotions = 1,
		RewardWeapon = "Greatsword_Common",
		DialogStartKey = "Dialog_Q04_Start",
		DialogActiveKey = "Dialog_Q04_Active",
		DialogDoneKey = "Dialog_Q04_Done",
	},
	Q05 = {
		NameKey = "Quest_Q05_Name",
		ObjectiveKey = "Quest_Q05_Objective",
		Giver = "Ilen",
		Type = "ChooseAffinity",
		MarkerId = "Shrine",
		Count = 1,
		RequiredLevel = 5,
		RewardXP = 250,
		RewardPotions = 1,
		DialogStartKey = "Dialog_Q05_Start",
		DialogActiveKey = "Dialog_Q05_Active",
		DialogDoneKey = "Dialog_Q05_Done",
		DialogLockedKey = "Dialog_Q05_Locked",
	},
	Q06 = {
		NameKey = "Quest_Q06_Name",
		ObjectiveKey = "Quest_Q06_Objective",
		Giver = "Ilen",
		Type = "Defeat",
		Target = "Sentry",
		Count = 3,
		RequiredLevel = 6,
		RewardXP = 500,
		RewardPotions = 1,
		RewardRareOfEquipped = true,
		DialogStartKey = "Dialog_Q06_Start",
		DialogActiveKey = "Dialog_Q06_Active",
		DialogDoneKey = "Dialog_Q06_Done",
		DialogLockedKey = "Dialog_Q06_Locked",
	},
	Q07 = {
		NameKey = "Quest_Q07_Name",
		ObjectiveKey = "Quest_Q07_Objective",
		Giver = "Ilen",
		Type = "Collect",
		Count = 5,
		CollectChance = 0.5,
		RequiredLevel = 10,
		RewardXP = 900,
		RewardPotions = 3,
		DialogStartKey = "Dialog_Q07_Start",
		DialogActiveKey = "Dialog_Q07_Active",
		DialogDoneKey = "Dialog_Q07_Done",
		DialogLockedKey = "Dialog_Q07_Locked",
	},
	Q08 = {
		NameKey = "Quest_Q08_Name",
		ObjectiveKey = "Quest_Q08_Objective",
		Giver = "Ilen",
		Type = "Defeat",
		Target = "Vharok", -- el jefe llega en las semanas 17–18
		Count = 1,
		RequiredLevel = 14,
		RewardXP = 3000,
		RewardPotions = 3,
		DialogStartKey = "Dialog_Q08_Start",
		DialogActiveKey = "Dialog_Q08_Active",
		DialogDoneKey = "Dialog_Q08_Done",
		DialogLockedKey = "Dialog_Q08_Locked",
	},
}

return {
	List = List,
	Order = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06", "Q07", "Q08" },
}
