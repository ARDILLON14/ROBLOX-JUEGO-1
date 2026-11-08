--!strict
--[[
	DebugHudController (solo desarrollo)
	Muestra nivel, XP y pociones arriba a la izquierda mientras no exista el HUD real (semana 8).
	Se desactiva con Debug.ShowDebugHud = false.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Debug = require(Config:WaitForChild("Debug"))
local Levels = require(Config:WaitForChild("Levels"))
local Strings = require(Config:WaitForChild("Strings"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local player = Players.LocalPlayer

local DebugHudController = {}

function DebugHudController:Init() end

function DebugHudController:Start()
	if not Debug.ShowDebugHud then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "DebugHud"
	gui.ResetOnSpawn = false

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 12, 0, 12)
	label.Size = UDim2.new(0.35, 0, 0, 28)
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.5
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "…"
	label.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui")

	PlayerDataController:onChanged(function()
		local data = PlayerDataController:get()
		if not data then
			return
		end
		local level: number = data.Level
		local potions: number = data.Inventory.Potions
		if level >= Levels.MaxLevel then
			label.Text = " " .. Strings.get("DebugHudMax", { level = level, potions = potions })
		else
			label.Text = " "
				.. Strings.get("DebugHud", {
					level = level,
					xp = data.XP,
					["next"] = Levels.xpToNext(level),
					potions = potions,
				})
		end
	end)
end

return DebugHudController
