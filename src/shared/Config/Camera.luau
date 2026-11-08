--!strict
-- Ajustes de la cámara en tercera persona (estilo shift-lock).

local Camera = {
	ShoulderOffset = Vector3.new(1.75, 0.5, 0), -- desplaza la cámara sobre el hombro derecho
}

return table.freeze(Camera)
