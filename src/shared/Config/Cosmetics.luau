--!strict
-- Cosméticos (GDD v1 §7.3, aprobado): títulos y auras que se ganan al subir de nivel. Sin ventaja en combate.

export type Cosmetic = {
	Slot: "Title" | "Aura",
	NameKey: string,
	Color: Color3,
}

local Cosmetics: { [string]: Cosmetic } = {
	Title_DawnSeeker = { Slot = "Title", NameKey = "Cosmetic_Title_DawnSeeker", Color = Color3.fromRGB(255, 200, 70) },
	Aura_AetherEmber = { Slot = "Aura", NameKey = "Cosmetic_Aura_AetherEmber", Color = Color3.fromRGB(255, 120, 60) },
	Title_VerdantiaGuardian = {
		Slot = "Title",
		NameKey = "Cosmetic_Title_VerdantiaGuardian",
		Color = Color3.fromRGB(120, 230, 140),
	},
}

return Cosmetics
