--!strict
--[[
	SmokeTestService (servidor, SOLO Studio) — autodiagnóstico al pulsar Play.
	Espera a que entre el primer jugador y comprueba (sin modificar datos) que cada sistema arrancó bien.
	Escribe líneas "[SMOKE] ✅/❌ ..." y un resumen final en Output. Cópialo y envíalo para corregir errores.
	Se desactiva con Debug.RunSmokeTest (y nunca se ejecuta en el juego publicado).
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Debug = require(Config:WaitForChild("Debug"))
local Strings = require(Config:WaitForChild("Strings"))
local Quests = require(Config:WaitForChild("Quests"))
local Enemies = require(Config:WaitForChild("Enemies"))
local Bosses = require(Config:WaitForChild("Bosses"))
local WeaponCatalog = require(Config:WaitForChild("Weapons"))
local DataService = require(script.Parent:WaitForChild("DataService"))

local SmokeTestService = {}

local passed = 0
local total = 0

local function check(name: string, ok: boolean, detail: string?)
	total += 1
	if ok then
		passed += 1
		print(`[SMOKE] ✅ {name}`)
	else
		warn(`[SMOKE] ❌ {name}{if detail then " — " .. detail else ""}`)
	end
end

local function countTagged(tag: string): number
	return #CollectionService:GetTagged(tag)
end

local function run(player: Player)
	print("[SMOKE] ===== Autodiagnóstico del servidor =====")

	-- Red y textos
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	check(
		"Mensajeros de red creados",
		remotes ~= nil and #remotes:GetChildren() >= 21,
		if remotes then `{#remotes:GetChildren()} encontrados` else "falta ReplicatedStorage/Remotes"
	)
	local localization = Shared:FindFirstChild("Localization")
	local stringsTable = localization and localization:FindFirstChild("Strings")
	check("Tabla de textos (LocalizationTable)", stringsTable ~= nil and stringsTable:IsA("LocalizationTable"))
	check("Textos cargados", Strings.get("LevelUp") ~= "LevelUp", `Strings.get("LevelUp") devolvió la clave`)

	-- Configuración
	local badTargets = {}
	for questId, quest in Quests.List do
		if quest.Target and not Enemies[quest.Target] and not (Bosses :: any)[quest.Target] then
			table.insert(badTargets, questId)
		end
	end
	check("Misiones → enemigos existentes", #badTargets == 0, table.concat(badTargets, ", "))
	check("Arma por defecto definida", WeaponCatalog.Weapons[WeaponCatalog.DefaultWeapon] ~= nil)

	-- Datos del jugador
	local data = nil
	for _ = 1, 30 do
		data = DataService:get(player)
		if data then
			break
		end
		task.wait(0.5)
	end
	check("Datos del jugador cargados (ProfileStore)", data ~= nil, "no cargaron en 15 s")
	local leaderstats = player:FindFirstChild("leaderstats")
	check("Columna Lv en la lista de jugadores", leaderstats ~= nil and leaderstats:FindFirstChild("Lv") ~= nil)

	-- Personaje y arma
	local character = player.Character or player.CharacterAdded:Wait()
	task.wait(2)
	check("Arma en la mano", character:FindFirstChild("Weapon") ~= nil, "falta el modelo Weapon (¿avatar R15?)")
	check(
		"Atributos del arma",
		typeof(character:GetAttribute("WeaponType")) == "string"
			and typeof(character:GetAttribute("WeaponId")) == "string"
	)

	-- Mundo
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	local enemyCount = 0
	if enemiesFolder then
		for _, child in enemiesFolder:GetChildren() do
			if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
				enemyCount += 1
			end
		end
	end
	check("Enemigos aparecidos", enemyCount > 0, `{enemyCount} enemigos en Workspace/Enemies`)
	check("Maestra Ilen (NPC)", countTagged("NPC") >= 1)
	check("Muñeco de práctica", countTagged("TrainingDummy") >= 1)
	check("Santuario de afinidad", countTagged("AffinityShrine") >= 1)
	if countTagged("BossArena") > 0 then
		check("Jefe Vharok en la arena", countTagged("Boss") >= 1)
	end
	if countTagged("Campfire") > 0 then
		check(
			"Fogatas con aviso (E)",
			(CollectionService:GetTagged("Campfire")[1] :: Instance):FindFirstChildOfClass("ProximityPrompt") ~= nil
		)
	end
	check("FPS del servidor publicados", Workspace:GetAttribute("ServerFps") ~= nil)

	print(`[SMOKE] RESUMEN SERVIDOR: {passed}/{total} correctos`)
	print("[SMOKE] Copia todas las líneas [SMOKE] (y lo que salga en rojo) y envíaselas a tu asistente.")
end

function SmokeTestService:Init() end

function SmokeTestService:Start()
	if not Debug.RunSmokeTest then
		return
	end
	task.spawn(function()
		local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
		task.wait(3) -- deja que todo termine de arrancar
		xpcall(run, function(err)
			warn(`[SMOKE] ❌ El autodiagnóstico falló: {err}`)
		end, player)
	end)
end

return SmokeTestService
