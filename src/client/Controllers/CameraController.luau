--!strict
--[[
	CameraController
	Cámara en tercera persona estilo shift-lock (decisión aprobada):
	- El ratón queda bloqueado en el centro de la pantalla.
	- El personaje siempre mira hacia donde apunta la cámara.
	- La cámara se coloca sobre el hombro derecho.
	Mantener Alt izquierdo (acción FreeCursor) libera el ratón temporalmente.
	Otros sistemas (inventario, diálogos) podrán liberarlo con setCursorFree().
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local CameraConfig = require(Config:WaitForChild("Camera"))
local InputController = require(script.Parent:WaitForChild("InputController"))

local RENDER_STEP_NAME = "EclipseShoulderCamera"

local player = Players.LocalPlayer

local CameraController = {}

-- Motivos por los que el ratón debe estar libre (p. ej., "FreeCursorKey", "Inventory").
local cursorFreeReasons: { [string]: boolean } = {}

local function isCursorFree(): boolean
	return next(cursorFreeReasons) ~= nil
end

local function update()
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not root:IsA("BasePart") or humanoid.Health <= 0 then
		return
	end

	humanoid.CameraOffset = CameraConfig.ShoulderOffset

	if isCursorFree() then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		humanoid.AutoRotate = true
		return
	end

	if UserInputService.KeyboardEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
	humanoid.AutoRotate = false

	-- Girar el personaje hacia donde mira la cámara (solo en horizontal).
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local look = camera.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude > 0.01 then
		root.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook.Unit)
	end
end

function CameraController:Init() end

function CameraController:Start()
	-- Se ejecuta cada fotograma, justo después de la cámara de Roblox.
	RunService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Camera.Value + 1, update)

	InputController:onAction("FreeCursor", function(state)
		CameraController:setCursorFree("FreeCursorKey", state == "Begin")
	end)
end

-- Libera (true) o vuelve a bloquear (false) el ratón por un motivo concreto.
function CameraController:setCursorFree(reason: string, free: boolean)
	if free then
		cursorFreeReasons[reason] = true
	else
		cursorFreeReasons[reason] = nil
	end
end

return CameraController
