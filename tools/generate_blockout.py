"""
Genera map/VerdantiaBlockout.model.json: mapa provisional en bloques (blockout) del
Campamento del Alba y la Linde Esmeralda para el slice vertical.
Solo se incluye en build.project.json (lugar de prueba). Después el mapa vive en Studio (decisión A5).
Uso: python3 tools/generate_blockout.py
"""
import json
import math
import random

random.seed(7)  # siempre el mismo resultado

GRASS = [0.42, 0.62, 0.31]
GRASS_DARK = [0.3, 0.5, 0.25]
DIRT = [0.55, 0.42, 0.28]
WOOD = [0.45, 0.32, 0.2]
LEAF = [0.22, 0.48, 0.2]
STONE = [0.55, 0.55, 0.52]
CLOTH = [0.85, 0.75, 0.55]


def part(name, size, pos, color, material="SmoothPlastic", shape=None, class_name="Part",
         tags=None, attributes=None, transparency=0, can_collide=True, rotation=None):
    props = {
        "Anchored": True,
        "Size": size,
        "Color": color,
        "Material": material,
        "TopSurface": "Smooth",
        "BottomSurface": "Smooth",
        "CanCollide": can_collide,
        "Transparency": transparency,
    }
    if rotation:
        # CFrame: posición + matriz de rotación (solo giro en Y)
        a = math.radians(rotation)
        c, s = math.cos(a), math.sin(a)
        props["CFrame"] = {"CFrame": {"position": pos, "orientation": [[c, 0, s], [0, 1, 0], [-s, 0, c]]}}
    else:
        props["Position"] = pos
    if shape:
        props["Shape"] = shape
    if tags:
        props["Tags"] = tags
    inst = {"Name": name, "ClassName": class_name, "Properties": props}
    if attributes:
        inst["attributes"] = attributes
    return inst


def folder(name, children):
    return {"Name": name, "ClassName": "Folder", "Children": children}


def lerp_color(a, b, t):
    return [a[i] + (b[i] - a[i]) * t for i in range(3)]


# Paletas de hojas por estilo (estética anime: colores saturados con variación suave)
LEAF_PALETTES = {
    "lush": ([0.24, 0.55, 0.22], [0.42, 0.68, 0.25]),
    "ruins": ([0.25, 0.45, 0.24], [0.35, 0.55, 0.3]),
    "withered": ([0.35, 0.22, 0.4], [0.5, 0.3, 0.45]),
}


def upright(inst, x, y, z):
    """Pone de pie un cilindro (Roblox los crea acostados en el eje X)."""
    inst["Properties"].pop("Position", None)
    inst["Properties"]["CFrame"] = {"CFrame": {"position": [x, y, z], "orientation": [[0, -1, 0], [1, 0, 0], [0, 0, 1]]}}
    return inst


def tree(name, x, z, height=None, style="lush"):
    """Árbol estilizado: tronco + 2-3 copas de distinto tamaño y tono."""
    h = height or random.uniform(14, 22)
    low, high = LEAF_PALETTES[style]
    trunk_color = [0.32, 0.22, 0.2] if style == "withered" else WOOD
    parts = [upright(part(f"{name}_Trunk", [h, 2.2, 2.2], [x, h / 2, z], trunk_color, "Wood", shape="Cylinder"), x, h / 2, z)]
    for j in range(random.choice([2, 3])):
        r = random.uniform(7, 12) * (1 - j * 0.18)
        ox, oz = random.uniform(-2.5, 2.5), random.uniform(-2.5, 2.5)
        color = lerp_color(low, high, random.random())
        parts.append(part(f"{name}_Leaves{j + 1}", [r, r * 0.85, r], [x + ox, h + j * 3 - 1, z + oz], color, "Grass",
                          shape="Ball", can_collide=False))
    return parts


def rock(name, x, z, size=None):
    s = size or random.uniform(2, 5)
    color = lerp_color([0.45, 0.45, 0.45], [0.6, 0.58, 0.55], random.random())
    return part(name, [s * random.uniform(1, 1.6), s * random.uniform(0.6, 1), s], [x, s * 0.35, z], color, "Slate",
                rotation=random.uniform(0, 180))


