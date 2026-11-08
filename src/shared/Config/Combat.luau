--!strict
-- Reglas globales de combate (GDD v1 §4 y Entrega 2B §4–5). Los valores son iniciales y se ajustarán en pruebas.

local Combat = {
	BaseWalkSpeed = 16, -- velocidad normal de Roblox
	AttackMoveSpeedMultiplier = 0.4, -- [PROPUESTA] más lento mientras atacas
	BlockMoveSpeedMultiplier = 0.5, -- más lento mientras bloqueas

	ComboLength = 3, -- golpes ligeros del combo
	ComboResetTime = 0.8, -- segundos sin atacar para reiniciar el combo

	HeavyMultiplier = 2.2,
	FinisherMultiplier = 1.8,
	CritChance = 0.1,
	CritMultiplier = 1.5,

	DodgeDuration = 0.3, -- también es el tiempo de invulnerabilidad
	DodgeSpeed = 40, -- studs por segundo (0,3 s × 40 = 12 studs)
	DodgeCooldown = 1.2,

	BlockDamageMultiplier = 0.3,
	PerfectBlockWindow = 0.2,

	HitboxHeight = 5,
	HitstopDuration = 0.05,

	-- Red (el servidor es un poco más permisivo para compensar la latencia)
	NetworkTimeTolerance = 0.15, -- segundos de margen al comprobar intervalos
	HitboxTolerance = 1.5, -- studs extra de alcance/ancho en el servidor

	-- Números de daño (GDD §4.6)
	DamageNumberDuration = 0.8,
	DamageNumberMergeWindow = 0.3, -- golpes al mismo objetivo en este tiempo se suman en un número
}

return table.freeze(Combat)
