--!strict
--[[
	NpcService (servidor)
	Crea los NPC a partir de piezas del mapa con la etiqueta "QuestNPC"
	(atributos: NpcId, p. ej. "Ilen"; NameKey, clave de su nombre en Config/Strings).
	Cada NPC tiene un aviso "Pulsa E" (ProximityPrompt). Su activación llega directamente al servidor.
	Si el mapa no tiene ningún NPC, se crea la Maestra Ilen junto al punto de aparición (lugar de pruebas).
]]

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local TAG_SPAWN = "QuestNPC"
local TAG_NPC = "NPC"
local DEFAULT_POSITION = Vector3.new(-8, 0.9, -4)

local NpcService = {}

local talkListeners: { (player: Player, npcId: string) -> () } = {}

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

local function buildNpc(npcId: string, nameKey: string, groundPosition: Vector3)
	local model = Instance.new("Model")
	model.Name = `NPC_{npcId}`
	local base = CFrame.new(groundPosition + Vector3.new(0, 2.5, 0))
	local cloak = Color3.fromRGB(40, 120, 120)
	local skin = Color3.fromRGB(235, 200, 160)

	local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), base, cloak, model)
	root.Transparency = 1
	makePart("Legs", Vector3.new(1.8, 2, 1), base * CFrame.new(0, -1.5, 0), Color3.fromRGB(60, 50, 40), model)
	makePart("Torso", Vector3.new(2, 2, 1), base * CFrame.new(0, 0.5, 0), cloak, model)
	makePart("Head", Vector3.new(1.2, 1.2, 1.2), base * CFrame.new(0, 2.1, 0), skin, model)
	model.PrimaryPart = root

	local humanoid = Instance.new("Humanoid")
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Hablar / Talk" -- el cliente lo cambia a su idioma
	prompt.ObjectText = npcId
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(player: Player)
		for _, listener in talkListeners do
			task.spawn(listener, player, npcId)
		end
	end)

	model:SetAttribute("NpcId", npcId)
	model:SetAttribute("NameKey", nameKey)
	model.Parent = Workspace
	CollectionService:AddTag(model, TAG_NPC)
end

local function registerSpawn(part: Instance)
	if not part:IsA("BasePart") then
		return
	end
	local npcId = part:GetAttribute("NpcId")
	local nameKey = part:GetAttribute("NameKey")
	if typeof(npcId) ~= "string" then
		warn(`[NpcService] {part:GetFullName()} no tiene un atributo NpcId válido`)
		return
	end
	part.Transparency = 1
	part.CanCollide = false
	buildNpc(npcId, if typeof(nameKey) == "string" then nameKey else npcId, part.Position)
end

function NpcService:Init() end

function NpcService:Start()
	local spawns = CollectionService:GetTagged(TAG_SPAWN)
	if #spawns == 0 then
		buildNpc("Ilen", "Npc_Ilen", DEFAULT_POSITION)
	end
	for _, part in spawns do
		registerSpawn(part)
	end
end

-- Otros servicios (p. ej., QuestService) se enteran cuando un jugador habla con un NPC.
function NpcService:onTalk(listener: (player: Player, npcId: string) -> ())
	table.insert(talkListeners, listener)
end

return NpcService
