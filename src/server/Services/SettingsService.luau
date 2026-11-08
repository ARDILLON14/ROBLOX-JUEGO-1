--!strict
--[[
	SettingsService (servidor) — guarda los ajustes del jugador (RequestUpdateSettings, decisión B4).
	Solo acepta campos conocidos con tipos y rangos válidos; todo lo demás se ignora.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Validate = require(Shared:WaitForChild("Util"):WaitForChild("Validate"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local SettingsService = {}

local function onRequestUpdateSettings(player: Player, changes: unknown)
	if typeof(changes) ~= "table" then
		return
	end
	local data = DataService:get(player)
	if not data then
		return
	end
	local input = changes :: { [any]: any }
	local settings = data.Settings
	if input.Language ~= nil and Validate.isOneOf(input.Language, { "auto", "es", "en" }) then
		settings.Language = input.Language
	end
	if input.ShowOthersDamage ~= nil and Validate.isBoolean(input.ShowOthersDamage) then
		settings.ShowOthersDamage = input.ShowOthersDamage
	end
	if input.EffectsVolume ~= nil and Validate.isFiniteNumber(input.EffectsVolume) then
		settings.EffectsVolume = math.clamp(input.EffectsVolume, 0, 1)
	end
	if input.EffectsQuality ~= nil and Validate.isOneOf(input.EffectsQuality, { "High", "Low" }) then
		settings.EffectsQuality = input.EffectsQuality
	end
	DataService:changed(player, "Settings")
end

function SettingsService:Init() end

function SettingsService:Start()
	Net.onRequest("RequestUpdateSettings", 2, onRequestUpdateSettings)
end

return SettingsService
