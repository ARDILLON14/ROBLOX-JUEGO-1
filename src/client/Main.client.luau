--!strict
-- Script de arranque del CLIENTE. Carga todos los controladores de la carpeta Controllers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Loader = require(Shared:WaitForChild("Util"):WaitForChild("Loader"))
local GameInfo = require(Shared:WaitForChild("Config"):WaitForChild("GameInfo"))

print(`[Client] {GameInfo.Name} v{GameInfo.Version}`)
Loader.start(script.Parent:WaitForChild("Controllers"), "Client")
