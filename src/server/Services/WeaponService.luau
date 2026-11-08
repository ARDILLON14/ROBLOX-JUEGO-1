--!strict
--[[
	WeaponService
	Pone el arma en la mano derecha de cada personaje al aparecer.
	- Por ahora el arma es un bloque provisional; el tipo sale de Debug.StartingWeaponType.
	- Cuando exista el inventario (semana 10), el arma saldrá de los datos guardados.
	- Guarda el tipo en el atributo "WeaponType" del personaje para que el cliente lo lea.
	Lo hace el SERVIDOR para que todos los jugadores vean el arma.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local WeaponTypes = require(Config:WaitForChild("WeaponTypes"))
local Debug = require(Config:WaitForChild("Debug"))

local WeaponService = {}

local function attachWeapon(character: Model, weaponTypeName: string)
	local weapon = WeaponTypes[weaponTypeName]
	if not weapon then
		warn(`[WeaponService] Tipo de arma desconocido: {weaponTypeName}`)
		return
	end

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
	blade.Color = weapon.BladeColor
	blade.Material = Enum.Material.Metal
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
	character:SetAttribute("WeaponType", weaponTypeName)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		attachWeapon(character, Debug.StartingWeaponType)
	end)
	if player.Character then
		attachWeapon(player.Character, Debug.StartingWeaponType)
	end
end

function WeaponService:Init() end

function WeaponService:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

return WeaponService
