--!strict
--[[
	BossBarController (cliente)
	- Barra de vida del jefe arriba en el centro (nombre, fase y vida), con los datos del servidor ("BossPhase").
	  Se oculta si sales de la arena (sin actualizaciones durante 2 s) o cuando el jefe muere o se reinicia.
	- Fase 2: el jefe se rodea de partículas de Éter morado. Invulnerable (transición): brillo morado intenso.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Strings = require(Shared:WaitForChild("Config"):WaitForChild("Strings"))
local Net = require(Shared:WaitForChild("Net"))
local SoundController = require(script.Parent:WaitForChild("SoundController"))
local GameFeelController = require(script.Parent:WaitForChild("GameFeelController"))

local AETHER = Color3.fromRGB(170, 80, 230)
local HIDE_AFTER = 2

local player = Players.LocalPlayer

local BossBarController = {}

local frame: Frame
local fill: Frame
local nameLabel: TextLabel
local phaseLabel: TextLabel
local lastUpdate = 0

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BossBar"
	gui.ResetOnSpawn = false

	frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 56)
	frame.Size = UDim2.new(0.45, 0, 0, 52)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = gui

	nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.75, 0, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextScaled = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = frame

	phaseLabel = Instance.new("TextLabel")
	phaseLabel.AnchorPoint = Vector2.new(1, 0)
	phaseLabel.Position = UDim2.new(1, 0, 0, 0)
	phaseLabel.Size = UDim2.new(0.25, 0, 0, 24)
	phaseLabel.BackgroundTransparency = 1
	phaseLabel.Font = Enum.Font.GothamBold
	phaseLabel.TextScaled = true
	phaseLabel.TextXAlignment = Enum.TextXAlignment.Right
	phaseLabel.TextColor3 = AETHER
	phaseLabel.TextStrokeTransparency = 0.4
	phaseLabel.Parent = frame

	local back = Instance.new("Frame")
	back.Position = UDim2.new(0, 0, 0, 28)
	back.Size = UDim2.new(1, 0, 0, 20)
	back.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	back.BackgroundTransparency = 0.2
	back.BorderSizePixel = 0
	back.Parent = frame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = back

	fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
	fill.BorderSizePixel = 0
	fill.Parent = back
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fill

	gui.Parent = player:WaitForChild("PlayerGui")
end

local function onBossPhase(nameKey: string, health: number, maxHealth: number, phase: number)
	if typeof(nameKey) ~= "string" or nameKey == "" or typeof(maxHealth) ~= "number" or maxHealth <= 0 then
		frame.Visible = false
		return
	end
	lastUpdate = os.clock()
	frame.Visible = true
	nameLabel.Text = Strings.get(nameKey)
	phaseLabel.Text = Strings.get("BossPhaseLabel", { phase = phase })
	fill.BackgroundColor3 = if phase >= 2 then AETHER else Color3.fromRGB(200, 50, 60)
	TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(math.clamp(health / maxHealth, 0, 1), 1) })
		:Play()
end

local function watchBoss(model: Instance)
	if not model:IsA("Model") then
		return
	end
	local root = model:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = AETHER
	highlight.OutlineColor = AETHER
	highlight.FillTransparency = 0.3
	highlight.Enabled = false
	highlight.Parent = model

	local function refresh()
		local existing = root:FindFirstChild("AetherAura")
		if (model:GetAttribute("Phase") or 1) >= 2 then
			if not existing then
				local emitter = Instance.new("ParticleEmitter")
				emitter.Name = "AetherAura"
				emitter.Color = ColorSequence.new(AETHER)
				emitter.LightEmission = 1
				emitter.Rate = 40
				emitter.Lifetime = NumberRange.new(1, 2)
				emitter.Speed = NumberRange.new(2, 6)
				emitter.SpreadAngle = Vector2.new(180, 180)
				emitter.Size =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0) })
				emitter.Parent = root
			end
		elseif existing then
			existing:Destroy()
		end
		highlight.Enabled = model:GetAttribute("Invulnerable") == true
	end
	model:GetAttributeChangedSignal("Phase"):Connect(function()
		refresh()
		if (model:GetAttribute("Phase") or 1) >= 2 then
			SoundController:play("BossRoar", root, 1)
			GameFeelController:shake(0.6, 1.2)
		end
	end)
	model:GetAttributeChangedSignal("Invulnerable"):Connect(refresh)
	refresh()
end

function BossBarController:Init() end

function BossBarController:Start()
	buildGui()
	Net.event("BossPhase").OnClientEvent:Connect(onBossPhase)
	RunService.Heartbeat:Connect(function()
		if frame.Visible and os.clock() - lastUpdate > HIDE_AFTER then
			frame.Visible = false
		end
	end)
	CollectionService:GetInstanceAddedSignal("Boss"):Connect(watchBoss)
	for _, model in CollectionService:GetTagged("Boss") do
		task.spawn(watchBoss, model)
	end
end

return BossBarController
