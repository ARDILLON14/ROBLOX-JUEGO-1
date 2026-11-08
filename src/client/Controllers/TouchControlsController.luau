--!strict
--[[
	TouchControlsController (cliente) — controles táctiles (primera actualización del GDD §11).
	Solo se activa en pantallas táctiles sin teclado. Los botones disparan las MISMAS acciones que el teclado
	(InputController:fire), así que el combate no cambia (decisión de diseño de la Entrega 2A).
	- Movimiento y salto: los controles táctiles de Roblox (joystick a la izquierda, salto a la derecha).
	- Botones propios a la derecha: Atacar (grande), Pesado, Esquivar, Bloquear (mantener), Habilidad,
	  Ulti (solo visible cuando está cargada) y Poción. Arriba a la derecha: Bolsa (inventario) y Diario.
	Tamaños relativos a la ALTURA de la pantalla (SizeConstraint RelativeYY): se ven bien en cualquier móvil.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local Affinities = require(Config:WaitForChild("Affinities"))
local Platform = require(Shared:WaitForChild("Util"):WaitForChild("Platform"))
local InputController = require(script.Parent:WaitForChild("InputController"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local COLOR_BUTTON = Color3.fromRGB(15, 20, 25)
local COLOR_ACCENT = Color3.fromRGB(255, 200, 70)

local player = Players.LocalPlayer

local TouchControlsController = {}

local buttons: { [string]: TextButton } = {}

-- Crea un botón redondo. position y size en proporción a la altura de la pantalla.
local function makeButton(parent: Instance, action: string, textKey: string, position: UDim2, size: number): TextButton
	local button = Instance.new("TextButton")
	button.Name = action
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = position
	button.Size = UDim2.fromScale(size, size)
	button.SizeConstraint = Enum.SizeConstraint.RelativeYY
	button.BackgroundColor3 = COLOR_BUTTON
	button.BackgroundTransparency = 0.35
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = Strings.get(textKey)
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_ACCENT
	stroke.Thickness = 2
	stroke.Transparency = 0.3
	stroke.Parent = button
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.15, 0)
	padding.PaddingRight = UDim.new(0.15, 0)
	padding.PaddingTop = UDim.new(0.25, 0)
	padding.PaddingBottom = UDim.new(0.25, 0)
	padding.Parent = button

	-- Pulsar = "Begin", soltar = "End" (necesario para mantener el bloqueo).
	button.InputBegan:Connect(function(input: InputObject)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			button.BackgroundTransparency = 0.1
			InputController:fire(action, "Begin")
		end
	end)
	button.InputEnded:Connect(function(input: InputObject)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			button.BackgroundTransparency = 0.35
			InputController:fire(action, "End")
		end
	end)
	buttons[action] = button
	return button
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TouchControls"
	gui.ResetOnSpawn = false

	-- Grupo de combate (abajo a la derecha, a la izquierda del botón de salto de Roblox).
	local cluster = Instance.new("Frame")
	cluster.AnchorPoint = Vector2.new(1, 1)
	cluster.Position = UDim2.new(1, -110, 1, -20)
	cluster.Size = UDim2.fromScale(0.62, 0.62)
	cluster.SizeConstraint = Enum.SizeConstraint.RelativeYY
	cluster.BackgroundTransparency = 1
	cluster.Parent = gui

	makeButton(cluster, "LightAttack", "Touch_Attack", UDim2.fromScale(0.72, 0.72), 0.2)
	makeButton(cluster, "HeavyAttack", "Touch_Heavy", UDim2.fromScale(0.42, 0.82), 0.13)
	makeButton(cluster, "Dodge", "Touch_Dodge", UDim2.fromScale(0.78, 0.38), 0.13)
	makeButton(cluster, "Block", "Touch_Block", UDim2.fromScale(0.5, 0.52), 0.13)
	makeButton(cluster, "Skill", "Touch_Skill", UDim2.fromScale(0.2, 0.62), 0.12)
	makeButton(cluster, "Ultimate", "Touch_Ultimate", UDim2.fromScale(0.45, 0.22), 0.13)
	makeButton(cluster, "UsePotion", "Touch_Potion", UDim2.fromScale(0.15, 0.88), 0.1)

	-- Menús (arriba a la derecha, debajo de la lista de jugadores).
	local menu = Instance.new("Frame")
	menu.AnchorPoint = Vector2.new(1, 0)
	menu.Position = UDim2.new(1, -70, 0.4, -48)
	menu.Size = UDim2.fromScale(0.22, 0.09)
	menu.SizeConstraint = Enum.SizeConstraint.RelativeYY
	menu.BackgroundTransparency = 1
	menu.Parent = gui
	makeButton(menu, "Inventory", "Touch_Inventory", UDim2.fromScale(0.25, 0.5), 0.09)
	makeButton(menu, "Journal", "Touch_Journal", UDim2.fromScale(0.75, 0.5), 0.09)

	gui.Parent = player:WaitForChild("PlayerGui")
end

-- Habilidad con el color de la afinidad; Ulti visible solo si está desbloqueada y cargada (GDD §4.1).
local function refreshAbilityButtons()
	local data = PlayerDataController:get()
	local affinityId: string = if data then data.Affinity.Selected else ""
	local config = Affinities.List[affinityId]
	local skill = buttons.Skill
	local ultimate = buttons.Ultimate
	if not config or not data then
		skill.Visible = false
		ultimate.Visible = false
		return
	end
	skill.Visible = true
	skill.TextColor3 = config.Color
	local rank = Affinities.rankOf(data.Affinity.Mastery[affinityId] or 0)
	local charge = player:GetAttribute("UltCharge")
	ultimate.Visible = rank >= 3 and typeof(charge) == "number" and charge >= 1
	ultimate.TextColor3 = config.Color
end

function TouchControlsController:Init() end

function TouchControlsController:Start()
	if not Platform.isTouch() then
		return -- PC: no se crea nada
	end
	buildGui()
	RunService.Heartbeat:Connect(refreshAbilityButtons)
end

return TouchControlsController
