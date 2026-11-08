--!strict
--[[
	Hitbox
	Busca personajes (modelos con Humanoid vivo) dentro de una caja delante de un punto.
	Lo usa el cliente para la respuesta visual y lo usará el servidor para decidir el daño real (semana 5).
]]

local Workspace = game:GetService("Workspace")

local Hitbox = {}

local function findCharacterModel(part: BasePart): Model?
	local model = part:FindFirstAncestorOfClass("Model")
	while model and not model:FindFirstChildOfClass("Humanoid") do
		model = model:FindFirstAncestorOfClass("Model")
	end
	return model
end

-- origin: posición y orientación del atacante. La caja empieza en él y se extiende "range" hacia delante.
function Hitbox.query(origin: CFrame, range: number, width: number, height: number, ignore: { Instance }): { Model }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore

	local boxCFrame = origin * CFrame.new(0, 0, -range / 2)
	local parts = Workspace:GetPartBoundsInBox(boxCFrame, Vector3.new(width, height, range), params)

	local seen: { [Model]: boolean } = {}
	local result: { Model } = {}
	for _, part in parts do
		local model = findCharacterModel(part)
		if model and not seen[model] then
			seen[model] = true
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(result, model)
			end
		end
	end
	return result
end

return Hitbox
