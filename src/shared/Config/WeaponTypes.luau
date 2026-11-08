--!strict
-- Tipos de arma (GDD v1 §5). Tiempos en segundos, distancias en studs.

export type WeaponType = {
	LightDamage: number,
	LightInterval: number, -- duración de cada golpe ligero
	LightHitTime: number, -- momento del golpe dentro de la animación
	HeavyDuration: number,
	HeavyHitTime: number,
	Range: number, -- alcance hacia delante
	Width: number, -- ancho del arco
	DodgeCancelDelay: number, -- tiempo mínimo dentro de un ataque antes de poder esquivar
	-- Arma provisional (bloque) hasta tener modelos:
	BladeSize: Vector3,
	BladeColor: Color3,
	GripOffset: CFrame, -- posición de la hoja respecto a la mano derecha
}

local WeaponTypes: { [string]: WeaponType } = {
	Katana = {
		LightDamage = 10,
		LightInterval = 0.35,
		LightHitTime = 0.15,
		HeavyDuration = 0.6,
		HeavyHitTime = 0.35,
		Range = 6,
		Width = 5,
		DodgeCancelDelay = 0,
		BladeSize = Vector3.new(0.15, 0.3, 4),
		BladeColor = Color3.fromRGB(220, 225, 235),
		GripOffset = CFrame.new(0, -0.1, -2),
	},
	Greatsword = {
		LightDamage = 18,
		LightInterval = 0.6,
		LightHitTime = 0.3,
		HeavyDuration = 0.9,
		HeavyHitTime = 0.55,
		Range = 8,
		Width = 8,
		DodgeCancelDelay = 0.25,
		BladeSize = Vector3.new(0.3, 0.8, 5.5),
		BladeColor = Color3.fromRGB(150, 155, 165),
		GripOffset = CFrame.new(0, -0.1, -2.75),
	},
}

return WeaponTypes