def bush(name, x, z, style="lush"):
    low, high = LEAF_PALETTES[style]
    r = random.uniform(2.5, 4.5)
    return part(name, [r * 1.3, r, r * 1.3], [x, r * 0.35, z], lerp_color(low, high, random.random()), "Grass",
                shape="Ball", can_collide=False)


def flower(name, x, z, color):
    return part(name, [0.6, 0.6, 0.6], [x, 0.7, z], color, "SmoothPlastic", shape="Ball", can_collide=False)


def zone_volume(zone, size, pos):
    """Volumen invisible que indica la zona (cambia el ambiente y muestra el nombre al entrar)."""
    return part(f"ZoneVolume_{zone}", size, pos, [1, 1, 1], tags=["ZoneVolume"], attributes={"Zone": zone},
                transparency=1, can_collide=False)


camp = []
camp.append(part("CampGround", [70, 0.4, 70], [0, 0.2, 0], GRASS, "Grass"))
camp.append(zone_volume("DawnCamp", [80, 1, 90], [0, 0.5, 0]))
for i, (x, z, col) in enumerate([(-30, 30, [0.8, 0.2, 0.2]), (30, 30, [0.95, 0.75, 0.2])]):
    camp.append(upright(part(f"BannerPole{i + 1}", [10, 0.5, 0.5], [x, 5, z], WOOD, "Wood", shape="Cylinder"), x, 5, z))
    camp.append(part(f"Banner{i + 1}", [0.2, 4, 2.5], [x, 7.5, z + 1.4], col, "Fabric"))
for i in range(6):
    a = i / 6 * math.tau
    camp.append(part(f"Log{i + 1}", [3, 0.8, 0.8], [8 + math.cos(a) * 3.5, 0.8, 8 + math.sin(a) * 3.5], WOOD, "Wood",
                     rotation=math.degrees(a)))
camp.append(part("Campfire_Camp", [3, 1, 3], [8, 0.9, 8], [0.9, 0.45, 0.15], "Neon",
                 tags=["Campfire"], attributes={"CampfireId": "Camp", "Zone": "DawnCamp"}))
for i, (x, z, rot) in enumerate([(-22, -18, 20), (22, -16, -25), (-24, 18, 160), (24, 20, 200)]):
    camp.append(part(f"Tent{i + 1}", [8, 6, 10], [x, 3.4, z], CLOTH, "Fabric", class_name="WedgePart", rotation=rot))
camp.append(part("QuestNPC_Ilen", [2, 1, 2], [-8, 0.9, -4], STONE, tags=["QuestNPC"],
                 attributes={"NpcId": "Ilen", "NameKey": "Npc_Ilen"}))
camp.append(part("TrainingArea", [16, 0.3, 12], [-14, 0.55, 12], DIRT, "Ground"))
# Altar para CAMBIAR de afinidad (decisión aprobada: cambio gratis en el campamento).
# La primera elección se hace en el Santuario de las Ruinas de Aelith.
camp.append(part("AffinityAltar", [2, 2, 2], [-14, 1.6, -4], [0.6, 0.5, 1], "Neon", shape="Ball",
                 tags=["AffinityShrine"], attributes={"ChangeOnly": True}))
camp.append(part("AltarBase", [4, 0.6, 4], [-14, 0.7, -4], STONE, "Slate"))
camp.append(part("NoticeBoard", [6, 4, 0.5], [6, 2.4, -14], WOOD, "WoodPlanks"))

path = []
for i in range(9):
    z = -40 - i * 20
    x = math.sin(i * 0.7) * 6
    path.append(part(f"Path{i + 1}", [12, 0.3, 22], [x, 0.25, z], DIRT, "Ground"))

verge = []
verge.append(part("VergeClearing", [110, 0.4, 130], [0, 0.2, -150], GRASS_DARK, "Grass"))
verge.append(zone_volume("EmeraldVerge", [120, 1, 180], [0, 0.5, -140]))
verge.append(part("Campfire_Verge", [3, 1, 3], [10, 0.9, -95], [0.9, 0.45, 0.15], "Neon",
                  tags=["Campfire"], attributes={"CampfireId": "Verge", "Zone": "EmeraldVerge"}))
