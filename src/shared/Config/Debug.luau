--!strict
--[[
	Interruptores de depuración.
	SEGURIDAD: los trucos (armas gratis, XP extra, multiplicadores...) SOLO funcionan en Roblox Studio.
	En el juego publicado se usan automáticamente los valores normales (segundo valor de cada dev(...)),
	así es imposible publicar el juego con un truco activado por olvido.
]]

local RunService = game:GetService("RunService")

local IS_STUDIO = RunService:IsStudio()

-- dev(valorEnStudio, valorEnElJuegoPublicado)
local function dev<T>(studioValue: T, releaseValue: T): T
	return if IS_STUDIO then studioValue else releaseValue
end

local Debug = {
	IsStudio = IS_STUDIO,

	-- Mensajes en Output
	LogInput = dev(true, false), -- cada acción pulsada
	LogCombat = dev(true, false), -- ataques, golpes, esquivas y bloqueos
	LogData = true, -- carga y guardado de datos (útil también en el juego publicado)
	LogEnemies = dev(true, false), -- aparición y derrota de enemigos

	-- Trucos para probar (solo Studio)
	GiveAllWeapons = dev(true, false), -- da las 6 armas al entrar
	DummyXPPerHit = dev(0, 0), -- XP por golpe al muñeco (pon 500 en Studio para subir rápido)
	MasteryMultiplier = dev(1, 1), -- multiplica la maestría ganada (pon 20 en Studio para probar los rangos)
	BossHealthMultiplier = dev(1, 1), -- multiplica la vida del jefe (pon 0.1 en Studio para probarlo rápido)
	SpawnTestEnemies = dev(true, false), -- si el mapa no tiene puntos "EnemySpawn", crea uno de prueba
	TestEnemySpawnPosition = Vector3.new(30, 1, -30),

	-- Parte del juego (también publicado): muñeco de la misión 1
	SpawnTrainingDummy = true,
	TrainingDummyPosition = Vector3.new(-14, 3, 12), -- zona de entrenamiento del campamento
}

return table.freeze(Debug)
