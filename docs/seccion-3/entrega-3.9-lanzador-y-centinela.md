# Sección 3 — Entrega 3.9 (semana 13)
## Brotespina Lanzador y Centinela Aelith: los 3 enemigos en juego

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Enemies.luau` | Nuevos: **Lanzador** (variante del Brotespina: hojas moradas, algo más pequeño, ataca a distancia) y **Centinela** (piedra, 1,6 veces más grande, escudo delante). Nuevos campos: tamaño, material, estilo de ataque, guardia frontal |
| `src/server/Services/EnemyService.luau` | Lanzador: mantiene la distancia (retrocede si te acercas a menos de ~11 studs) y dispara **espinas** que el servidor mueve (se pueden bloquear o esquivar). Centinela: **guardia frontal** — tus golpes ligeros de frente se bloquean (20 % de daño, "Bloqueado"); un **pesado o remate de frente rompe su guardia** y lo aturde 2 s; por la espalda o de lado recibe daño completo; su golpe es **imbloqueable** (brillo rojo, hay que esquivar) |
| `src/server/Services/CombatService.luau` | Cada golpe indica su origen (ligero, pesado, remate, habilidad, quemado) y admite "modificadores" de daño (lo usa la guardia) |
| `tools/generate_blockout.py` / mapa | Grupo de 3 Lanzadores (nivel 3) al norte-este de la Linde y 2 Centinelas (nivel 5) junto a las ruinas. **Provisional:** los Centinelas pasarán a las Ruinas de Aelith (Zona 2) en las semanas 15–16 |

### Valores iniciales
| | Brotespina | Lanzador | Centinela |
|---|---|---|---|
| Vida (nivel 1) / por nivel | 60 / +15 | 45 / +12 | 220 / +40 |
| Daño (nivel 1) / por nivel | 8 / +2 | 7 / +2 | 22 / +5 |
| Aviso antes de atacar | 0,6 s (blanco) | 0,7 s (blanco) | 1,0 s (**rojo**) |
| XP por nivel | 15 | 18 | 38 |

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.9.0`, 5 puntos de aparición (3 de Thornling, `3 × Spitter (nivel 3)`, `2 × Sentry (nivel 5)`). Nada en rojo |
| 2 | Ve al norte-este de la Linde | Lanzadores de hojas moradas: "Brotespina Lanzador · Nv 3" |
| 3 | Quédate a media distancia | Brillan y lanzan una espina morada que vuela hacia ti; si te toca, número rojo |
| 4 | Bloquea (F) o esquiva (Q) una espina | Bloqueo: "Bloqueado 2–3"; esquiva: sin daño |
| 5 | Corre hacia un Lanzador | Retrocede para mantener la distancia |
| 6 | Ve a las ruinas (oeste de la Linde) | Centinelas grandes de piedra con escudo: "Centinela Aelith · Nv 5" |
| 7 | Golpéalo con ataques ligeros de frente | Números grises "Bloqueado 2" |
| 8 | Dale un **pesado** (clic derecho) de frente | Daño completo y el Centinela **brilla azul** (aturdido ~2 s) |
| 9 | Golpéalo por la espalda | Daño completo con ligeros |
| 10 | Espera su ataque | Brilla **ROJO** 1 s; si bloqueas recibes el golpe completo (22+); si esquivas a tiempo no recibes daño |
| 11 | Derrota a cada tipo | XP: Lanzador nv 3 = 54; Centinela nv 5 = 190 |
