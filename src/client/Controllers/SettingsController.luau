--!strict
--[[
	SettingsController (cliente) — aplica los ajustes guardados:
	- Idioma (Strings.setLanguage).
	- Volumen: grupo de sonido "Effects" (todos los sonidos del juego deben usarlo).
	- Números de daño de otros y calidad de efectos: los consultan otros controladores con :get().
	Para cambiar un ajuste: SettingsController:set("Clave", valor) → lo pide al servidor, que lo valida y guarda.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Strings = require(Shared:WaitForChild("Config"):WaitForChild("Strings"))
local Net = require(Shared:WaitForChild("Net"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local DEFAULTS: { [string]: any } = {
	Language = "auto",
	ShowOthersDamage = true,
	EffectsVolume = 0.8,
	EffectsQuality = "High",
}

local SettingsController = {}

local effectsGroup: SoundGroup

local function apply()
	Strings.setLanguage(SettingsController:get("Language"))
	effectsGroup.Volume = SettingsController:get("EffectsVolume")
end

function SettingsController:Init()
	local existing = SoundService:FindFirstChild("Effects")
	if existing and existing:IsA("SoundGroup") then
		effectsGroup = existing
	else
		effectsGroup = Instance.new("SoundGroup")
		effectsGroup.Name = "Effects"
		effectsGroup.Parent = SoundService
	end
end

function SettingsController:Start()
	PlayerDataController:onChanged(function(key: string)
		if key == "*" or key == "Settings" then
			apply()
		end
	end)
end

function SettingsController:get(key: string): any
	local data = PlayerDataController:get()
	local settings = data and data.Settings
	if settings and settings[key] ~= nil then
		return settings[key]
	end
	return DEFAULTS[key]
end

function SettingsController:set(key: string, value: any)
	Net.event("RequestUpdateSettings"):FireServer({ [key] = value })
end

-- Grupo de sonido de efectos (para que el volumen de Ajustes les afecte).
function SettingsController:getEffectsGroup(): SoundGroup
	return effectsGroup
end

return SettingsController
