# ECLIPSE: The Fragments of Dawn — Sección 2, Entrega 2B
## Datos y red

---

## 1. Datos guardados del jugador

### 1.1 Qué se guarda [PROPUESTA]
Se guarda con ProfileStore bajo la clave `Player_<UserId>`. Todos los nombres van en inglés (son datos del código).

| Campo | Tipo | Ejemplo | Para qué |
|---|---|---|---|
| `DataVersion` | número | `1` | Saber qué "forma" tienen los datos para poder migrarlos en futuras versiones |
| `Level` | número | `7` | Nivel actual |
| `XP` | número | `830` | XP dentro del nivel actual |
| `Affinity.Selected` | texto o vacío | `"Fire"` | Afinidad equipada (vacío antes del nivel 5) |
| `Affinity.Mastery` | tabla | `{ Fire = 640, Lightning = 0 }` | Puntos de maestría **por afinidad** (no se pierden al cambiar) |
| `Inventory.Weapons` | lista | `{ "Katana_Common", "Greatsword_Common" }` | Armas que tiene |
| `Inventory.EquippedWeapon` | texto | `"Katana_Common"` | Arma en la mano |
| `Inventory.Potions` | número | `4` | Pociones (máx. 10) |
| `Cosmetics.Owned` | lista | `{ "Title_DawnSeeker" }` | Títulos/auras desbloqueados |
| `Cosmetics.EquippedTitle` / `EquippedAura` | texto o vacío | `"Title_DawnSeeker"` | Lo que lleva puesto |
| `Quests.ActiveId` | texto | `"Q04"` | Misión activa |
| `Quests.Progress` | número | `2` | Progreso de la misión activa (p. ej., 2 de 4) |
| `Quests.Completed` | conjunto | `{ Q01 = true, … }` | Misiones terminadas |
| `Fragments` | conjunto | `{ F01 = true, F03 = true }` | Fragmentos encontrados |
| `Campfires` | conjunto | `{ Camp = true, Verge = true }` | Fogatas descubiertas (viaje rápido) |
| `LastCampfire` | texto | `"Verge"` | Dónde reapareces |
| `Settings` | tabla | `{ Language = "auto", ShowOthersDamage = true, … }` | Ajustes del jugador |
| `Meta` | tabla | `{ FirstJoin = …, PlayTime = … }` | Métricas propias |

**No se guarda:** vida actual, posición exacta, enfriamientos, carga de la ulti. Al entrar apareces en `LastCampfire` con vida completa (coherente con "morir no castiga").

### 1.2 Reglas de seguridad de los datos
- Solo **DataService** toca los datos guardados. Los demás servicios piden cambios a través de él (p. ej., `ProgressionService` llama a "añadir XP").
- **Bloqueo de sesión** (lo hace ProfileStore): si el jugador entra en otro servidor antes de que el primero termine de guardar, no se duplican ni se pisan datos.
- Guardado automático periódico y al salir; al cerrar el servidor se espera a que todo se guarde. [VERIFICAR EN DOCUMENTACIÓN: "game:BindToClose"]
- **Migraciones:** si en el futuro cambia la forma de los datos, se sube `DataVersion` y una función convierte los datos viejos. Nunca se borra un campo sin migración.
- Las pruebas de datos se hacen en un **lugar de pruebas** separado para no ensuciar los datos reales. [VERIFICAR EN DOCUMENTACIÓN: "Enable Studio Access to API Services"]

---

## 2. Tablas de configuración
Cada tabla es un ModuleScript en `src/shared/Config/`. Aquí solo se definen sus campos; los valores salen del GDD aprobado.

