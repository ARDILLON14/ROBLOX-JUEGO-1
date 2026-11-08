# ECLIPSE: The Fragments of Dawn — Sección 1, Entrega 1A
## Diagnóstico, revisión de alcance, riesgos y preguntas críticas

---

## 1. Diagnóstico

### 1.1 Qué puede hacer atractiva la versión 1
| Elemento | Por qué engancha | Coste para ti |
|---|---|---|
| **Combate con buena "sensación"** (*game feel*: hitstop = micro-pausa al golpear, sacudida de cámara, números de daño, sonido contundente) | Es lo primero que el jugador nota en los primeros 30 segundos. Un combate que "se siente bien" compensa gráficos sencillos. | Medio. Son trucos baratos que se suman. |
| **Jefe cooperativo con patrones legibles** | Da un objetivo claro a la sesión y un motivo para jugar con amigos. | Alto, pero es el clímax de la v1. |
| **Progresión corta y visible** (subir de nivel cada 5–10 min al inicio) | Recompensa constante, clave para retener jugadores de 13+. | Bajo. |
| **Misterio del Éter** contado con el entorno (ruinas, inscripciones, cristales) | Le da identidad al mundo sin escribir mucho diálogo. | Bajo–medio. |
| **Estética anime propia** (VFX de colores saturados, contornos, UI estilizada) | Es lo que buscan los jugadores del género. | Medio. Depende de los assets. |

### 1.2 Qué la diferencia de otros juegos de Roblox
Muchos RPG de anime en Roblox se basan en *grind* (repetir lo mismo para subir estadísticas) y en sistemas de azar. La v1 puede diferenciarse así:
1. **Habilidad sobre estadísticas:** la esquiva y el bloqueo con *timing* importan más que el nivel. Un jugador hábil de nivel bajo puede vencer al jefe.
2. **Cooperación con sentido:** [PROPUESTA] **Resonancia**: si un enemigo está *Quemado* (fuego) y recibe un golpe de rayo, se produce una pequeña explosión extra. Cuesta poco de programar (un estado + una comprobación en el servidor) y premia que jugadores con afinidades distintas jueguen juntos.
3. **Exploración recompensada:** [PROPUESTA] **Fragmentos de Amanecer** escondidos en Verdantia. Cada uno desbloquea una línea de lore en el diario y da un pequeño bonus de XP. Encaja con el título del juego y anima a explorar.

### 1.3 Lo más difícil técnicamente para un principiante
| # | Desafío | Por qué es difícil |
|---|---|---|
| 1 | **Combate en red** | Roblox es cliente-servidor: tu PC (cliente) y el servidor de Roblox ven el juego con un pequeño retraso (*latencia*). El golpe tiene que *sentirse* instantáneo en tu pantalla, pero el **servidor** debe decidir si acertó y cuánto daño hizo (server-authoritative). Equilibrar las dos cosas es el reto central del proyecto. |
| 2 | **Animaciones** | Sin animaciones propias de katana y mandoble, el combate no funciona. Hay que aprender el *Animation Editor* de Studio (pestaña **Avatar** → **Animation Editor**, gratis). |
| 3 | **Guardado de datos** | Un error puede borrar el progreso de los jugadores. Se usa *DataStoreService* (el servicio de Roblox para guardar datos en la nube). Recomiendo envolverlo con un módulo probado y gratuito como **ProfileStore** [VERIFICAR EN DOCUMENTACIÓN: busca "DataStoreService" y "limits" en create.roblox.com/docs]. |
| 4 | **IA de enemigos y jefe** | Hay que programar estados (patrullar → perseguir → atacar → retirarse) y que no rompan el rendimiento con muchos enemigos. |
| 5 | **Interfaz adaptable a PC y móvil** | Si la UI usa tamaños fijos en píxeles, en móvil se rompe. Se diseña desde el inicio con escalas relativas. |

### 1.4 Orden recomendado
```
1. Preparación: Studio básico + Rojo + GitHub  (Rojo sincroniza los archivos de tu PC/GitHub con Studio)
2. Movimiento y cámara
3. Combate LOCAL contra un muñeco de prueba (ligero → pesado → combo → esquiva → bloqueo)
4. Combate en RED (el servidor valida el daño)       ← punto crítico
5. Guardado de datos (pronto, para no rehacerlo después)
6. Experiencia y niveles
7. Enemigo 1 completo → SLICE VERTICAL (mini-versión jugable de punta a punta)
8. Mandoble + afinidades (fuego, rayo)
9. Enemigos 2 y 3 + inventario
10. Misiones + mapa de Verdantia
11. Jefe
12. UI final + idiomas español/inglés
13. Pulido, pruebas con jugadores, publicación
```
La regla: **primero que funcione feo, luego que se vea bonito.** El arte del mapa va casi al final porque cambia mucho mientras se diseña.

