--!strict
--[[
	CombatController (cliente)
	Ataque ligero, combo de 3, pesado, remate, esquiva y bloqueo.
	- Reproduce animaciones y muestra un destello cuando golpeas algo (respuesta visual inmediata).
	- Envía cada acción al servidor (CombatService), que la valida y calcula el daño REAL.
	  El cliente nunca dice cuánto daño hace (decisión aprobada: server-authoritative).

	Estados (Entrega 2B §4): Idle, Attacking, Blocking, Dodging. (Stunned y Dead los decidirá el servidor.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local CombatConfig = require(Config:WaitForChild("Combat"))
local WeaponTypes = require(Config:WaitForChild("WeaponTypes"))
local Animations = require(Config:WaitForChild("Animations"))
local Debug = require(Config:WaitForChild("Debug"))
local Hitbox = require(Shared:WaitForChild("Combat"):WaitForChild("Hitbox"))
local Net = require(Shared:WaitForChild("Net"))
local InputController = require(script.Parent:WaitForChild("InputController"))

type State = "Idle" | "Attacking" | "Blocking" | "Dodging"
type AttackInput = "Light" | "Heavy"
type AttackKind = "Light" | "Heavy" | "Finisher"

local player = Players.LocalPlayer

local CombatController = {}

-- Estado actual
local state: State = "Idle"
local comboIndex = 0
local lastAttackEndTime = -math.huge
local attackStartTime = 0
local lastDodgeTime = -math.huge
local blockStartTime = 0 -- se usará para el bloqueo perfecto (semana 5)
local bufferedAttack: AttackInput? = nil -- ataque pulsado durante otro ataque
local actionToken = 0 -- cambia en cada acción nueva para cancelar temporizadores antiguos

-- Personaje actual
local character: Model? = nil
local humanoid: Humanoid? = nil
local root: BasePart? = nil
local animator: Animator? = nil
local tracks: { [string]: AnimationTrack } = {}
local currentTrack: AnimationTrack? = nil
local warnedMissing: { [string]: boolean } = {}

local function log(message: string)
	if Debug.LogCombat then
		print(`[Combat] {message}`)
	end
end

local function getWeapon(): (string, WeaponTypes.WeaponType)
	local name = if character then character:GetAttribute("WeaponType") else nil
	if typeof(name) == "string" and WeaponTypes[name] then
		return name, WeaponTypes[name]
	end
	return "Katana", WeaponTypes.Katana
end

local function setWalkSpeed(multiplier: number)
	if humanoid then
		humanoid.WalkSpeed = CombatConfig.BaseWalkSpeed * multiplier
	end
end

local function getTrack(key: string, animationId: string): AnimationTrack?
	if animationId == "" then
		if not warnedMissing[key] then
			warnedMissing[key] = true
			warn(`[Combat] Falta la animación "{key}" en Config/Animations (el combate funciona sin ella)`)
		end
		return nil
	end
	local cached = tracks[key]
	if cached then
		return cached
	end
	if not animator then
		return nil
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	tracks[key] = track
	return track
end

local function stopCurrentTrack()
	if currentTrack then
		currentTrack:Stop(0.05)
		currentTrack = nil
	end
end

-- Reproduce una animación. Si se indica duración, ajusta su velocidad para que dure eso.
local function playTrack(key: string, animationId: string, duration: number?, looped: boolean?)
	stopCurrentTrack()
	local track = getTrack(key, animationId)
	if not track then
		return
	end
	track.Looped = looped == true
	track:Play(0.05)
	if duration and track.Length > 0 then
		track:AdjustSpeed(track.Length / duration)
	end
	currentTrack = track
end

-- Destello blanco breve sobre lo que golpeas.
local function flash(model: Model)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.3
	highlight.OutlineTransparency = 1
	highlight.Parent = model
	task.delay(0.1, function()
		highlight:Destroy()
	end)
end

-- Micro-pausa de la animación al golpear (hitstop).
local function hitstop()
	local track = currentTrack
	if not track then
		return
	end
	local speed = track.Speed
	track:AdjustSpeed(0)
	task.delay(CombatConfig.HitstopDuration, function()
		if track.IsPlaying then
			track:AdjustSpeed(speed)
		end
	end)
end

local function doHitCheck(weapon: WeaponTypes.WeaponType, label: string)
	if not root or not character then
		return
	end
	local targets = Hitbox.query(root.CFrame, weapon.Range, weapon.Width, CombatConfig.HitboxHeight, { character })
	for _, model in targets do
		log(`{label} golpea a {model.Name}`)
		flash(model)
	end
	if #targets > 0 then
		hitstop()
	end
end

local requestAttack: (input: AttackInput) -> ()

local function performAttack(kind: AttackKind)
	local weaponName, weapon = getWeapon()
	local animations = Animations.Weapons[weaponName]
	local duration: number
	local hitTime: number
	local animationKey: string
	local animationId: string
	local label: string

	if kind == "Light" then
		if os.clock() - lastAttackEndTime > CombatConfig.ComboResetTime or comboIndex >= CombatConfig.ComboLength then
			comboIndex = 0
		end
		comboIndex += 1
		duration = weapon.LightInterval
		hitTime = weapon.LightHitTime
		animationKey = `{weaponName}.Light{comboIndex}`
		animationId = if animations then animations.Light[comboIndex] or "" else ""
		label = `Ligero {comboIndex}`
	else
		duration = weapon.HeavyDuration
		hitTime = weapon.HeavyHitTime
		local useFinisher = kind == "Finisher" and animations ~= nil and animations.Finisher ~= ""
		animationKey = if useFinisher then `{weaponName}.Finisher` else `{weaponName}.Heavy`
		animationId = if not animations then "" elseif useFinisher then animations.Finisher else animations.Heavy
		label = if kind == "Finisher" then "REMATE" else "Pesado"
		comboIndex = 0
	end

	actionToken += 1
	local token = actionToken
	state = "Attacking"
	attackStartTime = os.clock()
	setWalkSpeed(CombatConfig.AttackMoveSpeedMultiplier)
	playTrack(animationKey, animationId, duration)
	log(`{label} ({weaponName})`)
	-- El servidor decide por su cuenta si es remate; solo le decimos ligero o pesado.
	Net.event("RequestAttack"):FireServer(if kind == "Light" then "Light" else "Heavy")

	task.delay(hitTime, function()
		if token == actionToken and state == "Attacking" then
			doHitCheck(weapon, label)
		end
	end)

	task.delay(duration, function()
		if token ~= actionToken then
			return
		end
		lastAttackEndTime = os.clock()
		state = "Idle"
		setWalkSpeed(1)
		local nextAttack: AttackInput? = bufferedAttack
		bufferedAttack = nil
		if nextAttack then
			requestAttack(nextAttack)
		end
	end)
end

requestAttack = function(input: AttackInput)
	if state == "Attacking" then
		bufferedAttack = input -- se ejecutará al terminar el golpe actual
		return
	end
	if state ~= "Idle" or not humanoid or humanoid.Health <= 0 then
		return
	end
	if input == "Heavy" then
		local isFinisher = comboIndex == 2 and os.clock() - lastAttackEndTime <= CombatConfig.ComboResetTime
		performAttack(if isFinisher then "Finisher" else "Heavy")
	else
		performAttack("Light")
	end
end

local function requestDodge()
	if not root or not humanoid or humanoid.Health <= 0 or state == "Dodging" then
		return
	end
	local now = os.clock()
	if now - lastDodgeTime < CombatConfig.DodgeCooldown then
		log("Esquiva en enfriamiento")
		return
	end
	local _, weapon = getWeapon()
	if state == "Attacking" and now - attackStartTime < weapon.DodgeCancelDelay then
		return
	end

	lastDodgeTime = now
	actionToken += 1
	local token = actionToken
	bufferedAttack = nil
	comboIndex = 0
	state = "Dodging"
	setWalkSpeed(1)

	-- Dirección: hacia donde te mueves; si estás quieto, hacia atrás.
	local direction = humanoid.MoveDirection
	if direction.Magnitude < 0.1 then
		direction = -root.CFrame.LookVector
	end
	direction = Vector3.new(direction.X, 0, direction.Z)
	if direction.Magnitude < 0.01 then
		direction = Vector3.new(0, 0, 1)
	end
	direction = direction.Unit

	-- Impulso horizontal durante la esquiva (la gravedad sigue actuando).
	local attachment = Instance.new("Attachment")
	attachment.Name = "DodgeAttachment"
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	velocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
	velocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	velocity.PlaneVelocity = Vector2.new(direction.X, direction.Z) * CombatConfig.DodgeSpeed
	velocity.MaxForce = 1e7
	velocity.Parent = root

	playTrack("Dodge", Animations.Dodge, CombatConfig.DodgeDuration)
	log("Esquiva")
	Net.event("RequestDodge"):FireServer(direction)

	task.delay(CombatConfig.DodgeDuration, function()
		velocity:Destroy()
		attachment:Destroy()
		if token == actionToken then
			state = "Idle"
		end
	end)
end

local function startBlock()
	if state ~= "Idle" or not humanoid or humanoid.Health <= 0 then
		return
	end
	actionToken += 1
	state = "Blocking"
	blockStartTime = os.clock()
	setWalkSpeed(CombatConfig.BlockMoveSpeedMultiplier)
	playTrack("Block", Animations.Block, nil, true)
	log("Bloqueo: inicio")
	Net.event("RequestBlock"):FireServer(true)
end

local function stopBlock()
	if state ~= "Blocking" then
		return
	end
	actionToken += 1
	state = "Idle"
	stopCurrentTrack()
	setWalkSpeed(1)
	log(`Bloqueo: fin ({string.format("%.2f", os.clock() - blockStartTime)} s)`)
	Net.event("RequestBlock"):FireServer(false)
end

local function onCharacterAdded(newCharacter: Model)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid") :: Humanoid
	root = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
	animator = (humanoid :: Humanoid):WaitForChild("Animator") :: Animator
	tracks = {}
	currentTrack = nil
	state = "Idle"
	comboIndex = 0
	bufferedAttack = nil
	actionToken += 1
end

function CombatController:Init() end

function CombatController:Start()
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	InputController:onAction("LightAttack", function(inputState)
		if inputState == "Begin" then
			requestAttack("Light")
		end
	end)
	InputController:onAction("HeavyAttack", function(inputState)
		if inputState == "Begin" then
			requestAttack("Heavy")
		end
	end)
	InputController:onAction("Dodge", function(inputState)
		if inputState == "Begin" then
			requestDodge()
		end
	end)
	InputController:onAction("Block", function(inputState)
		if inputState == "Begin" then
			startBlock()
		else
			stopBlock()
		end
	end)
end

-- Estado actual (lo usarán otros controladores, p. ej., la interfaz).
function CombatController:getState(): State
	return state
end

return CombatController
