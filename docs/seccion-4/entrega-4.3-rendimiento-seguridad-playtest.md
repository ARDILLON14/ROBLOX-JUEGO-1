# Sección 4 — Entrega 4.3 (semana 22) — 🎯 preparación del HITO 2 (prueba pública)
## Rendimiento, seguridad y lista para la prueba pública

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## 1. Seguridad
| Archivo | Qué hace |
|---|---|
| `src/server/Services/AntiCheatService.luau` | **Velocidad y teletransporte** (pendiente de la Entrega 2B): cada 0,5 s compara la distancia horizontal recorrida con la máxima posible (caminar + esquiva/Paso Relámpago). Si se supera dos veces seguidas, el jugador vuelve a su última posición válida y se registra un aviso `[AntiCheat]` |
| `src/server/Services/ZoneService.luau` | Avisa al anticheat antes de sus teletransportes legítimos (viaje rápido, reaparición) |
| `src/shared/Net.luau` | Si un mensaje con datos extraños provoca un error, se registra y no afecta a nada más |
| `src/shared/Config/Debug.luau` | **Los trucos de prueba solo funcionan en Studio.** En el juego publicado se usan automáticamente los valores normales: es imposible publicar con armas gratis o XP extra por olvido |
| `src/server/Services/BossService.luau` | Limpia los datos de los jugadores que salen (memoria) |

### Revisión de seguridad completa
| Riesgo | Estado |
|---|---|
| Daño, XP, objetos o recompensas falsos | ✅ El cliente nunca los envía; los calcula el servidor |
| Atacar o usar habilidades más rápido | ✅ Intervalos y enfriamientos con el reloj del servidor + límites por segundo |
| Golpear desde lejos | ✅ Hitbox en el servidor. Combinado con el anticheat de teletransporte, un tramposo no puede pegarse a los enemigos desde lejos |
| Velocidad / teletransporte | ✅ Nuevo AntiCheatService [SUPUESTO: tolerancias por calibrar en la prueba pública] |
| Equipar objetos que no tienes | ✅ Se comprueba en el servidor |
| Saturar el servidor con mensajes | ✅ Límite por segundo en cada mensaje |
| Duplicar objetos / perder datos | ✅ ProfileStore con bloqueo de sesión |
| Cambiar atributos del personaje (arma, título) desde el cliente | ✅ Los cambios del cliente no llegan al servidor; el servidor solo lee los suyos |
| Volar | ⚠️ No se controla en la v1 (ventaja pequeña: no hay PvP ni recompensas por altura). [PROPUESTA] Revisarlo tras la prueba pública si se ve abuso |

## 2. Rendimiento
| Archivo | Qué hace |
|---|---|
| `src/client/Controllers/PerfOverlayController.luau` | **Panel F7**: FPS, FPS del servidor, ping, memoria, enemigos activos y piezas del mapa |
| `src/server/Services/ServerStatsService.luau` | Publica los FPS del servidor para el panel |

Medidas ya activas desde entregas anteriores: enemigos que "duermen" sin jugadores cerca, número fijo de enemigos por punto de aparición (tope por zona), efectos visuales solo en el cliente, calidad "Baja" en Ajustes, números de daño ajenos pequeños y agrupados, actualizaciones de la barra del jefe limitadas a 4 por segundo.

### Cómo medir (en Studio)
1. **Test → Clients and Servers → 2 Players → Start** (o más, si tu PC aguanta).
2. En cada ventana pulsa **F7** y recorre las 5 zonas. Anota FPS y FPS del servidor.
3. Para ver qué consume más: **Ctrl+F6** abre el MicroProfiler [VERIFICAR EN DOCUMENTACIÓN: "MicroProfiler"].
| Indicador | Bien | Revisar |
|---|---|---|
| FPS (tu PC) | ≥ 50 | < 30 |
| FPS del servidor | ≈ 60 | < 45 |
| Memoria | < 1.500 MB | > 2.500 MB |

## 3. Lista para la prueba pública (HITO 2, semana 22)
**Antes de publicar**
1. Prueba completa en Studio sin texto rojo en Output (lo más importante).
2. **File → Publish to Roblox** en tu lugar de desarrollo.
3. **Home → Game Settings → Security → Enable Studio Access to API Services** (guardado real). [VERIFICAR]
4. Avatar R15 en **Game Settings → Avatar**.
5. Jugadores por servidor = **12** (Creator Hub → tu experiencia → Places → Configure → Server Size). [VERIFICAR EN DOCUMENTACIÓN: "Max players"]
6. Completa el **cuestionario de madurez** (Creator Hub → tu experiencia → Audience / Maturity) [VERIFICAR]: violencia fantasiosa leve, sin sangre.
7. Acceso: público o por invitación (Creator Hub → Access/Privacy) [VERIFICAR EN DOCUMENTACIÓN: "experience access settings"].

**Durante la prueba (10+ personas que no conozcan el juego)**
- Pide que jueguen al menos 15 minutos sin ayuda.
- Si algo falla: captura con **F7** abierto y otra de la consola **F9** (Developer Console: los jugadores ven sus errores; tú, como dueño, también los del servidor).
- Preguntas (formulario gratuito, p. ej., Google Forms):
  1. ¿Entendiste los controles sin ayuda? ¿Cuánto tardaste?
  2. ¿Qué fue lo más divertido? ¿Y lo más aburrido o confuso?
  3. ¿El combate se siente bien? (1–5)
  4. ¿Hasta qué misión llegaste? ¿Por qué paraste?
  5. ¿Volverías a jugar mañana?
  6. ¿Tuviste lag? (captura F7)

**Criterio del HITO 2 (Entrega 2C):** 10+ desconocidos juegan, recoges sus respuestas, no hay pérdida de datos ni errores graves.

---

## Pruebas de esta entrega
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.16.0`, `[Server] 15 módulo(s)`, `[Client] 30 módulo(s)`. Nada en rojo |
| 2 | Pulsa **F7** | Panel verde abajo con FPS, servidor, ping, memoria, enemigos y piezas |
| 3 | Esquiva y usa el Paso Relámpago varias veces seguidas | **No** te devuelve atrás (si te devuelve, dímelo: la tolerancia es demasiado estricta) |
| 4 | Viaja con una fogata / muere y reaparece | No aparece ningún aviso `[AntiCheat]` |
| 5 | Prueba de trampa (solo Studio): en la barra de comandos del **cliente** (vista de cliente en Test) ejecuta `game.Players.LocalPlayer.Character:PivotTo(CFrame.new(0, 5, -300))` | Aviso `[AntiCheat]` en la salida del servidor y vuelves a donde estabas en ~1 s |
| 6 | En Studio con `GiveAllWeapons` | Tienes todas las armas (en el juego publicado, no) |
