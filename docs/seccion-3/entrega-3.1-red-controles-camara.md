# Sección 3 — Entrega 3.1 (semanas 1–2 del plan)
## Base de red, controles por acciones y cámara en tercera persona

### Qué se añadió
| Archivo | Qué hace |
|---|---|
| `src/shared/Net.luau` | El servidor crea los 20 "mensajeros" (RemoteEvents) aprobados en la Entrega 2B dentro de `ReplicatedStorage/Remotes`. `Net.onRequest` escucha peticiones con **límite por segundo** |
| `src/shared/Util/RateLimiter.luau` | Limita cuántas veces por segundo puede hacer algo cada jugador |
| `src/shared/Util/Validate.luau` | Comprobaciones de datos que llegan del cliente (números reales, vectores, listas permitidas) |
| `src/shared/Config/Controls.luau` | Qué tecla activa cada **acción** |
| `src/shared/Config/Camera.luau` | Desplazamiento de la cámara sobre el hombro |
| `src/shared/Config/Debug.luau` | Interruptor para ver en Output cada acción pulsada |
| `src/client/Controllers/InputController.luau` | Convierte teclas en acciones y avisa a quien escuche |
| `src/client/Controllers/CameraController.luau` | Cámara tipo shift-lock: ratón bloqueado, el personaje mira hacia la cámara, vista sobre el hombro. **Alt izquierdo** (mantener) libera el ratón |
| `default.project.json` | Desactiva el shift-lock propio de Roblox (usamos el nuestro) y limita el zoom entre 8 y 20 |
| `src/server/Main.server.luau` | Crea los mensajeros antes de cargar los servicios |
| Borrados | `ExampleService` y `ExampleController` (ya no hacen falta) |

Versión del juego: `0.1.0`.

Comprobado en el entorno de desarrollo (no en Studio): el proyecto se construye con Rojo, el verificador de tipos de Luau (luau-lsp) no da errores y el formato es correcto.

### Conceptos nuevos
- **Acción vs. tecla:** el combate preguntará "¿se pidió *Block*?", no "¿se pulsó F?". Cambiar una tecla = cambiar una línea en `Controls.luau`.
- **`gameProcessedEvent`:** Roblox avisa si una tecla ya la usó él (p. ej., escribiendo en el chat). En ese caso la ignoramos para no atacar mientras escribes.
- **`BindToRenderStep`:** ejecuta una función en cada fotograma, en un orden concreto. La usamos para girar el personaje justo después de que Roblox mueva la cámara.
- **`MouseBehavior.LockCenter`:** bloquea el ratón en el centro de la pantalla.

### [PROPUESTA] nueva
- **Alt izquierdo (mantener) = liberar el ratón.** No estaba en el GDD; hace falta para poder hacer clic fuera del juego o en menús mientras no existan las pantallas definitivas.

### ⚠️ Posible conflicto
- **Tab** abre la lista de jugadores de Roblox. [VERIFICAR EN STUDIO] Si al pulsar Tab no aparece `[Input] Inventory Begin` en Output, propongo cambiar el inventario a la tecla **I**.

---

## Pruebas (en Studio)
Antes: `rojo serve` abierto en VS Code y Studio conectado (**Plugins → Rojo → Connect**). Abre **View → Output**.

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Pulsa **Play** | En Output: `[Server] ECLIPSE: The Fragments of Dawn v0.1.0`, `[Net] 20 mensajeros creados en ReplicatedStorage/Remotes`, `[Server] 0 servicios todavía`, `[Client] … v0.1.0`, `[Client] 2 módulo(s) iniciado(s)`. Ningún texto rojo |
| 2 | Con el juego en marcha, en **Explorer** abre `ReplicatedStorage → Remotes` | 19 RemoteEvent + 1 UnreliableRemoteEvent (`HitBroadcast`) |
| 3 | Mueve el ratón | El cursor desaparece (bloqueado en el centro), la cámara gira y **el personaje gira con ella**. La cámara está un poco a la derecha del personaje (sobre el hombro) |
| 4 | Camina con WASD | Te mueves en relación a la cámara; el personaje sigue mirando al frente de la cámara (al pulsar S camina hacia atrás) |
| 5 | Rueda del ratón | Zoom entre cerca y lejos, pero **nunca** entra en primera persona |
| 6 | Mantén **Alt izquierdo** | Aparece el cursor y puedes moverlo libremente; el personaje vuelve a girar hacia donde camina. Al soltar, se bloquea de nuevo |
| 7 | Pulsa clic izq., clic der., F, Q, Z, X, 1, Tab, J | En Output aparece `[Input] LightAttack Begin` / `End`, `HeavyAttack`, `Block`, `Dodge`, `Skill`, `Ultimate`, `UsePotion`, `Inventory`, `Journal` |
| 8 | Abre el chat (tecla `/`), escribe "fqzx" y pulsa Enter | **No** aparecen mensajes `[Input] … Begin` mientras escribes |
| 9 | Mantén F, y suéltalo | `[Input] Block Begin` y al soltar `[Input] Block End` |
| 10 | Resetea el personaje (Esc → Reset Character) | Al reaparecer, la cámara y el giro siguen funcionando |
| 11 | En la terminal: `selene src` | `0 errors` (puede haber avisos; cópiamelos) |

## Qué me tienes que contar
1. Resultado de cada prueba (✅ / ❌) y, si falla, qué viste.
2. Lo que sale en Output al pulsar Play (prueba 1).
3. ¿La prueba 7 mostró `Inventory` con Tab?
4. Si la cámara o el giro se sienten raros (p. ej., tiembla, va con retraso), descríbelo.
5. Resultado de la prueba de la Entrega 2D (si aún no me lo contaste).
