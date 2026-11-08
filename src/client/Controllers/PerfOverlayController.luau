--!strict
--[[
	PerfOverlayController (cliente) — panel de rendimiento (tecla F7), para las pruebas de la semana 22
	y la prueba pública. Muestra: FPS, FPS del servidor, ping, memoria, enemigos activos y piezas del mapa.
	Pide a quien pruebe que haga una captura con F7 abierto si nota lag.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local InputController = require(script.Parent:WaitForChild("InputController"))

local player = Players.LocalPlayer

local PerfOverlayController = {}

local label: TextLabel
local frames = 0
local elapsed = 0
local fps = 0
local partCount = 0
local lastPartCount = -math.huge

local function countParts(): number
	local count = 0
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("BasePart") then
			count += 1
		end
	end
	return count
end

local function update()
	local now = os.clock()
	if now - lastPartCount > 5 then
		lastPartCount = now
		partCount = countParts()
	end
	local serverFps = Workspace:GetAttribute("ServerFps")
	local pingOk, ping = pcall(function()
		return player:GetNetworkPing() * 1000
	end)
	label.Text = string.format(
		" FPS %d  |  Servidor %s  |  Ping %s ms  |  Memoria %d MB  |  Enemigos %d  |  Piezas %d",
		fps,
		if typeof(serverFps) == "number" then tostring(serverFps) else "?",
		if pingOk and typeof(ping) == "number" then tostring(math.floor(ping)) else "?",
		math.floor(Stats:GetTotalMemoryUsageMb()),
		#CollectionService:GetTagged("Enemy"),
		partCount
	)
end

function PerfOverlayController:Init() end

function PerfOverlayController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "PerfOverlay"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -76)
	label.Size = UDim2.new(0.7, 0, 0, 22)
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.4
	label.Font = Enum.Font.Code
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(120, 255, 140)
	label.Visible = false
	label.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui")

	InputController:onAction("PerfOverlay", function(state)
		if state == "Begin" then
			label.Visible = not label.Visible
			lastPartCount = -math.huge
		end
	end)

	RunService.RenderStepped:Connect(function(deltaTime: number)
		frames += 1
		elapsed += deltaTime
		if elapsed >= 0.5 then
			fps = math.floor(frames / elapsed + 0.5)
			frames = 0
			elapsed = 0
			if label.Visible then
				update()
			end
		end
	end)
end

return PerfOverlayController
