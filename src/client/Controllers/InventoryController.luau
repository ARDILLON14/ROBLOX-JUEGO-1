--!strict
-- InventoryController (cliente). Por ahora: tecla 1 = usar poción (el servidor decide si se puede).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"))
local InputController = require(script.Parent:WaitForChild("InputController"))

local InventoryController = {}

function InventoryController:Init() end

function InventoryController:Start()
	InputController:onAction("UsePotion", function(state)
		if state == "Begin" then
			Net.event("RequestUsePotion"):FireServer()
		end
	end)
end

return InventoryController
