# Sección 3 — Entrega 3.8 (semanas 11–12)
## Afinidades Fuego y Rayo, maestría, ultis, Quemado y Resonancia

Las semanas 11 (Fuego) y 12 (Rayo + maestría + Resonancia) se hicieron juntas porque comparten el mismo sistema.
Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Affinities.luau` | Datos de ambas afinidades, rangos de maestría (0 / 600 / 2000), carga de ulti (500 de daño), Resonancia |
| `src/server/Services/AffinityService.luau` | Elegir afinidad (nivel 5, junto al Santuario, cambio gratis); validar y lanzar habilidad (Z) y ulti (X); maestría guardada por afinidad; Quemado; Resonancia; carga de ulti |
| `src/server/Services/CombatService.luau` | Funciones comunes reutilizadas por las habilidades: `dealDamage`, `queryTargets`, `queryTargetsAround`, `scaleByLevel`, `setBusy` |
| `src/client/Controllers/AbilityController.luau` | Z / X: pide la habilidad al servidor; el Paso Relámpago te mueve al instante |
| `src/client/Controllers/AffinityUiController.luau` | Pantalla "Elige tu afinidad" con las dos opciones |
| `src/client/Controllers/AbilityVfxController.luau` | Efectos provisionales de neón para todos (los de otros, más transparentes) y llamas sobre enemigos Quemados |
| `src/client/Controllers/HudController.luau` | Abajo-izquierda: maestría (rango y puntos), habilidad con enfriamiento, ulti (bloqueada hasta R3 / % de carga / ¡LISTA!) y avisos de rango |
| `src/client/Controllers/FeedbackController.luau` | Números naranja (fuego), celeste (rayo) y morado "¡RESONANCIA!" |
| `src/client/Controllers/CombatController.luau` | La embestida se separó en una función reutilizable (`dash`) |
| `src/shared/Net.luau` | **[PROPUESTA]** nuevo mensajero no fiable `AbilityEffect` (solo efectos visuales; no estaba en la lista aprobada de la Entrega 2B) |
| `tools/generate_blockout.py` / mapa | **Santuario provisional** (esfera morada) en el campamento. **[PROPUESTA]** Se moverá a las Ruinas de Aelith cuando se construya la Zona 2 (semanas 15–16) |
| `src/shared/Config/Debug.luau` | `MasteryMultiplier` para probar los rangos rápido |

### Habilidades (valores iniciales)
| | Fuego | Rayo |
|---|---|---|
| R1 (Z, 6 s) | **Tajo Ígneo**: 20 de daño en un arco frontal (10 × 10) + Quemado 3 s (4/s) | **Paso Relámpago**: embestida de 14 studs, 18 de daño a lo que atraviesa |
| R2 (600 pts) | Arco más ancho (14) y Quemado 5 s | La descarga salta a 2 enemigos cercanos (50 %) |
| R3 (2000 pts, X) | **Erupción del Alba**: 60 alrededor (radio 14) + Quemado | **Juicio del Trueno**: 70 en una zona 12 studs delante (radio 12) |
Todo se escala +4 % por nivel. **Resonancia**: un golpe de rayo sobre un enemigo Quemado → 30 de daño en radio 8 y se consume el Quemado.

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
Para probar rápido: en `Debug.luau` pon `DummyXPPerHit = 500` (subir de nivel) y `MasteryMultiplier = 20` (subir rangos). **Vuelve a ponerlos en 0 y 1 al terminar.**

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.8.0`, `[AffinityService] Afinidades listas`, `[Server] 10 módulo(s)`, `[Client] 17 módulo(s)`. Nada en rojo |
| 2 | HUD abajo-izquierda a nivel 1 | "Afinidad: nivel 5 (Santuario)" |
| 3 | Ve a la esfera morada del campamento y pulsa **E** a nivel 1 | Aviso "Necesitas nivel 5 para despertar tu afinidad" |
| 4 | Sube a nivel 5+, vuelve y pulsa **E** | Pantalla "Elige tu afinidad" con Fuego y Rayo; cursor libre |
| 5 | Elige **Fuego** | Aviso "Afinidad despertada: Fuego"; HUD: "Maestría Fuego R1: 0/600", "Tajo Ígneo [Z]", "Ulti: rango 3" |
| 6 | Pulsa **Z** frente al muñeco | Destello naranja en el suelo; número naranja (20+); el muñeco arde (llamas) y recibe números pequeños naranjas cada segundo; HUD muestra la cuenta atrás de 6 s |
| 7 | Sigue usando Z hasta 600 de maestría | Aviso "¡Fuego: rango 2 desbloqueado!"; el arco es más ancho |
| 8 | Llega a 2000 | "Rango 3"; la línea de ulti muestra un %. Pega con el arma hasta "¡LISTA!" y pulsa **X** | 
| 9 | Ulti de Fuego | Bola naranja que se expande; daño a todo alrededor |
| 10 | Vuelve al Santuario y elige **Rayo** | Maestría de Rayo empieza en 0; la de Fuego se conserva (al volver a Fuego sigue en R3) |
| 11 | Pulsa **Z** con Rayo | Te lanzas hacia delante con una línea celeste; daño a lo que atraviesas |
| 12 | **Resonancia (2 jugadores)**: uno con Fuego quema a un enemigo; el otro, con Rayo, lo golpea con Z | Explosión morada y número "¡RESONANCIA! 30" |
| 13 | Pulsa Z durante el enfriamiento, o X con la ulti sin cargar | No pasa nada |
| 14 | Con guardado real: Stop y Play | Conservas afinidad y maestría; la carga de ulti vuelve a 0 (no se guarda, decisión B1) |
