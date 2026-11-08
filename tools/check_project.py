"""
Comprobaciones de coherencia del proyecto (sin Roblox). Uso: python3 tools/check_project.py
Falla (código 1) si encuentra un problema. Lo ejecuta GitHub Actions en cada subida.
  1. Todas las claves de texto usadas en el código existen en el CSV, con español e inglés.
  2. Las misiones apuntan a enemigos/jefes que existen.
  3. Las armas del orden de inventario existen.
  4. El mapa provisional contiene las etiquetas que el código necesita.
"""
import csv
import glob
import json
import re
import sys

problems = []

# 1. Textos
rows = list(csv.DictReader(open("src/shared/Localization/Strings.csv", encoding="utf-8")))
keys = {r["Key"] for r in rows}
for r in rows:
    if not r["es"].strip() or not r["en"].strip():
        problems.append(f"Texto sin traducir: {r['Key']}")
seen = set()
for r in rows:
    if r["Key"] in seen:
        problems.append(f"Clave de texto repetida: {r['Key']}")
    seen.add(r["Key"])

used = set()
patterns = [
    r'Strings\.get\("(\w+)"',
    r'(?:NameKey|ObjectiveKey|LoreKey|DialogStartKey|DialogActiveKey|DialogDoneKey|DialogLockedKey|SkillNameKey|UltimateNameKey|textKey|nameKey)\s*=\s*"(\w+)"',
]
for path in glob.glob("src/**/*.luau", recursive=True):
    if "Packages" in path:
        continue
    text = open(path, encoding="utf-8").read()
    for pattern in patterns:
        used |= set(re.findall(pattern, text))
used.discard("Clave")  # ejemplo en un comentario
for key in sorted(used - keys):
    problems.append(f"Clave de texto usada pero inexistente en el CSV: {key}")

# 2. Misiones → enemigos
enemies_src = open("src/shared/Config/Enemies.luau", encoding="utf-8").read()
bosses_src = open("src/shared/Config/Bosses.luau", encoding="utf-8").read()
enemy_ids = set(re.findall(r"^\t(\w+) = \{", enemies_src, re.M)) | set(re.findall(r"^\t(\w+) = \{", bosses_src, re.M))
quests_src = open("src/shared/Config/Quests.luau", encoding="utf-8").read()
for target in re.findall(r'Target = "(\w+)"', quests_src):
    if target not in enemy_ids:
        problems.append(f"Una misión apunta a un enemigo inexistente: {target}")
order = re.search(r"Order = \{([^}]*)\}", quests_src).group(1)
for quest_id in re.findall(r'"(\w+)"', order):
    if not re.search(rf"^\t{quest_id} = \{{", quests_src, re.M):
        problems.append(f"Misión en Order sin definir: {quest_id}")

# 3. Armas
weapons_src = open("src/shared/Config/Weapons.luau", encoding="utf-8").read()
defined = set(re.findall(r"^\t(\w+) = \{ Type", weapons_src, re.M))
display = re.search(r"local DisplayOrder = \{([^}]*)\}", weapons_src).group(1)
for weapon_id in re.findall(r'"(\w+)"', display):
    if weapon_id not in defined:
        problems.append(f"Arma en DisplayOrder sin definir: {weapon_id}")

# 4. Etiquetas del mapa provisional
blockout = json.load(open("map/VerdantiaBlockout.model.json", encoding="utf-8"))
tags = {}


def walk(node):
    for tag in node.get("Properties", {}).get("Tags", []):
        tags[tag] = tags.get(tag, 0) + 1
    for child in node.get("Children", []):
        walk(child)


walk(blockout)
expected = {"EnemySpawn": 13, "Campfire": 5, "Fragment": 10, "QuestNPC": 1, "QuestMarker": 2,
            "AffinityShrine": 2, "BossArena": 1, "BossColumn": 6, "ZoneVolume": 5}
for tag, count in expected.items():
    if tags.get(tag, 0) != count:
        problems.append(f"Mapa: se esperaban {count} piezas con la etiqueta {tag} y hay {tags.get(tag, 0)}")

if problems:
    print("PROBLEMAS ENCONTRADOS:")
    for p in problems:
        print(" -", p)
    sys.exit(1)
print(f"OK: {len(keys)} textos, {len(used)} claves usadas, {len(enemy_ids)} enemigos/jefes, "
      f"{len(defined)} armas, etiquetas del mapa correctas")
