--!strict
--[[
	AbilityController (cliente)
	Z = habilidad de tu afinidad, X = ulti. El cliente solo PIDE (RequestAbility con la dirección de la cámara);
	el servidor valida rango, enfriamiento y carga, y calcula el daño.
	El Paso Relámpago mueve a tu personaje al instante (como la esquiva) para que se sienta inmediato.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Affinities = require(Shared:WaitForChild("Config"):WaitForChild("Affinities"))
local Net = require(Shared:WaitForChild("Net"))
local InputController = require(script.Parent:WaitForChild("InputController"))
local CombatController = require(script.Parent:WaitForChild("CombatController"))
local PlayerDataController = require(script.Parent:WaitForChild("PlayerDataController"))

local THUNDER_STEP_DURATION = 0.25

local player = Players.LocalPlayer

local AbilityController = {}

local function getAim(): Vector3?
	local camera = Workspace.CurrentCamera
	if not camera then
		return nil
	end
	local look = camera.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then
		return nil
	end
	return flat.Unit
end

local function getAffinity(): (string?, number)
	local data = PlayerDataController:get()
	if not data then
		return nil, 1
	end
	local affinityId: string = data.Affinity.Selected
	if not Affinities.List[affinityId] then
		return nil, 1
	end
	local points: number = data.Affinity.Mastery[affinityId] or 0
	return affinityId, Affinities.rankOf(points)
end

local function useSkill()
	local affinityId = getAffinity()
	local aim = getAim()
	if not affinityId or not aim or CombatController:getState() ~= "Idle" then
		return
	end
	local cooldownEnd = player:GetAttribute("SkillCooldownEnd")
	if typeof(cooldownEnd) == "number" and Workspace:GetServerTimeNow() < cooldownEnd then
		return
	end
	Net.event("RequestAbility"):FireServer("Skill", aim)
	if affinityId == "Lightning" then
		local config = Affinities.List.Lightning
		local distance = config.DashDistance or 14
		CombatController:dash(aim, distance / THUNDER_STEP_DURATION, THUNDER_STEP_DURATION)
	end
end

local function useUltimate()
	local affinityId, rank = getAffinity()
	local aim = getAim()
	if not affinityId or not aim or rank < 3 or CombatController:getState() ~= "Idle" then
		return
	end
	local charge = player:GetAttribute("UltCharge")
	if typeof(charge) ~= "number" or charge < 1 then
		return
	end
	Net.event("RequestAbility"):FireServer("Ultimate", aim)
end

function AbilityController:Init() end

function AbilityController:Start()
	InputController:onAction("Skill", function(state)
		if state == "Begin" then
			useSkill()
		end
	end)
	InputController:onAction("Ultimate", function(state)
		if state == "Begin" then
			useUltimate()
		end
	end)
end

return AbilityController
