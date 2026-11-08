--!strict
--[[
	Validate
	Comprobaciones para los datos que llegan del cliente.
	Regla: todo lo que envía el cliente es sospechoso hasta que se valida.
]]

local Validate = {}

-- Número real: ni NaN ("no es un número") ni infinito.
function Validate.isFiniteNumber(value: unknown): boolean
	return typeof(value) == "number" and value == value and math.abs(value) ~= math.huge
end

function Validate.isBoolean(value: unknown): boolean
	return typeof(value) == "boolean"
end

-- Texto que pertenece a una lista permitida (p. ej., {"Light", "Heavy"}).
function Validate.isOneOf(value: unknown, allowed: { string }): boolean
	return typeof(value) == "string" and table.find(allowed, value) ~= nil
end

-- Vector de dirección: componentes finitos y longitud aproximadamente 1.
function Validate.isUnitVector(value: unknown): boolean
	if typeof(value) ~= "Vector3" then
		return false
	end
	local vector = value :: Vector3
	if
		not Validate.isFiniteNumber(vector.X)
		or not Validate.isFiniteNumber(vector.Y)
		or not Validate.isFiniteNumber(vector.Z)
	then
		return false
	end
	return math.abs(vector.Magnitude - 1) < 0.05
end

return Validate
