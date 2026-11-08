# Sección 3 — Entrega 3.7 (semanas 9–10)
## Mandoble jugable, rarezas de armas, inventario y cosméticos

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**
Nota: la semana 9 incluía "correcciones del playtest"; quedan pendientes hasta recibir resultados de pruebas.

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Weapons.luau` | Las 6 armas (katana y mandoble × común/rara/épica). Rareza: daño ×1 / ×1,25 / ×1,5 y color (la épica brilla) |
| `src/shared/Config/Cosmetics.luau` | Títulos "Explorador del Alba" y "Guardián de Verdantia" y aura "Brasa de Éter" |
| `src/server/Services/WeaponService.luau` | El arma en la mano sale de tus **datos guardados**. `RequestEquipWeapon`: solo si existe, la tienes y no estás atacando/esquivando |
| `src/server/Services/CombatService.luau` | El daño aplica el **multiplicador de rareza**; nuevo `isBusy` |
| `src/server/Services/InventoryService.luau` | Equipar/quitar títulos y auras (`RequestEquipCosmetic`) |
| `src/client/Controllers/InventoryUiController.luau` | **Inventario** (Tab o I): pestañas Armas / Consumibles / Cosméticos |
| `src/client/Controllers/CosmeticVisualController.luau` | Muestra títulos (sobre la cabeza) y auras (partículas) de todos los jugadores, en tu idioma |
| `src/shared/Config/Controls.luau` | Inventario con **Tab o I** (resuelve el posible conflicto con la lista de jugadores) |
| `src/shared/Config/Debug.luau` | `GiveAllWeapons = true`: te da las 6 armas para probar. En el juego real el mandoble llega con la misión 4 y las rarezas con botín/misiones |

---

## Pruebas (abre de nuevo `builds/ECLIPSE-dev.rbxl` tras **Pull origin**)
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.7.0`, `[Server] 9 módulo(s)`, `[Client] 14 módulo(s)`. Nada en rojo |
| 2 | Pulsa **Tab** (o **I**) | Se abre el inventario y el cursor queda libre. Pestaña **Armas** con 6 armas; "Katana común" muestra **Equipado** |
| 3 | Pulsa **Equipar** en "Mandoble común" | La hoja en tu mano cambia a una más grande; el botón pasa a "Equipado" |
| 4 | Cierra (Tab o "Cerrar") y ataca al muñeco | Golpes más lentos y de más alcance; ligero = **18** |
| 5 | Equipa "Katana épica" | Hoja morada brillante; golpe ligero = **15** (10 × 1,5) a nivel 1 |
| 6 | Equipa "Mandoble raro" y ataca | Ligero = **23** (18 × 1,25, redondeado) |
| 7 | Intenta cambiar de arma justo mientras atacas | No cambia (el servidor lo impide) |
| 8 | Pestaña **Consumibles** | "Poción de Savia xN" con botón **Usar** (funciona igual que la tecla 1) |
| 9 | Pestaña **Cosméticos** a nivel 1 | Mensaje "Sube de nivel para conseguir títulos y auras…" |
| 10 | Sube a nivel 10 (truco: `DummyXPPerHit = 500` en Debug y golpea al muñeco; luego vuelve a 0) y equipa "Explorador del Alba" | Texto dorado sobre tu cabeza. A nivel 15, el aura "Brasa de Éter" muestra partículas naranjas |
| 11 | Prueba con 2 jugadores | Cada uno ve el arma, el título y el aura del otro |
| 12 | Con el guardado real activado (Entrega 3.4): equipa el mandoble, Stop y Play | Apareces con el mandoble equipado |
