--!strict
--[[
	ServerStatsService (servidor) — publica los FPS del servidor en el atributo "ServerFps" de Workspace
	(una vez por segundo) para el panel de rendimiento (F7). Si baja mucho de 60, el servidor va sobrecargado.
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ServerStatsService = {}

function ServerStatsService:Init() end

function ServerStatsService:Start()
	local frames = 0
	local elapsed = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		frames += 1
		elapsed += deltaTime
		if elapsed >= 1 then
			Workspace:SetAttribute("ServerFps", math.floor(frames / elapsed + 0.5))
			frames = 0
			elapsed = 0
		end
	end)
end

return ServerStatsService
