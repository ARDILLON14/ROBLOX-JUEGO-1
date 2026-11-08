--!strict
--[[
	AntiCheatService (servidor) — velocidad y teletransporte (pendiente de la Entrega 2B, §7).
	Cada jugador controla la física de su propio personaje (propiedad de red), así que un tramposo podría
	moverse más rápido o teletransportarse. Cada 0,5 s se compara la distancia HORIZONTAL recorrida con
	la máxima posible (caminar + esquiva/Paso Relámpago). Si se supera dos veces seguidas, el jugador vuelve
	a su última posición válida y se registra un aviso.
	Los teletransportes del propio juego (viaje rápido, reaparición) se autorizan con allowTeleport().
	[SUPUESTO] Tolerancias iniciales: ajustarlas si jugadores legítimos son devueltos atrás (lag).
]]

local Players = game:GetService("Players")

local CHECK_INTERVAL = 0.5
local MAX_SPEED = 26 -- studs/s (caminar a 16 con margen para el lag)
local BURST_ALLOWANCE = 18 -- studs extra por comprobación (esquiva 12, Paso Relámpago 14)
local STRIKES_TO_ACT = 2
local GRACE_TIME = 2 -- segundos sin comprobar tras aparecer o tras un teletransporte del juego

type Track = {
	lastPosition: Vector3?,
	lastTime: number,
	strikes: number,
	graceUntil: number,
}

local AntiCheatService = {}

local tracks: { [Player]: Track } = {}

local function getRoot(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function check(player: Player, track: Track, now: number)
	local root = getRoot(player)
	if not root then
		track.lastPosition = nil
		return
	end
	local position = root.Position
	if now < track.graceUntil or not track.lastPosition then
		track.lastPosition = position
		track.lastTime = now
		return
	end
	local last = track.lastPosition :: Vector3
	local elapsed = math.max(now - track.lastTime, 0.01)
	local horizontal = Vector3.new(position.X - last.X, 0, position.Z - last.Z).Magnitude
	local allowed = MAX_SPEED * elapsed + BURST_ALLOWANCE

	if horizontal > allowed then
		track.strikes += 1
		if track.strikes >= STRIKES_TO_ACT then
			warn(
				`[AntiCheat] {player.Name} se movió {math.floor(horizontal)} studs en {string.format("%.2f", elapsed)} s; vuelve a su última posición válida`
			)
			local character = player.Character
			if character then
				character:PivotTo(CFrame.new(last + Vector3.new(0, 3, 0)))
			end
			track.strikes = 0
			track.lastTime = now
			return -- se conserva la última posición válida
		end
	else
		track.strikes = math.max(0, track.strikes - 1)
	end
	track.lastPosition = position
	track.lastTime = now
end

-- Autoriza un teletransporte hecho por el propio juego (no cuenta como trampa).
function AntiCheatService:allowTeleport(player: Player)
	local track = tracks[player]
	if track then
		track.lastPosition = nil
		track.graceUntil = os.clock() + GRACE_TIME
	end
end

function AntiCheatService:Init() end

function AntiCheatService:Start()
	local function onPlayerAdded(player: Player)
		tracks[player] =
			{ lastPosition = nil, lastTime = os.clock(), strikes = 0, graceUntil = os.clock() + GRACE_TIME }
		player.CharacterAdded:Connect(function()
			AntiCheatService:allowTeleport(player)
		end)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerRemoving:Connect(function(player: Player)
		tracks[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL)
			local now = os.clock()
			for player, track in tracks do
				check(player, track, now)
			end
		end
	end)
end

return AntiCheatService
