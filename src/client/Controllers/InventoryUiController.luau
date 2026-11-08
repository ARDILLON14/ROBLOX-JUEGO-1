--!strict
--[[
	InventoryUiController (cliente) — pantalla de inventario (GDD v1 §8.1, lista simple aprobada).
	Tab o I para abrir/cerrar. Pestañas: Armas (equipar), Consumibles (usar), Cosméticos (equipar/quitar).
	El cliente solo PIDE; el servidor comprueba que tengas el objeto y aplica el cambio.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local WeaponCatalog = require(Config:WaitForChild("Weapons"))
local Cosmetics = require(Config:WaitForChild("Cosmetics"))
local Items = require(Config:WaitForChild("Items"))
local Net = require(Shared:WaitForChild("Net"))
local InputController = require(script.Parent:WaitForChild("InputController"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

type Tab = string -- "Weapons" | "Consumables" | "Cosmetics"

local COLOR_PANEL = Color3.fromRGB(15, 20, 25)
local COLOR_ROW = Color3.fromRGB(35, 42, 50)
local COLOR_ACCENT = Color3.fromRGB(255, 200, 70)

local player = Players.LocalPlayer

local InventoryUiController = {}

local panel: Frame
local list: ScrollingFrame
local tabButtons: { [Tab]: TextButton } = {}
local currentTab: Tab = "Weapons"
local isOpen = false

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function makeText(parent: Instance, text: string, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = parent
	return label
end

local function makeButton(parent: Instance, text: string, enabled: boolean, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(0.97, 0, 0.5, 0)
	button.Size = UDim2.new(0.24, 0, 0.6, 0)
	button.BackgroundColor3 = if enabled then COLOR_ACCENT else Color3.fromRGB(80, 85, 90)
	button.AutoButtonColor = enabled
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.fromRGB(20, 20, 20)
	button.Text = text
	button.Parent = parent
	corner(button, 6)
	if enabled then
		button.Activated:Connect(onClick)
	end
	return button
end

local function addRow(order: number, title: string, titleColor: Color3, detail: string): Frame
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 56)
	row.BackgroundColor3 = COLOR_ROW
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = list
	corner(row, 8)
	makeText(row, title, UDim2.new(0.68, 0, 0.45, 0), UDim2.new(0.03, 0, 0.08, 0), titleColor)
	local detailLabel = makeText(row, detail, UDim2.new(0.68, 0, 0.32, 0), UDim2.new(0.03, 0, 0.58, 0))
	detailLabel.Font = Enum.Font.Gotham
	detailLabel.TextColor3 = Color3.fromRGB(190, 195, 200)
	return row
end

local function clearList()
	for _, child in list:GetChildren() do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refresh()
	if not panel then
		return
	end
	for tab, button in tabButtons do
		button.BackgroundColor3 = if tab == currentTab then COLOR_ACCENT else COLOR_ROW
		button.TextColor3 = if tab == currentTab then Color3.fromRGB(20, 20, 20) else Color3.new(1, 1, 1)
	end
	clearList()
	local data = PlayerDataController:get()
	if not data then
		return
	end

	if currentTab == "Weapons" then
		for index, weaponId in WeaponCatalog.DisplayOrder do
			if table.find(data.Inventory.Weapons, weaponId) then
				local item = WeaponCatalog.Weapons[weaponId]
				local rarity = WeaponCatalog.Rarities[item.Rarity]
				local detail = `{Strings.get(rarity.NameKey)} · {Strings.get("DamageMultiplier", {
					mult = string.format("%.2f", rarity.DamageMultiplier),
				})}`
				local row = addRow(index, Strings.get(item.NameKey), rarity.Color, detail)
				local equipped = data.Inventory.EquippedWeapon == weaponId
				makeButton(row, Strings.get(if equipped then "Equipped" else "Equip"), not equipped, function()
					Net.event("RequestEquipWeapon"):FireServer(weaponId)
				end)
			end
		end
	elseif currentTab == "Consumables" then
		local count: number = data.Inventory.Potions
		local row = addRow(
			1,
			`{Strings.get(Items.SapPotion.NameKey)} x{count}`,
			Color3.fromRGB(90, 230, 110),
			Strings.get("PotionDescription")
		)
		makeButton(row, Strings.get("Use"), count > 0, function()
			Net.event("RequestUsePotion"):FireServer()
		end)
	else
		local owned: { string } = data.Cosmetics.Owned
		if #owned == 0 then
			local label = makeText(list, Strings.get("NoCosmetics"), UDim2.new(1, -8, 0, 40), UDim2.new())
			label.TextWrapped = true
			label.Font = Enum.Font.Gotham
		end
		for index, cosmeticId in owned do
			local cosmetic = Cosmetics[cosmeticId]
			if cosmetic then
				local equipped = data.Cosmetics.EquippedTitle == cosmeticId or data.Cosmetics.EquippedAura == cosmeticId
				local row = addRow(index, Strings.get(cosmetic.NameKey), cosmetic.Color, cosmetic.Slot)
				makeButton(row, Strings.get(if equipped then "Unequip" else "Equip"), true, function()
					Net.event("RequestEquipCosmetic"):FireServer(cosmeticId)
				end)
			end
		end
	end
end

local function setOpen(value: boolean)
	isOpen = value
	panel.Visible = value
	CameraController:setCursorFree("Inventory", value)
	if value then
		refresh()
	end
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Inventory"
	gui.ResetOnSpawn = false

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.45, 0.6)
	panel.BackgroundColor3 = COLOR_PANEL
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Active = true -- los clics sobre el panel no atacan
	panel.Visible = false
	panel.Parent = gui
	corner(panel, 12)

	makeText(
		panel,
		Strings.get("InventoryTitle"),
		UDim2.new(0.6, 0, 0.08, 0),
		UDim2.new(0.04, 0, 0.03, 0),
		COLOR_ACCENT
	)

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(0.97, 0, 0.03, 0)
	closeButton.Size = UDim2.new(0.18, 0, 0.07, 0)
	closeButton.BackgroundColor3 = COLOR_ROW
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = Strings.get("Close")
	closeButton.Parent = panel
	corner(closeButton, 6)
	closeButton.Activated:Connect(function()
		setOpen(false)
	end)

	local tabs: { Tab } = { "Weapons", "Consumables", "Cosmetics" }
	for index, tab in tabs do
		local button = Instance.new("TextButton")
		button.Position = UDim2.new(0.04 + (index - 1) * 0.31, 0, 0.13, 0)
		button.Size = UDim2.new(0.29, 0, 0.07, 0)
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.Text = Strings.get(`Tab_{tab}`)
		button.Parent = panel
		corner(button, 6)
		button.Activated:Connect(function()
			currentTab = tab
			refresh()
		end)
		tabButtons[tab] = button
	end

	list = Instance.new("ScrollingFrame")
	list.Position = UDim2.new(0.04, 0, 0.23, 0)
	list.Size = UDim2.new(0.92, 0, 0.73, 0)
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

function InventoryUiController:Init() end

function InventoryUiController:Start()
	buildGui()
	InputController:onAction("Inventory", function(state)
		if state == "Begin" then
			setOpen(not isOpen)
		end
	end)
	PlayerDataController:onChanged(function(key: string)
		if isOpen and (key == "*" or key == "Inventory" or key == "Cosmetics") then
			refresh()
		end
	end)
end

return InventoryUiController
