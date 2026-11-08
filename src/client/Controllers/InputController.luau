--!strict
--[[
	InputController
	Traduce teclas en ACCIONES y avisa a quien esté escuchando.
	Uso desde otro controlador:
		InputController:onAction("Block", function(state) ... end)  -- state = "Begin" o "End"
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Controls = require(Config:WaitForChild("Controls"))
local Debug = require(Config:WaitForChild("Debug"))

export type ActionState = "Begin" | "End"
type Callback = (state: ActionState) -> ()

local InputController = {}

local listeners: { [string]: { Callback } } = {}
local inputToAction: { [EnumItem]: string } = {}
local enabled = true

local function findAction(input: InputObject): string?
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return inputToAction[input.KeyCode]
	end
	return inputToAction[input.UserInputType]
end

function InputController:Init()
	for actionName, binding in Controls.Actions do
		for _, key in binding.PC do
			inputToAction[key] = actionName
		end
	end
end

function InputController:Start()
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		-- gameProcessedEvent = true cuando Roblox ya usó la tecla (p. ej., escribir en el chat).
		if gameProcessedEvent then
			return
		end
		local action = findAction(input)
		if action then
			InputController:fire(action, "Begin")
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		-- Al SOLTAR no se ignora gameProcessedEvent: así nunca se queda una acción "pegada"
		-- (p. ej., bloquear y soltar la tecla con el ratón encima de un botón).
		local action = findAction(input)
		if action then
			InputController:fire(action, "End")
		end
	end)
end

-- Escucha una acción. Devuelve una función para dejar de escuchar.
function InputController:onAction(actionName: string, callback: Callback): () -> ()
	assert(Controls.Actions[actionName], `[Input] Acción desconocida: {actionName}`)
	local list = listeners[actionName]
	if not list then
		list = {}
		listeners[actionName] = list
	end
	table.insert(list, callback)
	return function()
		local index = table.find(list, callback)
		if index then
			table.remove(list, index)
		end
	end
end

-- Dispara una acción. Lo usan las teclas y, en el futuro, los botones táctiles.
function InputController:fire(actionName: string, state: ActionState)
	if not enabled then
		return
	end
	if Debug.LogInput then
		print(`[Input] {actionName} {state}`)
	end
	local list = listeners[actionName]
	if list then
		for _, callback in list do
			task.spawn(callback, state)
		end
	end
end

-- Desactiva todas las acciones (p. ej., durante una escena o un diálogo).
function InputController:setEnabled(value: boolean)
	enabled = value
end

return InputController
