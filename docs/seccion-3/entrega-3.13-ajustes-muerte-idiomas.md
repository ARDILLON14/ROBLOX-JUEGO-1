# Sección 3 — Entrega 3.13 (semana 19) — última de la Sección 3
## Ajustes, pantalla de muerte y textos en CSV (LocalizationTable)

Comprobado fuera de Studio: Rojo construye (el CSV se convierte en una LocalizationTable con todos los textos), sin errores de tipos en nuestro código, formato correcto; todas las claves de texto usadas por el código existen en el CSV. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Localization/Strings.csv` | **Los 174 textos del juego** en español e inglés (decisión B7). Rojo lo convierte en una LocalizationTable |
| `src/shared/Config/Strings.luau` | Reescrito: lee la LocalizationTable al arrancar; idioma de la cuenta de Roblox o el elegido en Ajustes |
| `tools/strings_to_csv.py` | Script de uso único que pasó los textos al CSV |
| `src/server/Services/SettingsService.luau` | `RequestUpdateSettings`: guarda solo campos conocidos con valores válidos |
| `src/client/Controllers/SettingsController.luau` | Aplica los ajustes: idioma, volumen (grupo de sonido "Effects"), etc. |
| `src/client/Controllers/SettingsUiController.luau` | **Ajustes** con la tecla **P** o el botón ⚙ (arriba a la izquierda) |
| `src/client/Controllers/DeathController.luau` | **Pantalla de muerte**: "Has caído", dónde reapareces y "No pierdes experiencia ni objetos" |
| Feedback / AbilityVfx / CosmeticVisual / LevelUp | Respetan los ajustes (números de otros, calidad de efectos, volumen) |
| `src/server/Data/DataTemplate.luau` | Nuevos ajustes `EffectsVolume` y `EffectsQuality` (los datos existentes los reciben solos) |

### Ajustes disponibles
| Ajuste | Valores | Efecto |
|---|---|---|
| Idioma | Automático / Español / English | Cambia los textos que se generan desde ese momento; algunos paneles se actualizan al volver a entrar |
| Volumen de efectos | 0 %, 25 %, 50 %, 80 %, 100 % | Volumen de los sonidos del juego |
| Números de daño de otros jugadores | Sí / No | Ajuste aprobado para 12 jugadores |
| Calidad de efectos | Alta / Baja | Baja: no se dibujan los efectos de habilidades de otros y las auras tienen menos partículas |

**[PROPUESTA] Sensibilidad de la cámara:** el GDD la incluía en Ajustes, pero Roblox no permite que un juego cambie la sensibilidad del ratón; el jugador la ajusta en el menú de Roblox (Esc → Configuración). La pantalla de Ajustes lo indica. [VERIFICAR EN DOCUMENTACIÓN: "UserGameSettings MouseSensitivity"]

**[PROPUESTA] Cambio de idioma en caliente:** reconstruir todas las pantallas al cambiar de idioma añadiría bastante complejidad; propongo que los paneles ya creados se actualicen al volver a entrar (la pantalla lo avisa).

**Cómo editar textos desde ahora:** abre `src/shared/Localization/Strings.csv` (VS Code o una hoja de cálculo), cambia la columna `es` o `en`, guarda. Para un texto nuevo, añade una fila con una clave nueva y úsala con `Strings.get("Clave")`.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.13.0`, `[Server] 13 módulo(s)`, `[Client] 26 módulo(s)`. Nada en rojo y **ningún** aviso "No se encontró la LocalizationTable" |
| 2 | Mira el HUD y habla con Ilen | Todos los textos aparecen en tu idioma (no aparecen claves como `Quest_Q01_Name`) |
| 3 | Pulsa **P** (o el botón ⚙) | Panel de Ajustes con 4 opciones; cursor libre |
| 4 | Cambia Idioma a "English" y habla con Ilen | El diálogo sale en inglés |
| 5 | Pon "Números de daño de otros jugadores: No" (prueba con 2 jugadores) | Ya no ves los números del otro jugador; los tuyos sí |
| 6 | Calidad de efectos: Baja (2 jugadores) | No ves los efectos de habilidades del otro jugador |
| 7 | Volumen: 0 % y sube de nivel (si pusiste un ID de sonido en `Sounds.luau`) | No suena |
| 8 | Muere | Pantalla oscura: "Has caído — Reapareciendo en {tu fogata}… — No pierdes experiencia ni objetos"; desaparece al reaparecer |
| 9 | Con guardado real: Stop y Play | Los ajustes se conservan |