spawns = [
    ("EnemySpawn_Thornling_L1", [-18, 1, -115], 1, 3),
    ("EnemySpawn_Thornling_L2", [22, 1, -150], 2, 4),
    ("EnemySpawn_Thornling_L3", [-5, 1, -190], 3, 4),
]
# Lanzadores en la Linde (misión 4).
spawns = [(n, p, l, c, "Thornling") for n, p, l, c in spawns]
spawns += [
    ("EnemySpawn_Spitter_L3", [30, 1, -195], 3, 3, "Spitter"),
]
for name, pos, level, count, enemy_id in spawns:
    verge.append(part(name, [4, 1, 4], pos, [1, 0.2, 0.2], tags=["EnemySpawn"],
                      attributes={"EnemyId": enemy_id, "Level": level, "Count": count, "Zone": "EmeraldVerge"}))
# Ruinas pequeñas (futuro Fragmento F01, misión 3)
for i, (x, z, h) in enumerate([(-38, -175, 8), (-30, -182, 5), (-44, -168, 10), (-36, -186, 3)]):
    verge.append(part(f"RuinPillar{i + 1}", [3, h, 3], [x, h / 2 + 0.4, z], STONE, "Slate"))
verge.append(part("QuestMarker_VergeRuins", [2, 2, 2], [-37, 2, -177], [1, 0.85, 0.3], tags=["QuestMarker"],
                  attributes={"MarkerId": "VergeRuins", "Radius": 12}, transparency=1, can_collide=False))
verge.append(part("RuinFloor", [20, 0.5, 20], [-37, 0.45, -177], STONE, "Cobblestone"))

CRYSTAL = [1, 0.85, 0.35]
STONE_DARK = [0.4, 0.4, 0.42]
GRASS_WITHERED = [0.33, 0.36, 0.27]
ROOT_PURPLE = [0.45, 0.2, 0.55]


def fragment(fid, pos):
    return part(f"Fragment_{fid}", [1.2, 2.2, 1.2], pos, CRYSTAL, "Neon", tags=["Fragment"],
                attributes={"FragmentId": fid}, can_collide=False)


def campfire(cid, zone, pos):
    return part(f"Campfire_{cid}", [3, 1, 3], pos, [0.9, 0.45, 0.15], "Neon", tags=["Campfire"],
                attributes={"CampfireId": cid, "Zone": zone})


def spawn(enemy_id, level, count, pos, zone):
    return part(f"EnemySpawn_{enemy_id}_L{level}", [4, 1, 4], pos, [1, 0.2, 0.2], tags=["EnemySpawn"],
                attributes={"EnemyId": enemy_id, "Level": level, "Count": count, "Zone": zone})


# Fragmentos de la Linde (F01 en las ruinas pequeñas: misión 3)
verge += [fragment("F01", [-37, 2, -180]), fragment("F02", [46, 1.8, -118]), fragment("F03", [-50, 1.8, -205])]

# Caminos entre zonas
for i, z in enumerate([-225, -390, -550]):
    path.append(part(f"PathLink{i + 1}", [12, 0.3, 30], [0, 0.25, z], DIRT, "Ground"))

# ---------- ZONA 2: Ruinas de Aelith (niveles 6–12)
ruins = [part("RuinsGround", [110, 0.4, 140], [0, 0.2, -310], STONE_DARK, "Cobblestone"),
         zone_volume("AelithRuins", [120, 1, 160], [0, 0.5, -310]),
         campfire("Ruins", "AelithRuins", [12, 0.9, -248])]
ruins.append(part("Shrine_Plaza", [24, 0.6, 24], [0, 0.6, -315], STONE, "Marble"))
ruins.append(part("AffinityShrine", [3, 3, 3], [0, 3, -315], [0.6, 0.5, 1], "Neon", shape="Ball",
                  tags=["AffinityShrine"]))
