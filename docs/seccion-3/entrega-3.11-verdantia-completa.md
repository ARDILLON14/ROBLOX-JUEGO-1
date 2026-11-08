# Sección 3 — Entrega 3.11 (semanas 15–16)
## Verdantia completa en bloques, fogatas, viaje rápido, 10 Fragmentos y Diario

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## El mapa (de sur a norte, ~700 studs)
| Zona | Niveles | Qué hay |
|---|---|---|
| Campamento del Alba | — | Ilen, muñeco, fogata, **altar para cambiar de afinidad** |
| Linde Esmeralda | 1–5 | Brotespinas, Lanzadores, ruinas pequeñas, fogata, Fragmentos F01–F03 |
| **Ruinas de Aelith** (nueva) | 6–12 | Plaza con el **Santuario de afinidad**, muros y pilares, Centinelas, Brotespinas y Lanzadores, fogata, F04–F06 |
| **Hondonada Marchita** (nueva) | 12–18 | Suelo marchito, raíces corruptas moradas, árbol caído, los 3 enemigos en niveles altos, fogata, F07–F09 |
| **Corazón del Bosque** (nueva) | Jefe | Fogata, arena circular con 6 columnas, Árbol Primigenio, F10. La arena tiene la etiqueta `BossArena` lista para el jefe (semanas 17–18) |

Resuelve dos ubicaciones provisionales: el **Santuario** y los **Centinelas** ya están en las Ruinas de Aelith.
Para respetar la decisión aprobada ("cambio de afinidad gratis en el campamento"), el campamento tiene un **altar** que solo sirve para *cambiar* de afinidad (la primera elección es en el Santuario).

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `tools/generate_blockout.py` / `map/VerdantiaBlockout.model.json` | Las 3 zonas nuevas, caminos, 100 árboles, muros más largos |
| `src/shared/Config/World.luau` | Fogatas (5) y Fragmentos (10) como datos; 100 XP por Fragmento |
| `src/server/Services/ZoneService.luau` | **Fogatas**: descubrir, punto de reaparición, curación y viaje rápido. **Reaparición** junto a tu última fogata. **Viaje rápido** solo si no recibiste daño en 8 s. **Fragmentos**: guardar, XP y su historia |
| `src/server/Services/CombatService.luau` | Recuerda cuándo te dañaron por última vez (para el viaje rápido) |
| `src/server/Services/AffinityService.luau` | Santuarios con `ChangeOnly` (el altar del campamento) |
| `src/client/Controllers/CampfireUiController.luau` | Lista de fogatas descubiertas para viajar |
| `src/client/Controllers/FragmentController.luau` | Oculta los Fragmentos que ya recogiste (solo para ti) y anima los que faltan |
| `src/client/Controllers/JournalUiController.luau` | **Diario (J)**: misiones (✓ completadas, ► activa, ??? futuras) y Fragmentos con su historia |
| `src/shared/Config/Strings.luau` | Nombres de fogatas, 10 textos de historia y textos nuevos (ES/EN) |

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
Para ir rápido: `DummyXPPerHit = 500`; vuelve a 0 al terminar.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.11.0`, 13 puntos de aparición (4 en la Linde, 4 en las Ruinas, 5 en la Hondonada), `[Server] 11 módulo(s)`, `[Client] 21 módulo(s)`. Nada en rojo |
| 2 | Camina hacia el norte hasta el final | Linde → Ruinas (piedra) → Hondonada (suelo marchito, raíces moradas) → Corazón del Bosque (arena con columnas y árbol gigante) |
| 3 | Pulsa **E** en la fogata de la Linde | Aviso "Fogata descubierta: Linde Esmeralda", vida llena y ventana "Viaje rápido" |
| 4 | Viaja al Campamento desde ahí | Apareces junto a la fogata del campamento |
| 5 | Recibe daño y usa una fogata enseguida para viajar | "No puedes viajar en pleno combate" |
| 6 | Muere después de descansar en la fogata de las Ruinas | Reapareces junto a esa fogata |
| 7 | Recoge un Fragmento (cristal amarillo que flota y gira) | Aviso "(1/10)", caja con su historia y +100 XP; el cristal desaparece **solo para ti** |
| 8 | Pulsa **J** | Diario: pestaña Misiones (✓ / ► / ???) y pestaña Fragmentos con la historia de los recogidos |
| 9 | En el altar del campamento sin afinidad | "Despierta tu afinidad primero en el Santuario de las Ruinas de Aelith" |
| 10 | En el Santuario de las Ruinas a nivel 5+ | Pantalla de elección (y la misión 5 marca el Santuario con el rombo dorado) |
| 11 | Con afinidad, en el altar del campamento | Puedes cambiarla |
| 12 | 2 jugadores: uno recoge un Fragmento | El otro lo sigue viendo y puede recogerlo |
