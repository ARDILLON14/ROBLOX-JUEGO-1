--!strict
--[[
	HudController (cliente) — HUD básico del slice vertical (GDD v1 §10).
	- Abajo en el centro: vida y experiencia con tu nivel.
	- Abajo a la izquierda: pociones y esquiva (con su enfriamiento).
	- A la derecha: misión activa y su objetivo.
	- Arriba: avisos breves (objetivo cumplido, misión completada).
	Todo usa tamaños relativos a la pantalla para poder adaptarse a móvil más adelante.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Levels = require(Config:WaitForChild("Levels"))
local Quests = require(Config:WaitForChild("Quests"))
local Affinities = require(Config:WaitForChild("Affinities"))
local World = require(Config:WaitForChild("World"))
local Strings = require(Config:WaitForChild("Strings"))
local Net = require(Shared:WaitForChild("Net"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))
local CombatController = require(script.Parent:WaitForChild("CombatController"))

local player = Players.LocalPlayer

local COLOR_PANEL = Color3.fromRGB(15, 20, 25)
local COLOR_HEALTH = Color3.fromRGB(220, 60, 60)
local COLOR_XP = Color3.fromRGB(255, 200, 70)
local COLOR_TEXT = Color3.new(1, 1, 1)

local HudController = {}

local gui: ScreenGui
local healthFill: Frame
local healthText: TextLabel
local xpFill: Frame
local levelText: TextLabel
local xpText: TextLabel
local potionText: TextLabel
local dodgeText: TextLabel
local skillText: TextLabel
local ultText: TextLabel
local masteryText: TextLabel
local questTitle: TextLabel
local questObjective: TextLabel
local toast: TextLabel

local function makeLabel(parent: Instance, size: UDim2, position: UDim2, text: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = COLOR_TEXT
	label.TextScaled = true
	label.TextStrokeTransparency = 0.5
	label.Text = text
	label.Parent = parent
	return label
end

local function makeBar(parent: Instance, position: UDim2, height: number, color: Color3): (Frame, Frame)
	local back = Instance.new("Frame")
	back.Size = UDim2.new(1, 0, 0, height)
	back.Position = position
	back.BackgroundColor3 = COLOR_PANEL
	back.BackgroundTransparency = 0.3
	back.BorderSizePixel = 0
	back.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = back

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = back
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fill
	return back, fill
end

local function buildGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false

	-- Vida y experiencia (abajo, centro)
	local bottom = Instance.new("Frame")
	bottom.AnchorPoint = Vector2.new(0.5, 1)
	bottom.Position = UDim2.new(0.5, 0, 1, -14)
	bottom.Size = UDim2.new(0.36, 0, 0, 52)
	bottom.BackgroundTransparency = 1
	bottom.Parent = gui

	local healthBack
	healthBack, healthFill = makeBar(bottom, UDim2.new(0, 0, 0, 0), 24, COLOR_HEALTH)
	healthText = makeLabel(healthBack, UDim2.fromScale(1, 0.8), UDim2.fromScale(0, 0.1), "")

	local xpBack
	xpBack, xpFill = makeBar(bottom, UDim2.new(0, 0, 0, 30), 16, COLOR_XP)
	levelText = makeLabel(xpBack, UDim2.fromScale(0.3, 1), UDim2.fromScale(0.02, 0), "")
	levelText.TextXAlignment = Enum.TextXAlignment.Left
	xpText = makeLabel(xpBack, UDim2.fromScale(0.5, 1), UDim2.fromScale(0.48, 0), "")
	xpText.TextXAlignment = Enum.TextXAlignment.Right

	-- Pociones y esquiva (abajo, izquierda)
	local left = Instance.new("Frame")
	left.AnchorPoint = Vector2.new(0, 1)
	left.Position = UDim2.new(0, 16, 1, -14)
	left.Size = UDim2.new(0.2, 0, 0, 128)
	left.BackgroundTransparency = 1
	left.Parent = gui
	masteryText = makeLabel(left, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0), "")
	masteryText.TextXAlignment = Enum.TextXAlignment.Left
	masteryText.Font = Enum.Font.Gotham
	skillText = makeLabel(left, UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 22), "")
	skillText.TextXAlignment = Enum.TextXAlignment.Left
	ultText = makeLabel(left, UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 48), "")
	ultText.TextXAlignment = Enum.TextXAlignment.Left
	potionText = makeLabel(left, UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 76), "")
	potionText.TextXAlignment = Enum.TextXAlignment.Left
	dodgeText = makeLabel(left, UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 104), "")
	dodgeText.TextXAlignment = Enum.TextXAlignment.Left

	-- Misión (derecha)
	local questFrame = Instance.new("Frame")
	questFrame.AnchorPoint = Vector2.new(1, 0)
	questFrame.Position = UDim2.new(1, -16, 0.32, 0)
	questFrame.Size = UDim2.new(0.24, 0, 0, 74)
	questFrame.BackgroundColor3 = COLOR_PANEL
	questFrame.BackgroundTransparency = 0.4
	questFrame.BorderSizePixel = 0
	questFrame.Parent = gui
	local questCorner = Instance.new("UICorner")
	questCorner.CornerRadius = UDim.new(0, 8)
	questCorner.Parent = questFrame
	questTitle = makeLabel(questFrame, UDim2.new(0.92, 0, 0, 24), UDim2.new(0.04, 0, 0, 6), "")
	questTitle.TextColor3 = COLOR_XP
	questTitle.TextXAlignment = Enum.TextXAlignment.Left
	questObjective = makeLabel(questFrame, UDim2.new(0.92, 0, 0, 36), UDim2.new(0.04, 0, 0, 32), "")
	questObjective.Font = Enum.Font.Gotham
	questObjective.TextXAlignment = Enum.TextXAlignment.Left
	questObjective.TextYAlignment = Enum.TextYAlignment.Top
	questObjective.TextWrapped = true

	-- Avisos (arriba, centro)
	toast = makeLabel(gui, UDim2.new(0.5, 0, 0, 34), UDim2.new(0.25, 0, 0.12, 0), "")
	toast.TextColor3 = COLOR_XP
	toast.TextTransparency = 1
	toast.TextStrokeTransparency = 1

	gui.Parent = player:WaitForChild("PlayerGui")
