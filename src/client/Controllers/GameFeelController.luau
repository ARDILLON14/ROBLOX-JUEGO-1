--!strict
--[[
	GameFeelController (cliente) — "sensación" del combate (GDD v1 §4.5, pilar 1: "Combate que se siente").
	- Sacudida de cámara: críticos, Resonancia y golpes que recibes.
	- Destello rojo en los bordes de la pantalla al recibir daño.
	- Partículas en el punto de impacto (color según el tipo de golpe).
	- Estela del arma durante cada golpe (para TODOS los jugadores; el servidor marca cada golpe en el personaje).
	- Ráfaga de hojas cuando un enemigo cae.
	- Sonidos de impacto, bloqueo, curación y daño recibido.
	Calidad de efectos "Baja" (Ajustes): menos partículas y sin efectos de otros jugadores.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local SettingsController = require(script.Parent:WaitForChild("SettingsController"))
local SoundController = require(script.Parent:WaitForChild("SoundController"))

local HIT_COLORS: { [string]: Color3 } = {
	Normal = Color3.fromRGB(255, 255, 255),
	Crit = Color3.fromRGB(255, 215, 60),
	Fire = Color3.fromRGB(255, 130, 40),
	Lightning = Color3.fromRGB(90, 220, 255),
	Resonance = Color3.fromRGB(200, 90, 255),
	Blocked = Color3.fromRGB(170, 170, 170),
}

local HIT_SOUNDS: { [string]: string } = {
	Normal = "Hit",
	Fire = "Hit",
	Lightning = "Hit",
	Crit = "CritHit",
	Resonance = "CritHit",
	Blocked = "Block",
	PerfectBlock = "PerfectBlock",
	Received = "Hurt",
	Heal = "Potion",
}

local SHAKES: { [string]: number } = {
	Crit = 0.25,
	Resonance = 0.5,
	Received = 0.35,
}

local player = Players.LocalPlayer

local GameFeelController = {}

local shakeUntil = 0
local shakeDuration = 0
local shakeIntensity = 0
local damageFlash: Frame

local function isLowQuality(): boolean
	return SettingsController:get("EffectsQuality") == "Low"
end

-- Sacudida de cámara (intensidad en studs, se desvanece con el tiempo).
function GameFeelController:shake(intensity: number, duration: number)
	local now = os.clock()
	if intensity >= shakeIntensity * math.max(0, (shakeUntil - now) / math.max(shakeDuration, 0.001)) then
		shakeIntensity = intensity
		shakeDuration = duration
		shakeUntil = now + duration
	end
end

local function getPart(target: Instance): BasePart?
	for _, name in { "HumanoidRootPart", "Head", "Torso" } do
		local part = target:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

-- Ráfaga de partículas en una posición (pieza invisible temporal).
local function burst(position: Vector3, color: Color3, amount: number, speed: number, size: number)
	if isLowQuality() then
		amount = math.ceil(amount / 3)
	end
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.one * 0.2
	holder.Position = position
	holder.Parent = Workspace
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 0.8
	emitter.Lifetime = NumberRange.new(0.25, 0.5)
	emitter.Speed = NumberRange.new(speed * 0.5, speed)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0) })
	emitter.Rate = 0
	emitter.Parent = holder
	emitter:Emit(amount)
	task.delay(1, function()
		holder:Destroy()
	end)
end

