--!strict
--[[
	FragmentController (cliente)
	- Texto del aviso de los Fragmentos en tu idioma.
	- Los Fragmentos que YA recogiste se ocultan solo para ti (cada jugador tiene su propia colección).
	- Los que faltan giran y flotan para llamar la atención.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Strings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Strings"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local FragmentController = {}

local fragments: { BasePart } = {}
local baseCFrames: { [BasePart]: CFrame } = {}

local function refresh()
	local data = PlayerDataController:get()
	for _, part in fragments do
		local fragmentId = part:GetAttribute("FragmentId")
		local collected = data ~= nil and typeof(fragmentId) == "string" and data.Fragments[fragmentId] == true
		part.LocalTransparencyModifier = if collected then 1 else 0
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Enabled = not collected
		end
	end
end

local function setup(part: Instance)
	if not part:IsA("BasePart") then
		return
	end
	table.insert(fragments, part)
	baseCFrames[part] = part.CFrame
	local prompt = part:WaitForChild("ProximityPrompt", 10)
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.ActionText = Strings.get("Collect")
		prompt.ObjectText = Strings.get("Npc_Fragment")
	end
	refresh()
end

function FragmentController:Init() end

function FragmentController:Start()
	for _, part in CollectionService:GetTagged("Fragment") do
		task.spawn(setup, part)
	end
	CollectionService:GetInstanceAddedSignal("Fragment"):Connect(setup)
	PlayerDataController:onChanged(function(key: string)
		if key == "*" or key == "Fragments" then
			refresh()
		end
	end)
	-- Animación local: girar y flotar (no cambia nada en el servidor).
	RunService.RenderStepped:Connect(function()
		local t = os.clock()
		for _, part in fragments do
			local base = baseCFrames[part]
			if base and part.LocalTransparencyModifier < 1 then
				part.CFrame = base * CFrame.new(0, math.sin(t * 2) * 0.4, 0) * CFrame.Angles(0, t, 0)
			end
		end
	end)
end

return FragmentController
