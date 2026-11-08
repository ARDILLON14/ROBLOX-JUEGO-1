--!strict
-- Controlador de ejemplo para comprobar que el arranque funciona.
-- Se borrará cuando exista el primer controlador real (Sección 3).

local ExampleController = {}

function ExampleController:Init()
	print("[ExampleController] Init")
end

function ExampleController:Start()
	print("[ExampleController] Start")
end

return ExampleController
