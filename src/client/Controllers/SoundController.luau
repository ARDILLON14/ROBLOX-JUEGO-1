--!strict
--[[
	SoundController (cliente) — reproduce los sonidos de Config/Sounds.
		SoundController:play("Swing")                 -- sonido "de interfaz" (sin posición)
		SoundController:play("Hit", parte, 0.8)       -- sonido en 3D desde una pieza, con volumen
	Si el ID está vacío no hace nada. Usa el grupo "Effects" (volumen de Ajustes).
	También reproduce los sonidos de algunos avisos del servidor (misión completada, Fragmento, fogata).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Sounds = require(Shared:WaitForChild("Config"):WaitForChild("Sounds"))
local Net = require(Shared:WaitForChild("Net"))
local SettingsController = require(script.Parent:WaitForChild("SettingsController"))

local SoundController = {}

local NOTIFY_SOUNDS: { [string]: string } = {
	QuestComplete = "QuestComplete",
	FragmentFound = "FragmentFound",
	CampfireDiscovered = "Campfire",
	WeaponReward = "Equip",
}

function SoundController:play(key: string, parent: Instance?, volume: number?)
	local id = (Sounds :: any)[key]
	if typeof(id) ~= "string" or id == "" then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.6
	sound.SoundGroup = SettingsController:getEffectsGroup()
	sound.RollOffMaxDistance = 120
	sound.Parent = parent or SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	-- Por si el sonido no llega a cargar o no termina.
	task.delay(10, function()
		if sound.Parent then
			sound:Destroy()
		end
	end)
end

function SoundController:Init() end

function SoundController:Start()
	Net.event("Notify").OnClientEvent:Connect(function(kind: string)
		local key = NOTIFY_SOUNDS[kind]
		if key then
			SoundController:play(key)
		end
	end)
end

return SoundController
