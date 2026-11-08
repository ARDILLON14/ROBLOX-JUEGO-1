--!strict
--[[
	ProgressionService (servidor)
	Experiencia, niveles y recompensas (GDD v1 §7, aprobada).
	- Solo el servidor da XP (decisión server-authoritative).
	- Al subir de nivel: +vida máxima, curación completa, +1 poción (máx. 10)
	  y recompensas especiales en los niveles 5, 10, 15 y 20.
	- Avisa a TODOS los clientes (LevelUp) para que vean la columna de luz.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Levels = require(Shared:WaitForChild("Config"):WaitForChild("Levels"))
local Validate = require(Shared:WaitForChild("Util"):WaitForChild("Validate"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local ProgressionService = {}

local function updateCharacterStats(player: Player, heal: boolean)
	local data = DataService:get(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	humanoid.MaxHealth = Levels.maxHealth(data.Level)
	if heal then
		humanoid.Health = humanoid.MaxHealth
	end
end

local function updateLeaderstats(player: Player)
	local data = DataService:get(player)
	if not data then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats" -- Roblox muestra esta carpeta en la lista de jugadores
		folder.Parent = player
		leaderstats = folder
	end
	local levelValue = (leaderstats :: Instance):FindFirstChild("Lv")
	if not levelValue or not levelValue:IsA("IntValue") then
		local value = Instance.new("IntValue")
		value.Name = "Lv"
		value.Parent = leaderstats
		levelValue = value
	end
	(levelValue :: IntValue).Value = data.Level
end

-- Aplica las recompensas de un nivel concreto. Devuelve la lista de recompensas (claves de texto).
local function grantLevelRewards(player: Player, level: number): { string }
	local data = DataService:get(player)
	if not data then
		return {}
	end
	local rewards = { "RewardHeal" }
	if data.Inventory.Potions < Levels.MaxPotions then
		data.Inventory.Potions = math.min(Levels.MaxPotions, data.Inventory.Potions + Levels.PotionsPerLevel)
		table.insert(rewards, "RewardPotion")
	end
	local special = Levels.SpecialRewards[level]
	if special then
		if special.Type == "Affinity" then
			table.insert(rewards, "RewardAffinity") -- la elección llegará en la semana 11
		elseif special.Type == "Cosmetic" and special.Id then
			if not table.find(data.Cosmetics.Owned, special.Id) then
				table.insert(data.Cosmetics.Owned, special.Id)
			end
			table.insert(rewards, special.Id)
		end
	end
	return rewards
end

function ProgressionService:Init() end

function ProgressionService:Start()
	DataService:onPlayerLoaded(function(player: Player)
		updateLeaderstats(player)
		updateCharacterStats(player, true)
	end)

	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			character:WaitForChild("Humanoid")
			updateCharacterStats(player, true)
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

function ProgressionService:getLevel(player: Player): number
	local data = DataService:get(player)
	return if data then data.Level else 1
end

-- Da experiencia a un jugador. Sube de nivel tantas veces como haga falta.
function ProgressionService:addXP(player: Player, amount: number)
	if not Validate.isFiniteNumber(amount) or amount <= 0 then
		return
	end
	local data = DataService:get(player)
	if not data or data.Level >= Levels.MaxLevel then
		return
	end

	data.XP += math.floor(amount)
	local leveledUp = false
	local allRewards: { string } = {}

	while data.Level < Levels.MaxLevel and data.XP >= Levels.xpToNext(data.Level) do
		data.XP -= Levels.xpToNext(data.Level)
		data.Level += 1
		leveledUp = true
		for _, reward in grantLevelRewards(player, data.Level) do
			if not table.find(allRewards, reward) then
				table.insert(allRewards, reward)
			end
		end
	end
	if data.Level >= Levels.MaxLevel then
		data.XP = 0
	end

	DataService:changed(player, "XP")
	if leveledUp then
		DataService:changed(player, "Level")
		DataService:changed(player, "Inventory")
		DataService:changed(player, "Cosmetics")
		updateCharacterStats(player, true)
		updateLeaderstats(player)
		Net.event("LevelUp"):FireAllClients(player, data.Level, allRewards)
		print(`[ProgressionService] {player.Name} sube a nivel {data.Level}`)
	end
end

return ProgressionService
