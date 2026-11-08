--!strict
--[[
	InventoryService (servidor)
	- Pociones (GDD v1 §8.1): cura el 40 % de la vida máxima, enfriamiento 10 s, máximo 10.
	- Cosméticos: equipar/quitar títulos y auras (RequestEquipCosmetic). Se muestran con los atributos
	  "TitleId" y "AuraId" del personaje; cada cliente los dibuja en su idioma.
	(Las armas las gestiona WeaponService.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Items = require(Shared:WaitForChild("Config"):WaitForChild("Items"))
local Cosmetics = require(Shared:WaitForChild("Config"):WaitForChild("Cosmetics"))
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

local function applyCosmetics(player: Player)
	local data = DataService:get(player)
	local character = player.Character
	if not data or not character then
		return
	end
	character:SetAttribute("TitleId", if data.Cosmetics.EquippedTitle ~= "" then data.Cosmetics.EquippedTitle else nil)
	character:SetAttribute("AuraId", if data.Cosmetics.EquippedAura ~= "" then data.Cosmetics.EquippedAura else nil)
end

-- Equipa un cosmético; si ya estaba puesto, lo quita.
local function onRequestEquipCosmetic(player: Player, cosmeticId: unknown)
	if typeof(cosmeticId) ~= "string" then
		return
	end
	local cosmetic = Cosmetics[cosmeticId]
	local data = DataService:get(player)
	if not cosmetic or not data or not table.find(data.Cosmetics.Owned, cosmeticId) then
		return
	end
	if cosmetic.Slot == "Title" then
		data.Cosmetics.EquippedTitle = if data.Cosmetics.EquippedTitle == cosmeticId then "" else cosmeticId
	else
		data.Cosmetics.EquippedAura = if data.Cosmetics.EquippedAura == cosmeticId then "" else cosmeticId
	end
	DataService:changed(player, "Cosmetics")
	applyCosmetics(player)
end

function InventoryService:Init() end

function InventoryService:Start()
	Net.onRequest("RequestUsePotion", 2, onRequestUsePotion)
	Net.onRequest("RequestEquipCosmetic", 2, onRequestEquipCosmetic)
	DataService:onPlayerLoaded(applyCosmetics)
	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(function()
			applyCosmetics(player)
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerRemoving:Connect(function(player: Player)
		lastPotionUse[player] = nil
	end)
end

return InventoryService