ruins.append(part("QuestMarker_Shrine", [2, 2, 2], [0, 4.5, -315], [1, 0.85, 0.3], tags=["QuestMarker"],
                  attributes={"MarkerId": "Shrine", "Radius": 10}, transparency=1, can_collide=False))
for i, (x, z, h, w) in enumerate([(-45, -270, 10, 16), (45, -285, 7, 20), (-48, -345, 12, 14), (46, -360, 6, 18),
                                   (-20, -378, 9, 22), (22, -262, 5, 10)]):
    ruins.append(part(f"RuinWall{i + 1}", [w, h, 2], [x, h / 2 + 0.4, z], STONE, "Slate", rotation=random.uniform(-20, 20)))
for i in range(8):
    a = i / 8 * math.tau
    h = random.choice([4, 7, 10, 12])
    ruins.append(part(f"PlazaPillar{i + 1}", [2.4, h, 2.4], [math.cos(a) * 16, h / 2 + 0.4, -315 + math.sin(a) * 16],
                      STONE, "Marble"))
ruins += [
    spawn("Thornling", 6, 4, [0, 1, -268], "AelithRuins"),
    spawn("Sentry", 7, 2, [-28, 1, -292], "AelithRuins"),
    spawn("Sentry", 9, 3, [28, 1, -345], "AelithRuins"),
    spawn("Spitter", 8, 3, [-30, 1, -362], "AelithRuins"),
    fragment("F04", [-44, 1.8, -300]), fragment("F05", [44, 1.8, -330]), fragment("F06", [-20, 10.5, -378]),
]

# ---------- ZONA 3: Hondonada Marchita (niveles 12–18)
hollow = [part("HollowGround", [110, 0.4, 140], [0, 0.2, -470], GRASS_WITHERED, "Grass"),
          zone_volume("WitheredHollow", [120, 1, 160], [0, 0.5, -470]),
          campfire("Hollow", "WitheredHollow", [-12, 0.9, -408])]
for i in range(14):
    x, z = random.uniform(-48, 48), random.uniform(-530, -410)
    hollow.append(part(f"CorruptRoot{i + 1}", [random.uniform(8, 16), 1.2, 1.2], [x, 0.9, z], ROOT_PURPLE, "Neon",
                       rotation=random.uniform(0, 180)))
for i in range(16):
    x, z = random.uniform(-50, 50), random.uniform(-535, -405)
    hollow.append(upright(part(f"MushroomStem{i + 1}", [1.4, 0.5, 0.5], [x, 0.9, z], [0.85, 0.8, 0.75], "SmoothPlastic",
                               shape="Cylinder", can_collide=False), x, 0.9, z))
    hollow.append(part(f"MushroomCap{i + 1}", [1.6, 0.8, 1.6], [x, 1.7, z], [0.55, 0.3, 0.95], "Neon", shape="Ball",
                       can_collide=False))
hollow.append(part("FallenTree", [40, 3, 3], [-18, 1.8, -470], WOOD, "Wood", rotation=35))
hollow += [
    spawn("Thornling", 12, 4, [-22, 1, -430], "WitheredHollow"),
    spawn("Spitter", 13, 3, [26, 1, -455], "WitheredHollow"),
    spawn("Sentry", 14, 2, [-26, 1, -500], "WitheredHollow"),
    spawn("Thornling", 15, 4, [22, 1, -515], "WitheredHollow"),
    spawn("Spitter", 16, 3, [0, 1, -535], "WitheredHollow"),
    fragment("F07", [-46, 1.8, -448]), fragment("F08", [46, 1.8, -492]), fragment("F09", [-18, 4.5, -470]),
]