---

## 2. Revisión del alcance

### 2.1 Estimación honesta [SUPUESTO: un principiante tarda entre 2 y 3 veces más que alguien con experiencia; las horas incluyen aprender]
| Bloque | Horas aprox. |
|---|---|
| Preparación (Studio, Rojo, Git, conceptos de Luau) | 20 |
| Movimiento y cámara | 15 |
| Combate base + red | 60 |
| Armas (katana, mandoble) | 20 |
| Afinidades (2 habilidades) | 25 |
| 3 enemigos + IA | 45 |
| Jefe (2–3 fases) | 40 |
| Experiencia y niveles | 10 |
| Inventario | 20 |
| Misiones | 25 |
| Guardado | 15 |
| Mapa de Verdantia | 50 |
| UI + idiomas | 35 |
| Animaciones, VFX y sonido | 50 |
| Pruebas, bugs, pulido y publicación | 50 |
| **Total** | **≈ 480 h ≈ 30 semanas (~7 meses) a 16 h/sem** |

**Veredicto:** es viable, pero va justo. Siete meses es mucho tiempo sin publicar nada para un primer proyecto (riesgo de abandono). Recomiendo estos recortes, que no tocan la arquitectura y se pueden ampliar después:

### 2.2 Recortes recomendados
| Sistema | Versión original | Versión recortada [PROPUESTA] | Ahorro |
|---|---|---|---|
| Jefe | 2–3 fases | **2 fases** (la 2.ª con ataques nuevos y más rápida) | ~10 h |
| Enemigos | 3 tipos únicos | **2 cuerpos base + 1 variante** (por ejemplo, el lobo de Éter y su versión "Alfa" con otro color, más vida y un ataque extra). Cuenta como 3 tipos. | ~15 h |
| Inventario | Ranuras y arrastrar-soltar | **Lista simple**: armas (equipar) y pociones (usar). Sin arrastrar. | ~10 h |
| Mapa | Bosque grande | **3 zonas compactas + arena del jefe** | ~20 h |
| Misiones | Diálogos con opciones | **Cadena lineal de 6–8 misiones** con 3 tipos: hablar, ir a, derrotar/recoger | ~10 h |
| Animaciones | Únicas para todo | Las dos armas **comparten estructura** de combo (3 golpes + pesado); cambian velocidad, alcance y animación | ~20 h |
| Móvil | — | **No se construyen controles táctiles en la v1**, pero el sistema de entrada se diseña para añadirlos sin rehacer nada | (ya previsto) |

**Total recortado ≈ 390 h ≈ 24–25 semanas (~6 meses).**
**Hito intermedio recomendado:** el *slice vertical* (paso 7 del orden) hacia la **semana 8–10**, para probarlo con amigos y confirmar que el combate es divertido antes de construir el resto.

---

## 3. Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| **Rendimiento** (lag con muchos jugadores/enemigos/efectos) | Media | Alto | Límite de enemigos activos por zona; VFX en el cliente (solo visual); IA que "duerme" cuando no hay jugadores cerca; pruebas con el **MicroProfiler** (Ctrl+F6 en Studio) [VERIFICAR EN DOCUMENTACIÓN: "MicroProfiler"]. |
| **Pérdida de datos** | Media | Muy alto | Módulo de guardado probado (ProfileStore), guardado al salir y periódico, bloqueo de sesión, versión de esquema de datos, probar en un *place* de pruebas. |
| **Exploits** (trampas: daño falso, XP infinita, teletransporte) | Alta | Alto | Server-authoritative: el cliente solo envía "quiero atacar"; el servidor comprueba el enfriamiento (*cooldown*), la distancia y el estado, y calcula el daño. Límite de mensajes por segundo en los *RemoteEvents* (los canales de comunicación cliente↔servidor). |
| **Complejidad** (código enredado e imposible de ampliar) | Alta | Alto | Arquitectura de módulos simple aprobada en la Sección 2; datos de armas, enemigos y misiones en tablas de configuración, no dentro de la lógica. |
| **Experiencia del jugador** (no entiende qué hacer y se va en 2 minutos) | Alta | Muy alto | Primera misión que enseña los controles en menos de 2 minutos; indicador de objetivo siempre visible; probar con 3–5 personas que no conozcan el juego. |
| **Tiempo de desarrollo** (pierdes la motivación antes de terminar) | Alta | Muy alto | Recortes de la sección 2.2; slice vertical en ~10 semanas; metas semanales pequeñas y visibles. |
| **Dependencia de la IA** (código que no entiendes, APIs inventadas, bugs ocultos) | Alta | Alto | Cada script de IA se revisa y se prueba antes de integrarlo; tú debes poder explicar qué hace cada archivo; commits pequeños en GitHub para poder volver atrás; etiqueta [VERIFICAR EN DOCUMENTACIÓN]. |
| **Falta de assets** (modelos, animaciones, sonidos) | Alta | Medio–Alto | Estilo visual simple y coherente (low-poly + VFX llamativos); Creator Store gratuito (en Studio: pestaña **Window** → **Toolbox**), revisando siempre los scripts de lo que insertes porque pueden contener código malicioso; IA de 3D con plan gratuito para objetos sueltos; animaciones hechas por ti en el Animation Editor. |
| **Políticas de Roblox** (contenido, edad) | Baja | Alto | Violencia fantasiosa sin sangre; completar el cuestionario de madurez de la experiencia [VERIFICAR EN DOCUMENTACIÓN: "Maturity & Compliance questionnaire"]; filtrar cualquier texto escrito por jugadores. |

