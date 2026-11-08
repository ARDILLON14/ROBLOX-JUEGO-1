# Sección 3 — Entrega 3.2 (semanas 3–4) — BORRADOR, pendiente de revisión

> Estado: código escrito y verificado fuera de Studio (Rojo construye, sin errores de tipos, formato correcto). **No probado en Studio.** La guía de pruebas y de creación de animaciones se completará cuando el desarrollador elija cómo trabajar con Studio (Rojo, Claude Code local con MCP, o copiar/pegar).

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Combat.luau` | Reglas globales de combate (combo, esquiva, bloqueo, hitstop) |
| `src/shared/Config/WeaponTypes.luau` | Estadísticas de katana y mandoble + arma provisional (bloque) |
| `src/shared/Config/Animations.luau` | IDs de animaciones (vacíos por ahora; el combate funciona sin ellas) |
| `src/shared/Combat/Hitbox.luau` | Busca personajes en una caja delante del atacante |
| `src/server/Services/WeaponService.luau` | Pone el arma provisional en la mano derecha (visible para todos) |
| `src/client/Controllers/CombatController.luau` | Ligero, combo de 3, pesado, remate, esquiva y bloqueo LOCALES; destello y hitstop al golpear. Aún no hace daño (semana 5) |
| `src/shared/Config/Debug.luau` | Añade `LogCombat` y `StartingWeaponType` |

## [PROPUESTA] nueva
- Velocidad al atacar ×0,4 (`AttackMoveSpeedMultiplier`).
