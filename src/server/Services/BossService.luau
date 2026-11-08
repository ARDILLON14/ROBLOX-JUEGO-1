--!strict
--[[
	BossService (servidor) — Vharok, el Guardián Marchito (GDD v1 §6.2).
	Aparece en la pieza con etiqueta "BossArena" (atributos BossId y Radius).

	Fase 1 (100 % → 50 %): Zarpazo (bloqueable) · Barrido de raíces (marcas rojas bajo los jugadores: esquivar)
	                        · Llamada del bosque (invoca Brotespinas).
	Transición (50 %): ruge, se rodea de Éter morado, 2 s invulnerable.
	Fase 2 (50 % → 0 %): todo más rápido + Lluvia de espinas (marcas por la arena) + Embestida (brillo ROJO).
	                     Si la embestida choca contra una columna (etiqueta "BossColumn"), queda aturdido 3 s
	                     y recibe daño extra.
	- Vida escalada por jugadores en la arena (ajuste aprobado para 12 jugadores).
	- Recompensas para quien hizo ≥ 3 % de su vida: XP, poción y probabilidad de arma épica.
	- Se reinicia si todos salen de la arena; reaparece 3 minutos después de ser derrotado.
	El modelo se mueve por código (sin física) para que un jefe tan grande se comporte de forma predecible.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Bosses = require(Config:WaitForChild("Bosses"))
local Items = require(Config:WaitForChild("Items"))
local WeaponCatalog = require(Config:WaitForChild("Weapons"))
local Debug = require(Config:WaitForChild("Debug"))
local Hitbox = require(Shared:WaitForChild("Combat"):WaitForChild("Hitbox"))
local Net = require(Shared:WaitForChild("Net"))
local DataService = require(script.Parent:WaitForChild("DataService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))

local TAG_ARENA = "BossArena"
local TAG_COLUMN = "BossColumn"
local DEFAULT_ARENA_RADIUS = 40
local AI_TICK = 0.2
local BAR_UPDATE_INTERVAL = 0.25

type BossConfig = typeof(Bosses.Vharok)
type BossState = "Waiting" | "Fighting" | "Busy" | "Transition" | "Charging" | "Stunned" | "Dead"

type Boss = {
	id: string,
	config: BossConfig,
	arena: BasePart,
	radius: number,
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	groundY: number,
	state: BossState,
	phase: number,
	busyUntil: number,
	target: Player?,
	damageBy: { [Player]: number },
	nextRootSweep: number,
	nextSummon: number,
	nextThornRain: number,
	nextCharge: number,
	emptySince: number?,
	adds: { Model },
	playersCounted: number,
	actionToken: number,
}

local BossService = {}

local bosses: { [Model]: Boss } = {}

local function log(message: string)
	if Debug.LogEnemies then
		print(`[BossService] {message}`)
	end
end

local function notify(player: Player, kind: string, params: { [string]: any })
	Net.event("Notify"):FireClient(player, kind, params)
end

local function flat(vector: Vector3): Vector3
	return Vector3.new(vector.X, 0, vector.Z)
end

-- Jugadores vivos dentro de la arena.
local function playersInArena(boss: Boss): { Player }
	local list: { Player } = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
			local offset = root.Position - boss.arena.Position
			if flat(offset).Magnitude <= boss.radius and math.abs(offset.Y) < 40 then
				table.insert(list, player)
			end
		end
	end
	return list
end

local function getPlayerRoot(player: Player?): BasePart?
	if not player then
		return nil
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function speedFactor(boss: Boss): number
	return if boss.phase >= 2 then boss.config.Phase2SpeedMultiplier else 1
end

local function sendBar(boss: Boss, toPlayers: { Player }?)
	local list: { Player } = if toPlayers then toPlayers else playersInArena(boss)
	for _, player in list do
		Net.event("BossPhase")
			:FireClient(player, boss.config.NameKey, boss.humanoid.Health, boss.humanoid.MaxHealth, boss.phase)
	end
end

local function hideBar()
	for _, player in Players:GetPlayers() do
		Net.event("BossPhase"):FireClient(player, "", 0, 0, 0)
	end
end

-- Vida escalada según los jugadores en la arena, conservando el porcentaje actual.
local function rescaleHealth(boss: Boss, playerCount: number)
	local count = math.max(1, playerCount)
	if count == boss.playersCounted then
		return
	end
	boss.playersCounted = count
	local ratio = boss.humanoid.Health / boss.humanoid.MaxHealth
	local maxHealth = math.floor(
		boss.config.BaseHealth * Debug.BossHealthMultiplier * (1 + boss.config.HealthScalePerPlayer * (count - 1))
	)
	boss.humanoid.MaxHealth = maxHealth
	boss.humanoid.Health = maxHealth * ratio
end

local function makePart(
	model: Model,
	name: string,
	size: Vector3,
	offset: Vector3,
	color: Color3,
	material: Enum.Material,
	base: CFrame
)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = base * CFrame.new(offset)
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	return part
end

local function buildModel(config: BossConfig, base: CFrame): (Model, Humanoid, BasePart)
	local k = config.Scale
	local model = Instance.new("Model")
	model.Name = "Vharok"
	local wood = Color3.fromRGB(70, 50, 35)
	local stone = Color3.fromRGB(95, 95, 90)
	local moss = Color3.fromRGB(90, 60, 110)

	local root =
		makePart(model, "HumanoidRootPart", Vector3.new(2, 2, 1) * k, Vector3.zero, wood, Enum.Material.Wood, base)
	root.Transparency = 1
	root.CanQuery = true
	makePart(model, "Legs", Vector3.new(1.8, 1.6, 1.1) * k, Vector3.new(0, -1.7, 0) * k, wood, Enum.Material.Wood, base)
	makePart(
		model,
		"Body",
		Vector3.new(2.4, 2.4, 1.4) * k,
		Vector3.new(0, 0.2, 0) * k,
		stone,
		Enum.Material.Slate,
		base
	)
	makePart(model, "Head", Vector3.new(1.4, 1.2, 1.2) * k, Vector3.new(0, 2, 0) * k, wood, Enum.Material.Wood, base)
	makePart(model, "Moss", Vector3.new(2.6, 0.6, 1.6) * k, Vector3.new(0, 1.3, 0) * k, moss, Enum.Material.Grass, base)
	makePart(
		model,
		"LeftArm",
		Vector3.new(0.7, 2.6, 0.7) * k,
		Vector3.new(-1.6, -0.1, 0) * k,
		wood,
		Enum.Material.Wood,
		base
	)
	makePart(
		model,
		"RightArm",
		Vector3.new(0.7, 2.6, 0.7) * k,
		Vector3.new(1.6, -0.1, 0) * k,
		wood,
		Enum.Material.Wood,
		base
	)
	makePart(
		model,
		"BranchL",
		Vector3.new(0.3, 1.8, 0.3) * k,
		Vector3.new(-0.5, 3, 0) * k,
		wood,
		Enum.Material.Wood,
		base
	)
	makePart(
		model,
		"BranchR",
		Vector3.new(0.3, 2.2, 0.3) * k,
		Vector3.new(0.6, 3.2, 0) * k,
		wood,
		Enum.Material.Wood,
		base
	)
	model.PrimaryPart = root

	local humanoid = Instance.new("Humanoid")
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff -- usamos la barra del jefe
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.BreakJointsOnDeath = false
	humanoid.Parent = model
	return model, humanoid, root
end

-- Mueve el jefe a una posición manteniendo hacia dónde mira.
local function moveTo(boss: Boss, position: Vector3)
	boss.model:PivotTo(CFrame.lookAt(position, position + boss.root.CFrame.LookVector))
end

local function face(boss: Boss, position: Vector3)
	local from = boss.root.Position
	local direction = flat(position - from)
	if direction.Magnitude > 0.1 then
		boss.model:PivotTo(CFrame.lookAt(from, from + direction))
	end
end

-- Marcas rojas en el suelo; tras el aviso, daño imbloqueable a quien siga dentro (esquivar evita el daño).
local function groundAttack(boss: Boss, centers: { Vector3 }, radius: number, warning: number, damage: number)
	local markers: { Part } = {}
	for _, center in centers do
		local marker = Instance.new("Part")
		marker.Name = "BossWarning"
		marker.Shape = Enum.PartType.Cylinder
		marker.Size = Vector3.new(0.3, radius * 2, radius * 2)
		marker.CFrame = CFrame.new(Vector3.new(center.X, boss.groundY + 0.3, center.Z))
			* CFrame.Angles(0, 0, math.rad(90))
		marker.Color = Color3.fromRGB(255, 40, 40)
		marker.Material = Enum.Material.Neon
		marker.Transparency = 0.5
		marker.Anchored = true
		marker.CanCollide = false
		marker.CanQuery = false
		marker.CanTouch = false
		marker.Parent = Workspace
		table.insert(markers, marker)
	end
	local token = boss.actionToken
	task.delay(warning / speedFactor(boss), function()
		for _, marker in markers do
			marker:Destroy()
		end
		if boss.state == "Dead" or token ~= boss.actionToken then
			return
		end
		for _, player in playersInArena(boss) do
			local root = getPlayerRoot(player)
			if root then
				for _, center in centers do
					if flat(root.Position - center).Magnitude <= radius then
						CombatService:damagePlayer(player, damage, true)
						break
					end
				end
			end
		end
	end)
end

local function doClaw(boss: Boss, targetRoot: BasePart)
	local claw = boss.config.Claw
	local factor = speedFactor(boss)
	boss.state = "Busy"
	boss.actionToken += 1
	local token = boss.actionToken
	face(boss, targetRoot.Position)
	boss.model:SetAttribute("Telegraph", "Normal")
	task.delay(claw.Windup / factor, function()
		if boss.state ~= "Busy" or token ~= boss.actionToken then
			return
		end
		boss.model:SetAttribute("Telegraph", nil)
		local perfect = false
		local hits = Hitbox.query(boss.root.CFrame, claw.Range, claw.Width, 12, { boss.model })
		for _, model in hits do
			local player = Players:GetPlayerFromCharacter(model)
			if player and CombatService:damagePlayer(player, claw.Damage, false) == "PerfectBlock" then
				perfect = true
			end
		end
		if perfect then
			boss.state = "Stunned"
			boss.busyUntil = os.clock() + claw.PerfectBlockStun
			boss.model:SetAttribute("Stunned", true)
		else
			boss.state = "Fighting"
			boss.busyUntil = os.clock() + claw.Cooldown / factor
		end
	end)
end

local function doRootSweep(boss: Boss)
	local sweep = boss.config.RootSweep
	local centers: { Vector3 } = {}
	for _, player in playersInArena(boss) do
		local root = getPlayerRoot(player)
		if root then
			table.insert(centers, root.Position)
		end
	end
	if #centers > 0 then
		groundAttack(boss, centers, sweep.Radius, sweep.Warning, sweep.Damage)
	end
	boss.busyUntil = os.clock() + 0.8
end

local function doThornRain(boss: Boss)
	local rain = boss.config.ThornRain
	local centers: { Vector3 } = {}
	for _ = 1, rain.Spots do
		local angle = math.random() * math.pi * 2
		local distance = math.random() * (boss.radius - 6)
		table.insert(
			centers,
			boss.arena.Position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
		)
	end
	groundAttack(boss, centers, rain.Radius, rain.Warning, rain.Damage)
	boss.busyUntil = os.clock() + 0.8
end

local function doSummon(boss: Boss)
	local summon = boss.config.Summon
	for index = #boss.adds, 1, -1 do
		if not boss.adds[index].Parent then
			table.remove(boss.adds, index)
		end
	end
	for _ = 1, summon.Count do
		if #boss.adds >= summon.MaxAlive then
			break
		end
		local offset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
		local add = EnemyService:spawnTemporary(summon.EnemyId, summon.Level, boss.root.Position + offset)
		if add then
			table.insert(boss.adds, add)
		end
	end
	boss.busyUntil = os.clock() + 1
end

local function isNearColumn(position: Vector3, extra: number): boolean
	for _, column in CollectionService:GetTagged(TAG_COLUMN) do
		if column:IsA("BasePart") then
			local reach = math.max(column.Size.X, column.Size.Z) / 2 + extra
			if flat(column.Position - position).Magnitude <= reach then
				return true
			end
		end
	end
	return false
end

local function doCharge(boss: Boss, targetRoot: BasePart)
	local charge = boss.config.Charge
	boss.state = "Busy"
	boss.actionToken += 1
	local token = boss.actionToken
	face(boss, targetRoot.Position)
	boss.model:SetAttribute("Telegraph", "Unblockable")
	task.delay(charge.Windup / speedFactor(boss), function()
		if boss.state ~= "Busy" or token ~= boss.actionToken then
			return
		end
		boss.model:SetAttribute("Telegraph", nil)
		boss.state = "Charging"
		local direction = boss.root.CFrame.LookVector
		local traveled = 0
		local hitPlayers: { [Player]: boolean } = {}
		local bodyRadius = 1.2 * boss.config.Scale
		local connection: RBXScriptConnection
		connection = RunService.Heartbeat:Connect(function(deltaTime: number)
			local currentState: BossState = boss.state
			if currentState ~= "Charging" then
				connection:Disconnect()
				return
			end
			local stepDistance = charge.Speed * deltaTime
			traveled += stepDistance
			local nextPosition = boss.root.Position + direction * stepDistance
			-- Daño a los jugadores que atropella.
			for _, player in playersInArena(boss) do
				local root = getPlayerRoot(player)
				if
					root
					and not hitPlayers[player]
					and flat(root.Position - nextPosition).Magnitude <= bodyRadius + 2
				then
					hitPlayers[player] = true
					CombatService:damagePlayer(player, charge.Damage, true)
				end
			end
			local outOfArena = flat(nextPosition - boss.arena.Position).Magnitude > boss.radius - bodyRadius
			if isNearColumn(nextPosition, bodyRadius) then
				-- ¡Choque contra una columna! Aturdido y vulnerable.
				connection:Disconnect()
				boss.state = "Stunned"
				boss.busyUntil = os.clock() + charge.StunOnColumn
				boss.model:SetAttribute("Stunned", true)
				boss.model:SetAttribute("Vulnerable", true)
				log("Vharok choca contra una columna")
			elseif outOfArena or traveled >= charge.MaxDistance then
				connection:Disconnect()
				boss.state = "Fighting"
				boss.busyUntil = os.clock() + 1
			else
				moveTo(boss, nextPosition)
			end
		end)
	end)
end

local function startTransition(boss: Boss)
	boss.state = "Transition"
	boss.actionToken += 1
	boss.phase = 2
	boss.model:SetAttribute("Telegraph", nil)
	boss.model:SetAttribute("Invulnerable", true)
	boss.model:SetAttribute("Phase", 2)
	boss.busyUntil = os.clock() + boss.config.TransitionTime
	local now = os.clock()
	boss.nextThornRain = now + boss.config.TransitionTime + 2
	boss.nextCharge = now + boss.config.TransitionTime + 4
	sendBar(boss)
	log("Vharok entra en la fase 2")
end

local function resetBoss(boss: Boss)
	boss.state = "Waiting"
	boss.actionToken += 1
	boss.phase = 1
	boss.target = nil
	boss.damageBy = {}
	boss.playersCounted = 0
	boss.humanoid.MaxHealth = boss.config.BaseHealth * Debug.BossHealthMultiplier
	boss.humanoid.Health = boss.humanoid.MaxHealth
	boss.model:SetAttribute("Phase", 1)
	boss.model:SetAttribute("Telegraph", nil)
	boss.model:SetAttribute("Stunned", nil)
	boss.model:SetAttribute("Vulnerable", nil)
	boss.model:SetAttribute("Invulnerable", nil)
	moveTo(boss, Vector3.new(boss.arena.Position.X, boss.groundY + boss.config.Scale * 2.5, boss.arena.Position.Z))
	hideBar()
	log("Vharok se reinicia (no quedan jugadores en la arena)")
end

local spawnBoss: (bossId: string, arena: BasePart) -> ()

local function onBossDied(boss: Boss)
	boss.state = "Dead"
	boss.actionToken += 1
	bosses[boss.model] = nil
	local rewards = boss.config.Rewards
	local contributors: { Player } = {}
	for player, damage in boss.damageBy do
		if player.Parent == Players and damage >= boss.humanoid.MaxHealth * boss.config.ContributionThreshold then
			table.insert(contributors, player)
			ProgressionService:addXP(player, rewards.XP)
			local data = DataService:get(player)
			if data then
				data.Inventory.Potions = math.min(Items.SapPotion.Max, data.Inventory.Potions + rewards.Potions)
				if math.random() < rewards.EpicChance then
					local equipped = WeaponCatalog.Weapons[data.Inventory.EquippedWeapon]
					local epicId = `{if equipped then equipped.Type else "Katana"}_Epic`
					if not table.find(data.Inventory.Weapons, epicId) then
						table.insert(data.Inventory.Weapons, epicId)
						notify(player, "WeaponReward", { nameKey = WeaponCatalog.Weapons[epicId].NameKey })
					end
				end
				DataService:changed(player, "Inventory")
			end
		end
	end
	for _, player in Players:GetPlayers() do
		notify(player, "BossDefeated", { nameKey = boss.config.NameKey })
	end
	EnemyService:notifyDefeated(boss.id, contributors)
	hideBar()
	log(`Vharok derrotado; recompensas para {#contributors} jugador(es)`)

	task.delay(3, function()
		boss.model:Destroy()
	end)
	task.delay(boss.config.RespawnTime, function()
		spawnBoss(boss.id, boss.arena)
	end)
end

local function step(boss: Boss)
	if boss.state == "Dead" then
		return
	end
	local now = os.clock()
	local inArena = playersInArena(boss)

	-- Esperando o reinicio.
	if #inArena == 0 then
		if boss.state ~= "Waiting" then
			boss.emptySince = boss.emptySince or now
			if now - (boss.emptySince :: number) >= boss.config.ResetAfter then
				boss.emptySince = nil
				resetBoss(boss)
			end
		end
		return
	end
	boss.emptySince = nil
	if boss.state == "Waiting" then
		boss.state = "Fighting"
		boss.nextRootSweep = now + boss.config.RootSweep.Every
		boss.nextSummon = now + boss.config.Summon.Every / 2
		log("Comienza el combate contra Vharok")
	end
	rescaleHealth(boss, #inArena)

	if boss.state == "Transition" then
		if now >= boss.busyUntil then
			boss.model:SetAttribute("Invulnerable", nil)
			boss.state = "Fighting"
		end
		return
	end
	if boss.state == "Stunned" then
		if now >= boss.busyUntil then
			boss.model:SetAttribute("Stunned", nil)
			boss.model:SetAttribute("Vulnerable", nil)
			boss.state = "Fighting"
		end
		return
	end
	if boss.state ~= "Fighting" or now < boss.busyUntil then
		return
	end

	-- Fase 2 al 50 %.
	if boss.phase == 1 and boss.humanoid.Health <= boss.humanoid.MaxHealth * boss.config.Phase2Threshold then
		startTransition(boss)
		return
	end

	-- Objetivo: el jugador más cercano dentro de la arena.
	local targetRoot: BasePart? = nil
	local bestDistance = math.huge
	for _, player in inArena do
		local root = getPlayerRoot(player)
		if root then
			local distance = flat(root.Position - boss.root.Position).Magnitude
			if distance < bestDistance then
				bestDistance, targetRoot, boss.target = distance, root, player
			end
		end
	end
	if not targetRoot then
		return
	end

	local factor = speedFactor(boss)
	if boss.phase >= 2 and now >= boss.nextCharge and bestDistance >= boss.config.Charge.MinDistance then
		boss.nextCharge = now + boss.config.Charge.Every / factor
		doCharge(boss, targetRoot)
	elseif boss.phase >= 2 and now >= boss.nextThornRain then
		boss.nextThornRain = now + boss.config.ThornRain.Every / factor
		doThornRain(boss)
	elseif now >= boss.nextSummon then
		boss.nextSummon = now + boss.config.Summon.Every / factor
		doSummon(boss)
	elseif now >= boss.nextRootSweep then
		boss.nextRootSweep = now + boss.config.RootSweep.Every / factor
		doRootSweep(boss)
	elseif bestDistance <= boss.config.Claw.Range then
		doClaw(boss, targetRoot)
	end
end

-- Movimiento hacia el objetivo (cada fotograma, solo mientras combate sin atacar).
local function updateMovement(boss: Boss, deltaTime: number)
	if boss.state ~= "Fighting" or os.clock() < boss.busyUntil then
		return
	end
	local targetRoot = getPlayerRoot(boss.target)
	if not targetRoot then
		return
	end
	local position = boss.root.Position
	local offset = flat(targetRoot.Position - position)
	local distance = offset.Magnitude
	if distance <= boss.config.Claw.Range * 0.8 then
		face(boss, targetRoot.Position)
		return
	end
	local stepDistance = math.min(distance, boss.config.WalkSpeed * speedFactor(boss) * deltaTime)
	local nextPosition = position + offset.Unit * stepDistance
	if flat(nextPosition - boss.arena.Position).Magnitude <= boss.radius - 4 then
		boss.model:PivotTo(CFrame.lookAt(nextPosition, nextPosition + offset.Unit))
	else
		face(boss, targetRoot.Position)
	end
end

spawnBoss = function(bossId: string, arena: BasePart)
	local config = (Bosses :: any)[bossId] :: BossConfig?
	if not config then
		warn(`[BossService] Jefe desconocido: {bossId}`)
		return
	end
	local radiusAttribute = arena:GetAttribute("Radius")
	local radius = if typeof(radiusAttribute) == "number" then radiusAttribute else DEFAULT_ARENA_RADIUS
	local groundY = arena.Position.Y - arena.Size.Y / 2
	local base = CFrame.new(arena.Position.X, groundY + config.Scale * 2.5, arena.Position.Z)
	local model, humanoid, root = buildModel(config, base)
	humanoid.MaxHealth = config.BaseHealth * Debug.BossHealthMultiplier
	humanoid.Health = humanoid.MaxHealth
	model:SetAttribute("NameKey", config.NameKey)
	model:SetAttribute("Level", config.Level)
	model:SetAttribute("Phase", 1)
	model.Parent = Workspace
	CollectionService:AddTag(model, "Enemy") -- para los visuales comunes (avisos, aturdido, quemado)
	CollectionService:AddTag(model, "Boss")

	local now = os.clock()
	local boss: Boss = {
		id = bossId,
		config = config,
		arena = arena,
		radius = radius,
		model = model,
		humanoid = humanoid,
		root = root,
		groundY = groundY,
		state = "Waiting",
		phase = 1,
		busyUntil = 0,
		target = nil,
		damageBy = {},
		nextRootSweep = now,
		nextSummon = now,
		nextThornRain = now,
		nextCharge = now,
		emptySince = nil,
		adds = {},
		playersCounted = 0,
		actionToken = 0,
	}
	bosses[model] = boss
	humanoid.Died:Connect(function()
		onBossDied(boss)
	end)
	log(`{bossId} aparece en la arena`)
end

-- Invulnerable durante la transición; daño extra tras chocar contra una columna.
local function bossDamageModifier(_player: Player, target: Model, amount: number, kind: string): (number, string)
	if not bosses[target] then
		return amount, kind
	end
	if target:GetAttribute("Invulnerable") then
		return 0, kind
	end
	if target:GetAttribute("Vulnerable") then
		return math.floor(amount * Bosses.Vharok.Charge.VulnerableMultiplier + 0.5), kind
	end
	return amount, kind
end

function BossService:Init() end

function BossService:Start()
	CombatService:addDamageModifier(bossDamageModifier)
	CombatService:onDamageDealt(function(player: Player, target: Model, amount: number)
		local boss = bosses[target]
		if boss and boss.state ~= "Dead" then
			boss.damageBy[player] = (boss.damageBy[player] or 0) + amount
		end
	end)

	for _, arena in CollectionService:GetTagged(TAG_ARENA) do
		local bossId = arena:GetAttribute("BossId")
		if arena:IsA("BasePart") and typeof(bossId) == "string" then
			spawnBoss(bossId, arena)
		end
	end

	task.spawn(function()
		while true do
			task.wait(AI_TICK)
			for _, boss in bosses do
				xpcall(step, function(err)
					warn(`[BossService] Error en la IA del jefe: {err}`)
				end, boss)
			end
		end
	end)

	local barTimer = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		barTimer += deltaTime
		local sendNow = barTimer >= BAR_UPDATE_INTERVAL
		if sendNow then
			barTimer = 0
		end
		for _, boss in bosses do
			updateMovement(boss, deltaTime)
			if sendNow and boss.state ~= "Waiting" and boss.state ~= "Dead" then
				sendBar(boss)
			end
		end
	end)
end

return BossService
