# ECLIPSE: The Fragments of Dawn — Sección 1, Entrega 1B
## GDD de la versión 1 — Parte 1 (puntos 1–6)

> Nombres propios en formato **Español / English** (el juego es bilingüe). Todos los nombres son originales y están sujetos a tu aprobación.

---

## 1. Visión, propuesta de valor y pilares

**Visión:** un RPG de acción cooperativo de estética anime en el que dominar el combate y el Éter importa más que repetir tareas.

**Propuesta de valor (lo que diríamos en la página del juego):**
> "Explora Verdantia, un bosque ancestral corrompido por el Gran Eclipse. Domina la katana o el mandoble, despierta el fuego o el rayo y enfréntate con tus amigos al Guardián Marchito."

**3 pilares de diseño.** Cada idea nueva debe apoyar al menos uno; si no apoya ninguno, se descarta:

| Pilar | Qué significa | Ejemplos en la v1 |
|---|---|---|
| **1. Combate que se siente** | Cada golpe tiene peso; el timing y la lectura del enemigo importan | Hitstop, bloqueo perfecto, ataques enemigos telegrafiados |
| **2. Juntos somos más fuertes** | Jugar en grupo es más divertido y eficiente, nunca obligatorio | Resonancia fuego+rayo, recompensa por contribución, jefe que escala |
| **3. Un mundo que guarda secretos** | Explorar se recompensa con lore y progreso | Fragmentos de Amanecer, inscripciones de los Aelith |

---

## 2. Historia de Verdantia y cómo se cuenta

### 2.1 Historia [PROPUESTA]
- Hace miles de años, la civilización **Aelith** descubrió el **Éter** y construyó santuarios en el corazón de Verdantia, alrededor del **Árbol Primigenio / Primeval Tree**, que canalizaba el Éter de forma pura.
- Durante el **Gran Eclipse**, el sol se apagó por un instante y el Éter se descontroló. El mundo se fragmentó. En Verdantia, el Éter crudo empapó las raíces del Árbol y **corrompió** a sus criaturas y a su protector, **Vharok, el Guardián Marchito / Vharok, the Withered Warden**.
- Cuando volvió la luz, el primer amanecer dejó caer **Fragmentos de Amanecer / Fragments of Dawn**: cristales de luz pura capaces de calmar el Éter corrupto.
- Hoy, los **Exploradores del Alba / Dawn Seekers** (los jugadores) llegan al **Campamento del Alba / Dawn Camp**, en el borde del bosque, guiados por la **Maestra Ilen / Master Ilen**, una exploradora veterana.
- **Final de la v1:** al derrotar a Vharok, el Árbol se purifica en parte y revela un portal sellado con un símbolo de otra región. Es un gancho para futuras actualizaciones sin tener que diseñarlas ahora.

### 2.2 Cómo se cuenta dentro del juego
| Medio | Uso | Coste |
|---|---|---|
| Intro corta (≈30 s): movimientos de cámara sobre el bosque + texto en pantalla | Presenta el mundo al entrar por primera vez; se puede saltar | Bajo |
| Diálogos de NPC en caja de texto (Maestra Ilen y 2–3 NPC más) | Dar misiones y contexto | Bajo |
| Inscripciones Aelith (el jugador se acerca y lee) | Lore ambiental opcional | Muy bajo |
| Fragmentos de Amanecer → entrada en el **Diario** | Lore coleccionable | Bajo |
| Entorno: ruinas, raíces moradas, cristales | Contar sin palabras | Incluido en el mapa |

Regla: textos cortos (máx. 2–3 líneas por caja); todo texto pasa por el sistema de idiomas.

---

## 3. Gameplay loop

### 3.1 Minuto a minuto (bucle corto, 1–3 min)
```
Explorar → Encontrar enemigos → Combatir → Recibir XP / botín / maestría
    ↑                                                     ↓
    └──── Avanzar misión / encontrar Fragmento ←──────────┘
```

### 3.2 Sesión de 15–20 minutos (jugador nuevo)
| Minuto | Qué pasa |
|---|---|
| 0–2 | Intro, aparece en el Campamento del Alba, la Maestra Ilen enseña movimiento y ataques con un muñeco de prueba |
| 2–6 | Primera misión en la Zona 1: derrotar Brotespinas; sube a nivel 2 (animación + recompensa) |
| 6–10 | Encuentra su primer Fragmento; aprende esquiva y bloqueo contra un enemigo más fuerte; nivel 3 |
| 10–15 | Recibe el mandoble, prueba las dos armas; misión de ir a las ruinas; nivel 4 |
| 15–20 | Vuelve al campamento: entrega misiones; ve a otros jugadores; objetivo siguiente visible: "Llega a nivel 5 para despertar tu afinidad" |

