--!strict
--[[
	QuestService (servidor) — cadena de 8 misiones (GDD v1 §8.2). Solo el servidor cambia el progreso y da recompensas.
	- Hablar con quien da la misión: Available → Active (si tienes el nivel), o ReadyToTurnIn → recompensa y siguiente.
	- Progreso: muñeco, enemigos derrotados (si contribuiste ≥ 10 %), llegar a un punto, elegir afinidad, recoger objetos.
	- Al cargar los datos se "repara" la cadena: si se añadieron misiones nuevas, el jugador recibe la siguiente pendiente.
	- Diálogos y avisos se envían al cliente con "Notify" (clave de texto + parámetros).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Net = require(Shared:WaitForChild("Net"))
local Quests = require(Config:WaitForChild("Quests"))
local Items = require(Config:WaitForChild("Items"))
local WeaponCatalog = require(Config:WaitForChild("Weapons"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))
local NpcService = require(script.Parent:WaitForChild("NpcService"))
local AffinityService = require(script.Parent:WaitForChild("AffinityService"))

local TAG_MARKER = "QuestMarker"
local GOTO_CHECK_INTERVAL = 0.5
local DEFAULT_MARKER_RADIUS = 12

local QuestService = {}

local function notify(player: Player, kind: string, params: { [string]: any })
	Net.event("Notify"):FireClient(player, kind, params)
end

local function dialogue(player: Player, npcId: string, textKey: string)
	notify(player, "Dialogue", { npcId = npcId, textKey = textKey })
end

local function findMarker(markerId: string): BasePart?
	for _, marker in CollectionService:GetTagged(TAG_MARKER) do
		if marker:IsA("BasePart") and marker:GetAttribute("MarkerId") == markerId then
			return marker
		end
	end
	return nil
end

-- Primera misión de la cadena que el jugador aún no ha completado.
local function firstPendingQuest(completed: { [string]: boolean }): string?
	for _, questId in Quests.Order do
		if not completed[questId] then
			return questId
		end
	end
	return nil
end

local function markReady(player: Player, quest: Quests.Quest)
	local data = DataService:get(player)
	if not data then
		return
	end
	data.Quests.Progress = quest.Count
	data.Quests.Status = "ReadyToTurnIn"
	notify(player, "QuestReady", { npcId = quest.Giver })
end

-- Algunas misiones pueden estar cumplidas al aceptarlas (p. ej., ya elegiste afinidad).
local function checkInstantCompletion(player: Player, quest: Quests.Quest)
	local data = DataService:get(player)
	if data and quest.Type == "ChooseAffinity" and data.Affinity.Selected ~= "" then
		markReady(player, quest)
	end
end

local function grantRewards(player: Player, quest: Quests.Quest)
	local data = DataService:get(player)
	if not data then
		return
	end
	if quest.RewardPotions > 0 then
		data.Inventory.Potions = math.min(Items.SapPotion.Max, data.Inventory.Potions + quest.RewardPotions)
	end
	local weaponId = quest.RewardWeapon
	if quest.RewardRareOfEquipped then
		local equipped = WeaponCatalog.Weapons[data.Inventory.EquippedWeapon]
		weaponId = `{if equipped then equipped.Type else "Katana"}_Rare`
	end
	if weaponId and WeaponCatalog.Weapons[weaponId] and not table.find(data.Inventory.Weapons, weaponId) then
		table.insert(data.Inventory.Weapons, weaponId)
		notify(player, "WeaponReward", { nameKey = WeaponCatalog.Weapons[weaponId].NameKey })
	end
	DataService:changed(player, "Inventory")
	ProgressionService:addXP(player, quest.RewardXP)
end

local function onTalk(player: Player, npcId: string)
	local data = DataService:get(player)
	if not data then
		return
	end
	local questState = data.Quests
	local quest = Quests.List[questState.ActiveId]
	if not quest or questState.Status == "None" then
		dialogue(player, npcId, "Dialog_NoQuest")
		return
	end
	if quest.Giver ~= npcId then
		return
	end

	if questState.Status == "Available" then
		if quest.RequiredLevel and data.Level < quest.RequiredLevel then
			dialogue(player, npcId, quest.DialogLockedKey or "Dialog_NoQuest")
			return
		end
		questState.Status = "Active"
		questState.Progress = 0
		dialogue(player, npcId, quest.DialogStartKey)
		checkInstantCompletion(player, quest)
	elseif questState.Status == "Active" then
		dialogue(player, npcId, quest.DialogActiveKey)
	elseif questState.Status == "ReadyToTurnIn" then
		questState.Completed[questState.ActiveId] = true
		local nextId = firstPendingQuest(questState.Completed)
		questState.ActiveId = nextId or ""
		questState.Status = if nextId then "Available" else "None"
		questState.Progress = 0
		dialogue(player, npcId, quest.DialogDoneKey)
		notify(player, "QuestComplete", { nameKey = quest.NameKey })
		grantRewards(player, quest)
	end
	DataService:changed(player, "Quests")
end

-- Suma progreso si la misión activa es de ese tipo (y objetivo).
local function addProgress(player: Player, questType: Quests.QuestType, target: string?)
	local data = DataService:get(player)
	if not data or data.Quests.Status ~= "Active" then
		return
	end
	local quest = Quests.List[data.Quests.ActiveId]
	if not quest or quest.Type ~= questType or (quest.Target ~= nil and quest.Target ~= target) then
		return
	end
	data.Quests.Progress = math.min(quest.Count, data.Quests.Progress + 1)
	if data.Quests.Progress >= quest.Count then
		markReady(player, quest)
	end
	DataService:changed(player, "Quests")
end

-- Repara la cadena (misiones nuevas añadidas después de que el jugador terminara las anteriores).
local function repairChain(player: Player)
	local data = DataService:get(player)
	if not data then
		return
	end
	local questState = data.Quests
	local current = Quests.List[questState.ActiveId]
	if current and not questState.Completed[questState.ActiveId] then
		return -- todo en orden
	end
	local nextId = firstPendingQuest(questState.Completed)
	questState.ActiveId = nextId or ""
	questState.Status = if nextId then "Available" else "None"
	questState.Progress = 0
	DataService:changed(player, "Quests")
end

-- Comprueba periódicamente las misiones de "llegar a un punto".
local function checkGoToQuests()
	for _, player in Players:GetPlayers() do
		local data = DataService:get(player)
		local quest = if data and data.Quests.Status == "Active" then Quests.List[data.Quests.ActiveId] else nil
		if quest and quest.Type == "GoTo" and quest.MarkerId then
			local marker = findMarker(quest.MarkerId)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if marker and root and root:IsA("BasePart") then
				local radius = marker:GetAttribute("Radius")
				local range = if typeof(radius) == "number" then radius else DEFAULT_MARKER_RADIUS
				if (root.Position - marker.Position).Magnitude <= range then
					addProgress(player, "GoTo", nil)
				end
			end
		end
	end
end

function QuestService:Init() end

function QuestService:Start()
	NpcService:onTalk(onTalk)
	DataService:onPlayerLoaded(repairChain)

	CombatService:onDamageDealt(function(player: Player, target: Model)
		if CollectionService:HasTag(target, "TrainingDummy") then
			addProgress(player, "HitDummy", nil)
		end
	end)

	EnemyService:onEnemyDefeated(function(enemyId: string, contributors: { Player })
		for _, player in contributors do
			addProgress(player, "Defeat", enemyId)
			-- Objetos que sueltan los enemigos (misión "Collect").
			local data = DataService:get(player)
			local quest = if data and data.Quests.Status == "Active" then Quests.List[data.Quests.ActiveId] else nil
			if quest and quest.Type == "Collect" and math.random() < (quest.CollectChance or 0.5) then
				notify(player, "ItemCollected", { nameKey = "Item_WitheredSap" })
				addProgress(player, "Collect", nil)
			end
		end
	end)

	AffinityService:onAffinityChosen(function(player: Player)
		addProgress(player, "ChooseAffinity", nil)
	end)

	-- Los marcadores son invisibles: solo los ve el cliente como un rombo cuando toca.
	for _, marker in CollectionService:GetTagged(TAG_MARKER) do
		if marker:IsA("BasePart") then
			marker.Transparency = 1
			marker.CanCollide = false
			marker.CanQuery = false
		end
	end

	task.spawn(function()
		while true do
			task.wait(GOTO_CHECK_INTERVAL)
			checkGoToQuests()
		end
	end)
end

return QuestService