| Archivo | Una fila describe… | Campos principales |
|---|---|---|
| `WeaponTypes` | Katana / Greatsword | daño ligero, intervalo entre golpes, reinicio de combo, alcance, ancho del arco, multiplicadores pesado/remate, retraso de esquiva, animaciones |
| `Weapons` | Cada arma concreta (6) | tipo, rareza, multiplicador de daño, clave de nombre, modelo |
| `Affinities` | Fire / Lightning | rangos (umbral de maestría, habilidad, mejora, ulti), enfriamientos, daño, Quemado, carga de ulti |
| `Enemies` | Thornling, Spitter, Sentry | vida y daño por nivel, velocidad, rango de detección y de "correa" (*leash*: distancia máxima antes de volver), ataques, XP, botín |
| `Bosses` | Vharok | vida base, factor de escalado (0,6), fases, ataques por fase, botín, reaparición |
| `Levels` | Curva y recompensas | fórmula (100 × n^1,5), nivel máximo (20), mejoras por nivel, recompensas especiales |
| `Quests` | Cada misión (8) | tipo (Talk/GoTo/Defeat/Collect), objetivo, cantidad, NPC, recompensas, siguiente misión |
| `Items` | Pociones y cosméticos | efecto, máximo, enfriamiento, clave de nombre |
| `Zones` | Cada zona | id, rango de nivel, fogatas, Fragmentos, tope de enemigos activos |
| `Combat` | Reglas globales | crítico, bloqueo (×0,3), ventana de bloqueo perfecto (0,2 s), invulnerabilidad de esquiva, tolerancias de red |

### 2.1 Cómo se conecta el mapa con el código
Para no escribir posiciones en el código, en Studio se **marcan** piezas del mapa:
- **Etiquetas (Tags):** nombre que se pone a una pieza (p. ej., `EnemySpawn`, `Campfire`, `Fragment`). El código busca "todas las piezas con la etiqueta X" con *CollectionService*.
- **Atributos (Attributes):** datos que se añaden a una pieza (p. ej., `EnemyId = "Thornling"`, `Zone = "EmeraldVerge"`).
- Dónde en Studio: selecciona la pieza → ventana **Properties** → al final, secciones **Tags** y **Attributes** → botón **+**. [VERIFICAR EN DOCUMENTACIÓN: "CollectionService", "Instance attributes"]

| Etiqueta | Atributos | Lo usa |
|---|---|---|
| `EnemySpawn` | `EnemyId`, `Zone`, `Count` | EnemyService |
| `BossArena` | `BossId` | BossService |
| `Campfire` | `CampfireId`, `Zone` | ZoneService |
| `Fragment` | `FragmentId` | ZoneService |
| `QuestMarker` | `MarkerId` | QuestService |
| `Inscription` | `TextKey` | UIController (lectura) |

---

## 3. Comunicación cliente ↔ servidor

### 3.1 Conceptos nuevos
- **Propiedad de red (network ownership):** Roblox deja que el cliente de cada jugador controle la física de **su propio personaje** (por eso moverse se siente instantáneo). Consecuencia: el servidor no controla directamente el movimiento del jugador, así que debe **comprobar** que sea razonable. Los enemigos los controla el servidor. [VERIFICAR EN DOCUMENTACIÓN: "Network ownership"]
- **UnreliableRemoteEvent:** mensajero que puede perder algún mensaje pero es más ligero. Ideal para cosas cosméticas (efectos de otros jugadores). [VERIFICAR EN DOCUMENTACIÓN: "UnreliableRemoteEvent"]
- **ProximityPrompt:** el aviso "Pulsa E" al acercarte a algo. Su activación llega **directamente al servidor**, sin RemoteEvent propio. Se usa para NPC, fogatas, Fragmentos e inscripciones. [VERIFICAR EN DOCUMENTACIÓN: "ProximityPrompt"]