end

local function refreshData()
	local data = PlayerDataController:get()
	if not data then
		return
	end
	local level: number = data.Level
	levelText.Text = Strings.get("LevelShort", { level = level })
	if level >= Levels.MaxLevel then
		xpFill.Size = UDim2.fromScale(1, 1)
		xpText.Text = Strings.get("XPMax")
	else
		local needed = Levels.xpToNext(level)
		xpFill.Size = UDim2.fromScale(math.clamp(data.XP / needed, 0, 1), 1)
		xpText.Text = Strings.get("XPText", { xp = data.XP, ["next"] = needed })
	end
	potionText.Text = Strings.get("Potions", { count = data.Inventory.Potions })

	local questState = data.Quests
	local quest = Quests.List[questState.ActiveId]
	if not quest or questState.Status == "None" then
		questTitle.Text = Strings.get("QuestTitle")
		questObjective.Text = Strings.get("QuestNone")
		return
	end
	local npcName = Strings.get(`Npc_{quest.Giver}`)
	questTitle.Text = `{Strings.get("QuestTitle")}: {Strings.get(quest.NameKey)}`
	if questState.Status == "Available" and quest.RequiredLevel and level < quest.RequiredLevel then
		questObjective.Text = Strings.get("QuestReachLevel", { level = quest.RequiredLevel })
	elseif questState.Status == "Available" then
		questObjective.Text = Strings.get("QuestTalkTo", { npc = npcName })
	elseif questState.Status == "ReadyToTurnIn" then
		questObjective.Text = Strings.get("QuestReturnTo", { npc = npcName })
	else
		questObjective.Text = Strings.get(quest.ObjectiveKey, { progress = questState.Progress, count = quest.Count })
	end
end

