# Sección 4 — Entrega 4.7 (colchón)
## Animaciones provisionales generadas por código

Pendiente aprobado desde la Entrega 3.2: sin animaciones el combate funciona pero "no se ve". Esta entrega genera **animaciones provisionales por código** para que el combate se vea en Studio sin crear nada a mano.

Comprobado fuera de Studio: Rojo construye, sin errores de tipos, formato correcto, comprobador de coherencia OK. **No probado en Studio.** Versión: `1.0.0-rc3`.

## Cómo funciona
| Archivo | Qué hace |
|---|---|
| `src/client/Util/ProceduralAnimations.luau` | Construye 6 animaciones R15 a partir de poses escritas en código (rotaciones de hombros, codos, torso y piernas) y las registra para obtener un ID temporal |
| `src/client/Controllers/CombatController.luau` | Si `Config/Animations.luau` tiene un ID vacío y estás en Studio, usa la animación provisional |

| Animación | Movimiento |
|---|---|
| Light1 | Corte diagonal de arriba-derecha a abajo-izquierda |
| Light2 | Barrido horizontal de izquierda a derecha |
| Light3 | Estocada hacia delante con un paso |
| Heavy (también remate) | Arma por encima de la cabeza y golpe fuerte hacia abajo |
| Dodge | Cuerpo agachado e inclinado |
| Block (en bucle) | Arma cruzada delante del pecho |

## Limitaciones (importante)
- [VERIFICAR EN STUDIO] El registro de animaciones temporales normalmente **solo funciona en Studio**. En el juego publicado se necesitan animaciones **publicadas** con tu cuenta: sigue la guía de la Entrega 3.2 (Animation Editor) y pega los IDs en `Config/Animations.luau`. Cuando un ID está relleno, se usa ese y no el provisional.
- Las poses están calculadas sin poder verlas: si un movimiento queda raro (el brazo gira al revés, atraviesa el cuerpo…), dime cuál y lo ajusto, o úsalas como referencia para crear las tuyas.
- Si el registro falla, aparece un aviso `[ProceduralAnimations]` y el combate sigue igual que antes (sin animación).

## Pruebas
| # | Haz esto | Resultado esperado |
|---|---|---|
| 1 | Play en Studio | Output: `v1.0.0-rc3`. Ya **no** aparecen los avisos "Falta la animación…" |
| 2 | Haz el combo de 3 golpes | El brazo derecho hace un corte diagonal, un barrido y una estocada; la hoja (pegada a la mano) sigue el movimiento con su estela |
| 3 | Clic derecho | Arma arriba y golpe hacia abajo con el torso inclinado |
| 4 | Q / mantener F | Agachado e inclinado / arma cruzada delante del pecho mientras mantienes |
| 5 | Si algo se ve mal | Dime qué animación y qué parte del cuerpo |
