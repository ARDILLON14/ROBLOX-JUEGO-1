--!strict
--[[
	QuestMarkerController (cliente)
	Muestra un rombo dorado flotante sobre el punto del mapa al que te envía tu misión activa
	(piezas con la etiqueta "QuestMarker" y el atributo MarkerId).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quests = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Quests"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local TAG_MARKER = "QuestMarker"

local player = Players.LocalPlayer

local QuestMarkerController = {}

local billboards: { [Instance]: BillboardGui } = {}

local function getBillboard(marker: BasePart): BillboardGui
	local existing = billboards[marker]
	if existing then
		return existing
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(48, 48)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = marker
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 200, 70)
	label.TextStrokeTransparency = 0.2
	label.Text = "◆"
	label.Parent = billboard
	billboard.Parent = player:WaitForChild("PlayerGui")
	billboards[marker] = billboard
	return billboard
end

local function refresh()
	local data = PlayerDataController:get()
	local quest = if data and data.Quests.Status == "Active" then Quests.List[data.Quests.ActiveId] else nil
	local activeMarkerId = if quest then quest.MarkerId else nil
	for _, marker in CollectionService:GetTagged(TAG_MARKER) do
		if marker:IsA("BasePart") then
			local show = activeMarkerId ~= nil and marker:GetAttribute("MarkerId") == activeMarkerId
			if show then
				getBillboard(marker).Enabled = true
			elseif billboards[marker] then
				billboards[marker].Enabled = false
			end
		end
	end
end

function QuestMarkerController:Init() end

function QuestMarkerController:Start()
	PlayerDataController:onChanged(refresh)
	CollectionService:GetInstanceAddedSignal(TAG_MARKER):Connect(refresh)
end

return QuestMarkerController
