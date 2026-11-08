# Sección 4 — Entrega 4.2 (semana 21)
## Efectos visuales, sonido y "sensación" del combate

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/client/Controllers/GameFeelController.luau` | **Sacudida de cámara** (críticos, Resonancia, daño recibido, rugido del jefe); **destello rojo** en los bordes al recibir daño; **partículas de impacto** del color del golpe; **estela del arma** en cada golpe (visible para todos); **ráfaga de hojas** al caer un enemigo; sonidos de impacto/bloqueo/curación/daño |
| `src/client/Controllers/SoundController.luau` | Reproduce sonidos por clave (en 3D desde una pieza o "de interfaz"), siempre con el volumen de Ajustes; sonidos de avisos (misión completada, Fragmento, fogata, arma nueva) |
| `src/shared/Config/Sounds.luau` | **20 huecos de sonido** con nombre. 4 ya tienen sonidos incluidos con Roblox (provisionales): golpe ligero, golpe pesado, equipar arma, misión completada |
| `src/server/Services/CombatService.luau` | Marca cada golpe en el personaje (`SwingId`, `SwingDuration`) para que todos vean la estela |
| Combat / EnemyVisual / AbilityVfx / BossBar / LevelUp | Llaman al sistema de sonido: golpes, esquiva, aviso de ataque enemigo, habilidades, Resonancia, rugido del jefe (con sacudida), subida de nivel |

### Calidad de efectos "Baja" (Ajustes)
Un tercio de las partículas y sin partículas ni estelas de otros jugadores (rendimiento con 12 jugadores).

## Cómo añadir los sonidos (trabajo tuyo, ~1 sesión)
1. En Studio: **Window → Toolbox** → pestaña **Audio** (o el Creator Store en la web). Filtra por gratuitos / de Roblox.
2. Escucha y elige un sonido para cada clave de `src/shared/Config/Sounds.luau`.
3. Copia su ID y pégalo como `"rbxassetid://NUMERO"`.

| Clave | Qué buscar |
|---|---|
| `Hit` / `CritHit` | "sword hit", "impact", "slash hit" (el crítico, más grave) |
| `Block` / `PerfectBlock` | "metal clang", "parry", "shield block" / un "ting" agudo |
| `Dodge` | "whoosh", "dash" |
| `Hurt` | "hit grunt" corto (sin gritos fuertes: público 13+) |
| `Telegraph` | "warning", "charge up" corto |
| `EnemyDeath` | "leaves rustle", "wood break" |
| `AbilityFire` / `AbilityLightning` / `Resonance` | "fire whoosh" / "electric zap" / "magic explosion" |
| `BossRoar` | "monster roar", "creature growl" |
| `LevelUp` / `FragmentFound` / `Campfire` / `Potion` | "level up chime" / "magic sparkle" / "fire crackle" / "drink", "heal" |

[VERIFICAR EN STUDIO] Los sonidos `rbxasset://sounds/...` vienen con Roblox. Si alguno no suena o da error en Output, deja ese hueco vacío (`""`) o pon uno del Toolbox.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.15.0`, `[Client] 29 módulo(s)`. Nada en rojo |
| 2 | Ataca al aire | Estela de la hoja durante el golpe; sonido de espada (ligero y pesado distintos) |
| 3 | Golpea al muñeco | Partículas blancas en el impacto; los críticos: partículas amarillas y una pequeña sacudida |
| 4 | Recibe daño de un enemigo | Bordes rojos un instante y sacudida |
| 5 | Derrota un Brotespina | Ráfaga de partículas del color de su cabeza |
| 6 | Cambia de arma en el inventario | Sonido de desenvainar |
| 7 | Completa una misión | Sonido de aviso |
| 8 | Jefe a fase 2 | Sacudida fuerte de ~1 s |
| 9 | 2 jugadores | Ves la estela del arma del otro jugador cuando ataca |
| 10 | Ajustes → Calidad Baja | Menos partículas; no ves estelas ni partículas del otro jugador |
| 11 | Ajustes → Volumen 0 % | No suena nada del juego |