---

## 4. Preguntas críticas (ordenadas por impacto)

**1. ¿Trabajas con Rojo + GitHub o directamente en Studio?**
Rojo es una herramienta gratuita que sincroniza los scripts de una carpeta de tu PC (la que está en GitHub y edita Codex) con Studio. Sin Rojo, el código vive dentro del archivo de Studio y GitHub no lo ve.
→ **Recomendación:** Rojo para **todo el código**; Studio para construir el mapa y los modelos.

**2. ¿El jugador usa su propio avatar de Roblox o un personaje fijo del juego?**
→ **Recomendación:** **su avatar (R15)**. A los jugadores les gusta verse a sí mismos, te ahorra modelar personajes y las animaciones R15 funcionan con cualquier avatar. La identidad anime se consigue con armas, VFX, entorno e interfaz.

**3. ¿Cómo se apunta en combate?**
→ **Recomendación:** **ataques hacia donde mira la cámara**, con el personaje girando automáticamente (estilo *shift-lock*), **sin fijación de objetivo (lock-on) en la v1**. Es lo más sencillo, funciona bien con ratón y se adapta a móvil con un joystick y botones.

**4. ¿Cuántos jugadores por servidor y cómo se reparten las recompensas?**
→ **Recomendación:** **6 jugadores por servidor**. Enemigos compartidos; cada jugador que haya hecho al menos un pequeño porcentaje del daño recibe la XP completa y su propio botín (nadie "roba" kills).

**5. ¿Cómo se obtienen las afinidades?**
→ **Recomendación:** al llegar a **nivel 5** una misión te deja **elegir fuego o rayo**, y puedes cambiarla **gratis** en un NPC del campamento. Así todos prueban las dos y la Resonancia (si la apruebas) aparece de forma natural en grupo.

**6. ¿Estás dispuesto a aprender Blender básico más adelante?**
Blender es un programa de modelado 3D gratuito. Las IA de 3D generan modelos que casi siempre necesitan retoques: reducir polígonos, corregir escala o separar piezas.
→ **Recomendación:** **no al principio**. Usa bloques de Studio, el Creator Store y modelos IA sencillos hasta el slice vertical, y aprende lo mínimo de Blender después solo si hace falta.

**7. ¿Qué pasa al morir?**
→ **Recomendación:** reapareces en el **último punto de control** (fogata/santuario) **sin perder XP ni objetos**. Para 13+ y coop, castigar la muerte frustra más de lo que motiva.

**8. ¿Nivel máximo y duración del contenido?**
→ **Recomendación:** **nivel máximo 20**, unas **2–3 horas** de contenido la primera vez y el jefe repetible con botín propio para dar motivo a volver. Además, un **playtest público temprano** (prueba abierta) al terminar el slice vertical.

---

## ESTADO DEL PROYECTO — v1
- **Sección / entrega:** Sección 1 — Entrega 1A (Diagnóstico y preguntas). Esperando respuestas.
- **Decisiones aprobadas:** ninguna todavía. El alcance base del prompt (región Verdantia, sistemas de la v1, principios permanentes) se toma como punto de partida.
- **Supuestos:**
  - [SUPUESTO] Las estimaciones de horas consideran a un principiante y el tiempo de aprendizaje.
  - [SUPUESTO] El código se gestionará con GitHub + Codex (pendiente de confirmar Rojo).
- **Propuestas abiertas:** recortes de la sección 2.2; Resonancia fuego+rayo; Fragmentos de Amanecer coleccionables; slice vertical en la semana 8–10.
- **Pendientes:** respuestas a las 8 preguntas; aprobación o rechazo de los recortes y las propuestas.
- **Archivos creados o modificados:** `docs/seccion-1/entrega-1A-diagnostico.md`
- **Siguiente paso:** con tus respuestas, preparar la **Entrega 1B — GDD de la versión 1**.
