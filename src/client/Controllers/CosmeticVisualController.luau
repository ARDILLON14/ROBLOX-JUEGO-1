--!strict
--[[
	CosmeticVisualController (cliente)
	Dibuja los cosméticos equipados de TODOS los jugadores (atributos "TitleId" y "AuraId" del personaje):
	- Título: texto de color sobre la cabeza, en tu idioma.
	- Aura: partículas de color alrededor del personaje.
	Son solo visuales: no dan ninguna ventaja (principio de diseño sin pay-to-win).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local Cosmetics = require(Config:WaitForChild("Cosmetics"))

local CosmeticVisualController = {}

local function updateTitle(character: Model)
	local old = character:FindFirstChild("CosmeticTitle")
	if old then
		old:Destroy()
	end
	local titleId = character:GetAttribute("TitleId")
	local cosmetic = if typeof(titleId) == "string" then Cosmetics[titleId] else nil
	local head = character:FindFirstChild("Head")
	if not cosmetic or not head or not head:IsA("BasePart") then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CosmeticTitle"
	billboard.Size = UDim2.fromOffset(200, 24)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.MaxDistance = 60
	billboard.Adornee = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = cosmetic.Color
	label.TextStrokeTransparency = 0.3
	label.Text = Strings.get(cosmetic.NameKey)
	label.Parent = billboard
	billboard.Parent = character
end

local function updateAura(character: Model)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local old = root:FindFirstChild("CosmeticAura")
	if old then
		old:Destroy()
	end
	local auraId = character:GetAttribute("AuraId")
	local cosmetic = if typeof(auraId) == "string" then Cosmetics[auraId] else nil
	if not cosmetic then
		return
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "CosmeticAura"
	emitter.Color = ColorSequence.new(cosmetic.Color)
	emitter.LightEmission = 1
	emitter.Rate = 18
	emitter.Lifetime = NumberRange.new(0.8, 1.4)
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	emitter.Parent = root
end

local function watchCharacter(character: Model)
	character:WaitForChild("HumanoidRootPart", 10)
	character:GetAttributeChangedSignal("TitleId"):Connect(function()
		updateTitle(character)
	end)
	character:GetAttributeChangedSignal("AuraId"):Connect(function()
		updateAura(character)
	end)
	updateTitle(character)
	updateAura(character)
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then
		task.spawn(watchCharacter, player.Character)
	end
end

function CosmeticVisualController:Init() end

function CosmeticVisualController:Start()
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
end

return CosmeticVisualController
