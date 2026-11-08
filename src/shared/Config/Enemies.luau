--!strict
--[[
	Enemigos (GDD v1 §6.1, aprobado). Valores iniciales; se ajustarán en pruebas.
	Vida y daño crecen con el nivel del enemigo (lo define cada punto de aparición).
]]

export type EnemyConfig = {
	NameKey: string, -- clave en Config/Strings
	BaseHealth: number,
	HealthPerLevel: number,
	BaseDamage: number,
	DamagePerLevel: number,
	WalkSpeed: number,
	AggroRange: number, -- distancia a la que te detecta
	LeashRange: number, -- distancia máxima desde su punto de aparición antes de volver
	AttackRange: number,
	AttackWidth: number,
	AttackWindup: number, -- tiempo de aviso (brillo) antes del golpe
	AttackCooldown: number,
	Unblockable: boolean, -- true = brillo rojo, hay que esquivar
	StunDuration: number, -- aturdimiento tras un bloqueo perfecto
	XPPerLevel: number, -- XP = XPPerLevel × nivel del enemigo
	RespawnTime: number, -- segundos hasta reaparecer (menos con más jugadores cerca)
	BodyColor: Color3,
	LeafColor: Color3,
	Scale: number, -- tamaño del modelo provisional (1 = Brotespina)
	Material: Enum.Material,
	AttackStyle: "Melee" | "Ranged",
	-- Solo a distancia:
	PreferredRange: number?, -- intenta mantenerse a esta distancia
	ProjectileSpeed: number?,
	ProjectileRange: number?,
	-- Guardia frontal (Centinela):
	FrontGuard: boolean, -- bloquea golpes ligeros de frente; el pesado o el remate rompen su guardia
	GuardBlockMultiplier: number?, -- daño que pasa al bloquear (0,2 = 20 %)
	GuardBreakStun: number?, -- aturdimiento al romper su guardia
}

local Enemies: { [string]: EnemyConfig } = {
	Thornling = {
		NameKey = "Enemy_Thornling",
		BaseHealth = 60,
		HealthPerLevel = 15,
		BaseDamage = 8,
		DamagePerLevel = 2,
		WalkSpeed = 14,
		AggroRange = 30,
		LeashRange = 60,
		AttackRange = 5,
		AttackWidth = 4,
		AttackWindup = 0.6,
		AttackCooldown = 1.6,
		Unblockable = false,
		StunDuration = 1.5,
		XPPerLevel = 10, -- ajustado en la semana 24 (simulación de ritmo)
		RespawnTime = 10,
		BodyColor = Color3.fromRGB(95, 70, 45),
		LeafColor = Color3.fromRGB(80, 160, 70),
		Scale = 1,
		Material = Enum.Material.Wood,
		AttackStyle = "Melee",
		FrontGuard = false,
	},
	-- Variante de la Base 1: se queda atrás y lanza espinas (GDD §6.1).
	Spitter = {
		NameKey = "Enemy_Spitter",
		BaseHealth = 45,
		HealthPerLevel = 12,
		BaseDamage = 7,
		DamagePerLevel = 2,
		WalkSpeed = 13,
		AggroRange = 40,
		LeashRange = 60,
		AttackRange = 30, -- dispara si estás a esta distancia o menos
		AttackWidth = 2,
		AttackWindup = 0.7,
		AttackCooldown = 2,
		Unblockable = false,
		StunDuration = 1.5,
		XPPerLevel = 12, -- ×1,2 del Brotespina (ajustado en la semana 24)
		RespawnTime = 12,
		BodyColor = Color3.fromRGB(80, 60, 70),
		LeafColor = Color3.fromRGB(150, 90, 190),
		Scale = 0.9,
		Material = Enum.Material.Wood,
		AttackStyle = "Ranged",
		PreferredRange = 18,
		ProjectileSpeed = 45,
		ProjectileRange = 45,
		FrontGuard = false,
	},
	-- Base 2: grande, lento, bloquea de frente y tiene un golpe imbloqueable (GDD §6.1).
	Sentry = {
		NameKey = "Enemy_Sentry",
		BaseHealth = 220,
		HealthPerLevel = 40,
		BaseDamage = 22,
		DamagePerLevel = 5,
		WalkSpeed = 9,
		AggroRange = 28,
		LeashRange = 50,
		AttackRange = 7,
		AttackWidth = 7,
		AttackWindup = 1,
		AttackCooldown = 2.2,
		Unblockable = true, -- brillo ROJO: hay que esquivar
		StunDuration = 2,
		XPPerLevel = 30, -- ~×2,5–3 del Brotespina (ajustado en la semana 24)
		RespawnTime = 20,
		BodyColor = Color3.fromRGB(120, 120, 115),
		LeafColor = Color3.fromRGB(70, 130, 70),
		Scale = 1.6,
		Material = Enum.Material.Slate,
		AttackStyle = "Melee",
		FrontGuard = true,
		GuardBlockMultiplier = 0.2,
		GuardBreakStun = 2,
	},
}

return Enemies
