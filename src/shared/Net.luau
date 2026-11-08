--!strict
--[[
	Net
	Crea y entrega los RemoteEvents ("mensajeros" cliente <-> servidor).
	- El SERVIDOR los crea en ReplicatedStorage/Remotes la primera vez que se carga este módulo.
	- El CLIENTE espera a que existan.
	La lista de nombres sale de la Entrega 2B (aprobada). Pedir un nombre que no está en la lista da error,
	así se detectan errores de escritura al momento.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RateLimiter = require(script.Parent:WaitForChild("Util"):WaitForChild("RateLimiter"))

local FOLDER_NAME = "Remotes"
local WARN_COOLDOWN = 5 -- segundos entre avisos de límite superado (por jugador y mensaje)

-- Mensajes fiables (RemoteEvent).
local RELIABLE_EVENTS = {
	-- Cliente -> servidor (peticiones)
	"RequestAttack",
	"RequestDodge",
	"RequestBlock",
	"RequestAbility",
	"RequestUsePotion",
	"RequestEquipWeapon",
	"RequestEquipCosmetic",
	"RequestChooseAffinity",
	"RequestFastTravel",
	"RequestDialogueAction",
	"RequestUpdateSettings",
	-- Servidor -> cliente
	"DataSnapshot",
	"DataChanged",
	"HitConfirmed",
	"LevelUp",
	"QuestUpdated",
	"MasteryUpdated",
	"BossPhase",
	"Notify",
}

-- Mensajes no fiables (UnreliableRemoteEvent): solo cosas cosméticas.
local UNRELIABLE_EVENTS = {
	"HitBroadcast", -- golpes de otros jugadores (números pequeños y efectos)
	"AbilityEffect", -- [PROPUESTA] efectos visuales de habilidades para todos los jugadores
}

local isServer = RunService:IsServer()

local function buildFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	local folder: Folder = if existing and existing:IsA("Folder") then existing else Instance.new("Folder")
	folder.Name = FOLDER_NAME
	for _, name in RELIABLE_EVENTS do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	end
	for _, name in UNRELIABLE_EVENTS do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new("UnreliableRemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
	end
	folder.Parent = ReplicatedStorage
	return folder
end

local folder: Folder = if isServer then buildFolder() else ReplicatedStorage:WaitForChild(FOLDER_NAME) :: Folder

local Net = {}

-- Devuelve un RemoteEvent fiable por su nombre.
function Net.event(name: string): RemoteEvent
	assert(table.find(RELIABLE_EVENTS, name), `[Net] Mensaje fiable desconocido: {name}`)
	return folder:WaitForChild(name) :: RemoteEvent
end

-- Devuelve un UnreliableRemoteEvent por su nombre.
function Net.unreliable(name: string): UnreliableRemoteEvent
	assert(table.find(UNRELIABLE_EVENTS, name), `[Net] Mensaje no fiable desconocido: {name}`)
	return folder:WaitForChild(name) :: UnreliableRemoteEvent
end

local limiters: { RateLimiter.RateLimiter } = {}

--[[
	SOLO SERVIDOR. Escucha una petición del cliente con límite de frecuencia.
	Si el jugador envía más de maxPerSecond mensajes por segundo, los sobrantes se ignoran.
	El handler SIEMPRE debe validar los datos recibidos (ver Util/Validate).
]]
function Net.onRequest(name: string, maxPerSecond: number, handler: (player: Player, ...any) -> ())
	assert(isServer, "[Net] onRequest solo se puede usar en el servidor")
	local limiter = RateLimiter.new(maxPerSecond)
	table.insert(limiters, limiter)
	local lastWarn: { [Player]: number } = {}

	Net.event(name).OnServerEvent:Connect(function(player: Player, ...: any)
		if not limiter.allow(player) then
			local now = os.clock()
			if now - (lastWarn[player] or 0) > WARN_COOLDOWN then
				lastWarn[player] = now
				warn(`[Net] {player.Name} superó el límite de {name} ({maxPerSecond}/s)`)
			end
			return
		end
		-- Un error en un handler (p. ej., datos raros enviados por un tramposo) no debe tumbar nada más.
		xpcall(handler, function(err)
			warn(`[Net] Error procesando {name} de {player.Name}: {err}`)
		end, player, ...)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		lastWarn[player] = nil
	end)
end

if isServer then
	Players.PlayerRemoving:Connect(function(player: Player)
		for _, limiter in limiters do
			limiter.remove(player)
		end
	end)
	print(`[Net] {#RELIABLE_EVENTS + #UNRELIABLE_EVENTS} mensajeros creados en ReplicatedStorage/{FOLDER_NAME}`)
end

return Net