### 3.3 Sesiones posteriores
- **Sesión 2–3:** afinidad (nivel 5), Zona 2, enemigos nuevos, maestría.
- **Sesión 4–6:** Zona 3, preparación y combate contra el jefe (en grupo).
- **Después:** repetir el jefe por botín épico, completar maestrías, encontrar todos los Fragmentos, llegar a nivel 20.

---

## 4. Combate

### 4.1 Controles
| Acción | PC | Móvil (futuro) |
|---|---|---|
| Moverse | WASD | Joystick virtual (izquierda) |
| Cámara | Ratón (cámara bloqueada tipo shift-lock) | Deslizar en la mitad derecha |
| Saltar | Espacio | Botón saltar |
| Ataque ligero | Clic izquierdo | Botón grande "Atacar" |
| Ataque pesado | Clic derecho | Botón "Pesado" |
| Bloquear | F (mantener) | Botón "Bloquear" (mantener) |
| Esquivar | Q | Botón "Esquivar" |
| Habilidad de afinidad | Z | Botón de habilidad |
| Ulti | X | Botón de ulti (solo visible si está cargada) |
| Usar poción | 1 | Botón de poción |
| Interactuar | E | Botón que aparece al acercarse |
| Inventario / Misiones-Diario | Tab / J | Iconos en la parte superior |

La clave técnica: el juego no pregunta "¿pulsó la tecla F?", sino "¿pidió **Bloquear**?". Así, añadir botones táctiles más tarde no obliga a tocar el combate. [VERIFICAR EN DOCUMENTACIÓN: "ContextActionService" y "UserInputService"; se verá en la Sección 2]

### 4.2 Ataques y combo
| Entrada | Resultado |
|---|---|
| Ligero ×3 | Combo de 3 golpes; el 3.º empuja al enemigo |
| Ligero, Ligero, **Pesado** | **Remate**: rompe la guardia y aturde brevemente |
| Pesado solo | Golpe lento y fuerte; rompe la guardia de enemigos que bloquean |
| Pausa > 0,8 s entre golpes | El combo se reinicia |

### 4.3 Esquiva y bloqueo
- **Esquiva:** desplazamiento corto en la dirección del movimiento, con **invulnerabilidad (~0,3 s)**. Enfriamiento ~1,2 s. Indicador junto a la barra de vida.
- **Bloqueo:** reduce el daño frontal un 70 %; no puedes atacar mientras bloqueas y te mueves más lento.
- **Bloqueo perfecto:** si bloqueas justo antes del golpe (~0,2 s), anulas el daño y **aturdes** al enemigo. Recompensa la habilidad (pilar 1).
- **Ataques imbloqueables:** los enemigos brillan en **rojo** antes de lanzarlos; hay que esquivarlos.
- Sin barra de estamina en la v1 (menos UI y menos complejidad); los límites los ponen los enfriamientos.

### 4.4 Afinidades y maestría (opción B aprobada)
| Rango | 🔥 Fuego / Fire | ⚡ Rayo / Lightning |
|---|---|---|
| **R1 – Habilidad** | **Tajo Ígneo / Blazing Arc**: arco de fuego frontal; aplica **Quemado** (daño durante 3 s) | **Paso Relámpago / Thunder Step**: embestida corta que atraviesa y daña a los enemigos en el camino |
| **R2 – Mejora** | El arco es más ancho y Quemado dura 5 s | La embestida libera una descarga que salta a 2 enemigos cercanos |
| **R3 – Ulti** | **Erupción del Alba / Dawnburst**: explosión de fuego alrededor del jugador | **Juicio del Trueno / Thunder Verdict**: rayos caen sobre una zona frente al jugador |

- **Maestría:** se gana al usar habilidades y al derrotar enemigos con esa afinidad equipada. Progreso guardado **por afinidad**.
- **Ulti:** se carga haciendo daño; al llenarse, el botón brilla.
- **Resonancia:** golpe de rayo sobre enemigo Quemado → pequeña explosión extra (consume el Quemado). Como cada jugador solo tiene una afinidad equipada, la Resonancia necesita a otro jugador con la afinidad contraria: premia jugar en grupo.

