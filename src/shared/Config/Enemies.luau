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
		XPPerLevel = 15,
		RespawnTime = 10,
		BodyColor = Color3.fromRGB(95, 70, 45),
		LeafColor = Color3.fromRGB(80, 160, 70),
	},
}

return Enemies
