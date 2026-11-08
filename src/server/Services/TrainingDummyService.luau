--!strict
--[[
	TrainingDummyService (solo para desarrollo)
	- Crea un muñeco de práctica si Debug.SpawnTrainingDummy está activado.
	- Cualquier modelo con la etiqueta "TrainingDummy" recupera toda su vida 3 s después del último golpe.
	  (Puedes poner esa etiqueta a tus propios muñecos en Studio: Properties → Tags → +.)
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Debug = require(Config:WaitForChild("Debug"))

local TAG = "TrainingDummy"
local MAX_HEALTH = 1000
local HEAL_DELAY = 3

local TrainingDummyService = {}

local function makePart(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createDummy(position: Vector3)
	local model = Instance.new("Model")
	model.Name = "TrainingDummy"
	local base = CFrame.new(position)
	local wood = Color3.fromRGB(160, 120, 80)

	local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), base, wood, model)
	root.Transparency = 1
	makePart("Torso", Vector3.new(2, 2, 1), base, wood, model)
	makePart("Head", Vector3.new(1.2, 1.2, 1.2), base * CFrame.new(0, 1.6, 0), wood, model)
	makePart("Post", Vector3.new(0.4, 3, 0.4), base * CFrame.new(0, -2.5, 0), Color3.fromRGB(110, 80, 50), model)
	model.PrimaryPart = root

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = MAX_HEALTH
	humanoid.Health = MAX_HEALTH
	humanoid.DisplayName = "Muñeco de práctica / Training Dummy"
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	humanoid.BreakJointsOnDeath = false
	humanoid.Parent = model

	model.Parent = Workspace
	CollectionService:AddTag(model, TAG)
end

local function setupHealing(model: Instance)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local hitCount = 0
	humanoid.HealthChanged:Connect(function(health: number)
		if health >= humanoid.MaxHealth then
			return
		end
		hitCount += 1
		local myHit = hitCount
		task.delay(HEAL_DELAY, function()
			if myHit == hitCount and humanoid.Parent then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	end)
end

function TrainingDummyService:Init() end

function TrainingDummyService:Start()
	CollectionService:GetInstanceAddedSignal(TAG):Connect(setupHealing)
	for _, model in CollectionService:GetTagged(TAG) do
		setupHealing(model)
	end
	if Debug.SpawnTrainingDummy then
		createDummy(Debug.TrainingDummyPosition)
		print("[TrainingDummyService] Muñeco de práctica creado")
	end
end

return TrainingDummyService
