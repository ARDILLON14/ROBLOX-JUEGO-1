--!strict
--[[
	ZoneService (servidor) — fogatas, reaparición, viaje rápido y Fragmentos (GDD v1 §9).
	- Fogata (etiqueta "Campfire", atributo CampfireId): al usarla (E) se descubre, pasa a ser tu punto de
	  reaparición, te cura y abre el viaje rápido a las fogatas que ya descubriste.
	- Al reaparecer apareces junto a tu última fogata (decisión 7: morir no te hace perder nada).
	- Viaje rápido (RequestFastTravel): fogata descubierta, estar junto a una fogata y no haber recibido daño en 8 s.
	- Fragmento (etiqueta "Fragment", atributo FragmentId): al recogerlo se guarda, da 100 XP y muestra su historia.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local World = require(Shared:WaitForChild("Config"):WaitForChild("World"))
local Net = require(Shared:WaitForChild("Net"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))

local TAG_CAMPFIRE = "Campfire"
local TAG_FRAGMENT = "Fragment"

local ZoneService = {}

local campfireParts: { [string]: BasePart } = {}

local function notify(player: Player, kind: string, params: { [string]: any })
	Net.event("Notify"):FireClient(player, kind, params)
end

local function getRoot(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function teleportToCampfire(player: Player, campfireId: string)
	local campfire = campfireParts[campfireId]
	local character = player.Character
	if campfire and character then
		character:PivotTo(CFrame.new(campfire.Position + Vector3.new(4, 4, 0)))
	end
end

local function discoveredList(data: any): { string }
	local list: { string } = {}
	for campfireId in data.Campfires do
		if World.Campfires[campfireId] and campfireParts[campfireId] then
			table.insert(list, campfireId)
		end
	end
	table.sort(list, function(a: string, b: string)
		return World.Campfires[a].Order < World.Campfires[b].Order
	end)
	return list
end

local function onCampfireUsed(player: Player, campfireId: string)
	local data = DataService:get(player)
	if not data then
		return
	end
	local isNew = not data.Campfires[campfireId]
	data.Campfires[campfireId] = true
	data.LastCampfire = campfireId
	DataService:changed(player, "Campfires")
	DataService:changed(player, "LastCampfire")
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = humanoid.MaxHealth
	end
	if isNew then
		notify(player, "CampfireDiscovered", { campfireId = campfireId })
	end
	notify(player, "OpenCampfire", { current = campfireId, discovered = discoveredList(data) })
end

local function onRequestFastTravel(player: Player, campfireId: unknown)
	if typeof(campfireId) ~= "string" or not World.Campfires[campfireId] then
		return
	end
	local data = DataService:get(player)
	local root = getRoot(player)
	if not data or not root or not data.Campfires[campfireId] or not campfireParts[campfireId] then
		return
	end
	local nearCampfire = false
	for _, campfire in campfireParts do
		if (campfire.Position - root.Position).Magnitude <= World.CampfireRange then
			nearCampfire = true
			break
		end
	end
	if not nearCampfire then
		return
	end
	if os.clock() - CombatService:getLastHurtTime(player) < World.CombatLockTime then
		notify(player, "FastTravelBlocked", {})
		return
	end
	data.LastCampfire = campfireId
	DataService:changed(player, "LastCampfire")
	teleportToCampfire(player, campfireId)
end

local function onFragmentCollected(player: Player, fragmentId: string)
	local data = DataService:get(player)
	local info = World.Fragments[fragmentId]
	if not data or not info or data.Fragments[fragmentId] then
		return
	end
	data.Fragments[fragmentId] = true
	DataService:changed(player, "Fragments")
	local count = 0
	for _ in data.Fragments do
		count += 1
	end
	notify(player, "FragmentFound", { fragmentId = fragmentId, count = count })
	notify(player, "Dialogue", { npcId = "Fragment", textKey = info.LoreKey })
	ProgressionService:addXP(player, World.FragmentXP)
end

local function makePrompt(parent: BasePart, actionText: string, distance: number): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText -- el cliente lo cambia a su idioma
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = distance
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function setupCampfire(part: Instance)
	local campfireId = part:GetAttribute("CampfireId")
	if not part:IsA("BasePart") or typeof(campfireId) ~= "string" then
		return
	end
	campfireParts[campfireId] = part
	local fire = Instance.new("Fire")
	fire.Size = 6
	fire.Parent = part
	local prompt = makePrompt(part, "Descansar / Rest", 10)
	prompt.Triggered:Connect(function(player: Player)
		onCampfireUsed(player, campfireId)
	end)
end

local function setupFragment(part: Instance)
	local fragmentId = part:GetAttribute("FragmentId")
	if not part:IsA("BasePart") or typeof(fragmentId) ~= "string" then
		return
	end
	local prompt = makePrompt(part, "Recoger / Collect", 8)
	prompt.Triggered:Connect(function(player: Player)
		onFragmentCollected(player, fragmentId)
	end)
end

function ZoneService:Init() end

function ZoneService:Start()
	for _, part in CollectionService:GetTagged(TAG_CAMPFIRE) do
		setupCampfire(part)
	end
	CollectionService:GetInstanceAddedSignal(TAG_CAMPFIRE):Connect(setupCampfire)
	for _, part in CollectionService:GetTagged(TAG_FRAGMENT) do
		setupFragment(part)
	end
	CollectionService:GetInstanceAddedSignal(TAG_FRAGMENT):Connect(setupFragment)

	Net.onRequest("RequestFastTravel", 1, onRequestFastTravel)

	-- Reaparecer junto a la última fogata.
	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			character:WaitForChild("HumanoidRootPart", 10)
			task.wait() -- deja que Roblox termine de colocar al personaje
			local data = DataService:get(player)
			if data and data.LastCampfire ~= "Camp" then
				teleportToCampfire(player, data.LastCampfire)
			end
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

return ZoneService
