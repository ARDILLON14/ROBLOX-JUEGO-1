# Sección 4 — Entrega 4.4 (semana 24)
## Equilibrado, métricas (Analytics) y página del juego

La **semana 23** ("correcciones de la prueba pública") queda **[PENDIENTE]**: depende de los resultados de la prueba, que aún no se han recibido. Esta entrega adelanta la semana 24.

Comprobado fuera de Studio: Rojo construye, sin errores de tipos en nuestro código, formato correcto. **No probado en Studio.**

## 1. Equilibrado (estimación por simulación)
Herramienta: `tools/balance_sim.py` (Python). Simula cuánto tarda un jugador en subir de nivel con los valores actuales (vida de enemigos, daño por nivel, XP de enemigos, misiones, Fragmentos y jefe). Es una **estimación** [SUPUESTO]: la prueba pública manda.

| Momento | Objetivo del GDD | Antes | Después del ajuste |
|---|---|---|---|
| Nivel 5 (afinidad) | 30–40 min | ~5–10 min | ~15–20 min |
| Listo para el jefe (nivel 15) | ~2,5 h | ~1 h 15 min | ~2 h |
| Nivel 20 | 4–5 h | ~21 victorias contra el jefe | ~7 victorias (~2 h 40 min + repeticiones) |

**Cambios aplicados** (eran valores iniciales marcados como [SUPUESTO]):
| Valor | Antes | Ahora |
|---|---|---|
| XP del Brotespina por nivel | 15 | **10** |
| XP del Lanzador por nivel | 18 | **12** |
| XP del Centinela por nivel | 38 | **30** |
| XP del jefe por victoria | 1500 | **4000** |

Si en la prueba pública la gente sube demasiado rápido o demasiado lento, se ajustan estos números en `Config/Enemies.luau` y `Config/Bosses.luau`, y se vuelve a ejecutar la simulación.

## 2. Métricas (GDD §12)
| Archivo | Qué hace |
|---|---|
| `src/server/Services/MetricsService.luau` | **Embudo de bienvenida** de Roblox Analytics: registra una vez por jugador, y en orden, hasta dónde llega |
| `src/server/Data/DataTemplate.luau` | Nuevos contadores: `OnboardingStep`, `EnemiesDefeated`, `BossDefeats` |

| Paso | Significa | Meta del GDD |
|---|---|---|
| 1 Entró | — | — |
| 2 Aceptó la primera misión | Encontró a Ilen | — |
| 3 Tutorial completado | Entendió los controles | ≥ 70 % de los que entran |
| 4 Primer enemigo derrotado | Llegó a combatir de verdad | — |
| 5 Nivel 3 | — | — |
| 6 Nivel 5 | Llegó a la afinidad | ≥ 35 % |
| 7 Afinidad despertada | Completó la misión 5 | — |
| 8 Nivel 10 | Jugador comprometido | — |
| 9 Jefe derrotado | Completó la historia | ≥ 10 % |

**Dónde verlo:** Creator Hub → tu experiencia → **Analytics** (retención D1/D7, tiempo de sesión y embudos) [VERIFICAR EN STUDIO: nombre exacto del panel]. Los datos tardan en aparecer (normalmente al día siguiente).

**Cómo leerlo:** si muchos se quedan entre el paso 1 y el 3, el inicio confunde (controles, Ilen difícil de encontrar). Si se quedan entre el 4 y el 6, el ritmo es lento o el combate aburre.

## 3. Página del juego (Creator Hub)
### Nombre
- ES / EN: **ECLIPSE: The Fragments of Dawn** (nombre único; el subtítulo se traduce en la descripción)

### Descripción (pegar en Creator Hub; añade la traducción en la sección de localización del juego) [VERIFICAR EN DOCUMENTACIÓN: "Translate experience name and description"]
**Español**
> ⚔️ Explora Verdantia, un bosque ancestral corrompido por el Gran Eclipse.
> 🗡️ Domina la katana o el mandoble con combos, esquivas y bloqueos perfectos.
> 🔥⚡ Despierta el fuego o el rayo, sube su maestría y desbloquea tu ulti.
> 🤝 Juega con hasta 12 amigos: ¡combina fuego y rayo para provocar la RESONANCIA!
> 🌳 Encuentra los 10 Fragmentos de Amanecer y descubre los secretos de los Aelith.
> 👹 Enfrentaos a Vharok, el Guardián Marchito.
> Controles: WASD moverse · Clic atacar · Clic derecho golpe pesado · Q esquivar · F bloquear · Z habilidad · X ulti · 1 poción · Tab/I inventario · J diario · P ajustes

**English**
> ⚔️ Explore Verdantia, an ancient forest corrupted by the Great Eclipse.
> 🗡️ Master the katana or greatsword with combos, dodges and perfect blocks.
> 🔥⚡ Awaken fire or lightning, raise your mastery and unlock your ultimate.
> 🤝 Play with up to 12 friends: combine fire and lightning to trigger RESONANCE!
> 🌳 Find the 10 Fragments of Dawn and uncover the secrets of the Aelith.
> 👹 Face Vharok, the Withered Warden.
> Controls: WASD move · Click attack · Right click heavy strike · Q dodge · F block · Z skill · X ultimate · 1 potion · Tab/I inventory · J journal · P settings

### Ajustes de la página
| Campo | Valor recomendado |
|---|---|
| Género | RPG / Aventura |
| Dispositivos | **Solo PC** en la v1 (el móvil llega en la primera actualización) [VERIFICAR: dónde se eligen los dispositivos] |
| Jugadores por servidor | 12 |
| Cuestionario de madurez | Violencia fantasiosa leve, sin sangre ni gore |

### Icono y miniaturas (gratis)
- **Icono** (cuadrado) [VERIFICAR: tamaño recomendado, normalmente 512×512]: tu personaje con la katana sobre fondo morado con un sol eclipsado. Hazlo con una captura de Studio (cámara cerca, iluminación del Corazón del Bosque) y edítalo en un editor gratuito (Canva, Photopea).
- **Miniaturas** (16:9) [VERIFICAR: tamaño recomendado, normalmente 1920×1080]: 1) combate contra Vharok en fase 2; 2) Resonancia morada con dos jugadores; 3) la Linde Esmeralda con flores y árboles; 4) el Santuario de las Ruinas.
- Normas: sin texto engañoso, sin imágenes de otros juegos, sin promesas de cosas que no hay. [VERIFICAR EN DOCUMENTACIÓN: "Thumbnail guidelines"]

---

## Pruebas de esta entrega
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play | Output: `v0.17.0`, `[Server] 16 módulo(s)`. Nada en rojo. En Studio pueden salir avisos `[MetricsService]` si Analytics no está disponible en pruebas: no pasa nada |
| 2 | Derrota un Brotespina de nivel 1 | +10 XP (antes 15) |
| 3 | Con guardado real: completa Q01 y derrota un enemigo; Stop y Play | No se repiten los pasos ya registrados (no hay forma de verlo en Studio; se comprobará en Analytics tras publicar) |
