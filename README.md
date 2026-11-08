# ECLIPSE: The Fragments of Dawn

RPG de acción y aventura cooperativo de estética anime para Roblox.

- **Diseño y decisiones:** carpeta [`docs/`](docs/)
- **Ver el juego en Studio sin instalar nada más:** abre `builds/ECLIPSE-dev.rbxl` con Studio (File → Open from File) y pulsa Play. Detalles en [`docs/seccion-3/entrega-3.3-combate-en-red.md`](docs/seccion-3/entrega-3.3-combate-en-red.md)
- **Cómo preparar tu PC y conectar con Roblox Studio:** [`docs/seccion-2/entrega-2D-esqueleto.md`](docs/seccion-2/entrega-2D-esqueleto.md)

## Estructura
| Carpeta | En Roblox Studio | Qué contiene |
|---|---|---|
| `src/server` | ServerScriptService › Server | Código del servidor (servicios) |
| `src/client` | StarterPlayer › StarterPlayerScripts › Client | Código del cliente (controladores) |
| `src/shared` | ReplicatedStorage › Shared | Configuración y utilidades compartidas |

## Comandos
| Comando | Para qué |
|---|---|
| `rokit install` | Instala Rojo, Selene y StyLua en las versiones del proyecto |
| `rojo serve` | Sincroniza el código con Studio en vivo |
| `rojo build build.project.json -o builds/ECLIPSE-dev.rbxl` | Genera el lugar de prueba listo para abrir |
| `selene src` | Revisa el código en busca de errores comunes |
| `stylua src` | Da formato al código |

## Textos (español / inglés)
Todos los textos visibles están en `src/shared/Localization/Strings.csv` (columnas `Key, Source, Context, Example, es, en`).
Para añadir o cambiar un texto, edita esa fila; en el código se usa con `Strings.get("Clave")`.

El mapa se construye en Studio. El mapa provisional en bloques (`map/VerdantiaBlockout.model.json`, generado por `tools/generate_blockout.py`) solo se incluye en el lugar de prueba `builds/ECLIPSE-dev.rbxl`.
