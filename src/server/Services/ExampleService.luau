--!strict
-- Servicio de ejemplo para comprobar que el arranque funciona.
-- Se borrará cuando exista el primer servicio real (Sección 3).

local ExampleService = {}

function ExampleService:Init()
	print("[ExampleService] Init")
end

function ExampleService:Start()
	print("[ExampleService] Start")
end

return ExampleService
