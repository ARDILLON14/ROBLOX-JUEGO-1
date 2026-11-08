--!strict
--[[
	DeathController (cliente) — pantalla de muerte (GDD v1 §10).
	"Has caído" + dónde vas a reaparecer (tu última fogata) + recordatorio de que no pierdes nada (decisión 7).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local World = require(Config:WaitForChild("World"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local player = Players.LocalPlayer

local DeathController = {}

local overlay: Frame
local subtitle: TextLabel

local function makeLabel(text: string, position: UDim2, size: UDim2, color: Color3, font: Enum.Font): TextLabel
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = font
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	label.Parent = overlay
	return label
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Death"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 10

	overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Visible = false
	overlay.Parent = gui

	makeLabel(
		Strings.get("DeathTitle"),
		UDim2.fromScale(0.5, 0.42),
		UDim2.fromScale(0.5, 0.1),
		Color3.fromRGB(230, 70, 70),
		Enum.Font.GothamBlack
	)
	subtitle =
		makeLabel("", UDim2.fromScale(0.5, 0.52), UDim2.fromScale(0.5, 0.05), Color3.new(1, 1, 1), Enum.Font.GothamBold)
	makeLabel(
		Strings.get("DeathTip"),
		UDim2.fromScale(0.5, 0.58),
		UDim2.fromScale(0.4, 0.035),
		Color3.fromRGB(190, 195, 200),
		Enum.Font.Gotham
	)
	gui.Parent = player:WaitForChild("PlayerGui")
end

local function onDied()
	local data = PlayerDataController:get()
	local campfireId = if data then data.LastCampfire else "Camp"
	local info = World.Campfires[campfireId] or World.Campfires.Camp
	subtitle.Text = Strings.get("DeathRespawn", { place = Strings.get(info.NameKey) })
	overlay.Visible = true
	overlay.BackgroundTransparency = 1
	TweenService:Create(overlay, TweenInfo.new(1), { BackgroundTransparency = 0.35 }):Play()
end

local function onCharacterAdded(character: Model)
	overlay.Visible = false
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.Died:Connect(onDied)
end

function DeathController:Init() end

function DeathController:Start()
	buildGui()
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
end

return DeathController
