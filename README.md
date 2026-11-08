# ECLIPSE: The Fragments of Dawn

RPG de acción y aventura cooperativo de estética anime para Roblox.

- **Diseño y decisiones:** carpeta [`docs/`](docs/)
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
| `selene src` | Revisa el código en busca de errores comunes |
| `stylua src` | Da formato al código |

El mapa se construye en Studio y **no** está en este repositorio.
