--!strict
--[[
	ZoneAmbienceController (cliente) — ambiente por zona (semana 20: arte e iluminación).
	Detecta en qué zona estás (piezas invisibles con la etiqueta "ZoneVolume" y el atributo Zone) y:
	- cambia suavemente la niebla (Atmosphere) y el tono de color (ColorCorrection) según Config/World.Zones;
	- muestra el nombre de la zona y su rango de niveles al entrar (estilo anime).
	Todo es local: cada jugador ve el ambiente de la zona en la que está.
]]

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local World = require(Config:WaitForChild("World"))
local Strings = require(Config:WaitForChild("Strings"))

local CHECK_INTERVAL = 0.5
local BLEND_TIME = 2.5

local player = Players.LocalPlayer

local ZoneAmbienceController = {}

local currentZone: string? = nil
local atmosphere: Atmosphere
local colorCorrection: ColorCorrectionEffect
local title: TextLabel
local subtitle: TextLabel

local function ensureEffects()
	local existingAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if existingAtmosphere then
		atmosphere = existingAtmosphere
	else
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	local existingCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if existingCorrection then
		colorCorrection = existingCorrection
	else
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Parent = Lighting
	end
end

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZoneTitle"
	gui.ResetOnSpawn = false

	title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.2)
	title.Size = UDim2.fromScale(0.5, 0.07)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0.4
	title.TextTransparency = 1
	title.TextStrokeColor3 = Color3.fromRGB(30, 20, 40)
	title.Parent = gui

	subtitle = Instance.new("TextLabel")
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.fromScale(0.5, 0.255)
	subtitle.Size = UDim2.fromScale(0.3, 0.035)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextScaled = true
	subtitle.TextColor3 = Color3.fromRGB(255, 200, 70)
	subtitle.TextStrokeTransparency = 0.5
	subtitle.TextTransparency = 1
	subtitle.Parent = gui

	gui.Parent = player:WaitForChild("PlayerGui")
end

local function showTitle(info: World.ZoneInfo)
	title.Text = Strings.get(info.NameKey)
	if info.IsBossArea then
		subtitle.Text = Strings.get("ZoneBoss")
	elseif info.MinLevel and info.MaxLevel then
		subtitle.Text = Strings.get("ZoneLevels", { min = info.MinLevel, max = info.MaxLevel })
	else
		subtitle.Text = ""
	end
	for _, label in { title, subtitle } do
		label.TextTransparency = 0
		label.TextStrokeTransparency = 0.4
	end
	local myText = title.Text
	task.delay(3, function()
		if title.Text ~= myText then
			return
		end
		for _, label in { title, subtitle } do
			TweenService:Create(label, TweenInfo.new(1), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

local function applyZone(zoneId: string, instant: boolean)
	local info = World.Zones[zoneId]
	if not info then
		return
	end
	local tweenInfo = TweenInfo.new(if instant then 0 else BLEND_TIME, Enum.EasingStyle.Sine)
	TweenService:Create(atmosphere, tweenInfo, {
		Density = info.AtmosphereDensity,
		Color = info.AtmosphereColor,
		Decay = info.AtmosphereDecay,
		Haze = info.AtmosphereHaze,
	}):Play()
	TweenService:Create(colorCorrection, tweenInfo, { TintColor = info.Tint, Saturation = info.Saturation }):Play()
	if not instant then
		showTitle(info)
	end
end

-- Zona en la que está una posición (comprobando el rectángulo horizontal de cada volumen).
local function zoneAt(position: Vector3): string?
	for _, volume in CollectionService:GetTagged("ZoneVolume") do
		if volume:IsA("BasePart") then
			local localPosition = volume.CFrame:PointToObjectSpace(position)
			if math.abs(localPosition.X) <= volume.Size.X / 2 and math.abs(localPosition.Z) <= volume.Size.Z / 2 then
				local zone = volume:GetAttribute("Zone")
				if typeof(zone) == "string" then
					return zone
				end
			end
		end
	end
	return nil
end

function ZoneAmbienceController:Init() end

function ZoneAmbienceController:Start()
	ensureEffects()
	buildGui()
	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") then
				local zone = zoneAt(root.Position)
				-- En los caminos entre zonas se mantiene la última zona.
				if zone and zone ~= currentZone then
					local first = currentZone == nil
					currentZone = zone
					applyZone(zone, first)
				end
			end
		end
	end)
end

return ZoneAmbienceController
