# Sección 3 — Entrega 3.10 (semana 14)
## Cadena completa de 8 misiones con diálogos (ES/EN)

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Las 8 misiones (todas las da la Maestra Ilen)
| # | Misión | Tipo | Objetivo | Nivel mín. | Recompensa |
|---|---|---|---|---|---|
| 1 | Despertar del Explorador | Muñeco | Golpear 5 veces | — | 60 XP + 1 poción |
| 2 | Raíces Inquietas | Derrotar | 6 Brotespinas | — | 120 XP + 2 pociones |
| 3 | La Primera Luz | Ir a | Las ruinas al oeste de la Linde (rombo dorado) | — | 150 XP |
| 4 | El Peso del Acero | Derrotar | 4 Lanzadores | — | 200 XP + 1 poción + **Mandoble común** |
| 5 | Despertar del Éter | Afinidad | Despertar afinidad en el Santuario (rombo dorado) | 5 | 250 XP + 1 poción |
| 6 | Guardianes de Piedra | Derrotar | 3 Centinelas | 6 | 500 XP + 1 poción + **arma rara** del tipo equipado |
| 7 | Savia Marchita | Recoger | 5 Savias corruptas (50 % por enemigo derrotado) | 10 | 900 XP + 3 pociones |
| 8 | El Guardián Marchito | Derrotar | Vharok (el jefe llega en las semanas 17–18) | 14 | 3000 XP + 3 pociones + final |

[PROPUESTA] Niveles mínimos de las misiones 6–8 (6, 10 y 14) para que la curva de dificultad acompañe a la de experiencia. El GDD solo fijaba el nivel 5 para la afinidad.

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Quests.luau` | Las 8 misiones como datos + el orden de la cadena. Tipos nuevos: GoTo, ChooseAffinity, Collect; nivel mínimo; recompensas de arma |
| `src/server/Services/QuestService.luau` | Reescrito: nivel mínimo, comprobación de "llegar a un punto", misión cumplida al aceptarla si ya elegiste afinidad, objetos que sueltan los enemigos, recompensas de arma y **reparación de la cadena** (resuelve el pendiente de la migración de Q03: quien ya había terminado Q02 recibe Q03 al entrar) |
| `src/server/Services/AffinityService.luau` | Avisa cuando eliges afinidad (para la misión 5) |
| `src/client/Controllers/QuestMarkerController.luau` | **Rombo dorado** flotante sobre el destino de las misiones 3 y 5 |
| `src/client/Controllers/HudController.luau` | "Alcanza el nivel X para continuar" y avisos de arma nueva / objeto recogido |
| `src/shared/Config/Strings.luau` | Nombres, objetivos y diálogos de todas las misiones en español e inglés |
| Mapa | Marcadores invisibles `QuestMarker` en las ruinas y en el Santuario |

Nota: con `Debug.GiveAllWeapons = true` ya tienes todas las armas, así que las recompensas de arma de las misiones 4 y 6 no se notarán. Pon `false` para probarlas.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
Para ir rápido: `DummyXPPerHit = 500` para subir de nivel; vuelve a 0 al terminar.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.10.0`, `[Server] 10 módulo(s)`, `[Client] 18 módulo(s)`. Nada en rojo |
| 2 | Completa Q01 y Q02 con Ilen | Al entregar Q02, la siguiente es "La Primera Luz" con "!" sobre Ilen |
| 3 | Acepta Q03 | Rombo dorado sobre las ruinas (oeste de la Linde) |
| 4 | Llega a las ruinas | Aviso "¡Objetivo cumplido!" en menos de 1 s; vuelve con Ilen |
| 5 | Q04: derrota 4 Lanzadores y entrega | Con `GiveAllWeapons = false`: aviso "Nueva arma: Mandoble común" y aparece en el inventario |
| 6 | Q05 a nivel < 5 | Ilen te dice que vuelvas a nivel 5; el HUD dice "Alcanza el nivel 5 para continuar" |
| 7 | Q05 a nivel 5 | Rombo sobre el Santuario; al elegir afinidad, objetivo cumplido |
| 8 | Si ya tenías afinidad al aceptar Q05 | Se cumple al instante |
| 9 | Q06 (nivel 6): 3 Centinelas | "Nueva arma: Katana rara" (o Mandoble raro si llevas el mandoble) |
| 10 | Q07 (nivel 10): derrota enemigos | A veces aparece "+1 Savia corrupta" hasta 5 |
| 11 | Q08 (nivel 14) | Se acepta, pero aún no se puede completar (falta el jefe) |
| 12 | Con guardado real: un jugador que ya había terminado Q02 con la versión anterior | Al entrar tiene Q03 disponible |