### 4.5 Feedback visual y sonoro
| Momento | Visual | Sonido |
|---|---|---|
| Golpe acertado | Hitstop (~0,05 s), destello blanco en el enemigo, partículas, número de daño | Impacto distinto por arma |
| Golpe crítico / remate | Número más grande y de color, sacudida de cámara leve | Impacto grave |
| Bloqueo / bloqueo perfecto | Chispas / destello dorado + aturdimiento visible | Metálico / "cling" agudo |
| Esquiva | Estela del personaje | "Whoosh" |
| Ataque enemigo próximo | Brillo normal (bloqueable) o rojo (imbloqueable); marcas en el suelo para áreas | Aviso sonoro corto |
| Recibir daño | Borde rojo en pantalla, barra de vida que tiembla | Golpe sordo |

---

## 5. Katana vs. mandoble
| Atributo | Katana | Mandoble / Greatsword |
|---|---|---|
| Estilo | Rápida y precisa; ideal para combos y esquivar | Lenta y contundente; controla grupos |
| Daño por golpe ligero | Bajo (base 10) | Alto (base 18) |
| Velocidad del combo | Rápida (~0,35 s por golpe) | Lenta (~0,6 s por golpe) |
| Alcance / arco | Medio / estrecho | Largo / ancho (golpea a varios) |
| Ataque pesado | Estocada rápida, rompe guardia | Golpe al suelo con pequeña onda, rompe guardia y derriba |
| Movilidad | Puedes esquivar a mitad de combo | Esquivar a mitad de combo tiene un pequeño retraso |
| Daño por segundo aprox. | Ligeramente mayor contra un objetivo | Mayor contra grupos |
| Cómo se obtiene | Desde el inicio | Misión de la Zona 1 (≈ nivel 3–4) |

[SUPUESTO] Los números son puntos de partida; se ajustan en las pruebas.

**Variantes (botín):** cada arma tiene 3 rarezas que solo cambian el daño y el aspecto (color, brillo), no la forma de jugar:

| Rareza | Daño | Cómo se obtiene |
|---|---|---|
| Común | ×1,0 | Inicio / misión |
| Rara | ×1,25 | Enemigos de la Zona 2–3 (probabilidad baja) o misión |
| Épica | ×1,5 | Jefe (probabilidad baja por victoria) |

Total: 6 objetos de arma, usando solo 2 modelos base.

---

## 6. Enemigos y jefe

### 6.1 Enemigos
| Enemigo | Base | Comportamiento | Qué enseña al jugador |
|---|---|---|---|
| **Brotespina / Thornling** | Base 1 (humanoide pequeño de raíces) | Rápido y débil, aparece en grupos de 3–4; ataque de zarpazo bloqueable | Combo básico, el mandoble contra grupos |
| **Brotespina Lanzador / Thornling Spitter** | Variante de la Base 1 (otro color, se queda atrás) | Mantiene distancia y lanza espinas | Esquivar y priorizar objetivos |
| **Centinela Aelith / Aelith Sentry** | Base 2 (humanoide grande de piedra y raíz) | Lento; bloquea de frente; golpe pesado imbloqueable (brillo rojo) | Ataque pesado para romper la guardia, esquivar a tiempo |

**IA (estados):** Inactivo → Patrulla → Persigue → Ataca → Vuelve a su zona si el jugador se aleja demasiado. Los enemigos "duermen" si no hay jugadores cerca.

[PROPUESTA] Ambas bases son **humanoides** a propósito: el rig (esqueleto) humanoide se anima con el mismo Animation Editor que el jugador, y un animal de cuatro patas (como un lobo) sería mucho más difícil de animar para un principiante.

### 6.2 Jefe: Vharok, el Guardián Marchito
Gigante de madera y piedra (Base 2 escalada con piezas extra), en la arena del **Corazón del Bosque**.

| Fase | Vida | Ataques | Oportunidad para el jugador |
|---|---|---|---|
| **1 — Guardián** | 100 % → 50 % | **Zarpazo** (bloqueable); **Barrido de raíces** (marcas en el suelo, esquivar); **Llamada del bosque**: invoca 2 Brotespinas | Castigar después del zarpazo |
| *Transición* | 50 % | Ruge, se envuelve en Éter morado (2 s invulnerable, efecto visual) | — |
| **2 — Marchito** | 50 % → 0 % | Todo más rápido + **Lluvia de espinas** (zonas marcadas en la arena) + **Embestida** (imbloqueable, brillo rojo) | Si la embestida falla y choca contra una columna, queda **aturdido 3 s** (daño extra) |

- **Escala con jugadores:** vida = base × (1 + 0,6 × (jugadores en la arena − 1)). [SUPUESTO] El 0,6 se ajusta en las pruebas.
- **Botín:** cada jugador que contribuyó recibe XP, una poción y una probabilidad de arma Épica.
- **Reaparición:** 3 minutos después de ser derrotado.

---
*Continúa en la parte 2: progresión, inventario y misiones, mapa, interfaz, futuro y métricas.*