### 3.2 Mensajes del cliente al servidor (peticiones)
| Mensaje | Datos que envía | El servidor comprueba | Límite [SUPUESTO] |
|---|---|---|---|
| `RequestAttack` | `kind`: "Light" o "Heavy" | Tipo válido · vivo · no aturdido/bloqueando/esquivando · intervalo del arma cumplido · arma equipada y en propiedad | 10/s |
| `RequestDodge` | `direction` (vector) | Vector válido (no NaN, longitud ≈ 1) · enfriamiento · estado | 3/s |
| `RequestBlock` | `active`: sí/no | Booleano · estado | 10/s |
| `RequestAbility` | `kind`: "Skill" o "Ultimate", `aim` (vector) | Afinidad elegida · rango desbloqueado · enfriamiento / ulti cargada · vector válido | 3/s |
| `RequestUsePotion` | — | Tiene pociones · enfriamiento 10 s · vivo | 2/s |
| `RequestEquipWeapon` | `weaponId` | El arma existe en Config y **está en su inventario** · fuera de combate o en reposo | 2/s |
| `RequestEquipCosmetic` | `cosmeticId` | Lo tiene desbloqueado | 2/s |
| `RequestChooseAffinity` | `affinity` | Nivel ≥ 5 · valor válido · cerca del Santuario/NPC | 1/s |
| `RequestFastTravel` | `campfireId` | Fogata descubierta · cerca de una fogata · no en combate | 1/s |
| `RequestDialogueAction` | `npcId`, `action` | NPC cerca · acción válida para su misión actual | 4/s |
| `RequestUpdateSettings` | tabla de ajustes | Solo campos conocidos, tipos y rangos válidos | 2/s |

### 3.3 Mensajes del servidor al cliente
| Mensaje | Datos | Tipo |
|---|---|---|
| `DataSnapshot` | Copia de los datos del jugador al entrar | Fiable |
| `DataChanged` | Campo cambiado + valor (XP, nivel, inventario…) | Fiable |
| `HitConfirmed` | objetivo, daño, tipo (normal/crítico/fuego/rayo/Resonancia/bloqueado), atacante | Fiable al atacante · **no fiable** a los demás jugadores cercanos |
| `LevelUp` | nuevo nivel, recompensas | Fiable (a todos, para ver la columna de luz) |
| `QuestUpdated` | misión, progreso, completada | Fiable |
| `MasteryUpdated` | afinidad, puntos, rango | Fiable |
| `BossPhase` | jefe, fase, vida | Fiable (jugadores en la arena) |
| `Notify` | clave de texto + parámetros | Fiable |

Los avisos de ataque de los enemigos (brillo normal o rojo) se hacen con **atributos** en el enemigo que el cliente observa, sin mensajes extra.

### 3.4 Validaciones comunes (se aplican a todos los mensajes)
1. **Tipo correcto** de cada dato (`typeof`), y valores dentro de una lista permitida.
2. **Números finitos** (ni NaN ni infinito) y vectores normalizados.
3. **Límite de frecuencia por jugador y por mensaje**; si alguien lo supera, se ignoran sus mensajes y se registra.
4. **Estado del jugador** guardado en el servidor (ver §4); nunca se confía en el estado que diga el cliente.
5. **Distancia**: interactuar o golpear solo si está lo bastante cerca, según el servidor.

---

## 4. Estado de combate del jugador (en el servidor)
```
            ┌─────────┐  RequestAttack   ┌───────────┐
            │  Idle   │ ───────────────▶ │ Attacking │ ──(fin del golpe)──┐
            └─────────┘ ◀─────────────── └───────────┘                    │
              │  ▲  ▲                                                       │
 RequestBlock │  │  └──────────────(fin)──────── Dodging ◀── RequestDodge ──┤
              ▼  │                                                          │
            ┌──────────┐   golpe imbloqueable / remate enemigo              │
            │ Blocking │ ─────────────────────────────▶ Stunned ──(tiempo)──┘
            └──────────┘                                  │
                          vida = 0 (desde cualquiera) ──▶ Dead ──(reaparecer)──▶ Idle
```
| Estado | Puede atacar | Puede esquivar | Recibe daño |
|---|---|---|---|
| Idle | Sí | Sí | Sí |
| Attacking | Solo el siguiente golpe del combo | Katana sí; mandoble con retraso | Sí |
| Blocking | No | Sí | ×0,3 de frente; 0 si es bloqueo perfecto |
| Dodging | No | No | **No** (invulnerable ~0,3 s) |
| Stunned | No | No | Sí |
| Dead | No | No | No |

