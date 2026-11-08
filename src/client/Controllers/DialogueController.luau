--!strict
--[[
	DialogueController (cliente)
	Muestra los diálogos de los NPC (mensaje "Notify" de tipo "Dialogue" con su clave de texto).
	Mientras está abierto, el ratón queda libre para pulsar "Continuar".
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Strings = require(Shared:WaitForChild("Config"):WaitForChild("Strings"))
local Net = require(Shared:WaitForChild("Net"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))

local AUTO_CLOSE = 15

local player = Players.LocalPlayer

local DialogueController = {}

local panel: Frame
local speaker: TextLabel
local body: TextLabel
local openToken = 0

local function close()
	panel.Visible = false
	CameraController:setCursorFree("Dialogue", false)
end

local function open(npcId: string, textKey: string)
	openToken += 1
	local token = openToken
	speaker.Text = Strings.get(`Npc_{npcId}`)
	body.Text = Strings.get(textKey)
	panel.Visible = true
	CameraController:setCursorFree("Dialogue", true)
	task.delay(AUTO_CLOSE, function()
		if openToken == token then
			close()
		end
	end)
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Dialogue"
	gui.ResetOnSpawn = false

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.new(0.5, 0, 1, -84)
	panel.Size = UDim2.new(0.5, 0, 0.2, 0)
	panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	panel.BackgroundTransparency = 0.15
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	speaker = Instance.new("TextLabel")
	speaker.Position = UDim2.new(0.03, 0, 0.06, 0)
	speaker.Size = UDim2.new(0.6, 0, 0.2, 0)
	speaker.BackgroundTransparency = 1
	speaker.Font = Enum.Font.GothamBlack
	speaker.TextScaled = true
	speaker.TextXAlignment = Enum.TextXAlignment.Left
	speaker.TextColor3 = Color3.fromRGB(255, 200, 70)
	speaker.Parent = panel

	body = Instance.new("TextLabel")
	body.Position = UDim2.new(0.03, 0, 0.3, 0)
	body.Size = UDim2.new(0.94, 0, 0.45, 0)
	body.BackgroundTransparency = 1
	body.Font = Enum.Font.Gotham
	body.TextScaled = true
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextColor3 = Color3.new(1, 1, 1)
	body.Parent = panel
	local sizeLimit = Instance.new("UITextSizeConstraint")
	sizeLimit.MaxTextSize = 22
	sizeLimit.Parent = body

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(0.97, 0, 0.94, 0)
	button.Size = UDim2.new(0.22, 0, 0.18, 0)
	button.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(20, 20, 20)
	button.Text = Strings.get("Continue")
	button.Parent = panel
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button
	button.Activated:Connect(close)

	gui.Parent = player:WaitForChild("PlayerGui")
end

function DialogueController:Init() end

function DialogueController:Start()
	buildGui()
	Net.event("Notify").OnClientEvent:Connect(function(kind: string, params: { [string]: any })
		if kind == "Dialogue" and typeof(params) == "table" then
			local npcId = params.npcId
			local textKey = params.textKey
			if typeof(npcId) == "string" and typeof(textKey) == "string" then
				open(npcId, textKey)
			end
		end
	end)
end

return DialogueController
