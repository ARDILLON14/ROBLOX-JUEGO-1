--!strict
--[[
	ProceduralAnimations (cliente) — animaciones PROVISIONALES generadas por código para avatares R15.
	Se construyen como KeyframeSequence (poses en el tiempo) y se registran con KeyframeSequenceProvider,
	que da un ID temporal. [VERIFICAR EN DOCUMENTACIÓN: "KeyframeSequenceProvider:RegisterKeyframeSequence";
	normalmente solo funciona en Studio]. Por eso se usan SOLO en Studio y SOLO si el ID de Config/Animations
	está vacío. Para el juego publicado hay que crear y publicar las animaciones reales (Entrega 3.2).

	Ejes (articulaciones R15): rotar el hombro en X (+) lleva el brazo hacia delante/arriba; en Z (+) aleja
	el brazo derecho del cuerpo. El torso en X (−) se inclina hacia delante; en Y gira la cintura.
]]

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

type Joints = { [string]: CFrame }
type KeyframeSpec = { time: number, joints: Joints }
type AnimationSpec = { looped: boolean, keyframes: { KeyframeSpec } }

local ProceduralAnimations = {}

local function rad(x: number, y: number, z: number): CFrame
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

-- Jerarquía de articulaciones R15 (cada pose cuelga de su padre).
local HIERARCHY: { [string]: { string } } = {
	HumanoidRootPart = { "LowerTorso" },
	LowerTorso = { "UpperTorso", "RightUpperLeg", "LeftUpperLeg" },
	UpperTorso = { "Head", "RightUpperArm", "LeftUpperArm" },
	RightUpperArm = { "RightLowerArm" },
	RightLowerArm = { "RightHand" },
	LeftUpperArm = { "LeftLowerArm" },
	LeftLowerArm = { "LeftHand" },
	RightUpperLeg = { "RightLowerLeg" },
	LeftUpperLeg = { "LeftLowerLeg" },
}

-- Duraciones normalizadas a 1 s: CombatController ajusta la velocidad a la duración real del golpe.
local SPECS: { [string]: AnimationSpec } = {
	-- Golpe 1: diagonal de arriba-derecha a abajo-izquierda.
	Light1 = {
		looped = false,
		keyframes = {
			{
				time = 0,
				joints = { UpperTorso = rad(0, -20, 0), RightUpperArm = rad(140, 0, 40), RightLowerArm = rad(20, 0, 0) },
			},
			{
				time = 0.45,
				joints = { UpperTorso = rad(-5, 25, 0), RightUpperArm = rad(40, 0, -30), RightLowerArm = rad(5, 0, 0) },
			},
			{
				time = 1,
				joints = { UpperTorso = rad(0, 10, 0), RightUpperArm = rad(30, 0, -10), RightLowerArm = rad(10, 0, 0) },
			},
		},
	},
	-- Golpe 2: barrido horizontal de izquierda a derecha.
	Light2 = {
		looped = false,
		keyframes = {
			{
				time = 0,
				joints = { UpperTorso = rad(0, 30, 0), RightUpperArm = rad(90, 0, -40), RightLowerArm = rad(15, 0, 0) },
			},
			{
				time = 0.45,
				joints = { UpperTorso = rad(0, -30, 0), RightUpperArm = rad(90, 0, 60), RightLowerArm = rad(0, 0, 0) },
			},
			{
				time = 1,
				joints = { UpperTorso = rad(0, -10, 0), RightUpperArm = rad(60, 0, 30), RightLowerArm = rad(10, 0, 0) },
			},
		},
	},
	-- Golpe 3: estocada hacia delante.
	Light3 = {
		looped = false,
		keyframes = {
			{
				time = 0,
				joints = { UpperTorso = rad(5, 0, 0), RightUpperArm = rad(60, 0, 10), RightLowerArm = rad(70, 0, 0) },
			},
			{
				time = 0.45,
				joints = {
					UpperTorso = rad(-15, 0, 0),
					RightUpperArm = rad(95, 0, 0),
					RightLowerArm = rad(0, 0, 0),
					LeftUpperLeg = rad(25, 0, 0),
				},
			},
			{
				time = 1,
				joints = { UpperTorso = rad(-5, 0, 0), RightUpperArm = rad(70, 0, 0), RightLowerArm = rad(10, 0, 0) },
			},
		},
	},
	-- Pesado / remate: levantar por encima de la cabeza y golpear hacia abajo con fuerza.
	Heavy = {
		looped = false,
		keyframes = {
			{ time = 0, joints = {} },
			{
				time = 0.4,
				joints = {
					UpperTorso = rad(12, 0, 0),
					RightUpperArm = rad(170, 0, 10),
					LeftUpperArm = rad(160, 0, -10),
					RightLowerArm = rad(20, 0, 0),
				},
			},
			{
				time = 0.6,
				joints = {
					UpperTorso = rad(-28, 0, 0),
					RightUpperArm = rad(30, 0, -5),
					LeftUpperArm = rad(30, 0, 5),
					RightUpperLeg = rad(30, 0, 0),
					LeftUpperLeg = rad(-15, 0, 0),
				},
			},
			{ time = 1, joints = { UpperTorso = rad(-8, 0, 0), RightUpperArm = rad(40, 0, 0) } },
		},
	},
	-- Esquiva: cuerpo agachado e inclinado.
	Dodge = {
		looped = false,
		keyframes = {
			{ time = 0, joints = {} },
			{
				time = 0.3,
				joints = {
					UpperTorso = rad(-30, 0, 0),
					RightUpperLeg = rad(45, 0, 0),
					LeftUpperLeg = rad(-25, 0, 0),
					RightUpperArm = rad(-20, 0, 20),
					LeftUpperArm = rad(-20, 0, -20),
				},
			},
			{ time = 1, joints = {} },
		},
	},
	-- Bloqueo: arma cruzada delante del pecho (en bucle).
	Block = {
		looped = true,
		keyframes = {
			{
				time = 0,
				joints = {
					UpperTorso = rad(-5, 15, 0),
					RightUpperArm = rad(80, 0, -50),
					RightLowerArm = rad(60, 0, 0),
					LeftUpperArm = rad(70, 0, 40),
				},
			},
			{
				time = 1,
				joints = {
					UpperTorso = rad(-5, 15, 0),
					RightUpperArm = rad(82, 0, -50),
					RightLowerArm = rad(60, 0, 0),
					LeftUpperArm = rad(72, 0, 40),
				},
			},
		},
	},
}

