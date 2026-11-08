"""
Uso único (Entrega 3.13): extrae los textos de la tabla TEXTS de src/shared/Config/Strings.luau
y los escribe en src/shared/Localization/Strings.csv (decisión B7: textos en CSV → LocalizationTable).
Desde ahora, los textos se editan directamente en el CSV.
"""
import csv
import re

src = open("src/shared/Config/Strings.luau", encoding="utf-8").read()
start = src.index("local TEXTS")
end = src.index("\n}\n", start)
block = src[start:end]

texts = {}
lang = None
pattern = re.compile(r'^\t\t(\w+) = (".*"|\'.*\'),$')
for line in block.split("\n"):
    m = re.match(r"^\t(\w+) = \{$", line)
    if m:
        lang = m.group(1)
        texts[lang] = {}
        continue
    m = pattern.match(line)
    if m and lang:
        raw = m.group(2)
        value = raw[1:-1]
        value = value.replace('\\"', '"').replace("\\'", "'").replace("\\\\", "\\")
        texts[lang][m.group(1)] = value

keys = list(texts["es"].keys())
missing = [k for k in keys if k not in texts["en"]] + [k for k in texts["en"] if k not in texts["es"]]
assert not missing, f"Claves sin traducción: {missing}"

with open("src/shared/Localization/Strings.csv", "w", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Key", "Source", "Context", "Example", "es", "en"])
    for key in keys:
        writer.writerow([key, texts["en"][key], "", "", texts["es"][key], texts["en"][key]])
print(f"{len(keys)} textos exportados")

# Nota: este script ya se ejecutó. Strings.luau ahora lee el CSV; los textos nuevos se añaden en el CSV.
