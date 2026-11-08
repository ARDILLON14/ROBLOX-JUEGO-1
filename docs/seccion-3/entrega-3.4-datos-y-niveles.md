# Sección 3 — Entrega 3.4 (semana 6)
## Guardado de datos, experiencia, niveles y animación de subida de nivel

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código (luau-lsp), formato correcto. **No probado en Studio.**
Los avisos del verificador dentro de `ProfileStore.luau` son del propio módulo externo y no afectan.

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/server/Packages/ProfileStore.luau` | Módulo externo **ProfileStore 1.0.3** (gratuito, licencia Apache 2.0; ver `third_party/ProfileStore/`). Copiado sin cambios |
| `src/server/Data/DataTemplate.luau` | Datos guardados de cada jugador, según la decisión B1 |
| `src/server/Services/DataService.luau` | Carga y guarda los datos con bloqueo de sesión; avisa al cliente (`DataSnapshot`, `DataChanged`) |
| `src/server/Services/ProgressionService.luau` | XP y niveles con la curva aprobada; al subir: +vida, curación, +1 poción, recompensas de los niveles 5/10/15/20; columna "Lv" en la lista de jugadores |
| `src/server/Services/CombatService.luau` | El daño ya usa tu **nivel real**; **temporal**: golpear al muñeco da 25 XP |
| `src/client/Controllers/PlayerDataController.luau` | Copia de solo lectura de tus datos en el cliente |
| `src/client/Controllers/LevelUpController.luau` | Columna de luz dorada (la ven todos) + aviso "¡NIVEL X!" con recompensas |
| `src/client/Controllers/DebugHudController.luau` | Texto provisional arriba a la izquierda: nivel, XP y pociones |
| `src/shared/Config/Levels.luau` | Curva de XP (100 × n^1,5), nivel máximo 20, vida por nivel, recompensas |
| `src/shared/Config/Strings.luau` | Textos en español/inglés según el idioma de tu cuenta de Roblox (pasará a CSV en la semana 19) |
| `src/shared/Config/Sounds.luau` | ID del sonido de subida de nivel (vacío = sin sonido) |
| `builds/ECLIPSE-dev.rbxl` | Lugar de prueba actualizado |

### Conceptos nuevos
- **DataStore:** la "base de datos" de Roblox donde se guardan los datos de los jugadores.
- **Modo de prueba (mock):** si Studio no tiene permiso para usar DataStores, ProfileStore funciona igual pero **no guarda** al salir. Útil para probar sin riesgo.
- **leaderstats:** carpeta especial: lo que pongas dentro aparece en la lista de jugadores (arriba a la derecha).

---

## Pruebas
Abre `builds/ECLIPSE-dev.rbxl` (descárgalo de nuevo con **Pull origin**) o usa Rojo.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.4.0`, `[DataService] Datos de TuNombre cargados (nivel 1, XP 0)`, `[Server] 5 módulo(s)`, `[Client] 7 módulo(s)`. Puede salir un aviso de ProfileStore sobre modo de prueba/sin acceso a DataStore: es normal en un archivo sin publicar |
| 2 | Mira arriba a la izquierda | `Nv 1 · XP 0/100 · Pociones 0` (en inglés si tu Roblox está en inglés) |
| 3 | Lista de jugadores (arriba a la derecha) | Columna **Lv** con 1 |
| 4 | Golpea al muñeco 4 veces | XP 25 → 50 → 75 → **¡subida!**: columna de luz dorada sobre ti, aviso **¡NIVEL 2!** con "Vida restaurada · +1 Poción"; el texto pasa a `Nv 2 · XP 0/280 · Pociones 1`; Lv = 2 |
| 5 | Sigue hasta nivel 3 y golpea | El golpe ligero hace 11 en vez de 10 (+4 % por nivel) |
| 6 | Prueba rápida de niveles altos: Stop → en `Debug.luau` cambia `DummyXPPerHit = 25` por `500` → Play | Subes muy rápido. En el nivel 5 el aviso incluye "¡Ya puedes despertar tu afinidad!"; en el 10, "Nuevo título: Explorador del Alba". Al llegar a 20 ya no sube más. **Después vuelve a poner 25** |
| 7 | Prueba con 2 jugadores (**Test → 2 Players → Start**) y sube de nivel con uno | En la otra ventana se ve la columna de luz sobre el primero |
| 8 | Stop y Play de nuevo (archivo sin publicar) | Vuelves a nivel 1: es **lo esperado** en modo de prueba |

### Prueba de guardado real (opcional, recomendada antes del slice vertical)
1. **File → Publish to Roblox** (como tu lugar de desarrollo).
2. **Home → Game Settings → Security** → activa **Enable Studio Access to API Services** → **Save**. [VERIFICAR EN DOCUMENTACIÓN: "Enable Studio Access to API Services"]
3. Play, sube a nivel 3, Stop.
4. Play otra vez → debes seguir en **nivel 3** con tu XP y pociones.

⚠️ Con el acceso activado, las pruebas guardan datos de verdad en tu lugar de desarrollo. No afecta al juego público (aún no existe).

## Qué me tienes que contar
1. Resultado de cada prueba (✅ / ❌).
2. Texto en rojo de Output, tal cual.
3. Si probaste el guardado real: ¿conservaste el nivel?
