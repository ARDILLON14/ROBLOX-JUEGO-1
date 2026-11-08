--!strict
--[[
	EnemyService (servidor)
	Aparición, comportamiento (IA), ataques, derrota y reaparición de enemigos (GDD v1 §6.1).

	Puntos de aparición: piezas del mapa con la etiqueta "EnemySpawn" y los atributos
	  EnemyId (texto, p. ej. "Thornling"), Level (número) y Count (número)   ← decisión B3.
	Si no hay ninguno y Debug.SpawnTestEnemies está activado, se crea uno de prueba.

	IA (estados): Idle → Chase → Windup (aviso) → golpe → Cooldown → Chase…
	              Return (vuelve a su punto y se cura) · Stunned (tras tu bloqueo perfecto) · Dead
	- El servidor controla a los enemigos (SetNetworkOwner(nil)): ningún cliente puede moverlos.
	- Los enemigos "duermen" si no hay jugadores cerca (ahorra rendimiento).
	- XP para cada jugador que haya hecho al menos el 10 % de la vida del enemigo (decisión B6).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Enemies = require(Config:WaitForChild("Enemies"))
local Debug = require(Config:WaitForChild("Debug"))
local Hitbox = require(Shared:WaitForChild("Combat"):WaitForChild("Hitbox"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local ProgressionService = require(script.Parent:WaitForChild("ProgressionService"))

local TAG_SPAWN = "EnemySpawn"
local TAG_ENEMY = "Enemy"
local AI_TICK = 0.2 -- segundos entre decisiones de la IA
local SLEEP_RANGE = 120 -- sin jugadores a esta distancia, el enemigo duerme
local SPAWN_RADIUS = 6
local CONTRIBUTION_THRESHOLD = 0.10
local RESPAWN_PLAYER_FACTOR = 0.15 -- cada jugador extra cerca acelera la reaparición un 15 %

type EnemyState = "Idle" | "Chase" | "Windup" | "Cooldown" | "Return" | "Stunned" | "Dead"

type SpawnPoint = {
	part: BasePart,
	enemyId: string,
	level: number,
	count: number,
	alive: number,
	temporary: boolean?, -- refuerzos del jefe: no reaparecen
}

type Enemy = {
	config: Enemies.EnemyConfig,
	level: number,
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	spawnPoint: SpawnPoint,
	state: EnemyState,
	target: Player?,
	stateUntil: number,
	damageBy: { [Player]: number },
	maxHealth: number,
	damage: number,
	attackToken: number,
}

local EnemyService = {}

local enemies: { [Model]: Enemy } = {}
local defeatListeners: { (enemyId: string, contributors: { Player }) -> () } = {}
local folder: Folder

local function log(message: string)
	if Debug.LogEnemies then
		print(`[EnemyService] {message}`)
	end
end

-- Construye un enemigo provisional con bloques (sin modelo 3D todavía). "Scale" cambia su tamaño.
local function buildModel(config: Enemies.EnemyConfig, cframe: CFrame): (Model, Humanoid, BasePart)
	local model = Instance.new("Model")
	local k = config.Scale

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1) * k
	root.Transparency = 1
	root.CanCollide = false
	root.CFrame = cframe
	root.Parent = model
	model.PrimaryPart = root

	-- Piezas visibles, pegadas a la raíz. Posiciones relativas a su centro (el suelo está a -2,5).
	type Piece = { name: string, size: Vector3, offset: CFrame, color: Color3 }
	local pieces: { Piece } = {
		{ name = "Stump", size = Vector3.new(1.2, 0.8, 1), offset = CFrame.new(0, -2.1, 0), color = config.BodyColor },
		{ name = "Body", size = Vector3.new(1.6, 1.8, 1.2), offset = CFrame.new(0, -0.8, 0), color = config.BodyColor },
		{ name = "Head", size = Vector3.new(1.2, 1.2, 1.2), offset = CFrame.new(0, 0.7, 0), color = config.LeafColor },
		{
			name = "LeftArm",
			size = Vector3.new(0.4, 1.4, 0.4),
			offset = CFrame.new(-1.05, -0.7, 0),
			color = config.LeafColor,
		},
		{
			name = "RightArm",
			size = Vector3.new(0.4, 1.4, 0.4),
			offset = CFrame.new(1.05, -0.7, 0),
			color = config.LeafColor,
		},
	}
	if config.FrontGuard then
		-- Escudo de piedra delante: indica que bloquea de frente.
		table.insert(pieces, {
			name = "Shield",
			size = Vector3.new(2.2, 2.4, 0.4),
			offset = CFrame.new(0, -0.6, -0.9),
			color = Color3.fromRGB(150, 150, 140),
		})
	end
	for _, piece in pieces do
		local part = Instance.new("Part")
		part.Name = piece.name
		part.Size = piece.size * k
		part.CFrame = cframe * CFrame.new(piece.offset.Position * k)
		part.Color = piece.color
		part.Material = config.Material
		part.CanCollide = false
		part.Massless = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part
		part.Parent = model
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = 1.5 * k -- flota a esta altura (no tiene piernas)
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
	humanoid.Parent = model

	return model, humanoid, root
end

local function countPlayersNear(position: Vector3, range: number): number
	local count = 0
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") and (root.Position - position).Magnitude <= range then
			count += 1
		end
	end
	return count
end

-- Jugador vivo más cercano dentro de "range". Devuelve el jugador y su HumanoidRootPart.
local function findNearestPlayer(position: Vector3, range: number): (Player?, BasePart?)
	local bestPlayer: Player? = nil
	local bestRoot: BasePart? = nil
	local bestDistance = range
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
			local distance = (root.Position - position).Magnitude
			if distance <= bestDistance then
				bestPlayer, bestRoot, bestDistance = player, root, distance
			end
		end
	end
	return bestPlayer, bestRoot
end

local function getTargetRoot(player: Player?): BasePart?
	if not player or player.Parent ~= Players then
		return nil
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function faceTowards(enemy: Enemy, position: Vector3)
	local from = enemy.root.Position
	local flatTarget = Vector3.new(position.X, from.Y, position.Z)
	if (flatTarget - from).Magnitude > 0.1 then
		enemy.root.CFrame = CFrame.lookAt(from, flatTarget)
	end
end

local spawnEnemy: (spawnPoint: SpawnPoint) -> ()

local function onEnemyDied(enemy: Enemy)
	enemy.state = "Dead"
	enemy.attackToken += 1
	enemies[enemy.model] = nil

	-- XP para quien contribuyó lo suficiente.
	local xp = enemy.config.XPPerLevel * enemy.level
	local contributors: { Player } = {}
	for player, damage in enemy.damageBy do
		if player.Parent == Players and damage >= enemy.maxHealth * CONTRIBUTION_THRESHOLD then
			ProgressionService:addXP(player, xp)
			table.insert(contributors, player)
		end
	end
	local enemyId = enemy.model:GetAttribute("EnemyId")
	if typeof(enemyId) == "string" then
		for _, listener in defeatListeners do
			task.spawn(listener, enemyId, contributors)
		end
	end
	log(`{enemy.model.Name} derrotado (+{xp} XP a los que contribuyeron)`)

	task.delay(1.5, function()
		enemy.model:Destroy()
	end)

	-- Reaparición: más rápida cuanta más gente hay cerca (ajuste aprobado para 12 jugadores).
	local spawnPoint = enemy.spawnPoint
	spawnPoint.alive -= 1
	if spawnPoint.temporary then
		spawnPoint.part:Destroy()
		return
	end
	local nearby = math.max(1, countPlayersNear(spawnPoint.part.Position, SLEEP_RANGE))
	local delayTime = enemy.config.RespawnTime / (1 + RESPAWN_PLAYER_FACTOR * (nearby - 1))
	task.delay(delayTime, function()
		if spawnPoint.alive < spawnPoint.count then
			spawnEnemy(spawnPoint)
		end
	end)
end

spawnEnemy = function(spawnPoint: SpawnPoint)
	local config = Enemies[spawnPoint.enemyId]
	if not config then
		warn(`[EnemyService] Enemigo desconocido en un punto de aparición: {spawnPoint.enemyId}`)
		return
	end
	local angle = math.random() * math.pi * 2
	local distance = math.random() * SPAWN_RADIUS
	local position = spawnPoint.part.Position + Vector3.new(math.cos(angle) * distance, 3, math.sin(angle) * distance)
	local model, humanoid, root = buildModel(config, CFrame.new(position))

	local level = spawnPoint.level
	local maxHealth = config.BaseHealth + config.HealthPerLevel * (level - 1)
	model.Name = spawnPoint.enemyId
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	humanoid.WalkSpeed = config.WalkSpeed
	model:SetAttribute("EnemyId", spawnPoint.enemyId)
	model:SetAttribute("NameKey", config.NameKey)
	model:SetAttribute("Level", level)
	model.Parent = folder
	root:SetNetworkOwner(nil) -- el servidor controla su física
	CollectionService:AddTag(model, TAG_ENEMY)

	local enemy: Enemy = {
		config = config,
		level = level,
		model = model,
		humanoid = humanoid,
		root = root,
		spawnPoint = spawnPoint,
		state = "Idle",
		target = nil,
		stateUntil = 0,
		damageBy = {},
		maxHealth = maxHealth,
		damage = config.BaseDamage + config.DamagePerLevel * (level - 1),
		attackToken = 0,
	}
	enemies[model] = enemy
	spawnPoint.alive += 1

	humanoid.Died:Connect(function()
		onEnemyDied(enemy)
	end)
end

local function stun(enemy: Enemy, duration: number?)
	enemy.state = "Stunned"
	enemy.attackToken += 1
	enemy.stateUntil = os.clock() + (duration or enemy.config.StunDuration)
	enemy.model:SetAttribute("Telegraph", nil)
	enemy.model:SetAttribute("Stunned", true)
	enemy.humanoid:Move(Vector3.zero)
end

-- Espina del Lanzador: el servidor la mueve y comprueba si toca a un jugador (se puede bloquear o esquivar).
local function fireProjectile(enemy: Enemy, targetPosition: Vector3)
	local origin = enemy.root.Position + Vector3.new(0, 0.5, 0)
	local offset = targetPosition - origin
	if offset.Magnitude < 0.1 then
		return
	end
	local direction = offset.Unit
	local speed = enemy.config.ProjectileSpeed or 45
	local maxDistance = enemy.config.ProjectileRange or 45
	local damage = enemy.damage

	local spine = Instance.new("Part")
	spine.Name = "Spine"
	spine.Size = Vector3.new(0.4, 0.4, 1.6)
	spine.Color = enemy.config.LeafColor
	spine.Material = Enum.Material.Neon
	spine.Anchored = true
	spine.CanCollide = false
	spine.CanQuery = false
	spine.CanTouch = false
	spine.CFrame = CFrame.lookAt(origin, origin + direction)
	spine.Parent = folder

	local traveled = 0
	local connection: RBXScriptConnection
	connection = RunService.Heartbeat:Connect(function(deltaTime: number)
		local stepDistance = speed * deltaTime
		traveled += stepDistance
		local position = spine.Position + direction * stepDistance
		spine.CFrame = CFrame.lookAt(position, position + direction)
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") and (root.Position - position).Magnitude <= 2.5 then
				CombatService:damagePlayer(player, damage, false)
				connection:Disconnect()
				spine:Destroy()
				return
			end
		end
		if traveled >= maxDistance then
			connection:Disconnect()
			spine:Destroy()
		end
	end)
end

local function startAttack(enemy: Enemy, targetRoot: BasePart)
	enemy.state = "Windup"
	enemy.attackToken += 1
	local token = enemy.attackToken
	enemy.humanoid:MoveTo(enemy.root.Position) -- se detiene
	enemy.humanoid.AutoRotate = false
	faceTowards(enemy, targetRoot.Position)
	-- Aviso visual: el cliente lo muestra como brillo (normal o rojo).
	enemy.model:SetAttribute("Telegraph", if enemy.config.Unblockable then "Unblockable" else "Normal")

	task.delay(enemy.config.AttackWindup, function()
		if enemy.attackToken ~= token or enemy.state ~= "Windup" then
			return
		end
		enemy.model:SetAttribute("Telegraph", nil)
		enemy.humanoid.AutoRotate = true

		if enemy.config.AttackStyle == "Ranged" then
			local currentTarget = getTargetRoot(enemy.target)
			fireProjectile(enemy, if currentTarget then currentTarget.Position else targetRoot.Position)
			enemy.state = "Cooldown"
			enemy.stateUntil = os.clock() + enemy.config.AttackCooldown
			return
		end

		local hits =
			Hitbox.query(enemy.root.CFrame, enemy.config.AttackRange + 1, enemy.config.AttackWidth, 5, { folder })
		local wasPerfectBlocked = false
		for _, model in hits do
			local player = Players:GetPlayerFromCharacter(model)
			if player then
				local result = CombatService:damagePlayer(player, enemy.damage, enemy.config.Unblockable)
				if result == "PerfectBlock" then
					wasPerfectBlocked = true
				end
			end
		end

		if wasPerfectBlocked then
			stun(enemy)
		else
			enemy.state = "Cooldown"
			enemy.stateUntil = os.clock() + enemy.config.AttackCooldown
		end
	end)
end

local function step(enemy: Enemy)
	local now = os.clock()
	local position = enemy.root.Position
	local home = enemy.spawnPoint.part.Position

	-- Dormir si no hay nadie cerca.
	if countPlayersNear(position, SLEEP_RANGE) == 0 then
		if (position - home).Magnitude > 8 then
			enemy.humanoid:MoveTo(home)
		end
		return
	end

	local state = enemy.state
	if state == "Windup" or state == "Dead" then
		return
	elseif state == "Stunned" then
		if now >= enemy.stateUntil then
			enemy.model:SetAttribute("Stunned", nil)
			enemy.state = "Chase"
		end
	elseif state == "Cooldown" then
		local targetRoot = getTargetRoot(enemy.target)
		if targetRoot then
			faceTowards(enemy, targetRoot.Position)
		end
		if now >= enemy.stateUntil then
			enemy.state = "Chase"
		end
	elseif state == "Idle" then
		local player = findNearestPlayer(position, enemy.config.AggroRange)
		if player then
			enemy.target = player
			enemy.state = "Chase"
		end
	elseif state == "Chase" then
		local targetRoot = getTargetRoot(enemy.target)
		local tooFarFromHome = (position - home).Magnitude > enemy.config.LeashRange
		if not targetRoot or tooFarFromHome then
			-- Buscar otro objetivo cercano antes de rendirse.
			local player: Player? = nil
			if not tooFarFromHome then
				player = findNearestPlayer(position, enemy.config.AggroRange)
			end
			if player then
				enemy.target = player
			else
				enemy.target = nil
				enemy.state = "Return"
			end
			return
		end
		local distance = (targetRoot.Position - position).Magnitude
		if distance > enemy.config.AggroRange * 1.5 then
			enemy.target = nil
			enemy.state = "Return"
		elseif enemy.config.AttackStyle == "Ranged" and distance < (enemy.config.PreferredRange or 18) * 0.6 then
			-- Demasiado cerca: el Lanzador retrocede.
			local away = position - targetRoot.Position
			away = Vector3.new(away.X, 0, away.Z)
			if away.Magnitude > 0.1 then
				enemy.humanoid:MoveTo(position + away.Unit * 8)
			end
		elseif distance <= enemy.config.AttackRange then
			startAttack(enemy, targetRoot)
		else
			enemy.humanoid:MoveTo(targetRoot.Position)
		end
	elseif state == "Return" then
		enemy.humanoid:MoveTo(home)
		if (position - home).Magnitude < 5 then
			enemy.state = "Idle"
			enemy.humanoid.Health = enemy.maxHealth -- se cura al volver
			enemy.damageBy = {}
		end
	end
end

local function registerSpawnPoint(part: Instance)
	if not part:IsA("BasePart") then
		return
	end
	local enemyId = part:GetAttribute("EnemyId")
	local level = part:GetAttribute("Level")
	local count = part:GetAttribute("Count")
	if typeof(enemyId) ~= "string" or not Enemies[enemyId] then
		warn(`[EnemyService] {part:GetFullName()} tiene la etiqueta {TAG_SPAWN} pero su atributo EnemyId no es válido`)
		return
	end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	local spawnPoint: SpawnPoint = {
		part = part,
		enemyId = enemyId,
		level = if typeof(level) == "number" then math.max(1, math.floor(level)) else 1,
		count = if typeof(count) == "number" then math.max(1, math.floor(count)) else 3,
		alive = 0,
	}
	for _ = 1, spawnPoint.count do
		spawnEnemy(spawnPoint)
	end
	log(`Punto de aparición: {spawnPoint.count} × {enemyId} (nivel {spawnPoint.level})`)
end

local function createTestSpawn()
	local part = Instance.new("Part")
	part.Name = "TestEnemySpawn"
	part.Size = Vector3.new(4, 1, 4)
	part.Position = Debug.TestEnemySpawnPosition
	part:SetAttribute("EnemyId", "Thornling")
	part:SetAttribute("Level", 1)
	part:SetAttribute("Count", 3)
	part.Parent = Workspace
	CollectionService:AddTag(part, TAG_SPAWN)
end

function EnemyService:Init()
	folder = Instance.new("Folder")
	folder.Name = "Enemies"
	folder.Parent = Workspace
end

-- Guardia frontal (Centinela): golpes ligeros de frente → bloqueados; pesado o remate de frente → rompe la guardia.
local function guardModifier(
	player: Player,
	target: Model,
	amount: number,
	kind: string,
	source: string
): (number, string)
	local enemy = enemies[target]
	if not enemy or not enemy.config.FrontGuard or enemy.state == "Stunned" or enemy.state == "Dead" then
		return amount, kind
	end
	local character = player.Character
	local attackerRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not attackerRoot or not attackerRoot:IsA("BasePart") then
		return amount, kind
	end
	local toAttacker = attackerRoot.Position - enemy.root.Position
	toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z)
	if toAttacker.Magnitude < 0.1 or enemy.root.CFrame.LookVector:Dot(toAttacker.Unit) < 0.3 then
		return amount, kind -- por detrás o de lado: daño completo
	end
	if source == "Heavy" or source == "Finisher" then
		stun(enemy, enemy.config.GuardBreakStun)
		return amount, kind
	elseif source == "Light" then
		return math.max(1, math.floor(amount * (enemy.config.GuardBlockMultiplier or 0.2) + 0.5)), "Blocked"
	end
	return amount, kind
end

function EnemyService:Start()
	CombatService:addDamageModifier(guardModifier)
	-- Si un jugador daña a un enemigo: se apunta su contribución y el enemigo le persigue.
	CombatService:onDamageDealt(function(player: Player, target: Model, amount: number)
		local enemy = enemies[target]
		if not enemy or enemy.state == "Dead" then
			return
		end
		enemy.damageBy[player] = (enemy.damageBy[player] or 0) + amount
		if enemy.state == "Idle" or enemy.state == "Return" then
			enemy.target = player
			enemy.state = "Chase"
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		for _, enemy in enemies do
			enemy.damageBy[player] = nil
			if enemy.target == player then
				enemy.target = nil
			end
		end
	end)

	if #CollectionService:GetTagged(TAG_SPAWN) == 0 and Debug.SpawnTestEnemies then
		createTestSpawn()
	end
	for _, part in CollectionService:GetTagged(TAG_SPAWN) do
		registerSpawnPoint(part)
	end
	CollectionService:GetInstanceAddedSignal(TAG_SPAWN):Connect(registerSpawnPoint)

	-- Bucle de la IA.
	task.spawn(function()
		while true do
			task.wait(AI_TICK)
			for _, enemy in enemies do
				xpcall(step, function(err)
					warn(`[EnemyService] Error en la IA de {enemy.model.Name}: {err}`)
				end, enemy)
			end
		end
	end)
end

-- Crea un enemigo que NO reaparece (lo usa el jefe para invocar refuerzos). Devuelve su modelo.
function EnemyService:spawnTemporary(enemyId: string, level: number, position: Vector3): Model?
	if not Enemies[enemyId] then
		return nil
	end
	local home = Instance.new("Part")
	home.Name = "TemporarySpawn"
	home.Anchored = true
	home.CanCollide = false
	home.CanQuery = false
	home.Transparency = 1
	home.Size = Vector3.one
	home.Position = position
	home.Parent = folder
	local spawnPoint: SpawnPoint = {
		part = home,
		enemyId = enemyId,
		level = level,
		count = 0,
		alive = 0,
		temporary = true,
	}
	spawnEnemy(spawnPoint)
	for model, enemy in enemies do
		if enemy.spawnPoint == spawnPoint then
			return model
		end
	end
	return nil
end

-- Avisa a los oyentes de una derrota que no gestiona este servicio (p. ej., el jefe).
function EnemyService:notifyDefeated(enemyId: string, contributors: { Player })
	for _, listener in defeatListeners do
		task.spawn(listener, enemyId, contributors)
	end
end

-- Otros servicios (p. ej., QuestService) se enteran de cada enemigo derrotado y de quién contribuyó.
function EnemyService:onEnemyDefeated(listener: (enemyId: string, contributors: { Player }) -> ())
	table.insert(defeatListeners, listener)
end

return EnemyService
