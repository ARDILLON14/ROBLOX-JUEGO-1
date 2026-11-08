# Sección 3 — Entrega 3.5 (semana 7)
## Primer enemigo: Brotespina (IA, aparición, ataques, XP y reaparición)

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Enemies.luau` | Datos del Brotespina: vida 60 (+15/nivel), daño 8 (+2/nivel), velocidad, distancias, aviso de 0,6 s, XP 15 × nivel, reaparición 10 s |
| `src/server/Services/EnemyService.luau` | Aparición desde piezas con la etiqueta `EnemySpawn`; IA (reposo → persecución → aviso → golpe → espera; vuelve a casa y se cura si te alejas; aturdido tras tu bloqueo perfecto; duerme si no hay nadie cerca); XP a quien hizo ≥ 10 % de su vida; reaparición más rápida con más jugadores cerca |
| `src/server/Services/CombatService.luau` | Nuevo `damagePlayer`: aplica tu defensa (esquiva = 0, bloqueo perfecto = 0 y aturde al enemigo, bloqueo = 30 %); avisa de cada golpe tuyo a otros servicios |
| `src/client/Controllers/EnemyVisualController.luau` | Nombre y nivel del enemigo en tu idioma; brillo **blanco-amarillo** antes de un golpe bloqueable, **rojo** si es imbloqueable, **azul** si está aturdido |
| `src/client/Controllers/FeedbackController.luau` | Nuevos números: daño que **recibes** (rojo), "Bloqueado X" (gris), "¡Perfecto!" (dorado) |
| `src/shared/Config/Debug.luau` | `SpawnTestEnemies` crea un grupo de 3 Brotespinas de prueba; `DummyXPPerHit` pasa a **0** (la XP ya viene de los enemigos) |

### Conceptos nuevos
- **IA por estados:** el enemigo siempre está en un estado (persiguiendo, atacando…) y unas reglas simples deciden cuándo cambia.
- **SetNetworkOwner(nil):** obliga a que el servidor controle la física del enemigo, para que ningún jugador pueda moverlo con trampas.
- **Telegrafiar:** avisar visualmente un ataque antes de que ocurra, para que el jugador pueda reaccionar.

### Cómo poner enemigos en tu mapa (cuando construyas Verdantia)
1. Inserta una pieza (**Home → Part**) donde quieras el grupo.
2. **Properties → Tags → +** → `EnemySpawn`.
3. **Properties → Attributes → +**: `EnemyId` (string) = `Thornling`, `Level` (number) = 1, `Count` (number) = 3.
4. Al pulsar Play, la pieza se vuelve invisible y aparecen los enemigos. (El grupo de prueba deja de crearse en cuanto exista un punto tuyo.)

---

## Pruebas
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.5.0`, `[EnemyService] Punto de aparición: 3 × Thornling (nivel 1)`, `[Server] 6 módulo(s)`, `[Client] 8 módulo(s)`. Nada en rojo |
| 2 | Mira hacia la derecha-delante del punto de aparición (~40 studs) | 3 Brotespinas (bloques marrones con cabeza verde) quietos |
| 3 | Acércate (~30 studs) | Te persiguen. Sobre ellos: "Brotespina · Nv 1" |
| 4 | Deja que te alcancen | Antes de golpear, el enemigo **brilla blanco-amarillo** ~0,6 s; luego recibes daño: **número rojo** (8) junto a ti y baja tu vida |
| 5 | Mantén **F** cuando brille | "Bloqueado 2" en gris (30 % de 8) |
| 6 | Pulsa **F** justo cuando empieza a brillar o un instante antes del golpe | "**¡Perfecto!**" dorado, no recibes daño y el enemigo **brilla azul** (aturdido ~1,5 s) |
| 7 | Pulsa **Q** justo antes del golpe | No recibes daño |
| 8 | Derrota a uno (60 de vida) | Se desarma; Output: `Thornling derrotado (+15 XP …)`; tu XP sube 15 |
| 9 | Espera ~10 s | Aparece otro en su zona |
| 10 | Huye lejos (más de ~60 studs de su zona) | Dejan de seguirte, vuelven a su sitio y recuperan la vida |
| 11 | Deja que te maten | Reapareces (Roblox, ~5 s); los enemigos vuelven a su zona |
| 12 | **2 jugadores**: uno golpea a un enemigo una sola vez y el otro lo remata | Solo recibe XP quien hizo ≥ 10 % de su vida (6 de daño): con un golpe de 10 ambos reciben XP |

### Posible problema a vigilar
- [VERIFICAR EN STUDIO] Los Brotespinas no tienen piernas y "flotan" a una altura fija (HipHeight). Si se hunden en el suelo, caen al vacío o tiemblan, dímelo y lo ajusto.

## Qué me tienes que contar
1. Resultado de cada prueba (✅ / ❌).
2. Texto en rojo de Output, tal cual.
3. ¿Se siente justo el combate? (¿demasiado fáciles/difíciles, el aviso se ve a tiempo?)
