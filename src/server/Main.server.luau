--!strict
-- Script de arranque del SERVIDOR. Carga todos los servicios de la carpeta Services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Loader = require(Shared:WaitForChild("Util"):WaitForChild("Loader"))
local GameInfo = require(Shared:WaitForChild("Config"):WaitForChild("GameInfo"))

print(`[Server] {GameInfo.Name} v{GameInfo.Version}`)
Loader.start(script.Parent:WaitForChild("Services"), "Server")
