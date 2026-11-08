--!strict
--[[
	SettingsUiController (cliente) — pantalla de Ajustes (GDD v1 §10).
	Se abre con la tecla P o con el botón de engranaje (a la derecha, encima de la misión; pensado también para móvil).
	Opciones: idioma, volumen de efectos, números de daño de otros jugadores y calidad de efectos.
	La sensibilidad de la cámara se cambia en el menú de Roblox (los juegos no pueden modificarla).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local GameInfo = require(Config:WaitForChild("GameInfo"))
local InputController = require(script.Parent:WaitForChild("InputController"))
local CameraController = require(script.Parent:WaitForChild("CameraController"))
local SettingsController = require(script.Parent:WaitForChild("SettingsController"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local COLOR_ACCENT = Color3.fromRGB(255, 200, 70)
local COLOR_ROW = Color3.fromRGB(35, 42, 50)

local LANGUAGES = { "auto", "es", "en" }
local VOLUMES = { 0, 0.25, 0.5, 0.8, 1 }
local QUALITIES = { "High", "Low" }

local player = Players.LocalPlayer

local SettingsUiController = {}

local panel: Frame
local valueButtons: { [string]: TextButton } = {}
local isOpen = false

local function nextIn<T>(list: { T }, current: T): T
	local index = table.find(list, current) or 0
	return list[index % #list + 1]
end

local function describe(key: string): string
	local value = SettingsController:get(key)
	if key == "Language" then
		return Strings.get(`Lang_{value}`)
	elseif key == "EffectsVolume" then
		return `{math.floor((value :: number) * 100 + 0.5)}%`
	elseif key == "ShowOthersDamage" then
		return Strings.get(if value then "On" else "Off")
	else
		return Strings.get(`Quality_{value}`)
	end
end

local function refresh()
	for key, button in valueButtons do
		button.Text = describe(key)
	end
end

local function onClick(key: string)
	local value = SettingsController:get(key)
	if key == "Language" then
		SettingsController:set(key, nextIn(LANGUAGES, value))
	elseif key == "EffectsVolume" then
		-- Siguiente nivel de volumen (el más cercano por encima del actual).
		local nextValue = VOLUMES[1]
		for _, volume in VOLUMES do
			if volume > (value :: number) + 0.01 then
				nextValue = volume
				break
			end
		end
		SettingsController:set(key, nextValue)
	elseif key == "ShowOthersDamage" then
		SettingsController:set(key, not value)
	else
		SettingsController:set(key, nextIn(QUALITIES, value))
	end
end

local function setOpen(value: boolean)
	isOpen = value
	panel.Visible = value
	CameraController:setCursorFree("Settings", value)
	if value then
		refresh()
	end
end

local function makeLabel(parent: Instance, text: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = parent
	return label
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Settings"
	gui.ResetOnSpawn = false

	-- Botón de engranaje (siempre visible).
	local gear = Instance.new("TextButton")
	-- A la derecha, encima del panel de misión (arriba a la izquierda está el chat de Roblox).
	gear.AnchorPoint = Vector2.new(1, 0)
	gear.Position = UDim2.new(1, -16, 0.4, -48)
	gear.Size = UDim2.fromOffset(40, 40)
	gear.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	gear.BackgroundTransparency = 0.3
	gear.Font = Enum.Font.GothamBold
	gear.TextScaled = true
	gear.TextColor3 = COLOR_ACCENT
	gear.Text = "⚙"
	gear.Parent = gui
	local gearCorner = Instance.new("UICorner")
	gearCorner.CornerRadius = UDim.new(0, 8)
	gearCorner.Parent = gear
	gear.Activated:Connect(function()
		setOpen(not isOpen)
	end)

	panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.42, 0.55)
	panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Visible = false
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel

	local title =
		makeLabel(panel, Strings.get("SettingsTitle"), UDim2.fromScale(0.6, 0.09), UDim2.fromScale(0.05, 0.04))
	title.Font = Enum.Font.GothamBlack
	title.TextColor3 = COLOR_ACCENT

	local closeButton = Instance.new("TextButton")
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.fromScale(0.95, 0.04)
	closeButton.Size = UDim2.fromScale(0.2, 0.08)
	closeButton.BackgroundColor3 = COLOR_ROW
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Text = Strings.get("Close")
	closeButton.Parent = panel
	closeButton.Activated:Connect(function()
		setOpen(false)
	end)

	local options = {
		{ key = "Language", label = "Settings_Language" },
		{ key = "EffectsVolume", label = "Settings_Volume" },
		{ key = "ShowOthersDamage", label = "Settings_OthersDamage" },
		{ key = "EffectsQuality", label = "Settings_Quality" },
	}
	for index, option in options do
		local y = 0.17 + (index - 1) * 0.15
		local row = Instance.new("Frame")
		row.Position = UDim2.fromScale(0.05, y)
		row.Size = UDim2.fromScale(0.9, 0.12)
		row.BackgroundColor3 = COLOR_ROW
		row.BorderSizePixel = 0
		row.Parent = panel
		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row
		makeLabel(row, Strings.get(option.label), UDim2.fromScale(0.6, 0.5), UDim2.fromScale(0.04, 0.25))
		local button = Instance.new("TextButton")
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.fromScale(0.97, 0.5)
		button.Size = UDim2.fromScale(0.32, 0.7)
		button.BackgroundColor3 = COLOR_ACCENT
		button.Font = Enum.Font.GothamBold
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(20, 20, 20)
		button.Parent = row
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 6)
		buttonCorner.Parent = button
		local key = option.key
		button.Activated:Connect(function()
			onClick(key)
		end)
		valueButtons[key] = button
	end

	local hint = makeLabel(
		panel,
		`{Strings.get("Settings_SensitivityHint")}  {Strings.get("Settings_LanguageHint")}`,
		UDim2.fromScale(0.9, 0.1),
		UDim2.fromScale(0.05, 0.8)
	)
	hint.Font = Enum.Font.Gotham
	hint.TextWrapped = true
	hint.TextColor3 = Color3.fromRGB(180, 185, 190)

	-- Versión del juego (útil para los informes de errores de los jugadores).
	local version = makeLabel(panel, `v{GameInfo.Version}`, UDim2.fromScale(0.3, 0.05), UDim2.fromScale(0.05, 0.92))
	version.Font = Enum.Font.Code
	version.TextColor3 = Color3.fromRGB(130, 135, 140)

	gui.Parent = player:WaitForChild("PlayerGui")
end

function SettingsUiController:Init() end

function SettingsUiController:Start()
	buildGui()
	InputController:onAction("Settings", function(state)
		if state == "Begin" then
			setOpen(not isOpen)
		end
	end)
	PlayerDataController:onChanged(function(key: string)
		if isOpen and (key == "*" or key == "Settings") then
			refresh()
		end
	end)
end

return SettingsUiController