-- Habilidad, ulti y maestría (se actualiza cada fotograma por los enfriamientos).
local function refreshAbilities()
	local data = PlayerDataController:get()
	local affinityId: string = if data then data.Affinity.Selected else ""
	local config = Affinities.List[affinityId]
	if not data or not config then
		masteryText.Text = ""
		skillText.Text = Strings.get("NoAffinity")
		skillText.TextColor3 = COLOR_TEXT
		skillText.TextTransparency = 0.4
		ultText.Text = ""
		return
	end
	local affinityName = Strings.get(config.NameKey)
	local points: number = data.Affinity.Mastery[affinityId] or 0
	local rank = Affinities.rankOf(points)
	local nextThreshold = Affinities.Ranks[rank + 1]
	masteryText.Text = if nextThreshold
		then Strings.get(
			"MasteryText",
			{ affinity = affinityName, rank = rank, points = points, ["next"] = nextThreshold }
		)
		else Strings.get("MasteryMax", { affinity = affinityName, rank = rank })

	local skillName = Strings.get(config.SkillNameKey)
	local cooldownEnd = player:GetAttribute("SkillCooldownEnd")
	local remaining = if typeof(cooldownEnd) == "number" then cooldownEnd - Workspace:GetServerTimeNow() else 0
	skillText.TextColor3 = config.Color
	if remaining > 0 then
		skillText.Text = Strings.get("SkillCooldown", { name = skillName, time = string.format("%.1f", remaining) })
		skillText.TextTransparency = 0.5
	else
		skillText.Text = Strings.get("SkillReady", { name = skillName })
		skillText.TextTransparency = 0
	end

	local ultName = Strings.get(config.UltimateNameKey)
	ultText.TextColor3 = config.Color
	if rank < 3 then
		ultText.Text = Strings.get("UltLocked")
		ultText.TextTransparency = 0.5
	else
		local charge = player:GetAttribute("UltCharge")
		local value = if typeof(charge) == "number" then charge else 0
		ultText.Text = if value >= 1
			then Strings.get("UltReady", { name = ultName })
			else Strings.get("UltCharging", { name = ultName, percent = math.floor(value * 100) })
		ultText.TextTransparency = if value >= 1 then 0 else 0.4
	end
end

local function watchHealth(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local function update()
		local ratio = if humanoid.MaxHealth > 0 then humanoid.Health / humanoid.MaxHealth else 0
		TweenService:Create(healthFill, TweenInfo.new(0.15), { Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1) })
			:Play()
		healthText.Text = `{math.ceil(humanoid.Health)} / {math.ceil(humanoid.MaxHealth)}`
	end
	humanoid.HealthChanged:Connect(update)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)
	update()
end

local function showToast(text: string)
	toast.Text = text
	toast.TextTransparency = 0
	toast.TextStrokeTransparency = 0.4
	local myText = text
	task.delay(3, function()
		if toast.Text == myText then
			TweenService:Create(toast, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

local function hideDefaultHealthBar()
	for _ = 1, 10 do
		local ok = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		end)
		if ok then
			return
		end
		task.wait(0.5)
	end
end

function HudController:Init() end

function HudController:Start()
	buildGui()
	task.spawn(hideDefaultHealthBar)

	PlayerDataController:onChanged(refreshData)
	player.CharacterAdded:Connect(watchHealth)
	if player.Character then
		task.spawn(watchHealth, player.Character)
	end

	RunService.Heartbeat:Connect(function()
		refreshAbilities()
		local remaining = CombatController:getDodgeCooldownRemaining()
		if remaining > 0 then
			dodgeText.Text = Strings.get("DodgeCooldown", { time = string.format("%.1f", remaining) })
			dodgeText.TextTransparency = 0.5
		else
			dodgeText.Text = Strings.get("DodgeReady")
			dodgeText.TextTransparency = 0
		end
	end)

	Net.event("Notify").OnClientEvent:Connect(function(kind: string, params: { [string]: any })
		if kind == "QuestReady" then
			showToast(Strings.get("QuestReady", { npc = Strings.get(`Npc_{params.npcId}`) }))
		elseif kind == "QuestComplete" then
			showToast(Strings.get("QuestComplete", { name = Strings.get(params.nameKey) }))
		elseif kind == "WeaponReward" then
			showToast(Strings.get("WeaponReward", { name = Strings.get(params.nameKey) }))
		elseif kind == "ItemCollected" then
			showToast(Strings.get("ItemCollected", { name = Strings.get(params.nameKey) }))
		elseif kind == "CampfireDiscovered" then
			local info = World.Campfires[params.campfireId]
			showToast(Strings.get("CampfireDiscovered", { name = if info then Strings.get(info.NameKey) else "" }))
		elseif kind == "FastTravelBlocked" then
			showToast(Strings.get("FastTravelBlocked"))
		elseif kind == "FragmentFound" then
			showToast(Strings.get("FragmentFound", { count = params.count, total = 10 }))
		elseif kind == "AffinityChangeOnly" then
			showToast(Strings.get("AffinityChangeOnly"))
		elseif kind == "AffinityLocked" then
			showToast(Strings.get("AffinityLocked", { level = params.level }))
		elseif kind == "AffinityChosen" or kind == "MasteryRank" then
			local config = Affinities.List[params.affinity]
			local name = if config then Strings.get(config.NameKey) else tostring(params.affinity)
			showToast(
				if kind == "AffinityChosen"
					then Strings.get("AffinityChosen", { name = name })
					else Strings.get("MasteryRank", { name = name, rank = params.rank })
			)
		end
	end)
end

return HudController
