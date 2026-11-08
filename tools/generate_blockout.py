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


def tree(name, x, z, height=None):
    h = height or random.uniform(14, 22)
    trunk = part(f"{name}_Trunk", [h, 2.2, 2.2], [x, h / 2, z], WOOD, "Wood", shape="Cylinder")
    # Cilindro acostado en X: se gira 90° en Z para ponerlo de pie
    trunk["Properties"].pop("Position")
    trunk["Properties"]["CFrame"] = {"CFrame": {"position": [x, h / 2, z], "orientation": [[0, -1, 0], [1, 0, 0], [0, 0, 1]]}}
    r = random.uniform(9, 13)
    leaves = part(f"{name}_Leaves", [r, r, r], [x, h + r * 0.25, z], LEAF, "Grass", shape="Ball")
    return [trunk, leaves]


camp = []
camp.append(part("CampGround", [70, 0.4, 70], [0, 0.2, 0], GRASS, "Grass"))
camp.append(part("Campfire_Camp", [3, 1, 3], [8, 0.9, 8], [0.9, 0.45, 0.15], "Neon",
                 tags=["Campfire"], attributes={"CampfireId": "Camp", "Zone": "DawnCamp"}))
for i, (x, z, rot) in enumerate([(-22, -18, 20), (22, -16, -25), (-24, 18, 160), (24, 20, 200)]):
    camp.append(part(f"Tent{i + 1}", [8, 6, 10], [x, 3.4, z], CLOTH, "Fabric", class_name="WedgePart", rotation=rot))
camp.append(part("QuestNPC_Ilen", [2, 1, 2], [-8, 0.9, -4], STONE, tags=["QuestNPC"],
                 attributes={"NpcId": "Ilen", "NameKey": "Npc_Ilen"}))
camp.append(part("TrainingArea", [16, 0.3, 12], [-14, 0.55, 12], DIRT, "Ground"))
camp.append(part("AffinityShrine", [3, 3, 3], [14, 1.9, -6], [0.6, 0.5, 1], "Neon", shape="Ball",
                 tags=["AffinityShrine"]))  # provisional: se moverá a las Ruinas de Aelith
camp.append(part("ShrineBase", [5, 0.6, 5], [14, 0.7, -6], STONE, "Slate"))
camp.append(part("NoticeBoard", [6, 4, 0.5], [6, 2.4, -14], WOOD, "WoodPlanks"))

path = []
for i in range(9):
    z = -40 - i * 20
    x = math.sin(i * 0.7) * 6
    path.append(part(f"Path{i + 1}", [12, 0.3, 22], [x, 0.25, z], DIRT, "Ground"))

verge = []
verge.append(part("VergeClearing", [110, 0.4, 130], [0, 0.2, -150], GRASS_DARK, "Grass"))
verge.append(part("Campfire_Verge", [3, 1, 3], [10, 0.9, -95], [0.9, 0.45, 0.15], "Neon",
                  tags=["Campfire"], attributes={"CampfireId": "Verge", "Zone": "EmeraldVerge"}))
spawns = [
    ("EnemySpawn_Thornling_L1", [-18, 1, -115], 1, 3),
    ("EnemySpawn_Thornling_L2", [22, 1, -150], 2, 4),
    ("EnemySpawn_Thornling_L3", [-5, 1, -190], 3, 4),
]
for name, pos, level, count in spawns:
    verge.append(part(name, [4, 1, 4], pos, [1, 0.2, 0.2], tags=["EnemySpawn"],
                      attributes={"EnemyId": "Thornling", "Level": level, "Count": count, "Zone": "EmeraldVerge"}))
# Ruinas pequeñas (futuro Fragmento F01, misión 3)
for i, (x, z, h) in enumerate([(-38, -175, 8), (-30, -182, 5), (-44, -168, 10), (-36, -186, 3)]):
    verge.append(part(f"RuinPillar{i + 1}", [3, h, 3], [x, h / 2 + 0.4, z], STONE, "Slate"))
verge.append(part("RuinFloor", [20, 0.5, 20], [-37, 0.45, -177], STONE, "Cobblestone"))

trees = []
n = 0
for z in range(-30, -215, -12):
    for side in (-1, 1):
        x = side * random.uniform(16, 26)
        if -200 < z < -95:
            x = side * random.uniform(48, 58)  # el claro es más ancho
        n += 1
        trees += tree(f"Tree{n}", x, z)
for i in range(10):
    a = i / 10 * math.tau
    n += 1
    trees += tree(f"Tree{n}", math.cos(a) * 42, math.sin(a) * 42)

walls = []
for name, size, pos in [
    ("WallWest", [2, 40, 300], [-62, 20, -90]),
    ("WallEast", [2, 40, 300], [62, 20, -90]),
    ("WallNorth", [126, 40, 2], [0, 20, -232]),
    ("WallSouth", [126, 40, 2], [0, 20, 52]),
]:
    walls.append(part(name, size, pos, [1, 1, 1], transparency=1))

model = {
    "ClassName": "Model",
    "Children": [
        folder("DawnCamp", camp),
        folder("Path", path),
        folder("EmeraldVerge", verge),
        folder("Trees", trees),
        folder("InvisibleWalls", walls),
    ],
}

with open("map/VerdantiaBlockout.model.json", "w", encoding="utf-8") as f:
    json.dump(model, f, indent=1)
print(f"Blockout generado: {n} árboles")