local function onHit(target: Instance, amount: number, kind: string, isMine: boolean)
	if typeof(target) ~= "Instance" then
		return
	end
	if not isMine and isLowQuality() then
		return
	end
	local part = getPart(target)
	local color = HIT_COLORS[kind]
	if part and color and kind ~= "Received" then
		burst(part.Position, color, if kind == "Crit" or kind == "Resonance" then 18 else 10, 18, 0.5)
	end
	if not isMine then
		return
	end
	local soundKey = HIT_SOUNDS[kind]
	if soundKey then
		SoundController:play(soundKey, if kind == "Received" or kind == "Heal" then nil else part, 0.5)
	end
	local shake = SHAKES[kind]
	if shake then
		GameFeelController:shake(shake, 0.2)
	end
	if kind == "Received" and typeof(amount) == "number" and amount > 0 then
		damageFlash.BackgroundTransparency = 0.75
		TweenService:Create(damageFlash, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	end
end

-- Estela del arma: dos puntos en los extremos de la hoja; se activa durante cada golpe.
local function setupWeaponTrail(character: Model)
	local function attach()
		local weapon = character:FindFirstChild("Weapon")
		local blade = weapon and weapon:FindFirstChild("Blade")
		if not blade or not blade:IsA("BasePart") or blade:FindFirstChild("SwingTrail") then
			return
		end
		local half = blade.Size.Z / 2
		local tip = Instance.new("Attachment")
		tip.Position = Vector3.new(0, 0, -half)
		tip.Parent = blade
		local base = Instance.new("Attachment")
		base.Position = Vector3.new(0, 0, half * 0.2)
		base.Parent = blade
		local trail = Instance.new("Trail")
		trail.Name = "SwingTrail"
		trail.Attachment0 = tip
		trail.Attachment1 = base
		trail.Color = ColorSequence.new(blade.Color)
		trail.LightEmission = 0.6
		trail.Lifetime = 0.15
		trail.Transparency =
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
		trail.Enabled = false
		trail.Parent = blade
		if character == player.Character then
			SoundController:play("Equip", nil, 0.4)
		end
	end
	character.ChildAdded:Connect(function(child: Instance)
		if child.Name == "Weapon" then
			task.wait() -- la hoja se añade justo después
			attach()
		end
	end)
	attach()

	character:GetAttributeChangedSignal("SwingId"):Connect(function()
		if character ~= player.Character and isLowQuality() then
			return
		end
		local weapon = character:FindFirstChild("Weapon")
		local blade = weapon and weapon:FindFirstChild("Blade")
		local trail = blade and blade:FindFirstChild("SwingTrail")
		if trail and trail:IsA("Trail") then
			local duration = character:GetAttribute("SwingDuration")
			trail.Enabled = true
			local swingId = character:GetAttribute("SwingId")
			task.delay(if typeof(duration) == "number" then duration else 0.35, function()
				if character:GetAttribute("SwingId") == swingId then
					trail.Enabled = false
				end
			end)
		end
	end)
end

local function watchEnemy(model: Instance)
	if not model:IsA("Model") or CollectionService:HasTag(model, "Boss") then
		return
	end
	local humanoid = model:WaitForChild("Humanoid", 5)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.Died:Connect(function()
			local head = model:FindFirstChild("Head")
			if head and head:IsA("BasePart") then
				burst(head.Position, head.Color, 24, 14, 0.8)
				SoundController:play("EnemyDeath", head, 0.5)
			end
		end)
	end
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DamageFlash"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	damageFlash = Instance.new("Frame")
	damageFlash.Size = UDim2.fromScale(1, 1)
	damageFlash.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	damageFlash.BackgroundTransparency = 1
	damageFlash.BorderSizePixel = 0
	damageFlash.Parent = gui
	-- Más intenso en los bordes que en el centro.
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.3, 0.8),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Parent = damageFlash
	gui.Parent = player:WaitForChild("PlayerGui")
end

function GameFeelController:Init() end

function GameFeelController:Start()
	buildGui()

	RunService:BindToRenderStep("EclipseCameraShake", Enum.RenderPriority.Camera.Value + 2, function()
		local now = os.clock()
		local camera = Workspace.CurrentCamera
		if now >= shakeUntil or not camera then
			return
		end
		local strength = shakeIntensity * (shakeUntil - now) / shakeDuration
		local offset = Vector3.new(math.random() - 0.5, math.random() - 0.5, 0) * strength
		camera.CFrame = camera.CFrame * CFrame.new(offset)
	end)

	Net.event("HitConfirmed").OnClientEvent:Connect(function(target: Instance, amount: number, kind: string)
		onHit(target, amount, kind, true)
	end)
	Net.unreliable("HitBroadcast").OnClientEvent:Connect(function(target: Instance, amount: number, kind: string)
		onHit(target, amount, kind, false)
	end)

	local function watchPlayer(other: Player)
		other.CharacterAdded:Connect(setupWeaponTrail)
		if other.Character then
			task.spawn(setupWeaponTrail, other.Character)
		end
	end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, other in Players:GetPlayers() do
		watchPlayer(other)
	end

	CollectionService:GetInstanceAddedSignal("Enemy"):Connect(watchEnemy)
	for _, model in CollectionService:GetTagged("Enemy") do
		task.spawn(watchEnemy, model)
	end
end

return GameFeelController
