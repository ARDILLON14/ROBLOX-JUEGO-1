# ECLIPSE: The Fragments of Dawn — Sección 2, Entrega 2D
## Esqueleto del proyecto y conexión con Roblox Studio

### Qué se creó en el repositorio
| Archivo | Para qué |
|---|---|
| `default.project.json` | Le dice a Rojo dónde va cada carpeta dentro de Studio |
| `rokit.toml` | Versiones fijas de Rojo 7.7.1, Selene 0.32.0 y StyLua 2.6.0 |
| `selene.toml`, `stylua.toml` | Reglas del revisor y del formateador |
| `.gitignore` | Archivos que Git no debe guardar |
| `src/shared/Util/Loader.luau` | Carga los módulos de una carpeta y llama a `Init()` y luego a `Start()` |
| `src/shared/Config/GameInfo.luau` | Nombre y versión del juego |
| `src/server/Main.server.luau` | Arranque del servidor |
| `src/client/Main.client.luau` | Arranque del cliente |
| `src/server/Services/ExampleService.luau` | Servicio de prueba (se borrará en la Sección 3) |
| `src/client/Controllers/ExampleController.luau` | Controlador de prueba (se borrará en la Sección 3) |

Comprobado en el entorno de desarrollo: `rojo build` genera el lugar sin errores y `stylua --check` no encuentra problemas de formato. Selene no se pudo ejecutar allí (necesita descargar la lista de APIs de Roblox); ejecútalo tú en tu PC (paso 9).

### Árbol resultante en Studio
```
ReplicatedStorage
└─ Shared (Folder)
   ├─ Config › GameInfo (ModuleScript)
   └─ Util › Loader (ModuleScript)
ServerScriptService
└─ Server (Folder)
   ├─ Main (Script)
   └─ Services › ExampleService (ModuleScript)
StarterPlayer › StarterPlayerScripts
└─ Client (Folder)
   ├─ Main (LocalScript)
   └─ Controllers › ExampleController (ModuleScript)
```

---

## Pasos de instalación (una sola vez)

**1. Roblox Studio.** Descárgalo desde create.roblox.com e inicia sesión.

**2. Git + GitHub Desktop.** Instala GitHub Desktop (incluye Git). Inicia sesión con tu cuenta de GitHub → **File → Clone repository** → `ardillon14/roblox-juego-1` → elige una carpeta en tu PC. Luego, arriba, **Current Branch** → selecciona `claude/vigilant-ritchie-y3u73n`.

**3. VS Code.** Instálalo y abre la carpeta del proyecto (**File → Open Folder**). En la pestaña de extensiones (icono de cuadrados a la izquierda) instala:
- **Luau Language Server** (autor: JohnnyMorganz)
- **Selene** (autor: Kampfkarren)
- **StyLua** (autor: JohnnyMorganz) — opcional
[VERIFICAR EN DOCUMENTACIÓN: nombres exactos en el Marketplace de VS Code]

**4. Rokit.** Ve a github.com/rojo-rbx/rokit → **Releases** → descarga la versión para tu sistema (Windows: archivo `...windows-x86_64.zip`), descomprímela y ejecuta `rokit.exe`; se instalará sola. Cierra y vuelve a abrir VS Code. [VERIFICAR EN DOCUMENTACIÓN: sección "Installation" del README de Rokit]

**5. Instalar las herramientas del proyecto.** En VS Code abre una terminal (**Terminal → New Terminal**) y escribe:
```
rokit install
```
Si pregunta si confías en las herramientas, responde que sí. Comprueba con `rojo --version` → debe decir `Rojo 7.7.1`.

**6. Plugin de Rojo para Studio.** En la misma terminal:
```
rojo plugin install
```
Abre (o reinicia) Studio: en la pestaña **Plugins** debe aparecer **Rojo**.

**7. Crear el lugar de desarrollo.** En Studio: **New → Baseplate**. Luego **File → Publish to Roblox** → nombre: `ECLIPSE (dev)`. Este será tu lugar de pruebas.

## Conectar y probar (cada vez que trabajes)

**8. Iniciar la sincronización.** En la terminal de VS Code:
```
rojo serve
```
Resultado esperado: un mensaje indicando que Rojo escucha en el puerto `34872`. Deja esa terminal abierta.

**9. Conectar Studio.** En Studio: **Plugins → Rojo** → **Connect** (dirección `localhost`, puerto `34872`). Si pregunta, acepta los cambios.
En **View → Explorer** deben aparecer las carpetas `Shared`, `Server` y `Client` con el árbol de arriba.

**10. Probar.** Abre **View → Output** y pulsa **Play** (F5). Resultado esperado en Output (además de mensajes propios de Roblox):
```
[Server] ECLIPSE: The Fragments of Dawn v0.0.1
[ExampleService] Init
[ExampleService] Start
[Server] 1 módulo(s) iniciado(s)
[Client] ECLIPSE: The Fragments of Dawn v0.0.1
[ExampleController] Init
[ExampleController] Start
[Client] 1 módulo(s) iniciado(s)
```
No debe haber texto rojo ni naranja con `[Server]` o `[Client]`.

**11. Probar la sincronización en vivo.** Detén el juego (**Stop**). En VS Code abre `src/shared/Config/GameInfo.luau`, cambia `"0.0.1"` por `"0.0.2"` y guarda (Ctrl+S). Pulsa Play: Output debe mostrar `v0.0.2`. Después vuelve a poner `"0.0.1"`.

**12. Revisor de código.** En la terminal: `selene src`. La primera vez descarga la lista de APIs de Roblox. Resultado esperado: `Results: 0 errors, 0 warnings`.

### Problemas comunes
| Síntoma | Solución |
|---|---|
| `rokit` o `rojo` "no se reconoce como comando" | Cierra y vuelve a abrir VS Code (o el PC) tras instalar Rokit |
| El plugin no conecta | Comprueba que `rojo serve` sigue abierto y que el puerto es `34872` |
| Cambié un script en Studio y se borró mi cambio | Normal: el código se edita **solo en VS Code**; Rojo sobrescribe Studio |
| No aparece la pestaña de Rojo en Studio | Repite el paso 6 con Studio cerrado y vuelve a abrirlo |

### Qué me tienes que contar
1. ¿Completaste los pasos 1–12?
2. Copia lo que salió en **Output** al pulsar Play (paso 10).
3. ¿Qué dijo `selene src` (paso 12)?
4. Cualquier error, tal cual aparece.
