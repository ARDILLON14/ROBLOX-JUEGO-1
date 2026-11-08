# Sección 3 — Entrega 3.12 (semanas 17–18)
## Jefe: Vharok, el Guardián Marchito

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## Cómo funciona
| Fase | Ataques | Cómo defenderse |
|---|---|---|
| **1** (100 % → 50 %) | **Zarpazo** (brillo blanco, 0,8 s) | Bloquear (F); bloqueo perfecto lo aturde 1 s |
| | **Barrido de raíces**: círculos rojos bajo cada jugador; 1,2 s después, daño | Salir del círculo o esquivar (Q) |
| | **Llamada del bosque**: invoca 2 Brotespinas (máx. 4 a la vez; no reaparecen) | Derrotarlos o ignorarlos |
| *Transición* (50 %) | Ruge, partículas de Éter morado; **invulnerable 2 s** | — |
| **2** (50 % → 0 %) | Todo ~35 % más rápido | — |
| | **Lluvia de espinas**: 6 círculos rojos por la arena | Salir de los círculos |
| | **Embestida** (brillo **ROJO** 1 s): carga en línea recta | Esquivar a un lado. Si choca contra una **columna**, queda **aturdido 3 s** y recibe **+50 % de daño** |

- **Vida**: 3500 × (1 + 0,6 × (jugadores en la arena − 1)). Se recalcula si entran o salen jugadores, conservando el porcentaje.
- **Recompensas** (≥ 3 % de su vida): 1500 XP, 1 poción y 20 % de probabilidad de **arma épica** del tipo que llevas.
- Completa la **misión 8** para quien contribuyó.
- Se **reinicia** si la arena queda vacía 10 s; **reaparece** 3 minutos después de morir.
- El jefe se mueve por código (sin física): con un modelo tan grande, la física de Roblox podría volcarlo o atascarlo.

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Bosses.luau` | Todos los números de Vharok (vida, escalado, ataques, recompensas) |
| `src/server/Services/BossService.luau` | Aparición en la arena, IA de 2 fases, marcas de suelo, embestida contra columnas, escalado, recompensas, reinicio y reaparición |
| `src/server/Services/EnemyService.luau` | `spawnTemporary` (refuerzos que no reaparecen) y `notifyDefeated` (para la misión 8 y la maestría) |
| `src/client/Controllers/BossBarController.luau` | Barra del jefe (nombre, fase, vida) y aura de Éter en la fase 2 |
| Mapa | Columnas de la arena con la etiqueta `BossColumn` |
| `src/shared/Config/Debug.luau` | `BossHealthMultiplier` para probar rápido |

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
Para ir rápido: `BossHealthMultiplier = 0.1` (350 de vida) y `DummyXPPerHit = 500`. **Vuelve a 1 y 0 al terminar.** Usa el viaje rápido a "Corazón del Bosque" tras descubrir su fogata.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.12.0`, `[BossService] Vharok aparece en la arena`, `[Server] 12 módulo(s)`, `[Client] 22 módulo(s)`. Nada en rojo |
| 2 | Entra en la arena (círculo con columnas) | `Comienza el combate contra Vharok`; barra arriba: "Vharok, el Guardián Marchito — Fase 1" |
| 3 | Acércate | Brilla blanco y da un zarpazo (~30); bloquéalo; con bloqueo perfecto brilla azul |
| 4 | Espera | Círculos rojos bajo tus pies; sal de ellos antes de 1,2 s |
| 5 | Espera más | Aparecen 2 Brotespinas a su lado |
| 6 | Bájale al 50 % | Partículas moradas, brillo morado 2 s (no recibe daño); la barra pasa a "Fase 2" y se vuelve morada |
| 7 | Fase 2 | Círculos rojos por toda la arena; se mueve y ataca más rápido |
| 8 | Aléjate > 12 studs con una columna detrás de ti | Brilla **rojo**, carga hacia ti; esquiva y deja que choque con la columna → brilla azul 3 s y tus golpes hacen +50 % |
| 9 | Derrótalo | Aviso "¡Vharok, el Guardián Marchito ha sido derrotado!", +1500 XP, poción, quizá arma épica; la barra desaparece. Si tenías la misión 8 activa: objetivo cumplido |
| 10 | Espera 3 minutos | Vuelve a aparecer |
| 11 | Sal de la arena 10 s durante el combate | Se reinicia con vida completa |
| 12 | 2 jugadores en la arena | La vida máxima aumenta un 60 % al entrar el segundo |
