--!strict
-- Script de arranque del SERVIDOR. Crea los mensajeros (Net) y carga todos los servicios de la carpeta Services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Loader = require(Shared:WaitForChild("Util"):WaitForChild("Loader"))
local GameInfo = require(Shared:WaitForChild("Config"):WaitForChild("GameInfo"))

print(`[Server] {GameInfo.Name} v{GameInfo.Version}`)
require(Shared:WaitForChild("Net")) -- crea ReplicatedStorage/Remotes antes que nada
-- La carpeta Services solo existe cuando hay al menos un servicio dentro.
local services = script.Parent:FindFirstChild("Services")
if services then
	Loader.start(services, "Server")
else
	print("[Server] 0 servicios todavía")
end
