--!strict
--[[
	AbilityVfxController (cliente) — efectos visuales provisionales de las habilidades (piezas de neón).
	- Los recibe por "AbilityEffect" (para TODOS los jugadores). Son solo visuales: el daño lo decide el servidor.
	- Enemigos Quemados (atributo "Burning"): llamas sobre ellos.
	Los de otros jugadores se ven más transparentes (ajuste aprobado para 12 jugadores).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Affinities = require(Shared:WaitForChild("Config"):WaitForChild("Affinities"))
local Net = require(Shared:WaitForChild("Net"))

local RESONANCE_COLOR = Color3.fromRGB(200, 90, 255)

local player = Players.LocalPlayer

local AbilityVfxController = {}

local function flashPart(
	shape: Enum.PartType,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	duration: number,
	isMine: boolean,
	growTo: Vector3?
)
	local part = Instance.new("Part")
	part.Shape = shape
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = if isMine then 0.25 else 0.6
	part.Parent = Workspace
	local goal: { [string]: any } = { Transparency = 1 }
	if growTo then
		goal.Size = growTo
	end
	local tween =
		TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
end

local function play(caster: Player, affinityId: string, kind: string, origin: Vector3, direction: Vector3)
	local isMine = caster == player
	if affinityId == "Resonance" then
		flashPart(Enum.PartType.Ball, Vector3.one * 2, CFrame.new(origin), RESONANCE_COLOR, 0.5, true, Vector3.one * 16)
		return
	end
	local config = Affinities.List[affinityId]
	if not config then
		return
	end
	local facing = CFrame.lookAt(origin, origin + direction)
	if affinityId == "Fire" and kind == "Skill" then
		local range = config.SkillRange or 10
		local width = config.SkillWidthRank2 or 14
		flashPart(
			Enum.PartType.Block,
			Vector3.new(width * 0.6, 0.4, range * 0.5),
			facing * CFrame.new(0, -1, -range / 2),
			config.Color,
			0.35,
			isMine,
			Vector3.new(width, 0.4, range)
		)
	elseif affinityId == "Fire" then
		local radius = config.UltimateRadius or 14
		flashPart(
			Enum.PartType.Ball,
			Vector3.one * 3,
			CFrame.new(origin),
			config.Color,
			0.6,
			isMine,
			Vector3.one * radius * 2
		)
	elseif kind == "Skill" then
		local distance = config.DashDistance or 14
		flashPart(
			Enum.PartType.Block,
			Vector3.new(0.6, 0.6, distance),
			facing * CFrame.new(0, 0, -distance / 2),
			config.Color,
			0.4,
			isMine,
			nil
		)
	else
		local center = origin + direction * (config.UltimateDistance or 12)
		local radius = config.UltimateRadius or 12
		for i = 1, 6 do
			local angle = (i / 6) * math.pi * 2
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius * 0.6
			local strikeAt = center + offset
			task.delay(i * 0.04, function()
				flashPart(
					Enum.PartType.Block,
					Vector3.new(0.8, 30, 0.8),
					CFrame.new(strikeAt + Vector3.new(0, 15, 0)),
					config.Color,
					0.45,
					isMine,
					nil
				)
			end)
		end
		flashPart(
			Enum.PartType.Cylinder,
			Vector3.new(0.4, radius * 2, radius * 2),
			CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90)),
			config.Color,
			0.5,
			isMine,
			nil
		)
	end
end

local function watchBurning(model: Instance)
	if not model:IsA("Model") then
		return
	end
	local function refresh()
		local root = model:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		local existing = root:FindFirstChild("BurnFire")
		if model:GetAttribute("Burning") then
			if not existing then
				local fire = Instance.new("Fire")
				fire.Name = "BurnFire"
				fire.Size = 4
				fire.Heat = 6
				fire.Parent = root
			end
		elseif existing then
			existing:Destroy()
		end
	end
	model:GetAttributeChangedSignal("Burning"):Connect(refresh)
	refresh()
end

function AbilityVfxController:Init() end

function AbilityVfxController:Start()
	Net.unreliable("AbilityEffect").OnClientEvent
		:Connect(function(caster: Player, affinityId: string, kind: string, origin: Vector3, direction: Vector3)
			if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
				return
			end
			play(caster, affinityId, kind, origin, direction)
		end)
	for _, tag in { "Enemy", "TrainingDummy" } do
		CollectionService:GetInstanceAddedSignal(tag):Connect(watchBurning)
		for _, model in CollectionService:GetTagged(tag) do
			watchBurning(model)
		end
	end
end

return AbilityVfxController
