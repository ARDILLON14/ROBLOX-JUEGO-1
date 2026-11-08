--!strict
--[[
	Loader
	Carga todos los ModuleScripts de una carpeta y los arranca en dos pasos:
	  1. Init()  -> cada módulo se prepara (no debe usar otros módulos todavía).
	  2. Start() -> cada módulo empieza a funcionar (ya puede usar los demás).
	Si un módulo falla, se muestra un aviso en Output y los demás siguen funcionando.
]]

local Loader = {}

type Entry = {
	name: string,
	module: any,
}

local function callSafely(label: string, moduleName: string, methodName: string, module: any)
	local method = module[methodName]
	if type(method) ~= "function" then
		return
	end
	local ok, err = pcall(method, module)
	if not ok then
		warn(`[{label}] {moduleName}:{methodName}() falló: {err}`)
	end
end

function Loader.start(folder: Instance, label: string)
	local entries: { Entry } = {}

	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child)
			if ok then
				table.insert(entries, { name = child.Name, module = result })
			else
				warn(`[{label}] No se pudo cargar {child.Name}: {result}`)
			end
		end
	end

	-- Orden alfabético para que el arranque sea siempre igual.
	table.sort(entries, function(a: Entry, b: Entry)
		return a.name < b.name
	end)

	for _, entry in entries do
		callSafely(label, entry.name, "Init", entry.module)
	end

	for _, entry in entries do
		task.spawn(callSafely, label, entry.name, "Start", entry.module)
	end

	print(`[{label}] {#entries} módulo(s) iniciado(s)`)
end

return Loader
