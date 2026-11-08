# Sección 3 — Entrega 3.3 (semana 5)
## Combate en red: el servidor valida y calcula el daño + números de daño

Comprobado fuera de Studio: Rojo construye, sin errores de tipos (luau-lsp), formato correcto. **No probado en Studio.**

## Cómo VER el trabajo en Roblox Studio

### Por qué "no se ve nada"
1. **El código solo llega a Studio si Rojo está conectado.** Abrir Studio sin `rojo serve` + **Connect** muestra un lugar vacío.
2. **El código casi no "se ve" en modo edición.** Los scripts están en el Explorer (`ServerScriptService`, `StarterPlayer`, `ReplicatedStorage`), pero el arma, el muñeco y los números solo aparecen **al pulsar Play**, porque los crea el código mientras el juego corre.
3. **Rama de GitHub:** todo el trabajo está en la rama `claude/vigilant-ritchie-y3u73n`. Si miras otra rama, el repositorio parece vacío.

### Opción rápida: abrir el lugar ya preparado (sin Rojo)
1. En GitHub Desktop: **Current Branch** → `claude/vigilant-ritchie-y3u73n` → **Fetch origin** → **Pull origin**.
   (O en la web: abre el repositorio, cambia a esa rama, entra en `builds/ECLIPSE-dev.rbxl` → botón de descarga.)
2. En Studio: **File → Open from File…** → elige `builds/ECLIPSE-dev.rbxl` dentro de la carpeta del proyecto.
3. Verás un suelo verde y un punto de aparición. En **Explorer** están todos los scripts.
4. Pulsa **Play**: aparece la katana en tu mano y un **muñeco de práctica** delante.

Este archivo es una "foto" del código: cuando yo actualice el repositorio, vuelve a descargarlo. Para trabajar día a día, usa Rojo (siguiente apartado), que actualiza Studio en vivo.

### Opción de trabajo diario: Rojo
1. Abre `builds/ECLIPSE-dev.rbxl` en Studio y guárdalo como tu lugar de desarrollo (**File → Publish to Roblox**).
2. En VS Code: `rojo serve`. En Studio: **Plugins → Rojo → Connect**.
3. Desde entonces, cada vez que bajes cambios con **Pull origin**, aparecen solos en Studio.

---

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/server/Services/CombatService.luau` | **Nuevo.** Recibe `RequestAttack`, `RequestDodge`, `RequestBlock`; valida tipo de dato, estado, intervalos y enfriamientos con el reloj del servidor; busca objetivos con la hitbox (con tolerancia de red) y aplica el daño con la fórmula aprobada; avisa al atacante (`HitConfirmed`) y a los demás (`HitBroadcast`). Sin PvP. Prepara `getIncomingDamageMultiplier` para los enemigos (esquiva = 0, bloqueo perfecto = 0, bloqueo = 0,3) |
| `src/server/Services/TrainingDummyService.luau` | **Nuevo (solo desarrollo).** Crea un muñeco con 1000 de vida y barra visible; se cura 3 s después del último golpe. Cualquier modelo con la etiqueta `TrainingDummy` también se cura |
| `src/client/Controllers/FeedbackController.luau` | **Nuevo.** Números de daño: blancos (normal), amarillos y más grandes (crítico); los tuyos grandes, los de otros pequeños y semitransparentes; golpes rápidos al mismo objetivo se suman |
| `src/client/Controllers/CombatController.luau` | Ahora envía cada ataque, esquiva y bloqueo al servidor |
| `src/server/Services/WeaponService.luau` | Funciona también si el lugar está en R6 (usa "Right Arm") |
| `src/shared/Config/Combat.luau` | Tolerancias de red y ajustes de los números de daño |
| `src/shared/Config/Debug.luau` | `SpawnTrainingDummy` y `TrainingDummyPosition` |
| `build.project.json` + `builds/ECLIPSE-dev.rbxl` | Lugar listo para abrir: suelo, punto de aparición y todo el código |

Pendiente para semanas posteriores: el daño usa nivel 1 y rareza ×1 hasta que existan la progresión (semana 6) y el inventario (semana 10). Las afinidades (fuego, rayo, Resonancia) añadirán sus colores de número en las semanas 11–12.

## Pruebas
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.3.0`, `[Net] 20 mensajeros…`, `[TrainingDummyService] Muñeco de práctica creado`, `[Server] 3 módulo(s)`, `[Client] 4 módulo(s)`. Nada en rojo |
| 2 | Mira delante del punto de aparición | Muñeco de madera con nombre y barra de vida |
| 3 | Golpea al muñeco con clic | Destello blanco + **número blanco** (10) sobre su cabeza que sube y desaparece; la barra baja; Output: `[CombatService] TuNombre: Ligero 1 → TrainingDummy -10 (Normal)` |
| 4 | Golpea varias veces | Algunos números salen **amarillos y más grandes** (críticos ~10 %: 15). Golpes muy seguidos se **suman** en el mismo número |
| 5 | Clic, clic, clic derecho | El último: `Remate` con 18 (o 27 si es crítico) |
| 6 | Solo clic derecho | `Pesado` con 22 (o 33) |
| 7 | Deja de golpear 3 s | La vida del muñeco vuelve a 1000 |
| 8 | Haz spam de clics | El daño no llega más rápido de un golpe cada ~0,35 s |
| 9 | Ataca y pulsa Q justo después | Si esquivas antes del momento del golpe, ese golpe **no** hace daño |
| 10 | **Prueba con 2 jugadores:** pestaña **Test** → en "Clients and Servers" elige **2 Players** → **Start**. Golpea al muñeco con un jugador | En su ventana: números grandes. En la ventana del otro jugador: números pequeños y semitransparentes. Ambos ven bajar la misma barra |
| 11 | En la prueba de 2 jugadores, golpea al otro jugador | No recibe daño (sin PvP) |
