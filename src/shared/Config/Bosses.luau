--!strict
--[[
	Jefe de Verdantia: Vharok, el Guardián Marchito (GDD v1 §6.2, aprobado; 2 fases por el recorte aprobado).
	Valores iniciales; se ajustarán en pruebas con distintos números de jugadores.
]]

local Bosses = {
	Vharok = {
		NameKey = "Boss_Vharok",
		Level = 18,
		BaseHealth = 3500,
		HealthScalePerPlayer = 0.6, -- vida = base × (1 + 0,6 × (jugadores en la arena − 1))
		Scale = 3.2,
		WalkSpeed = 10,
		Phase2Threshold = 0.5, -- pasa a la fase 2 al 50 % de vida
		Phase2SpeedMultiplier = 1.35, -- todo más rápido en la fase 2
		TransitionTime = 2, -- invulnerable mientras ruge
		ResetAfter = 10, -- segundos sin jugadores en la arena para reiniciarse
		RespawnTime = 180,
		ContributionThreshold = 0.03, -- 3 % de su vida para recibir recompensa (decisión B6)

		Claw = { Damage = 30, Range = 11, Width = 10, Windup = 0.8, Cooldown = 1.6, PerfectBlockStun = 1 },
		RootSweep = { Damage = 25, Radius = 6, Warning = 1.2, Every = 8 },
		Summon = { EnemyId = "Thornling", Level = 14, Count = 2, MaxAlive = 4, Every = 20 },
		ThornRain = { Damage = 25, Radius = 5, Spots = 6, Warning = 1.2, Every = 10 }, -- solo fase 2
		Charge = { -- solo fase 2
			Damage = 40,
			Windup = 1,
			Speed = 70,
			MaxDistance = 45,
			Every = 12,
			MinDistance = 12,
			StunOnColumn = 3,
			VulnerableMultiplier = 1.5, -- daño extra mientras está aturdido tras chocar
		},

		Rewards = { XP = 1500, Potions = 1, EpicChance = 0.2 },
	},
}

return Bosses
