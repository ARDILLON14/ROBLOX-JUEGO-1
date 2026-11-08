--!strict
--[[
	MetricsService (servidor) — métricas del GDD v1 §12 con el embudo de bienvenida de Roblox Analytics.
	Cada paso se registra UNA vez por jugador (se guarda el último en Meta.OnboardingStep) y en orden.
	Se ven en Creator Hub → tu experiencia → Analytics (embudos / funnels). [VERIFICAR EN STUDIO: ubicación del panel]
	Si la función no existe o falla, el juego sigue igual (se ignora).

	Pasos:  1 Entró · 2 Aceptó la primera misión · 3 Tutorial completado · 4 Primer enemigo derrotado
	        5 Nivel 3 · 6 Nivel 5 · 7 Afinidad despertada (misión 5) · 8 Nivel 10 · 9 Jefe derrotado
]]

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")

local DataService = require(script.Parent:WaitForChild("DataService"))
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))

local CHECK_INTERVAL = 5

type Step = { name: string, reached: (data: any) -> boolean }

local STEPS: { Step } = {
	{
		name = "Joined",
		reached = function()
			return true
		end,
	},
	{
		name = "AcceptedFirstQuest",
		reached = function(data)
			return data.Quests.Completed.Q01 == true
				or data.Quests.ActiveId ~= "Q01"
				or data.Quests.Status ~= "Available"
		end,
	},
	{
		name = "TutorialComplete",
		reached = function(data)
			return data.Quests.Completed.Q01 == true
		end,
	},
	{
		name = "FirstEnemyDefeated",
		reached = function(data)
			return data.Meta.EnemiesDefeated >= 1
		end,
	},
	{
		name = "Level3",
		reached = function(data)
			return data.Level >= 3
		end,
	},
	{
		name = "Level5",
		reached = function(data)
			return data.Level >= 5
		end,
	},
	{
		name = "AffinityAwakened",
		reached = function(data)
			return data.Quests.Completed.Q05 == true
		end,
	},
	{
		name = "Level10",
		reached = function(data)
			return data.Level >= 10
		end,
	},
	{
		name = "BossDefeated",
		reached = function(data)
			return data.Meta.BossDefeats >= 1
		end,
	},
}

local MetricsService = {}

local function logStep(player: Player, step: number, name: string)
	local ok, err = pcall(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, name)
	end)
	if not ok then
		warn(`[MetricsService] No se pudo registrar el paso {step} ({name}): {err}`)
	end
end

-- Registra en orden todos los pasos nuevos que el jugador ya cumple.
local function evaluate(player: Player)
	local data = DataService:get(player)
	if not data then
		return
	end
	local stored = data.Meta.OnboardingStep
	for index = stored + 1, #STEPS do
		local step = STEPS[index]
		if not step.reached(data) then
			break
		end
		logStep(player, index, step.name)
		data.Meta.OnboardingStep = index
	end
end

function MetricsService:Init() end

function MetricsService:Start()
	DataService:onPlayerLoaded(evaluate)
	EnemyService:onEnemyDefeated(function(enemyId: string, contributors: { Player })
		for _, player in contributors do
			local data = DataService:get(player)
			if data then
				if enemyId == "Vharok" then
					data.Meta.BossDefeats += 1
				else
					data.Meta.EnemiesDefeated += 1
				end
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL)
			for _, player in Players:GetPlayers() do
				evaluate(player)
			end
		end
	end)
end

return MetricsService
