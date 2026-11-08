--!strict
--[[
	InventoryService (servidor)
	Por ahora solo las pociones (GDD v1 §8.1): cura el 40 % de la vida máxima, enfriamiento 10 s, máximo 10.
	El inventario completo (armas, cosméticos) llega en la semana 10.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Items = require(Shared:WaitForChild("Config"):WaitForChild("Items"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local InventoryService = {}

local lastPotionUse: { [Player]: number } = {}

local function onRequestUsePotion(player: Player)
	local data = DataService:get(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not data or not humanoid or humanoid.Health <= 0 then
		return
	end
	local now = os.clock()
	if now - (lastPotionUse[player] or -math.huge) < Items.SapPotion.Cooldown then
		return
	end
	if data.Inventory.Potions <= 0 or humanoid.Health >= humanoid.MaxHealth then
		return
	end
	lastPotionUse[player] = now
	data.Inventory.Potions -= 1
	local heal = math.floor(humanoid.MaxHealth * Items.SapPotion.HealFraction + 0.5)
	humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + heal)
	DataService:changed(player, "Inventory")
	if character then
		Net.event("HitConfirmed"):FireClient(player, character, heal, "Heal")
	end
end

function InventoryService:Init() end

function InventoryService:Start()
	Net.onRequest("RequestUsePotion", 2, onRequestUsePotion)
	Players.PlayerRemoving:Connect(function(player: Player)
		lastPotionUse[player] = nil
	end)
end

return InventoryService
