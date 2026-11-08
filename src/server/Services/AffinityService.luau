--!strict
--[[
	AffinityService (servidor) — afinidades Fuego y Rayo (GDD v1 §4.4, opción B aprobada).
	- Elegir afinidad: nivel 5+, junto al Santuario (pieza con etiqueta "AffinityShrine"). Cambiar es gratis.
	- Habilidad (Z) y ulti (X): el servidor valida rango, enfriamiento y carga, y calcula el daño.
	- Maestría por afinidad (guardada): +10 por impacto de habilidad, +5 por enemigo derrotado con ella equipada.
	- Quemado: daño cada segundo. Resonancia: un golpe de RAYO sobre un enemigo Quemado provoca una explosión.
	- Carga de ulti: se llena haciendo daño (no se guarda al salir, decisión B1).
	Atributos del jugador que lee el cliente: "SkillCooldownEnd" (hora del servidor) y "UltCharge" (0 a 1).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Affinities = require(Config:WaitForChild("Affinities"))
local Debug = require(Config:WaitForChild("Debug"))
local Net = require(Shared:WaitForChild("Net"))
local Validate = require(Shared:WaitForChild("Util"):WaitForChild("Validate"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))

local TAG_SHRINE = "AffinityShrine"
local DEFAULT_SHRINE_POSITION = Vector3.new(14, 1.5, -6)
local BURN_TICK = 1

type Burn = {
	endTime: number,
	nextTick: number,
	damage: number,
	source: Player,
}

local AffinityService = {}

local skillReadyAt: { [Player]: number } = {}
local ultCharge: { [Player]: number } = {}
local burning: { [Model]: Burn } = {}

local function notify(player: Player, kind: string, params: { [string]: any })
	Net.event("Notify"):FireClient(player, kind, params)
end

local function getRoot(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function getTargetRoot(target: Model): BasePart?
	local root = target:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function setUltCharge(player: Player, value: number)
	ultCharge[player] = math.clamp(value, 0, 1)
	player:SetAttribute("UltCharge", ultCharge[player])
end

local function addMastery(player: Player, affinityId: string, points: number)
	local data = DataService:get(player)
	if not data then
		return
	end
	local mastery: { [string]: number } = data.Affinity.Mastery :: any
	local before = mastery[affinityId] or 0
	local after = before + points * Debug.MasteryMultiplier
	mastery[affinityId] = after
	local oldRank, newRank = Affinities.rankOf(before), Affinities.rankOf(after)
	if newRank > oldRank then
		notify(player, "MasteryRank", { affinity = affinityId, rank = newRank })
	end
	DataService:changed(player, "Affinity")
end

local function applyBurn(target: Model, source: Player, duration: number, tickDamage: number)
	local now = os.clock()
	burning[target] = {
		endTime = now + duration,
		nextTick = now + BURN_TICK,
		damage = tickDamage,
		source = source,
	}
	target:SetAttribute("Burning", true)
end

local function clearBurn(target: Model)
	burning[target] = nil
	if target.Parent then
		target:SetAttribute("Burning", nil)
	end
end

local function effect(player: Player, affinityId: string, kind: string, origin: Vector3, direction: Vector3)
	Net.unreliable("AbilityEffect"):FireAllClients(player, affinityId, kind, origin, direction)
end

-- Golpe de rayo sobre un enemigo Quemado → explosión de Resonancia (consume el Quemado).
local function checkResonance(player: Player, target: Model)
	if not burning[target] then
		return
	end
	clearBurn(target)
	local targetRoot = getTargetRoot(target)
	if not targetRoot then
		return
	end
	local damage = CombatService:scaleByLevel(player, Affinities.ResonanceDamage)
	for _, other in CombatService:queryTargetsAround(targetRoot.Position, Affinities.ResonanceRadius) do
		CombatService:dealDamage(player, other, damage, "Resonance")
	end
	effect(player, "Resonance", "Explosion", targetRoot.Position, Vector3.zAxis)
end

local function hitWithAbility(player: Player, affinityId: string, target: Model, damage: number, kind: string)
	CombatService:dealDamage(player, target, damage, kind)
	addMastery(player, affinityId, Affinities.MasteryPerAbilityHit)
end

local function castFire(
	player: Player,
	config: Affinities.AffinityConfig,
	rank: number,
	kind: string,
	root: BasePart,
	aim: Vector3
)
	if kind == "Skill" then
		local origin = CFrame.lookAt(root.Position, root.Position + aim)
		local width = if rank >= 2 then config.SkillWidthRank2 or 14 else config.SkillWidth or 10
		local burnDuration = if rank >= 2 then config.BurnDurationRank2 or 5 else config.BurnDuration or 3
		local damage = CombatService:scaleByLevel(player, config.SkillDamage)
		local tick = CombatService:scaleByLevel(player, config.BurnTickDamage or 4)
		for _, target in CombatService:queryTargets(origin, config.SkillRange or 10, width) do
			hitWithAbility(player, "Fire", target, damage, "Fire")
			applyBurn(target, player, burnDuration, tick)
		end
	else
		local damage = CombatService:scaleByLevel(player, config.UltimateDamage)
		local tick = CombatService:scaleByLevel(player, config.BurnTickDamage or 4)
		for _, target in CombatService:queryTargetsAround(root.Position, config.UltimateRadius or 14) do
			hitWithAbility(player, "Fire", target, damage, "Fire")
			applyBurn(target, player, config.BurnDurationRank2 or 5, tick)
		end
	end
end

local function castLightning(
	player: Player,
	config: Affinities.AffinityConfig,
	rank: number,
	kind: string,
	root: BasePart,
	aim: Vector3
)
	if kind == "Skill" then
		local origin = CFrame.lookAt(root.Position, root.Position + aim)
		local damage = CombatService:scaleByLevel(player, config.SkillDamage)
		local hit: { [Model]: boolean } = {}
		local targets = CombatService:queryTargets(origin, config.DashDistance or 14, config.DashWidth or 5)
		for _, target in targets do
			hit[target] = true
			hitWithAbility(player, "Lightning", target, damage, "Lightning")
			checkResonance(player, target)
		end
		-- Rango 2: la descarga salta a enemigos cercanos.
		if rank >= 2 then
			local chainDamage = math.max(1, math.floor(damage * (config.ChainDamageFraction or 0.5) + 0.5))
			for _, target in targets do
				local targetRoot = getTargetRoot(target)
				if targetRoot then
					local jumps = 0
					for _, other in CombatService:queryTargetsAround(targetRoot.Position, config.ChainRange or 12) do
						if jumps >= (config.ChainCount or 2) then
							break
						end
						if not hit[other] then
							hit[other] = true
							jumps += 1
							hitWithAbility(player, "Lightning", other, chainDamage, "Lightning")
							checkResonance(player, other)
						end
					end
				end
			end
		end
	else
		local center = root.Position + aim * (config.UltimateDistance or 12)
		local damage = CombatService:scaleByLevel(player, config.UltimateDamage)
		for _, target in CombatService:queryTargetsAround(center, config.UltimateRadius or 12) do
			hitWithAbility(player, "Lightning", target, damage, "Lightning")
			checkResonance(player, target)
		end
	end
end

local function onRequestAbility(player: Player, kind: unknown, aim: unknown)
	if not Validate.isOneOf(kind, { "Skill", "Ultimate" }) or not Validate.isUnitVector(aim) then
		return
	end
	local data = DataService:get(player)
	local root = getRoot(player)
	if not data or not root then
		return
	end
	local affinityId = data.Affinity.Selected
	local config = Affinities.List[affinityId]
	if not config or CombatService:isBusy(player) then
		return
	end
	local mastery: { [string]: number } = data.Affinity.Mastery :: any
	local rank = Affinities.rankOf(mastery[affinityId] or 0)
	local now = os.clock()

	if kind == "Skill" then
		if now < (skillReadyAt[player] or 0) - 0.1 then
			return
		end
		skillReadyAt[player] = now + config.SkillCooldown
		player:SetAttribute("SkillCooldownEnd", Workspace:GetServerTimeNow() + config.SkillCooldown)
	else
		if rank < 3 or (ultCharge[player] or 0) < 1 then
			return
		end
		setUltCharge(player, 0)
	end

	-- Solo dirección horizontal.
	local flatAim = Vector3.new((aim :: Vector3).X, 0, (aim :: Vector3).Z)
	flatAim = if flatAim.Magnitude > 0.01 then flatAim.Unit else root.CFrame.LookVector

	CombatService:setBusy(player, Affinities.CastTime)
	effect(player, affinityId, kind :: string, root.Position, flatAim)
	if affinityId == "Fire" then
		castFire(player, config, rank, kind :: string, root, flatAim)
	else
		castLightning(player, config, rank, kind :: string, root, flatAim)
	end
end

local function isNearShrine(player: Player): boolean
	local root = getRoot(player)
	if not root then
		return false
	end
	for _, shrine in CollectionService:GetTagged(TAG_SHRINE) do
		if shrine:IsA("BasePart") and (shrine.Position - root.Position).Magnitude <= Affinities.ShrineRange then
			return true
		end
	end
	return false
end

local function onRequestChooseAffinity(player: Player, affinityId: unknown)
	if typeof(affinityId) ~= "string" or not Affinities.List[affinityId] then
		return
	end
	local data = DataService:get(player)
	if not data or data.Level < Affinities.RequiredLevel or not isNearShrine(player) then
		return
	end
	if data.Affinity.Selected == affinityId then
		return
	end
	data.Affinity.Selected = affinityId
	DataService:changed(player, "Affinity")
	setUltCharge(player, 0)
	notify(player, "AffinityChosen", { affinity = affinityId })
end

local function setupShrine(shrine: Instance)
	if not shrine:IsA("BasePart") then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Afinidad / Affinity" -- el cliente lo cambia a su idioma
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = shrine
	prompt.Triggered:Connect(function(player: Player)
		local data = DataService:get(player)
		if not data then
			return
		end
		if data.Level < Affinities.RequiredLevel then
			notify(player, "AffinityLocked", { level = Affinities.RequiredLevel })
		else
			notify(player, "OpenAffinityChoice", {})
		end
	end)
end

local function createDefaultShrine()
	local shrine = Instance.new("Part")
	shrine.Name = "AffinityShrine"
	shrine.Shape = Enum.PartType.Ball
	shrine.Size = Vector3.new(3, 3, 3)
	shrine.Position = DEFAULT_SHRINE_POSITION
	shrine.Anchored = true
	shrine.Material = Enum.Material.Neon
	shrine.Color = Color3.fromRGB(150, 120, 255)
	shrine.Parent = Workspace
	CollectionService:AddTag(shrine, TAG_SHRINE)
end

function AffinityService:Init() end

function AffinityService:Start()
	Net.onRequest("RequestAbility", 3, onRequestAbility)
	Net.onRequest("RequestChooseAffinity", 1, onRequestChooseAffinity)

	-- Santuario: el del mapa o, si no hay, uno provisional en el campamento.
	if #CollectionService:GetTagged(TAG_SHRINE) == 0 then
		createDefaultShrine()
	end
	for _, shrine in CollectionService:GetTagged(TAG_SHRINE) do
		setupShrine(shrine)
	end
	CollectionService:GetInstanceAddedSignal(TAG_SHRINE):Connect(setupShrine)

	-- Carga de la ulti: cualquier daño que hagas.
	CombatService:onDamageDealt(function(player: Player, _target: Model, amount: number)
		local data = DataService:get(player)
		if data and data.Affinity.Selected ~= "" then
			setUltCharge(player, (ultCharge[player] or 0) + amount / Affinities.UltimateChargeDamage)
		end
	end)

	-- Maestría por enemigo derrotado con la afinidad equipada.
	EnemyService:onEnemyDefeated(function(_enemyId: string, contributors: { Player })
		for _, player in contributors do
			local data = DataService:get(player)
			if data and Affinities.List[data.Affinity.Selected] then
				addMastery(player, data.Affinity.Selected, Affinities.MasteryPerKill)
			end
		end
	end)

	DataService:onPlayerLoaded(function(player: Player)
		setUltCharge(player, 0)
		player:SetAttribute("SkillCooldownEnd", 0)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		skillReadyAt[player] = nil
		ultCharge[player] = nil
		for target, burn in burning do
			if burn.source == player then
				clearBurn(target)
			end
		end
	end)

	-- Bucle del Quemado.
	task.spawn(function()
		while true do
			task.wait(0.25)
			local now = os.clock()
			for target, burn in burning do
				local humanoid = target:FindFirstChildOfClass("Humanoid")
				if not target.Parent or not humanoid or humanoid.Health <= 0 or now >= burn.endTime then
					clearBurn(target)
				elseif now >= burn.nextTick then
					burn.nextTick += BURN_TICK
					CombatService:dealDamage(burn.source, target, burn.damage, "Fire", "Burn")
				end
			end
		end
	end)

	if Debug.LogCombat then
		print("[AffinityService] Afinidades listas (Fuego, Rayo)")
	end
end

return AffinityService
