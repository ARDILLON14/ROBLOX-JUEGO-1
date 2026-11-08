--!strict
--[[
	NpcVisualController (cliente)
	- Nombre del NPC y texto del aviso ("Hablar") en tu idioma.
	- Marca sobre el NPC: "!" si tiene una misión para ti, "?" si puedes entregársela.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Strings = require(Config:WaitForChild("Strings"))
local Quests = require(Config:WaitForChild("Quests"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local TAG_NPC = "NPC"

local NpcVisualController = {}

local markers: { [string]: TextLabel } = {} -- NpcId → marca

local function refreshMarkers()
	local data = PlayerDataController:get()
	local quest = if data then Quests[data.Quests.ActiveId] else nil
	for npcId, marker in markers do
		local status = if data then data.Quests.Status else nil
		if quest and quest.Giver == npcId and status == "Available" then
			marker.Text = "!"
			marker.Visible = true
		elseif quest and quest.Giver == npcId and status == "ReadyToTurnIn" then
			marker.Text = "?"
			marker.Visible = true
		else
			marker.Visible = false
		end
	end
end

local function setupNpc(model: Instance)
	if not model:IsA("Model") then
		return
	end
	local npcId = model:GetAttribute("NpcId")
	local nameKey = model:GetAttribute("NameKey")
	if typeof(npcId) ~= "string" then
		return
	end
	local name = if typeof(nameKey) == "string" then Strings.get(nameKey) else npcId

	local humanoid = model:WaitForChild("Humanoid", 5)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.DisplayName = name
	end
	local root = model:WaitForChild("HumanoidRootPart", 5)
	if not root or not root:IsA("BasePart") then
		return
	end
	local prompt = root:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.ActionText = Strings.get("Talk")
		prompt.ObjectText = name
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(60, 60)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = root
	billboard.Parent = model
	local marker = Instance.new("TextLabel")
	marker.Size = UDim2.fromScale(1, 1)
	marker.BackgroundTransparency = 1
	marker.Font = Enum.Font.GothamBlack
	marker.TextScaled = true
	marker.TextColor3 = Color3.fromRGB(255, 200, 70)
	marker.TextStrokeTransparency = 0.2
	marker.Visible = false
	marker.Parent = billboard
	markers[npcId] = marker
	refreshMarkers()
end

function NpcVisualController:Init() end

function NpcVisualController:Start()
	CollectionService:GetInstanceAddedSignal(TAG_NPC):Connect(setupNpc)
	for _, model in CollectionService:GetTagged(TAG_NPC) do
		task.spawn(setupNpc, model)
	end
	PlayerDataController:onChanged(refreshMarkers)
end

return NpcVisualController
