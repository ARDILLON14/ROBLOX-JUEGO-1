--!strict
--[[
	LevelUpController (cliente)
	Efecto de subida de nivel (GDD v1 §7.2, aprobado):
	- Columna de luz dorada sobre el jugador que sube (la ven todos).
	- Si eres tú: aviso grande "¡NIVEL X!" con las recompensas y sonido (si hay ID en Config/Sounds).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Net = require(Shared:WaitForChild("Net"))
local Strings = require(Config:WaitForChild("Strings"))
local SoundController = require(script.Parent:WaitForChild("SoundController"))

local GOLD = Color3.fromRGB(255, 205, 80)
local COLUMN_HEIGHT = 30
local COLUMN_DURATION = 1.4
local BANNER_DURATION = 2.5

local player = Players.LocalPlayer

local LevelUpController = {}

local function showColumn(target: Player)
	local character = target.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end
	local column = Instance.new("Part")
	column.Name = "LevelUpColumn"
	column.Shape = Enum.PartType.Cylinder
	column.Material = Enum.Material.Neon
	column.Color = GOLD
	column.Anchored = true
	column.CanCollide = false
	column.CanQuery = false
	column.CanTouch = false
	column.CastShadow = false
	column.Transparency = 0.2
	-- Un cilindro de Roblox está "acostado" en el eje X: se gira 90° para ponerlo de pie.
	column.Size = Vector3.new(COLUMN_HEIGHT, 4, 4)
	column.CFrame = CFrame.new(root.Position + Vector3.new(0, COLUMN_HEIGHT / 2 - 3, 0))
		* CFrame.Angles(0, 0, math.rad(90))
	column.Parent = Workspace

	local tween = TweenService:Create(
		column,
		TweenInfo.new(COLUMN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transparency = 1, Size = Vector3.new(COLUMN_HEIGHT, 9, 9) }
	)
	tween:Play()
	tween.Completed:Connect(function()
		column:Destroy()
	end)
end

local function playSound()
	SoundController:play("LevelUp", nil, 0.8)
end

local function showBanner(level: number, rewards: { string })
	local gui = Instance.new("ScreenGui")
	gui.Name = "LevelUpBanner"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.28)
	title.Size = UDim2.fromScale(0.5, 0.12) -- tamaños relativos a la pantalla (sirve también en móvil)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextColor3 = GOLD
	title.TextStrokeTransparency = 0.3
	title.Text = Strings.get("LevelUp", { level = level })
	title.Parent = gui

	local lines: { string } = {}
	for _, reward in rewards do
		table.insert(lines, Strings.get(reward))
	end
	local subtitle = Instance.new("TextLabel")
	subtitle.AnchorPoint = Vector2.new(0.5, 0)
	subtitle.Position = UDim2.fromScale(0.5, 0.35)
	subtitle.Size = UDim2.fromScale(0.5, 0.05)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextScaled = true
	subtitle.TextColor3 = Color3.new(1, 1, 1)
	subtitle.TextStrokeTransparency = 0.4
	subtitle.Text = table.concat(lines, "  ·  ")
	subtitle.Parent = gui

	local scale = Instance.new("UIScale")
	scale.Scale = 0.5
	scale.Parent = title

	gui.Parent = player:WaitForChild("PlayerGui")
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()

	task.delay(BANNER_DURATION, function()
		local fadeInfo = TweenInfo.new(0.5)
		TweenService:Create(title, fadeInfo, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		local fade = TweenService:Create(subtitle, fadeInfo, { TextTransparency = 1, TextStrokeTransparency = 1 })
		fade:Play()
		fade.Completed:Connect(function()
			gui:Destroy()
		end)
	end)
end

function LevelUpController:Init() end

function LevelUpController:Start()
	Net.event("LevelUp").OnClientEvent:Connect(function(who: Player, level: number, rewards: { string })
		if typeof(who) ~= "Instance" or not who:IsA("Player") then
			return
		end
		showColumn(who)
		if who == player then
			showBanner(level, if typeof(rewards) == "table" then rewards else {})
			playSound()
		end
	end)
end

return LevelUpController
