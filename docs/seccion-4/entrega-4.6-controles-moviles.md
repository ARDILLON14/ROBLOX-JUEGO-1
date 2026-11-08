# Sección 4 — Entrega 4.6 (colchón, semanas 26–28)
## Controles táctiles para móvil (primera actualización del GDD §11, adelantada)

**Por qué ahora:** las semanas 26–28 son colchón del plan; mientras llegan los resultados de las pruebas en Studio, se adelanta la primera actualización aprobada. **En PC no cambia nada.** La página del juego debe seguir en "solo PC" hasta probarlo en móvil.

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio ni en un móvil.** Versión: `1.0.0-rc2`.

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Util/Platform.luau` | Detecta pantalla táctil sin teclado |
| `src/client/Controllers/TouchControlsController.luau` | **Botones táctiles** que disparan las mismas acciones que el teclado (el combate no cambia): Atacar (grande), Pesado, Esquivar, Bloquear (mantener), Habilidad (con el color de tu afinidad), **Ulti solo visible cuando está cargada** (GDD §4.1), Poción, Bolsa (inventario) y Diario |
| `src/client/Controllers/HudController.luau` | En móvil, la información de la izquierda sube para no quedar bajo el joystick y las barras se estrechan |
| `src/client/Controllers/CameraController.luau` | En móvil no intenta bloquear el ratón |
| `Strings.csv` | Nombres de los botones (ES/EN) |

Movimiento y salto: los controles táctiles propios de Roblox (joystick a la izquierda, salto abajo a la derecha). Los botones de combate se colocan a la izquierda del botón de salto.

## Pruebas (en Studio, sin móvil)
1. Pestaña **Test** → **Device** (emulador de dispositivos) → elige un teléfono (p. ej., iPhone o Android) [VERIFICAR EN DOCUMENTACIÓN: "Device emulator"].
2. Play.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play en el emulador | Joystick y salto de Roblox + botones redondos a la derecha; Bolsa y Diario arriba a la derecha |
| 2 | Play en PC normal | **No** aparece ningún botón táctil (todo igual que antes) |
| 3 | Pulsa Atacar repetidamente | Combo como con el clic |
| 4 | Mantén Bloquear | Bloqueas mientras lo mantienes |
| 5 | Sin afinidad | No aparecen Habilidad ni Ulti |
| 6 | Con afinidad en rango 3 y la ulti cargada | Aparece el botón ULTI |
| 7 | Gira la cámara deslizando en la mitad derecha | La cámara gira y el personaje mira hacia ella |
| 8 | Comprueba que nada se solapa | Botones, barras de vida/XP, misión y textos de la izquierda visibles a la vez |

Si algo se solapa en tu teléfono, dime el modelo y lo ajusto (las posiciones están en `TouchControlsController.luau`).