# ---------- Corazón del Bosque: arena del jefe (semanas 17–18)
heart = [campfire("Heart", "ForestHeart", [10, 0.9, -566]), zone_volume("ForestHeart", [120, 1, 140], [0, 0.5, -620])]
arena_floor = part("ArenaFloor", [1, 80, 80], [0, 0.5, -615], [0.36, 0.3, 0.25], "Ground", shape="Cylinder")
arena_floor["Properties"].pop("Position")
arena_floor["Properties"]["CFrame"] = {"CFrame": {"position": [0, 0.5, -615], "orientation": [[0, -1, 0], [1, 0, 0], [0, 0, 1]]}}
heart.append(arena_floor)
for i in range(6):
    a = i / 6 * math.tau + 0.3
    heart.append(part(f"ArenaColumn{i + 1}", [5, 18, 5], [math.cos(a) * 26, 9.5, -615 + math.sin(a) * 26], STONE, "Slate",
                      tags=["BossColumn"]))
heart.append(part("BossArena_Vharok", [6, 1, 6], [0, 1, -615], [0.6, 0.1, 0.6], tags=["BossArena"],
                  attributes={"BossId": "Vharok", "Radius": 40}, transparency=1, can_collide=False))
trunk = part("PrimevalTree_Trunk", [60, 16, 16], [0, 30, -668], WOOD, "Wood", shape="Cylinder")
trunk["Properties"].pop("Position")
trunk["Properties"]["CFrame"] = {"CFrame": {"position": [0, 30, -668], "orientation": [[0, -1, 0], [1, 0, 0], [0, 0, 1]]}}
heart.append(trunk)
heart.append(part("PrimevalTree_Crown", [70, 40, 70], [0, 68, -668], [0.35, 0.25, 0.45], "Grass", shape="Ball"))
heart.append(fragment("F10", [0, 2, -652]))

def style_for(z):
    if z < -395:
        return "withered"
    if z < -235:
        return "ruins"
    return "lush"


trees = []
n = 0
for z in range(-30, -560, -12):
    for side in (-1, 1):
        x = side * random.uniform(16, 26)
        if z < -95:
            x = side * random.uniform(52, 59)  # las zonas son más anchas
        n += 1
        trees += tree(f"Tree{n}", x, z, style=style_for(z))
for i in range(10):
    a = i / 10 * math.tau
    n += 1
    trees += tree(f"Tree{n}", math.cos(a) * 42, math.sin(a) * 42)

# Decoración: rocas, arbustos y flores (sin colisión salvo las rocas)
decor = []
FLOWER_COLORS = [[1, 0.85, 0.3], [1, 0.5, 0.6], [0.6, 0.75, 1], [1, 1, 1]]
for i in range(70):
    z = random.uniform(-545, -25)
    side = random.choice((-1, 1))
    x = side * (random.uniform(30, 50) if z < -95 else random.uniform(10, 15))
    decor.append(rock(f"Rock{i + 1}", x, z))
for i in range(90):
    z = random.uniform(-545, 20)
    side = random.choice((-1, 1))
    x = side * (random.uniform(25, 54) if z < -95 else random.uniform(9, 30))
    decor.append(bush(f"Bush{i + 1}", x, z, style=style_for(z)))
for i in range(120):
    z = random.uniform(-230, 25)
    x = random.uniform(-50, 50) if z < -95 else random.choice((-1, 1)) * random.uniform(8, 30)
    decor.append(flower(f"Flower{i + 1}", x, z, random.choice(FLOWER_COLORS)))

walls = []
for name, size, pos in [
    ("WallWest", [2, 60, 740], [-62, 30, -318]),
    ("WallEast", [2, 60, 740], [62, 30, -318]),
    ("WallNorth", [126, 60, 2], [0, 30, -688]),
    ("WallSouth", [126, 40, 2], [0, 20, 52]),
]:
    walls.append(part(name, size, pos, [1, 1, 1], transparency=1))

model = {
    "ClassName": "Model",
    "Children": [
        folder("DawnCamp", camp),
        folder("Path", path),
        folder("EmeraldVerge", verge),
        folder("AelithRuins", ruins),
        folder("WitheredHollow", hollow),
        folder("ForestHeart", heart),
        folder("Trees", trees),
        folder("Decor", decor),
        folder("InvisibleWalls", walls),
    ],
}

with open("map/VerdantiaBlockout.model.json", "w", encoding="utf-8") as f:
    json.dump(model, f, indent=1)
print(f"Blockout generado: {n} árboles")
