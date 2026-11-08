--!strict
--[[
	WeaponService (servidor)
	- Pone en la mano derecha el arma EQUIPADA según los datos guardados (Inventory.EquippedWeapon).
	- Atiende RequestEquipWeapon: solo si el arma existe, la tienes y no estás atacando/esquivando (decisión B4).
	- Guarda en el personaje los atributos "WeaponType" (Katana/Greatsword) y "WeaponId" (arma concreta),
	  que leen el cliente y CombatService.
	El arma sigue siendo un bloque provisional; la rareza cambia su color (la épica brilla).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local WeaponTypes = require(Config:WaitForChild("WeaponTypes"))
local WeaponCatalog = require(Config:WaitForChild("Weapons"))
local Debug = require(Config:WaitForChild("Debug"))
local Net = require(Shared:WaitForChild("Net"))
local Validate = require(Shared:WaitForChild("Util"):WaitForChild("Validate"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))

local WeaponService = {}

local function attachWeapon(character: Model, weaponId: string)
	local item = WeaponCatalog.Weapons[weaponId]
	if not item then
		weaponId = WeaponCatalog.DefaultWeapon
		item = WeaponCatalog.Weapons[weaponId]
	end
	local weapon = WeaponTypes[item.Type]
	local rarity = WeaponCatalog.Rarities[item.Rarity]

	-- R15 tiene "RightHand"; R6 (por si el lugar no está en R15) tiene "Right Arm".
	local hand = character:WaitForChild("RightHand", 3) or character:FindFirstChild("Right Arm")
	if not hand or not hand:IsA("BasePart") then
		warn("[WeaponService] No se encontró la mano derecha del personaje")
		return
	end

	local old = character:FindFirstChild("Weapon")
	if old then
		old:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "Weapon"

	local blade = Instance.new("Part")
	blade.Name = "Blade"
	blade.Size = weapon.BladeSize
	blade.Color = if item.Rarity == "Common" then weapon.BladeColor else rarity.Color
	blade.Material = if rarity.Glow then Enum.Material.Neon else Enum.Material.Metal
	blade.CanCollide = false
	blade.CanTouch = false
	blade.CanQuery = false
	blade.Massless = true
	blade.CFrame = hand.CFrame * weapon.GripOffset
	blade.Parent = model

	local weld = Instance.new("Weld")
	weld.Part0 = hand
	weld.Part1 = blade
	weld.C0 = weapon.GripOffset
	weld.Parent = blade

	model.Parent = character
	character:SetAttribute("WeaponType", item.Type)
	character:SetAttribute("WeaponId", weaponId)
end

local function attachEquipped(player: Player)
	local data = DataService:get(player)
	local character = player.Character
	if data and character then
		attachWeapon(character, data.Inventory.EquippedWeapon)
	end
end

local function onRequestEquipWeapon(player: Player, weaponId: unknown)
	if typeof(weaponId) ~= "string" or not WeaponCatalog.Weapons[weaponId] then
		return
	end
	local data = DataService:get(player)
	if not data or not table.find(data.Inventory.Weapons, weaponId) then
		return -- no la tiene
	end
	if CombatService:isBusy(player) or data.Inventory.EquippedWeapon == weaponId then
		return
	end
	data.Inventory.EquippedWeapon = weaponId
	DataService:changed(player, "Inventory")
	attachEquipped(player)
end

function WeaponService:Init() end

function WeaponService:Start()
	Net.onRequest("RequestEquipWeapon", 2, function(player: Player, weaponId: unknown)
		if Validate.isOneOf(weaponId, WeaponCatalog.DisplayOrder) then
			onRequestEquipWeapon(player, weaponId)
		end
	end)

	DataService:onPlayerLoaded(function(player: Player, data)
		-- Solo desarrollo: dar todas las armas para probar el inventario.
		if Debug.GiveAllWeapons then
			for _, weaponId in WeaponCatalog.DisplayOrder do
				if not table.find(data.Inventory.Weapons, weaponId) then
					table.insert(data.Inventory.Weapons, weaponId)
				end
			end
			DataService:changed(player, "Inventory")
		end
		attachEquipped(player)
	end)

	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			character:WaitForChild("Humanoid")
			attachEquipped(player)
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

return WeaponService
