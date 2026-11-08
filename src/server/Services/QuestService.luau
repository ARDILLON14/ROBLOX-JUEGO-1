--!strict
--[[
	QuestService (servidor)
	Misiones lineales (GDD v1 §8.2). Solo el servidor cambia el progreso y da recompensas.
	- Hablar con quien da la misión: Available → Active, o ReadyToTurnIn → recompensa y siguiente misión.
	- Progreso: golpes al muñeco (HitDummy) y enemigos derrotados (Defeat, si contribuiste ≥ 10 %).
	- Diálogos y avisos se envían al cliente con "Notify" (clave de texto + parámetros).
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Quests = require(Shared:WaitForChild("Config"):WaitForChild("Quests"))
local Items = require(Shared:WaitForChild("Config"):WaitForChild("Items"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))
local NpcService = require(script.Parent:WaitForChild("NpcService"))

local QuestService = {}

local function notify(player: Player, kind: string, params: { [string]: any })
	Net.event("Notify"):FireClient(player, kind, params)
end

local function dialogue(player: Player, npcId: string, textKey: string)
	notify(player, "Dialogue", { npcId = npcId, textKey = textKey })
end

local function onTalk(player: Player, npcId: string)
	local data = DataService:get(player)
	if not data then
		return
	end
	local questState = data.Quests
	local quest = Quests[questState.ActiveId]
	if not quest or questState.Status == "None" then
		dialogue(player, npcId, "Dialog_NoQuest")
		return
	end
	if quest.Giver ~= npcId then
		return
	end

	if questState.Status == "Available" then
		questState.Status = "Active"
		questState.Progress = 0
		dialogue(player, npcId, quest.DialogStartKey)
	elseif questState.Status == "Active" then
		dialogue(player, npcId, quest.DialogActiveKey)
	elseif questState.Status == "ReadyToTurnIn" then
		local completedId = questState.ActiveId
		questState.Completed[completedId] = true
		if quest.RewardPotions > 0 then
			data.Inventory.Potions = math.min(Items.SapPotion.Max, data.Inventory.Potions + quest.RewardPotions)
			DataService:changed(player, "Inventory")
		end
		if quest.Next and Quests[quest.Next] then
			questState.ActiveId = quest.Next
			questState.Status = "Available"
		else
			questState.ActiveId = ""
			questState.Status = "None"
		end
		questState.Progress = 0
		dialogue(player, npcId, quest.DialogDoneKey)
		notify(player, "QuestComplete", { nameKey = quest.NameKey })
		ProgressionService:addXP(player, quest.RewardXP)
	end
	DataService:changed(player, "Quests")
end

-- Suma progreso si la misión activa es de ese tipo (y objetivo).
local function addProgress(player: Player, questType: string, target: string?)
	local data = DataService:get(player)
	if not data or data.Quests.Status ~= "Active" then
		return
	end
	local quest = Quests[data.Quests.ActiveId]
	if not quest or quest.Type ~= questType or (quest.Target ~= nil and quest.Target ~= target) then
		return
	end
	data.Quests.Progress = math.min(quest.Count, data.Quests.Progress + 1)
	if data.Quests.Progress >= quest.Count then
		data.Quests.Status = "ReadyToTurnIn"
		notify(player, "QuestReady", { npcId = quest.Giver })
	end
	DataService:changed(player, "Quests")
end

function QuestService:Init() end

function QuestService:Start()
	NpcService:onTalk(onTalk)
	CombatService:onDamageDealt(function(player: Player, target: Model)
		if CollectionService:HasTag(target, "TrainingDummy") then
			addProgress(player, "HitDummy", nil)
		end
	end)
	EnemyService:onEnemyDefeated(function(enemyId: string, contributors: { Player })
		for _, player in contributors do
			addProgress(player, "Defeat", enemyId)
		end
	end)
end

return QuestService
