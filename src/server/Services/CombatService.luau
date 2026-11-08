--!strict
--[[
	CombatService (servidor)
	Recibe las peticiones de combate, las VALIDA y calcula el daño real (Entrega 2B §3–5).
	- El cliente solo dice "quiero atacar (ligero/pesado)", "quiero esquivar hacia X", "bloqueo sí/no".
	- El servidor comprueba estado, intervalos y enfriamientos con su propio reloj.
	- El servidor busca a quién golpea (Hitbox) y calcula el daño con la fórmula aprobada.
	- No hay PvP: los jugadores no se dañan entre sí.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local CombatConfig = require(Config:WaitForChild("Combat"))
local WeaponTypes = require(Config:WaitForChild("WeaponTypes"))
local Debug = require(Config:WaitForChild("Debug"))
local Hitbox = require(Shared:WaitForChild("Combat"):WaitForChild("Hitbox"))
local Validate = require(Shared:WaitForChild("Util"):WaitForChild("Validate"))
local Net = require(Shared:WaitForChild("Net"))
local Levels = require(Config:WaitForChild("Levels"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

type CombatState = {
	busyUntil: number, -- hasta cuándo está ocupado (atacando o esquivando)
	comboIndex: number,
	lastAttackEnd: number,
	attackStart: number,
	attackToken: number,
	lastDodge: number,
	invulnerableUntil: number,
	blocking: boolean,
	blockStart: number,
}

export type HitKind = "Normal" | "Crit"

local CombatService = {}

local states: { [Player]: CombatState } = {}

local function log(message: string)
	if Debug.LogCombat then
		print(`[CombatService] {message}`)
	end
end

local function newState(): CombatState
	return {
		busyUntil = 0,
		comboIndex = 0,
		lastAttackEnd = -math.huge,
		attackStart = 0,
		attackToken = 0,
		lastDodge = -math.huge,
		invulnerableUntil = 0,
		blocking = false,
		blockStart = 0,
	}
end

-- Devuelve el personaje, su Humanoid y su HumanoidRootPart si el jugador está vivo.
local function getAliveCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil, nil, nil
	end
	return character, humanoid, root
end

local function getWeapon(character: Model): WeaponTypes.WeaponType?
	local name = character:GetAttribute("WeaponType")
	if typeof(name) == "string" then
		return WeaponTypes[name]
	end
	return nil
end

-- Todos los personajes de jugadores (para excluirlos del golpe: no hay PvP).
local function getPlayerCharacters(): { Instance }
	local list: { Instance } = {}
	for _, other in Players:GetPlayers() do
		if other.Character then
			table.insert(list, other.Character)
		end
	end
	return list
end

-- Fórmula de daño aprobada (2B §5).
local function calculateDamage(
	player: Player,
	weapon: WeaponTypes.WeaponType,
	attackMultiplier: number
): (number, HitKind)
	local level = ProgressionService:getLevel(player)
	local rarityMultiplier = 1 -- [PENDIENTE] semana 10: rareza del arma equipada
	local damage = weapon.LightDamage * rarityMultiplier * (1 + Levels.DamagePerLevel * (level - 1)) * attackMultiplier
	local kind: HitKind = "Normal"
	if math.random() < CombatConfig.CritChance then
		damage *= CombatConfig.CritMultiplier
		kind = "Crit"
	end
	return math.floor(damage + 0.5), kind
end

local function sendHit(attacker: Player, target: Model, amount: number, kind: string)
	Net.event("HitConfirmed"):FireClient(attacker, target, amount, kind)
	for _, other in Players:GetPlayers() do
		if other ~= attacker then
			Net.unreliable("HitBroadcast"):FireClient(other, target, amount, kind)
		end
	end
end

local function resolveHit(player: Player, weapon: WeaponTypes.WeaponType, attackMultiplier: number, label: string)
	local _, _, root = getAliveCharacter(player)
	if not root then
		return
	end
	local targets = Hitbox.query(
		root.CFrame,
		weapon.Range + CombatConfig.HitboxTolerance,
		weapon.Width + CombatConfig.HitboxTolerance,
		CombatConfig.HitboxHeight,
		getPlayerCharacters()
	)
	for _, target in targets do
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local amount, kind = calculateDamage(player, weapon, attackMultiplier)
			humanoid:TakeDamage(amount)
			sendHit(player, target, amount, kind)
			log(`{player.Name}: {label} → {target.Name} -{amount} ({kind})`)
			-- Temporal (solo desarrollo): XP por golpear al muñeco, para probar la subida de nivel.
			if Debug.DummyXPPerHit > 0 and CollectionService:HasTag(target, "TrainingDummy") then
				ProgressionService:addXP(player, Debug.DummyXPPerHit)
			end
		end
	end
end

local function onRequestAttack(player: Player, kind: unknown)
	if not Validate.isOneOf(kind, { "Light", "Heavy" }) then
		return
	end
	local state = states[player]
	local character = getAliveCharacter(player)
	if not state or not character then
		return
	end
	local weapon = getWeapon(character)
	if not weapon then
		return
	end

	local now = os.clock()
	if state.blocking or now < state.busyUntil - CombatConfig.NetworkTimeTolerance then
		return -- todavía está ocupado: se ignora
	end

	local duration: number
	local hitTime: number
	local multiplier: number
	local label: string

	if kind == "Light" then
		if now - state.lastAttackEnd > CombatConfig.ComboResetTime + CombatConfig.NetworkTimeTolerance then
			state.comboIndex = 0
		end
		if state.comboIndex >= CombatConfig.ComboLength then
			state.comboIndex = 0
		end
		state.comboIndex += 1
		duration = weapon.LightInterval
		hitTime = weapon.LightHitTime
		multiplier = 1
		label = `Ligero {state.comboIndex}`
	else
		local isFinisher = state.comboIndex == 2
			and now - state.lastAttackEnd <= CombatConfig.ComboResetTime + CombatConfig.NetworkTimeTolerance
		duration = weapon.HeavyDuration
		hitTime = weapon.HeavyHitTime
		multiplier = if isFinisher then CombatConfig.FinisherMultiplier else CombatConfig.HeavyMultiplier
		label = if isFinisher then "Remate" else "Pesado"
		state.comboIndex = 0
	end

	state.attackStart = now
	state.busyUntil = now + duration
	state.lastAttackEnd = now + duration
	state.attackToken += 1
	local token = state.attackToken

	task.delay(hitTime, function()
		-- Si mientras tanto esquivó o murió, el golpe se cancela.
		if states[player] == state and state.attackToken == token then
			resolveHit(player, weapon, multiplier, label)
		end
	end)
end

local function onRequestDodge(player: Player, direction: unknown)
	if not Validate.isUnitVector(direction) then
		return
	end
	local state = states[player]
	local character = getAliveCharacter(player)
	if not state or not character then
		return
	end
	local weapon = getWeapon(character)
	local now = os.clock()
	if now - state.lastDodge < CombatConfig.DodgeCooldown - CombatConfig.NetworkTimeTolerance then
		return
	end
	if weapon and now < state.busyUntil and now - state.attackStart < weapon.DodgeCancelDelay then
		return
	end

	state.lastDodge = now
	state.attackToken += 1 -- cancela el golpe pendiente
	state.comboIndex = 0
	state.blocking = false
	state.busyUntil = now + CombatConfig.DodgeDuration
	state.invulnerableUntil = now + CombatConfig.DodgeDuration + CombatConfig.NetworkTimeTolerance
end

local function onRequestBlock(player: Player, active: unknown)
	if not Validate.isBoolean(active) then
		return
	end
	local state = states[player]
	if not state then
		return
	end
	if active == true then
		if os.clock() < state.busyUntil - CombatConfig.NetworkTimeTolerance or not getAliveCharacter(player) then
			return
		end
		state.blocking = true
		state.blockStart = os.clock()
	else
		state.blocking = false
	end
end

function CombatService:Init() end

function CombatService:Start()
	Net.onRequest("RequestAttack", 10, onRequestAttack)
	Net.onRequest("RequestDodge", 3, onRequestDodge)
	Net.onRequest("RequestBlock", 10, onRequestBlock)

	local function onPlayerAdded(player: Player)
		states[player] = newState()
		player.CharacterAdded:Connect(function()
			states[player] = newState()
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerRemoving:Connect(function(player: Player)
		states[player] = nil
	end)
end

--[[
	Para la semana 7 (enemigos): consulta si un jugador está esquivando o bloqueando.
	Devuelve el multiplicador de daño que debe recibir: 0 (esquiva o bloqueo perfecto), 0,3 (bloqueo) o 1.
]]
function CombatService:getIncomingDamageMultiplier(player: Player): number
	local state = states[player]
	if not state then
		return 1
	end
	local now = os.clock()
	if now < state.invulnerableUntil then
		return 0
	end
	if state.blocking then
		if now - state.blockStart <= CombatConfig.PerfectBlockWindow then
			return 0
		end
		return CombatConfig.BlockDamageMultiplier
	end
	return 1
end

return CombatService
