--!strict
--[[
	JournalUiController (cliente) — Diario (tecla J), GDD v1 §10.
	Pestañas: Misiones (completadas, activa y "???" para las futuras) y Fragmentos (historia de los que encontraste).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local Quests = require(Config:WaitForChild("Quests"))
local World = require(Config:WaitForChild("World"))
local InputController = require(script.Parent:WaitForChild("InputController"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local COLOR_ACCENT = Color3.fromRGB(255, 200, 70)
local COLOR_ROW = Color3.fromRGB(35, 42, 50)

local player = Players.LocalPlayer

local JournalUiController = {}

local panel: Frame
local list: ScrollingFrame
local tabButtons: { [string]: TextButton } = {}
local currentTab = "Quests"
local isOpen = false

local function addEntry(order: number, title: string, body: string, color: Color3)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundColor3 = COLOR_ROW
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = list
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = row
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = row
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = row

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 22)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = color
	titleLabel.Text = title
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = row

	if body ~= "" then
		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.Size = UDim2.new(1, 0, 0, 0)
		bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.Font = Enum.Font.Gotham
		bodyLabel.TextSize = 15
		bodyLabel.TextWrapped = true
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.TextColor3 = Color3.fromRGB(200, 205, 210)
		bodyLabel.Text = body
		bodyLabel.LayoutOrder = 2
		bodyLabel.Parent = row
	end
end

local function refresh()
	for tab, button in tabButtons do
		button.BackgroundColor3 = if tab == currentTab then COLOR_ACCENT else COLOR_ROW
		button.TextColor3 = if tab == currentTab then Color3.fromRGB(20, 20, 20) else Color3.new(1, 1, 1)
	end
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local data = PlayerDataController:get()
	if not data then
		return
	end

	if currentTab == "Quests" then
		for index, questId in Quests.Order do
			local quest = Quests.List[questId]
			if data.Quests.Completed[questId] then
				addEntry(index, `✓ {Strings.get(quest.NameKey)}`, "", Color3.fromRGB(120, 220, 130))
			elseif data.Quests.ActiveId == questId then
				local objective =
					Strings.get(quest.ObjectiveKey, { progress = data.Quests.Progress, count = quest.Count })
				addEntry(index, `► {Strings.get(quest.NameKey)}`, objective, COLOR_ACCENT)
			else
				addEntry(index, "???", "", Color3.fromRGB(130, 130, 130))
			end
		end
	else
		local ids: { string } = {}
		for fragmentId in World.Fragments do
			table.insert(ids, fragmentId)
		end
		table.sort(ids, function(a: string, b: string)
			return World.Fragments[a].Order < World.Fragments[b].Order
		end)
		local count = 0
		for _, fragmentId in ids do
			if data.Fragments[fragmentId] then
				count += 1
			end
		end
		addEntry(0, Strings.get("FragmentsCount", { count = count, total = #ids }), "", COLOR_ACCENT)
		for index, fragmentId in ids do
			local info = World.Fragments[fragmentId]
			if data.Fragments[fragmentId] then
				addEntry(
					index,
					`{Strings.get("Npc_Fragment")} {info.Order}`,
					Strings.get(info.LoreKey),
					Color3.new(1, 1, 1)
				)
			else
				addEntry(index, `{Strings.get("Npc_Fragment")} {info.Order}`, "???", Color3.fromRGB(130, 130, 130))
			end
		end
	end
end

local function setOpen(value: boolean)
	isOpen = value
	panel.Visible = value
	CameraController:setCursorFree("Journal", value)
	if value then
		refresh()
	end
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Journal"
	gui.ResetOnSpawn = false

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.45, 0.65)
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
	title.Position = UDim2.fromScale(0.04, 0.03)
	title.Size = UDim2.fromScale(0.6, 0.07)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_ACCENT
	title.Text = Strings.get("JournalTitle")
	title.Parent = panel

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.fromScale(0.96, 0.03)
	closeButton.Size = UDim2.fromScale(0.18, 0.06)
	closeButton.BackgroundColor3 = COLOR_ROW
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = Strings.get("Close")
	closeButton.Parent = panel
	closeButton.Activated:Connect(function()
		setOpen(false)
	end)

	for index, tab in { "Quests", "Fragments" } do
		local button = Instance.new("TextButton")
		button.Position = UDim2.new(0.04 + (index - 1) * 0.47, 0, 0.12, 0)
		button.Size = UDim2.new(0.45, 0, 0.06, 0)
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.Text = Strings.get(`JournalTab_{tab}`)
		button.Parent = panel
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 6)
		buttonCorner.Parent = button
		button.Activated:Connect(function()
			currentTab = tab
			refresh()
		end)
		tabButtons[tab] = button
	end

	list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromScale(0.04, 0.21)
	list.Size = UDim2.fromScale(0.92, 0.76)
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

function JournalUiController:Init() end

function JournalUiController:Start()
	buildGui()
	InputController:onAction("Journal", function(state)
		if state == "Begin" then
			setOpen(not isOpen)
		end
	end)
	PlayerDataController:onChanged(function()
		if isOpen then
			refresh()
		end
	end)
end

return JournalUiController
