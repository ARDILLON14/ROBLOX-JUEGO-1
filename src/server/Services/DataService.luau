--!strict
--[[
	DataService (servidor)
	Único servicio que toca los datos guardados (decisión B1). Usa ProfileStore:
	- Bloqueo de sesión: si entras en otro servidor, los datos no se duplican ni se pisan.
	- Guardado automático periódico, al salir y al cerrar el servidor.
	- Si Studio no tiene acceso a los DataStores, ProfileStore trabaja "de prueba" (mock):
	  todo funciona, pero los datos NO se guardan entre sesiones.

	Uso desde otros servicios:
		local data = DataService:get(player)       -- nil si aún no cargó
		data.XP += 10
		DataService:changed(player, "XP")          -- avisa al cliente del cambio
		DataService:onPlayerLoaded(function(player, data) ... end)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Debug = require(Shared:WaitForChild("Config"):WaitForChild("Debug"))
local ProfileStore = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("ProfileStore"))
local DataTemplate = require(script.Parent.Parent:WaitForChild("Data"):WaitForChild("DataTemplate"))

type Data = DataTemplate.Data

local STORE_NAME = "PlayerData"
local CURRENT_VERSION = 1

local DataService = {}

local store = ProfileStore.New(STORE_NAME, DataTemplate)
local profiles: { [Player]: any } = {}
local joinTimes: { [Player]: number } = {}
local loadedCallbacks: { (Player, Data) -> () } = {}

local function log(message: string)
	if Debug.LogData then
		print(`[DataService] {message}`)
	end
end

-- Convierte datos de versiones antiguas a la actual. Hoy solo existe la versión 1.
local function migrate(data: Data)
	if data.DataVersion < CURRENT_VERSION then
		-- Ejemplo futuro: if data.DataVersion < 2 then ... end
		data.DataVersion = CURRENT_VERSION
	end
end

local function onPlayerAdded(player: Player)
	local params: any = {
		Cancel = function()
			return player.Parent ~= Players
		end,
	}
	local profile = store:StartSessionAsync(`Player_{player.UserId}`, params)
	if profile == nil then
		player:Kick("No se pudieron cargar tus datos. Vuelve a entrar. / Could not load your data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	local data: Data = profile.Data
	migrate(data)
	if data.Meta.FirstJoin == 0 then
		data.Meta.FirstJoin = os.time()
	end

	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		player:Kick("Tus datos se abrieron en otro servidor. / Your data was opened on another server.")
	end)

	if player.Parent ~= Players then
		profile:EndSession() -- se fue mientras cargaba
		return
	end

	profiles[player] = profile
	joinTimes[player] = os.clock()
	log(`Datos de {player.Name} cargados (nivel {data.Level}, XP {data.XP})`)

	Net.event("DataSnapshot"):FireClient(player, data)
	for _, callback in loadedCallbacks do
		task.spawn(callback, player, data)
	end
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		local data: Data = profile.Data
		data.Meta.PlayTime += math.floor(os.clock() - (joinTimes[player] or os.clock()))
		profile:EndSession() -- guarda y libera el bloqueo de sesión
		log(`Datos de {player.Name} guardados`)
	end
	profiles[player] = nil
	joinTimes[player] = nil
end

function DataService:Init() end

function DataService:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	-- Al cerrar el servidor, ProfileStore espera a que todo se guarde (BindToClose interno).
end

-- Datos del jugador (se pueden modificar). nil si todavía no cargaron.
function DataService:get(player: Player): Data?
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

-- Avisa al cliente de que cambió un campo de primer nivel (p. ej., "XP", "Inventory").
function DataService:changed(player: Player, key: string)
	local data: any = DataService:get(player)
	if data then
		Net.event("DataChanged"):FireClient(player, key, data[key])
	end
end

-- Ejecuta callback(player, data) cuando un jugador termina de cargar (y ya para los cargados).
function DataService:onPlayerLoaded(callback: (Player, Data) -> ())
	table.insert(loadedCallbacks, callback)
	for player, profile in profiles do
		task.spawn(callback, player, profile.Data)
	end
end

return DataService