---

## 5. Cálculo de daño (en el servidor) [PROPUESTA]
```
daño = daño_base_del_arma
     × multiplicador_de_rareza        (1 / 1,25 / 1,5)
     × (1 + 0,04 × (nivel − 1))
     × multiplicador_de_ataque        (ligero 1 · pesado 2,2 · remate 1,8)
     × crítico                        (10 % de probabilidad → ×1,5)
```
- Habilidades: daño propio definido en `Affinities`, escalado por nivel igual que arriba.
- Daño al jugador: daño del ataque enemigo × (0,3 si bloquea de frente | 0 si bloqueo perfecto | 0 si esquivando).
- **Detección del golpe:** el servidor revisa una caja delante del jugador (alcance y ancho del arma) y filtra con un ángulo frontal. Para compensar la latencia, la caja es un poco más grande (tolerancia) en vez de "rebobinar el tiempo", que es mucho más complejo. [VERIFICAR EN DOCUMENTACIÓN: "WorldRoot:GetPartBoundsInBox", "OverlapParams"]
- **Contribución para la recompensa:** enemigos normales ≥ 10 % de su vida máxima; jefe ≥ 3 % (con 12 jugadores, la media es ~8 %). [SUPUESTO] Ajustable.

---

## 6. Idiomas (español / inglés)
- Los textos viven en archivos `.csv` dentro de `src/localization/`; Rojo los convierte en una **LocalizationTable** (tabla de traducciones de Roblox). [VERIFICAR EN DOCUMENTACIÓN: "LocalizationTable", y en la documentación de Rojo: "csv localization"]
- Cada texto tiene una **clave** y dos columnas: `es` y `en`.

| Clave | es | en |
|---|---|---|
| `UI.Inventory.Title` | Inventario | Inventory |
| `Quest.Q02.Name` | Raíces Inquietas | Restless Roots |
| `Notify.LevelUp` | ¡NIVEL {level}! | LEVEL {level}! |

- El código **nunca** escribe textos directamente; siempre usa claves. El idioma se toma del de Roblox del jugador, salvo que lo cambie en Ajustes.

---

## 7. Resumen de defensas contra trampas
| Trampa | Defensa |
|---|---|
| Daño falso / matar de un golpe | El cliente no envía daño; el servidor lo calcula |
| Atacar más rápido (auto-clicker o exploit) | Intervalo del arma y límite de frecuencia en el servidor |
| Golpear desde lejos | Detección del golpe en el servidor con distancia máxima |
| XP, objetos o pociones infinitas | Solo los servicios del servidor dan recompensas; el inventario se comprueba antes de equipar/usar |
| Equipar armas que no tiene | Se comprueba que esté en su inventario |
| Velocidad / teletransporte | Comprobación periódica de distancia recorrida; si es imposible, se devuelve al jugador a su última posición válida y se registra [SUPUESTO: tolerancia a calibrar] |
| Saturar el servidor con mensajes | Límite de frecuencia por mensaje |
| Duplicar objetos entre servidores | Bloqueo de sesión de ProfileStore |
| Invulnerabilidad | La vida y el estado los controla el servidor |

---

## 8. Decisiones de esta entrega que necesitan tu aprobación
| # | Propuesta |
|---|---|
| B1 | Esquema de datos guardados (§1.1) y lo que **no** se guarda |
| B2 | Las 10 tablas de configuración (§2) |
| B3 | Conexión mapa–código con Etiquetas y Atributos (§2.1) |
| B4 | Lista de mensajes cliente↔servidor y sus validaciones (§3) |
| B5 | Máquina de estados de combate (§4) |
| B6 | Fórmula de daño, crítico 10 % ×1,5, umbrales de contribución 10 % / 3 % (§5) |
| B7 | Sistema de idiomas con claves y CSV (§6) |
