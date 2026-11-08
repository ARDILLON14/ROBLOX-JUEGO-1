--!strict
--[[
	SmokeTestController (cliente, SOLO Studio) — autodiagnóstico de la parte del jugador.
	Comprueba pantallas, textos, datos recibidos y sonido. Escribe "[SMOKE] cliente ..." en Output.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Debug = require(Config:WaitForChild("Debug"))
local Strings = require(Config:WaitForChild("Strings"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local player = Players.LocalPlayer

local SmokeTestController = {}

local passed = 0
local total = 0

local function check(name: string, ok: boolean, detail: string?)
	total += 1
	if ok then
		passed += 1
		print(`[SMOKE] cliente ✅ {name}`)
	else
		warn(`[SMOKE] cliente ❌ {name}{if detail then " — " .. detail else ""}`)
	end
end

local function run()
	local playerGui = player:WaitForChild("PlayerGui")
	for _ = 1, 30 do
		if PlayerDataController:get() then
			break
		end
		task.wait(0.5)
	end
	check("Datos recibidos del servidor", PlayerDataController:get() ~= nil, "no llegó DataSnapshot en 15 s")
	check("Textos cargados", Strings.get("LevelUp") ~= "LevelUp")
	for _, guiName in { "Hud", "Dialogue", "Inventory", "Journal", "Settings", "Death", "BossBar" } do
		check(`Pantalla {guiName}`, playerGui:FindFirstChild(guiName) ~= nil)
	end
	check("Grupo de sonido Effects", SoundService:FindFirstChild("Effects") ~= nil)
	check("Cámara: mensajeros de red disponibles", ReplicatedStorage:FindFirstChild("Remotes") ~= nil)
	print(`[SMOKE] RESUMEN CLIENTE: {passed}/{total} correctos`)
end

function SmokeTestController:Init() end

function SmokeTestController:Start()
	if not Debug.RunSmokeTest then
		return
	end
	task.delay(6, function()
		xpcall(run, function(err)
			warn(`[SMOKE] cliente ❌ El autodiagnóstico falló: {err}`)
		end)
	end)
end

return SmokeTestController
