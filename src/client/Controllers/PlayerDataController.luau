--!strict
--[[
	PlayerDataController (cliente)
	Copia de SOLO LECTURA de los datos del jugador, enviada por el servidor.
	El cliente nunca cambia estos datos: solo los muestra (HUD, inventario...).
		PlayerDataController:get()                       -- tabla de datos o nil
		PlayerDataController:onChanged(function(key) end) -- se llama al cargar ("*") y en cada cambio
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"))

local PlayerDataController = {}

local data: { [string]: any }? = nil
local listeners: { (key: string) -> () } = {}

local function notify(key: string)
	for _, listener in listeners do
		task.spawn(listener, key)
	end
end

function PlayerDataController:Init() end

function PlayerDataController:Start()
	Net.event("DataSnapshot").OnClientEvent:Connect(function(snapshot: { [string]: any })
		data = snapshot
		notify("*")
	end)
	Net.event("DataChanged").OnClientEvent:Connect(function(key: string, value: any)
		if data then
			data[key] = value
			notify(key)
		end
	end)
end

function PlayerDataController:get(): { [string]: any }?
	return data
end

function PlayerDataController:onChanged(listener: (key: string) -> ())
	table.insert(listeners, listener)
	if data then
		task.spawn(listener, "*")
	end
end

return PlayerDataController
