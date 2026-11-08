--!strict
--[[
	AffinityUiController (cliente)
	- Texto del aviso del Santuario en tu idioma.
	- Pantalla para elegir afinidad (Fuego o Rayo) cuando el servidor la abre (Notify "OpenAffinityChoice").
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local Affinities = require(Config:WaitForChild("Affinities"))
local Net = require(Shared:WaitForChild("Net"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))

local player = Players.LocalPlayer

local AffinityUiController = {}

local panel: Frame

local function close()
	panel.Visible = false
	CameraController:setCursorFree("AffinityChoice", false)
end

local function open()
	panel.Visible = true
	CameraController:setCursorFree("AffinityChoice", true)
end

local function buildCard(parent: Instance, affinityId: string, position: UDim2)
	local config = Affinities.List[affinityId]
	local card = Instance.new("Frame")
	card.Position = position
	card.Size = UDim2.fromScale(0.44, 0.55)
	card.BackgroundColor3 = Color3.fromRGB(35, 42, 50)
	card.BorderSizePixel = 0
	card.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card
	local stroke = Instance.new("UIStroke")
	stroke.Color = config.Color
	stroke.Thickness = 2
	stroke.Parent = card

	local title = Instance.new("TextLabel")
	title.Position = UDim2.fromScale(0.05, 0.05)
	title.Size = UDim2.fromScale(0.9, 0.2)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextColor3 = config.Color
	title.Text = Strings.get(config.NameKey)
	title.Parent = card

	local desc = Instance.new("TextLabel")
	desc.Position = UDim2.fromScale(0.05, 0.3)
	desc.Size = UDim2.fromScale(0.9, 0.4)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextScaled = true
	desc.TextWrapped = true
	desc.TextColor3 = Color3.new(1, 1, 1)
	desc.Text = Strings.get(`AffinityDesc_{affinityId}`)
	desc.Parent = card
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.Parent = desc

	local button = Instance.new("TextButton")
	button.Position = UDim2.fromScale(0.2, 0.75)
	button.Size = UDim2.fromScale(0.6, 0.17)
	button.BackgroundColor3 = config.Color
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(20, 20, 20)
	button.Text = Strings.get("Choose")
	button.Parent = card
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button
	button.Activated:Connect(function()
		Net.event("RequestChooseAffinity"):FireServer(affinityId)
		close()
	end)
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "AffinityChoice"
	gui.ResetOnSpawn = false

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.5, 0.55)
	panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Visible = false
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel

	local title = Instance.new("TextLabel")
	title.Position = UDim2.fromScale(0.05, 0.04)
	title.Size = UDim2.fromScale(0.7, 0.1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 200, 70)
	title.Text = Strings.get("AffinityChooseTitle")
	title.Parent = panel

	local hint = Instance.new("TextLabel")
	hint.Position = UDim2.fromScale(0.05, 0.15)
	hint.Size = UDim2.fromScale(0.9, 0.08)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.TextScaled = true
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextColor3 = Color3.fromRGB(190, 195, 200)
	hint.Text = Strings.get("AffinityChooseHint")
	hint.Parent = panel

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.fromScale(0.96, 0.04)
	closeButton.Size = UDim2.fromScale(0.16, 0.09)
	closeButton.BackgroundColor3 = Color3.fromRGB(35, 42, 50)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = Strings.get("Close")
	closeButton.Parent = panel
	closeButton.Activated:Connect(close)

	buildCard(panel, "Fire", UDim2.fromScale(0.04, 0.3))
	buildCard(panel, "Lightning", UDim2.fromScale(0.52, 0.3))

	gui.Parent = player:WaitForChild("PlayerGui")
end

local function localizeShrine(shrine: Instance)
	local prompt = shrine:WaitForChild("ProximityPrompt", 10)
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.ActionText = Strings.get("AffinityPrompt")
	end
end

function AffinityUiController:Init() end

function AffinityUiController:Start()
	buildGui()
	Net.event("Notify").OnClientEvent:Connect(function(kind: string)
		if kind == "OpenAffinityChoice" then
			open()
		end
	end)
	CollectionService:GetInstanceAddedSignal("AffinityShrine"):Connect(localizeShrine)
	for _, shrine in CollectionService:GetTagged("AffinityShrine") do
		task.spawn(localizeShrine, shrine)
	end
end

return AffinityUiController
