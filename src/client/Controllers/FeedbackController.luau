--!strict
--[[
	FeedbackController
	Números de daño en pantalla (GDD §4.6, decisión aprobada).
	- Los números vienen del SERVIDOR: siempre muestran el daño real.
	- Tus golpes: grandes y opacos. Golpes de otros jugadores: pequeños y semitransparentes.
	- Golpes seguidos al mismo objetivo (en 0,3 s) se suman en un solo número.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CombatConfig = require(Shared:WaitForChild("Config"):WaitForChild("Combat"))
local Strings = require(Shared:WaitForChild("Config"):WaitForChild("Strings"))
local Net = require(Shared:WaitForChild("Net"))

local player = Players.LocalPlayer

local COLORS: { [string]: Color3 } = {
	Normal = Color3.fromRGB(255, 255, 255),
	Crit = Color3.fromRGB(255, 215, 60),
	Received = Color3.fromRGB(255, 70, 70), -- daño que recibes
	Blocked = Color3.fromRGB(170, 170, 170),
	PerfectBlock = Color3.fromRGB(255, 205, 80),
}

type ActiveNumber = {
	label: TextLabel,
	gui: BillboardGui,
	total: number,
	time: number,
	token: number,
}

local FeedbackController = {}

local active: { [Instance]: ActiveNumber } = {} -- un número activo por objetivo (solo tus golpes)

local function getAnchor(target: Instance): BasePart?
	local head = target:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head
	end
	local root = target:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function animateAndRemove(gui: BillboardGui, label: TextLabel, isMine: boolean, onDone: () -> ())
	local duration = CombatConfig.DamageNumberDuration
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2, 0)
	TweenService:Create(gui, info, { StudsOffset = gui.StudsOffset + Vector3.new(0, 2, 0) }):Play()
	local fade = TweenService:Create(label, info, { TextTransparency = 1, TextStrokeTransparency = 1 })
	fade:Play()
	fade.Completed:Connect(function(playbackState: Enum.PlaybackState)
		if playbackState == Enum.PlaybackState.Completed then
			gui:Destroy()
			onDone()
		end
	end)
	label.TextTransparency = if isMine then 0 else 0.5
end

local function showNumber(target: Instance, amount: number, kind: string, isMine: boolean)
	if typeof(target) ~= "Instance" or typeof(amount) ~= "number" then
		return
	end
	local anchor = getAnchor(target)
	if not anchor then
		return
	end
	local color = COLORS[kind] or COLORS.Normal
	local now = os.clock()

	local text = tostring(amount)
	if kind == "PerfectBlock" then
		text = Strings.get("PerfectBlock")
	elseif kind == "Blocked" then
		text = Strings.get("Blocked", { amount = amount })
	end
	local canMerge = isMine and (kind == "Normal" or kind == "Crit")

	-- Agrupar tus golpes rápidos al mismo objetivo.
	local existing = if canMerge then active[target] else nil
	if existing and now - existing.time <= CombatConfig.DamageNumberMergeWindow then
		existing.total += amount
		existing.time = now
		existing.token += 1
		existing.label.Text = tostring(existing.total)
		existing.label.TextColor3 = color
		return
	end

	local size = if isMine then (if kind == "Crit" then 56 else 44) else 26
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(160, size)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.Adornee = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = if isMine then 0.2 else 0.7
	label.Parent = gui
	gui.Parent = player:WaitForChild("PlayerGui")

	if canMerge then
		local entry: ActiveNumber = { label = label, gui = gui, total = amount, time = now, token = 0 }
		active[target] = entry
		animateAndRemove(gui, label, true, function()
			if active[target] == entry then
				active[target] = nil
			end
		end)
	else
		animateAndRemove(gui, label, isMine, function() end)
	end
end

function FeedbackController:Init() end

function FeedbackController:Start()
	Net.event("HitConfirmed").OnClientEvent:Connect(function(target: Instance, amount: number, kind: string)
		showNumber(target, amount, kind, true)
	end)
	Net.unreliable("HitBroadcast").OnClientEvent:Connect(function(target: Instance, amount: number, kind: string)
		showNumber(target, amount, kind, false)
	end)
end

return FeedbackController
