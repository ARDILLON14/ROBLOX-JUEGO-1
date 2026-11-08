# Sección 3 — Entrega 3.6 (semana 8) — 🎯 HITO 1: SLICE VERTICAL
## Campamento + Linde Esmeralda en bloques, misiones 1–2, NPC, pociones y HUD básico

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `map/VerdantiaBlockout.model.json` (+ `tools/generate_blockout.py`) | **Mapa provisional en bloques**: Campamento del Alba (tiendas, fogata, zona de entrenamiento, tablón, punto para la Maestra Ilen), camino al norte, Linde Esmeralda (claro, fogata, 3 grupos de Brotespinas de nivel 1, 2 y 3, ruinas pequeñas), 42 árboles y muros invisibles. Solo va en el lugar de prueba `builds/ECLIPSE-dev.rbxl`: a partir de ahí **el mapa vive en Studio** (decisión A5) y lo puedes editar libremente |
| `src/shared/Config/Quests.luau` | Misiones Q01 "Despertar del Explorador" (golpear 5 veces al muñeco) y Q02 "Raíces Inquietas" (derrotar 6 Brotespinas) con diálogos ES/EN |
| `src/server/Services/NpcService.luau` | Crea la **Maestra Ilen** desde la pieza con etiqueta `QuestNPC`; aviso "Pulsa E" para hablar |
| `src/server/Services/QuestService.luau` | Aceptar, progresar y entregar misiones; recompensas de XP y pociones; avisos al cliente |
| `src/server/Services/InventoryService.luau` | **Pociones** (tecla 1): curan 40 %, enfriamiento 10 s, máximo 10 |
| `src/server/Services/EnemyService.luau` | Avisa de cada enemigo derrotado y de quién contribuyó (para las misiones) |
| `src/client/Controllers/HudController.luau` | **HUD básico**: vida y XP con nivel (abajo), pociones y esquiva con enfriamiento (abajo izquierda), misión activa (derecha), avisos (arriba). Oculta la barra de vida de Roblox |
| `src/client/Controllers/DialogueController.luau` | Caja de diálogo con nombre del NPC y botón "Continuar" (libera el ratón mientras está abierta) |
| `src/client/Controllers/NpcVisualController.luau` | Nombre del NPC en tu idioma y marca **"!"** (misión disponible) o **"?"** (para entregar) |
| `src/client/Controllers/InventoryController.luau` | Tecla 1 → pedir usar poción al servidor |
| `src/shared/Config/Items.luau` / `Strings.luau` | Poción de Savia y todos los textos nuevos ES/EN |
| `src/server/Data/DataTemplate.luau` | Nuevo campo `Quests.Status` (los datos existentes lo reciben solos; no hace falta migración) |
| Borrado | `DebugHudController.luau` (sustituido por el HUD) |

[PENDIENTE] Cuando se añada la misión Q03, los jugadores que ya terminaron Q02 necesitarán una pequeña migración para recibirla.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.6.0`, 3 puntos de aparición de Thornling (niveles 1, 2, 3), `[Server] 9 módulo(s)`, `[Client] 12 módulo(s)`. Nada en rojo |
| 2 | Mira alrededor | Campamento con tiendas, fogata, árboles; Maestra Ilen con un **"!"** dorado encima; muñeco en la zona de entrenamiento |
| 3 | HUD | Abajo: barra de vida roja "100 / 100" y barra de XP "Nv 1 · 0/100 XP". Abajo-izq.: "Pociones x0 [1]" y "Esquiva [Q]". Derecha: "Misión: Despertar del Explorador — Habla con Maestra Ilen" |
| 4 | Acércate a Ilen y pulsa **E** | Caja de diálogo con su texto; el cursor queda libre. "Continuar" la cierra. El objetivo pasa a "Golpea al muñeco (0/5)" |
| 5 | Golpea al muñeco 5 veces | El contador sube; al llegar a 5: aviso arriba "¡Objetivo cumplido! Vuelve con Maestra Ilen"; marca **"?"** sobre Ilen |
| 6 | Habla con Ilen | Diálogo de despedida, aviso "Misión completada", +60 XP y +1 poción. Nueva misión: "Raíces Inquietas" con "!" |
| 7 | Acepta Q02 y sigue el camino al norte | Llegas a la Linde Esmeralda (claro grande) con grupos de Brotespinas |
| 8 | Pulsa **Q** | "Esquiva" se ve gris con la cuenta atrás y vuelve a blanco |
| 9 | Recibe daño y pulsa **1** | Número verde "+40" y la vida sube; las pociones bajan en 1. Con la vida llena no se gasta |
| 10 | Derrota 6 Brotespinas | "(6/6)" → vuelve con Ilen → completa Q02: +120 XP y +2 pociones. Después: "Más misiones muy pronto…" |
| 11 | Intenta salir de la zona | Muros invisibles en los bordes |

### Prueba con amigos (criterio del HITO 1, Entrega 2C)
Publica el lugar (**File → Publish to Roblox**), configura el acceso (Creator Hub → tu experiencia → acceso de amigos/privado) [VERIFICAR EN DOCUMENTACIÓN: "experience access settings"] e invita a 2–4 amigos. El hito se cumple si un amigo:
1. Entiende los controles sin ayuda en menos de 2 minutos.
2. Derrota Brotespinas y sube de nivel.
3. Sale y al volver conserva su progreso (requiere el acceso a API de la Entrega 3.4).
4. No aparecen errores rojos en la consola.

Pregunta a cada amigo: ¿qué fue lo más divertido?, ¿qué fue confuso?, ¿volverías a jugar?