local registered: { [string]: string } = {}
local failed = false

local function buildPose(name: string, joints: Joints): Pose
	local pose = Instance.new("Pose")
	pose.Name = name
	pose.CFrame = joints[name] or CFrame.new()
	pose.Weight = 1
	pose.EasingStyle = Enum.PoseEasingStyle.Cubic
	pose.EasingDirection = Enum.PoseEasingDirection.Out
	local children: { string } = HIERARCHY[name] or {}
	for _, childName in children do
		buildPose(childName, joints).Parent = pose
	end
	return pose
end

local function buildSequence(spec: AnimationSpec): KeyframeSequence
	local sequence = Instance.new("KeyframeSequence")
	sequence.Loop = spec.looped
	sequence.Priority = Enum.AnimationPriority.Action
	for _, keyframeSpec in spec.keyframes do
		local keyframe = Instance.new("Keyframe")
		keyframe.Time = keyframeSpec.time
		buildPose("HumanoidRootPart", keyframeSpec.joints).Parent = keyframe
		keyframe.Parent = sequence
	end
	return sequence
end

--[[
	ID temporal para una clave de animación del combate ("Katana.Light2", "Greatsword.Heavy", "Dodge", "Block"...).
	Devuelve "" si no hay animación provisional o si el registro no está disponible.
]]
function ProceduralAnimations.getId(key: string): string
	if failed then
		return ""
	end
	-- "Katana.Light2" → "Light2"; "Greatsword.Finisher" → "Heavy".
	local name = string.match(key, "%.(%w+)$") or key
	if name == "Finisher" then
		name = "Heavy"
	end
	local cached = registered[name]
	if cached then
		return cached
	end
	local spec = SPECS[name]
	if not spec then
		return ""
	end
	local ok, result = pcall(function()
		return KeyframeSequenceProvider:RegisterKeyframeSequence(buildSequence(spec))
	end)
	if not ok or typeof(result) ~= "string" then
		failed = true
		warn(`[ProceduralAnimations] No se pudieron registrar las animaciones provisionales: {result}`)
		return ""
	end
	registered[name] = result
	return result
end

return ProceduralAnimations
