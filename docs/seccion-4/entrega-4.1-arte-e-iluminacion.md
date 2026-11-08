# Sección 4 — Entrega 4.1 (semana 20)
## Arte del mapa e iluminación + correcciones de la revisión

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## 1. Correcciones (revisión completa del código)
No se recibieron errores de Studio, así que se hizo una revisión estática completa: tipos (luau-lsp), lint, construcción con Rojo, y que todas las claves de texto usadas existan en el CSV. No aparecieron errores de código. Se corrigieron dos problemas de interfaz:
| Problema | Corrección |
|---|---|
| El botón ⚙ (arriba a la izquierda) quedaba encima de la ventana de chat de Roblox | Movido a la derecha, encima del panel de misión |
| El panel de misión podía taparse con la lista de jugadores al haber 12 | Bajado al 40 % de la altura de la pantalla |

⚠️ Los errores que solo aparecen al ejecutar el juego (Output en rojo) **solo se pueden corregir si me los envías**.

## 2. Arte e iluminación (lo que se puede hacer desde el código)
| Archivo | Qué hace |
|---|---|
| `build.project.json` | Iluminación del lugar de prueba: tecnología **Future** (luces y sombras de mejor calidad), hora 14:30, `Atmosphere` (niebla con profundidad), `Bloom` (brillo suave del neón), `ColorCorrection` (colores algo más saturados, estilo anime) y `SunRays` (rayos de sol) |
| `tools/generate_blockout.py` | **Pasada de arte del mapa**: árboles estilizados con 2–3 copas de distinto tono según la zona (verdes vivos en la Linde, apagados en las Ruinas, morados en la Hondonada), 70 rocas, 90 arbustos, 120 flores de colores, setas de neón morado en la Hondonada, estandartes y troncos alrededor de la fogata del campamento. ~790 piezas en total (presupuesto de rendimiento holgado) |
| `src/shared/Config/World.luau` | Ambiente de cada zona: densidad y color de la niebla, tono y saturación |
| `src/client/Controllers/ZoneAmbienceController.luau` | Al entrar en una zona, la niebla y el color cambian suavemente (2,5 s) y aparece su **nombre y rango de niveles** en grande (estilo anime). Usa piezas invisibles con la etiqueta `ZoneVolume` |

### Ambiente por zona
| Zona | Niebla | Sensación |
|---|---|---|
| Campamento del Alba | Ligera, cálida | Refugio seguro |
| Linde Esmeralda | Verde suave | Bosque vivo |
| Ruinas de Aelith | Gris | Antigua, misteriosa |
| Hondonada Marchita | Densa, morada | Corrupción del Éter |
| Corazón del Bosque | Morada | Peligro: jefe |

## 3. Guía: sustituir los bloques por arte real (trabajo tuyo en Studio)
El arte final se hace en Studio (decisión A5). Orden recomendado: **lo que más se ve primero** (árboles del camino, fogatas, Santuario, arena del jefe), después decoración.

### Fuentes gratuitas
| Fuente | Para qué | Cuidado |
|---|---|---|
| **Creator Store / Toolbox** (Studio: **Window → Toolbox**) | Árboles, rocas, ruinas, props | Antes de usar un modelo: despliégalo en el Explorer y **borra cualquier Script/LocalScript que traiga** (pueden ser maliciosos, p. ej., con `require(número)` o `getfenv`). Usa la etiqueta "verificado" cuando exista |
| **IA de 3D con plan gratuito** (Meshy, Tripo u otras) | Objetos sueltos (cofres, estatuas, cristales) | Pide estilo "low poly, stylized, anime". Exporta en FBX u OBJ e impórtalo con **Avatar/Home → Import 3D** [VERIFICAR EN DOCUMENTACIÓN: "3D Importer"]. Revisa el número de triángulos [VERIFICAR: límite de triángulos por malla] |
| **Terreno de Roblox** (**Home → Editor**/Terrain) | Suelo, colinas, agua | Opcional; el suelo de bloques funciona bien con el estilo actual |

### Guía de estilo (para que todo combine)
- Formas simples y redondeadas, pocos detalles pequeños, colores saturados (estilo anime/low poly).
- Materiales: `Grass`, `Wood`, `Slate`, `Marble`, `Neon` solo para cosas mágicas (Éter, cristales, fogatas).
- Paleta: verdes vivos (Linde), grises con musgo (Ruinas), morados y negros (Hondonada/Corazón), dorado para el Alba (Fragmentos, interfaz).

### Reglas para no romper nada
1. **No borres ni renombres** las piezas con etiquetas: `EnemySpawn`, `Campfire`, `Fragment`, `QuestNPC`, `QuestMarker`, `AffinityShrine`, `BossArena`, `BossColumn`, `ZoneVolume`. Puedes moverlas; si sustituyes una por un modelo, copia su etiqueta y sus atributos.
2. Las piezas decorativas sin colisión (`CanCollide = false`) evitan atascos.
3. Presupuesto orientativo: < 5.000 piezas visibles en el mapa para que funcione bien también en móvil más adelante. Comprueba el rendimiento con el MicroProfiler (Ctrl+F6) en la semana 22.
4. Guarda con **File → Publish to Roblox** después de cada sesión de arte.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.14.0`, `[Client] 27 módulo(s)`. Nada en rojo. Al aparecer, sin título de zona (la primera zona se aplica sin aviso) |
| 2 | Mira el mapa | Árboles con varias copas, rocas, arbustos, flores, estandartes; luz más cálida y niebla suave |
| 3 | Camina a la Linde Esmeralda | Aparece "Linde Esmeralda — Nv 1–5" en grande y la niebla cambia a verde suave |
| 4 | Ruinas → Hondonada → Corazón | Cada zona cambia el ambiente; la Hondonada es morada y densa, con setas brillantes |
| 5 | El botón ⚙ | Está a la derecha, encima del panel de misión; no tapa el chat |
| 6 | Rendimiento | Pulsa **Shift+F5** en el juego para ver los FPS [VERIFICAR]; anótalos en cada zona |
