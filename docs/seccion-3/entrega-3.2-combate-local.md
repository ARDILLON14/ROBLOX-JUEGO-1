# Sección 3 — Entrega 3.2 (semanas 3–4)
## Combate local: ligero, combo, pesado, remate, esquiva y bloqueo

Forma de trabajo elegida: **opción A (Rojo)**. El código está en GitHub; Rojo lo copia a Studio.

Comprobado fuera de Studio: Rojo construye el proyecto, el verificador de tipos (luau-lsp) no da errores y el formato es correcto. **No probado en Studio.**

## Qué incluye
| Archivo | Qué hace |
|---|---|
| `src/shared/Config/Combat.luau` | Reglas globales (combo, esquiva, bloqueo, hitstop) |
| `src/shared/Config/WeaponTypes.luau` | Estadísticas de katana y mandoble + arma provisional (bloque) |
| `src/shared/Config/Animations.luau` | IDs de animaciones (vacíos: el combate funciona sin ellas) |
| `src/shared/Combat/Hitbox.luau` | Busca personajes en una caja delante del atacante (lo reutilizará el servidor en la semana 5) |
| `src/server/Services/WeaponService.luau` | Pone el arma provisional en la mano derecha; la ven todos los jugadores |
| `src/client/Controllers/CombatController.luau` | Ligero, combo de 3, pesado, remate, esquiva y bloqueo; destello blanco y hitstop al golpear. **Aún no hace daño** (semana 5, en el servidor) |
| `src/shared/Config/Debug.luau` | `LogCombat` (mensajes en Output) y `StartingWeaponType` (arma inicial temporal) |

### Conceptos nuevos
- **Buffer de entrada:** si pulsas atacar mientras otro golpe aún no termina, se guarda y se ejecuta al acabar. Así el combo fluye sin tener que clicar en el momento exacto.
- **LinearVelocity:** fuerza que empuja al personaje a una velocidad fija; se usa para la esquiva.
- **Highlight:** efecto que colorea un modelo entero; se usa para el destello de golpe.

### [PROPUESTA] nueva
- Velocidad al atacar ×0,4 (`AttackMoveSpeedMultiplier` en `Combat.luau`).

---

## Preparación (una vez)
1. **Bajar el código:** GitHub Desktop → botón **Fetch origin** y luego **Pull origin**.
2. **Avatares R15:** en Studio, **Home → Game Settings → Avatar** → tipo **R15** → **Save**. (El arma se pega a la "RightHand", que solo existe en R15.) [VERIFICAR EN STUDIO: ubicación exacta del menú]
3. **Muñeco de práctica:** pestaña **Avatar → Rig Builder** → **R15** → **Block Avatar**. Aparece un muñeco llamado "Rig".
   - Muévelo unos pasos delante del punto de aparición.
   - En **Explorer**, despliega el Rig → selecciona **HumanoidRootPart** → en **Properties** marca **Anchored** (para que no se caiga ni se mueva).
   - Guarda el lugar (**File → Publish to Roblox**). El muñeco es parte del mapa, así que vive en Studio, no en GitHub.
4. `rojo serve` en VS Code y en Studio **Plugins → Rojo → Connect**.

## Pruebas
Abre **View → Output**. Los avisos amarillos "Falta la animación…" son **normales** (aún no hay animaciones).

| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | **Play** | `[Server] … v0.2.0`, `[Server] 1 módulo(s) iniciado(s)`, `[Client] 3 módulo(s) iniciado(s)`. Nada en rojo |
| 2 | Mira tu personaje | Una hoja gris clara (katana provisional) en la mano derecha |
| 3 | Acércate al muñeco y haz 3 clics seguidos | `[Combat] Ligero 1 (Katana)`, `Ligero 2`, `Ligero 3`; cada uno con `… golpea a Rig`, y el muñeco **destella en blanco** |
| 4 | Espera más de 1 s y vuelve a hacer clic | Empieza otra vez en `Ligero 1` |
| 5 | Clic, clic, **clic derecho** | `[Combat] REMATE (Katana)` |
| 6 | Solo clic derecho | `[Combat] Pesado (Katana)` |
| 7 | Clics muy rápidos (spam) | Los golpes no van más rápido de uno cada ~0,35 s |
| 8 | Muévete con WASD y pulsa **Q** | Un impulso rápido (~12 studs) hacia donde te movías. `[Combat] Esquiva` |
| 9 | Quieto, pulsa **Q** | Impulso hacia atrás |
| 10 | Pulsa **Q** dos veces seguidas | La segunda: `Esquiva en enfriamiento` |
| 11 | Mantén **F** y camina | Caminas más lento; `Bloqueo: inicio`. Al soltar: `Bloqueo: fin (X s)`. Clic mientras bloqueas: no ataca |
| 12 | Ataca mientras caminas | Te mueves más lento durante el golpe |
| 13 | Ataca al aire (lejos del muñeco) | Aparece `Ligero 1`, pero **no** `golpea a` |
| 14 | Stop. En VS Code, `src/shared/Config/Debug.luau`: cambia `"Katana"` por `"Greatsword"`, guarda y pulsa Play | Hoja más grande y oscura; golpes más lentos (~0,6 s) y de más alcance; Q justo al empezar un golpe no hace nada. Al terminar, vuelve a poner `"Katana"` |

Si la hoja aparece en una posición rara (atravesando el cuerpo, apuntando hacia arriba…), dímelo: se corrige con `GripOffset` en `WeaponTypes.luau`.

---

## Animaciones (después de que las pruebas funcionen)
Sin animaciones el combate funciona, pero no se ve. Para cada animación:
1. Selecciona el muñeco "Rig" → pestaña **Avatar → Animation Editor**. [VERIFICAR EN STUDIO]
2. Crea una animación nueva con el nombre de la tabla.
3. Mueve partes del cuerpo y añade 2–3 poses (*keyframes*) en los tiempos indicados.
4. Prioridad: **Action**. Para `Block`, activa **Loop**.
5. **Publish to Roblox** → copia el número de ID.
6. Pégalo en `src/shared/Config/Animations.luau` así: `"rbxassetid://123456789"`.

| Animación | Dónde va en `Animations.luau` | Duración aprox. | Idea de poses |
|---|---|---|---|
| Katana_Light1 | `Katana.Light[1]` | 0,35 s | brazo derecho de arriba-derecha a abajo-izquierda |
| Katana_Light2 | `Katana.Light[2]` | 0,35 s | barrido de izquierda a derecha |
| Katana_Light3 | `Katana.Light[3]` | 0,35 s | estocada hacia delante |
| Katana_Heavy | `Katana.Heavy` | 0,6 s | levantar por encima de la cabeza y bajar fuerte |
| Dodge | `Dodge` | 0,3 s | cuerpo inclinado, piernas recogidas |
| Block | `Block` (Loop) | 1 s | arma cruzada delante del pecho |

El remate usa el pesado si no tiene animación propia. El mandoble puede esperar a la semana 9.
