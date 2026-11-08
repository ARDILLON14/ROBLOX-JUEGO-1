--!strict
--[[
	EnemyVisualController (cliente)
	- Nombre del enemigo en TU idioma y su nivel.
	- Aviso de ataque (atributo "Telegraph" que pone el servidor):
	    "Normal"      → brillo blanco-amarillo (se puede bloquear)
	    "Unblockable" → brillo ROJO (hay que esquivar)
	- Aturdido (atributo "Stunned") → brillo azul.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Strings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Strings"))
local SoundController = require(script.Parent:WaitForChild("SoundController"))

local TAG_ENEMY = "Enemy"
local COLOR_NORMAL = Color3.fromRGB(255, 240, 170)
local COLOR_UNBLOCKABLE = Color3.fromRGB(255, 40, 40)
local COLOR_STUNNED = Color3.fromRGB(110, 170, 255)

local EnemyVisualController = {}

local function setupEnemy(model: Instance)
	if not model:IsA("Model") then
		return
	end
	local humanoid = model:WaitForChild("Humanoid", 5)
	if humanoid and humanoid:IsA("Humanoid") then
		local nameKey = model:GetAttribute("NameKey")
		local level = model:GetAttribute("Level")
		if typeof(nameKey) == "string" then
			humanoid.DisplayName = Strings.get("EnemyName", { name = Strings.get(nameKey), level = level or 1 })
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0.2
	highlight.Enabled = false
	highlight.Parent = model

	local function refresh()
		local telegraph = model:GetAttribute("Telegraph")
		if model:GetAttribute("Stunned") then
			highlight.FillColor = COLOR_STUNNED
			highlight.OutlineColor = COLOR_STUNNED
			highlight.Enabled = true
		elseif telegraph == "Unblockable" then
			highlight.FillColor = COLOR_UNBLOCKABLE
			highlight.OutlineColor = COLOR_UNBLOCKABLE
			highlight.Enabled = true
		elseif telegraph == "Normal" then
			highlight.FillColor = COLOR_NORMAL
			highlight.OutlineColor = COLOR_NORMAL
			highlight.Enabled = true
		else
			highlight.Enabled = false
		end
	end
	model:GetAttributeChangedSignal("Telegraph"):Connect(function()
		refresh()
		if model:GetAttribute("Telegraph") then
			SoundController:play("Telegraph", model:FindFirstChild("HumanoidRootPart"), 0.5)
		end
	end)
	model:GetAttributeChangedSignal("Stunned"):Connect(refresh)
	refresh()
end

function EnemyVisualController:Init() end

function EnemyVisualController:Start()
	CollectionService:GetInstanceAddedSignal(TAG_ENEMY):Connect(setupEnemy)
	for _, model in CollectionService:GetTagged(TAG_ENEMY) do
		task.spawn(setupEnemy, model)
	end
end

return EnemyVisualController
