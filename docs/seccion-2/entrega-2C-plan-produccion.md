# ECLIPSE: The Fragments of Dawn — Sección 2, Entrega 2C
## Plan de producción

[SUPUESTO] 16 h/semana (p. ej., 4 sesiones de 4 h). Total estimado ≈ 390 h + colchón.

### Ritmo semanal recomendado
- **Una meta por semana**, que termine en algo que se pueda **probar con Play** en Studio.
- Al final de la semana: commit, nota de 3 líneas en `docs/diario-de-desarrollo.md` (qué funcionó, qué no, qué sigue).
- Si una semana se atrasa, **no se acumula**: se recorta o se mueve, y se avisa en el estado del proyecto.

### Calendario
| Semana | Meta | Resultado que puedes probar | Sección |
|---|---|---|---|
| 0 | Instalar herramientas, primer contacto con Studio | Studio abierto, Rojo conectado (Entrega 2D) | 2 |
| 1 | Esqueleto de servicios/controladores, configuración vacía | En la consola (Output) aparecen los mensajes de arranque de cada servicio | 3 |
| 2 | Entrada por acciones + cámara tipo shift-lock | Te mueves y la cámara gira el personaje; teclas reasignables | 3 |
| 3 | Ataque ligero y combo (local, contra muñeco) con animaciones provisionales | Combo de 3 golpes con su animación | 3 |
| 4 | Pesado, remate, esquiva y bloqueo (local) | Todos los movimientos funcionan contra el muñeco | 3 |
| 5 | **Combate en red**: el servidor valida y calcula; hitstop y números de daño | Dos jugadores (prueba local de 2 jugadores en Studio) ven el mismo daño | 3 |
| 6 | Guardado (ProfileStore) + XP y niveles + efecto de subida de nivel | Sales y vuelves: conservas nivel y XP | 3 |
| 7 | Enemigo 1 (Brotespina): IA, aparición, botín, XP | Combates contra grupos de Brotespinas | 3 |
| 8 | **🎯 HITO 1 — Slice vertical**: Campamento + Linde Esmeralda en bloques, misiones 1–2, HUD básico | Prueba con 2–4 amigos | 3 |
| 9 | Correcciones del playtest + mandoble | Dos armas jugables | 3 |
| 10 | Rarezas de armas + inventario | Equipas armas desde el inventario | 3 |
| 11 | Afinidad Fuego (R1–R3) + elección a nivel 5 | Tajo Ígneo, mejora y ulti | 3 |
| 12 | Afinidad Rayo + maestría + Resonancia | Dos jugadores provocan Resonancia | 3 |
| 13 | Lanzador y Centinela | Los 3 enemigos en juego | 3 |
| 14 | Sistema de misiones completo (8) + diálogos | Cadena completa jugable | 3 |
| 15–16 | Mapa completo en bloques + fogatas, viaje rápido, Fragmentos | Recorrido completo de Verdantia | 3 |
| 17–18 | Jefe Vharok (fase 1, luego fase 2 y escalado) | Combate de jefe completo | 3 |
| 19 | UI final (inventario, diario, ajustes, muerte) + idiomas ES/EN | Cambias de idioma y todo se traduce | 3 |
| 20 | Arte del mapa (Toolbox revisado, modelos IA sencillos), iluminación | Verdantia "se ve bonita" | 4 |
| 21 | VFX y sonido, pulido del game feel | El combate "se siente" | 4 |
| 22 | Rendimiento y seguridad (MicroProfiler, pruebas de trampas) + **🎯 HITO 2 — Playtest público** | Prueba abierta con desconocidos | 4 |
| 23 | Correcciones del playtest | — | 4 |
| 24 | Equilibrado, eventos de métricas, cuestionario de madurez, página del juego (icono, miniaturas, descripción ES/EN) | Todo listo para publicar | 4 |
| 25 | **🚀 Publicación de la v1** | Juego público | 4 |
| 26–28 | **Colchón** para imprevistos (es normal usarlo) | — | — |

**Fecha realista de publicación: entre las semanas 25 y 28 (~6–7 meses).**

### Criterios de los hitos
| Hito | Se considera logrado si… |
|---|---|
| Slice vertical (S8) | Un amigo entra, entiende los controles sin ayuda en < 2 min, derrota Brotespinas, sube de nivel, sale y al volver conserva su progreso, sin errores en la consola |
| Playtest público (S22) | 10+ desconocidos juegan; recoges su opinión; no hay pérdida de datos ni errores graves |
| Publicación (S25) | Todo el contenido del GDD v1, ambos idiomas, cuestionario de madurez completado |

### Plan de assets (gratuitos)
| Asset | Hasta el slice vertical | Para la versión final |
|---|---|---|
| Animaciones | Provisionales hechas por ti en el Animation Editor (rápidas y simples) | Mejoradas en el Animation Editor |
| Armas | Bloques con forma de espada | Modelos del Creator Store o generados con IA y revisados |
| Enemigos | Rig humanoide con colores | Rig con piezas decorativas (raíces, piedra) |
| Mapa | Bloques grises (*blockout*) | Toolbox revisado + terreno de Roblox + iluminación |
| Sonido | Biblioteca de audio gratuita de Roblox (Creator Store → Audio) | La misma, mejor seleccionada |
| VFX | Partículas básicas de Studio | Partículas ajustadas con colores de afinidad |
