--!strict
--[[
	CampfireUiController (cliente) — viaje rápido (GDD v1 §9 y §10).
	Al usar una fogata, el servidor envía la lista de fogatas descubiertas (Notify "OpenCampfire").
	El cliente muestra la lista y PIDE viajar (RequestFastTravel); el servidor decide si se puede.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local World = require(Config:WaitForChild("World"))
local Net = require(Shared:WaitForChild("Net"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))

local COLOR_ACCENT = Color3.fromRGB(255, 200, 70)
local COLOR_ROW = Color3.fromRGB(35, 42, 50)

local player = Players.LocalPlayer

local CampfireUiController = {}

local panel: Frame
local list: ScrollingFrame

local function close()
	panel.Visible = false
	CameraController:setCursorFree("Campfire", false)
end

local function open(current: string, discovered: { string })
	for _, child in list:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for index, campfireId in discovered do
		local info = World.Campfires[campfireId]
		if info then
			local isHere = campfireId == current
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -8, 0, 44)
			button.LayoutOrder = index
			button.BackgroundColor3 = if isHere then Color3.fromRGB(70, 75, 80) else COLOR_ROW
			button.AutoButtonColor = not isHere
			button.Font = Enum.Font.GothamBold
			button.TextScaled = true
			button.TextColor3 = if isHere then Color3.fromRGB(170, 170, 170) else Color3.new(1, 1, 1)
			button.Text = if isHere
				then `{Strings.get(info.NameKey)} ({Strings.get("Here")})`
				else Strings.get(info.NameKey)
			button.Parent = list
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = button
			if not isHere then
				button.Activated:Connect(function()
					Net.event("RequestFastTravel"):FireServer(campfireId)
					close()
				end)
			end
		end
	end
	panel.Visible = true
	CameraController:setCursorFree("Campfire", true)
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Campfire"
	gui.ResetOnSpawn = false

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.32, 0.5)
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
	title.Position = UDim2.fromScale(0.06, 0.04)
	title.Size = UDim2.fromScale(0.6, 0.1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_ACCENT
	title.Text = Strings.get("FastTravelTitle")
	title.Parent = panel

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.fromScale(0.94, 0.04)
	closeButton.Size = UDim2.fromScale(0.26, 0.09)
	closeButton.BackgroundColor3 = COLOR_ROW
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = Strings.get("Close")
	closeButton.Parent = panel
	closeButton.Activated:Connect(close)

	list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromScale(0.06, 0.18)
	list.Size = UDim2.fromScale(0.88, 0.78)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	gui.Parent = player:WaitForChild("PlayerGui")
end

local function localizePrompt(part: Instance, textKey: string)
	local prompt = part:WaitForChild("ProximityPrompt", 10)
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.ActionText = Strings.get(textKey)
		local campfireId = part:GetAttribute("CampfireId")
		local info = if typeof(campfireId) == "string" then World.Campfires[campfireId] else nil
		if info then
			prompt.ObjectText = Strings.get(info.NameKey)
		end
	end
end

function CampfireUiController:Init() end

function CampfireUiController:Start()
	buildGui()
	Net.event("Notify").OnClientEvent:Connect(function(kind: string, params: { [string]: any })
		if kind == "OpenCampfire" and typeof(params) == "table" and typeof(params.discovered) == "table" then
			open(tostring(params.current), params.discovered)
		end
	end)
	for _, part in CollectionService:GetTagged("Campfire") do
		task.spawn(localizePrompt, part, "Rest")
	end
	CollectionService:GetInstanceAddedSignal("Campfire"):Connect(function(part)
		localizePrompt(part, "Rest")
	end)
end

return CampfireUiController
