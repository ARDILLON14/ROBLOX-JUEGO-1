# Sección 4 — Entrega 4.5 (semana 25)
## Versión candidata 1.0.0-rc1 y guía de publicación

**Estado honesto:** el juego está completo en código, pero **ninguna entrega se ha ejecutado todavía en Roblox Studio** y la prueba pública (HITO 2) no se ha hecho. Por eso la versión es **1.0.0-rc1** (candidata), no 1.0.0. Pasará a 1.0.0 cuando se cumpla la lista "¿Listo para publicar?".

Cambios de código de esta entrega: versión `1.0.0-rc1` y número de versión visible en Ajustes (para que los jugadores lo incluyan al informar de errores). Nuevo `CHANGELOG.md`.

---

## 1. Prueba completa en Studio (antes de nada)
Abre `builds/ECLIPSE-dev.rbxl` y sigue este recorrido. **Cópiame todo lo que salga en rojo o naranja en Output.**

| # | Sistema | Qué hacer | ✅/❌ |
|---|---|---|---|
| 1 | Arranque | Play: `v1.0.0-rc1`, `[Server] 16 módulo(s)`, `[Client] 30 módulo(s)`, nada en rojo | |
| 2 | Cámara y controles | Moverse, ratón bloqueado, Alt libera | |
| 3 | Combate | Combo, pesado, remate, esquiva, bloqueo contra el muñeco; números de daño | |
| 4 | Misiones 1–2 | Ilen, muñeco, 6 Brotespinas | |
| 5 | Niveles | Subir de nivel: columna dorada, aviso, pociones | |
| 6 | Enemigos | Brotespina, Lanzador (espinas), Centinela (guardia, golpe rojo) | |
| 7 | Inventario | Tab/I, equipar armas | |
| 8 | Afinidad | Santuario de las Ruinas (nivel 5), Z/X, maestría | |
| 9 | Mundo | Fogatas, viaje rápido, Fragmentos, Diario (J), zonas | |
| 10 | Jefe | Fases 1 y 2, embestida contra columna, recompensa | |
| 11 | Ajustes y muerte | P, idioma, pantalla de muerte | |
| 12 | Cooperativo | Test → 2 Players: estelas, Resonancia, números ajenos | |
| 13 | Guardado | Con API activada: Stop/Play conserva todo | |
| 14 | Rendimiento | F7 en cada zona (FPS ≥ 50, servidor ≈ 60) | |

Atajos de prueba (solo Studio, en `Debug.luau`): `DummyXPPerHit = 500`, `MasteryMultiplier = 20`, `BossHealthMultiplier = 0.1`.

## 2. ¿Listo para publicar? (criterios de la Entrega 2C)
- [ ] Recorrido completo en Studio sin errores rojos.
- [ ] Prueba pública con 10+ desconocidos y sus respuestas recogidas (Entrega 4.3).
- [ ] Correcciones de la prueba pública hechas (semana 23).
- [ ] Sin pérdida de datos en la prueba pública.
- [ ] Todo el contenido del GDD v1 funciona (lista de arriba).
- [ ] Ambos idiomas revisados (pon tu Roblox en inglés y en español).
- [ ] Cuestionario de madurez completado.
- [ ] Página del juego lista (descripción ES/EN, icono, miniaturas; Entrega 4.4).

## 3. Pasos de publicación (cuando todo esté marcado)
1. En VS Code cambia la versión en `src/shared/Config/GameInfo.luau` a `"1.0.0"` y haz commit.
2. Con Rojo conectado a tu lugar de desarrollo, comprueba que el código está actualizado.
3. **File → Publish to Roblox** (tu experiencia).
4. Creator Hub → tu experiencia:
   - Server Size = 12, Avatar R15, dispositivos = PC [VERIFICAR: ubicación de cada opción].
   - Descripción ES/EN, icono y miniaturas.
   - Acceso: **Public** [VERIFICAR EN DOCUMENTACIÓN: "experience access settings"].
5. Entra tú en el juego publicado (no en Studio): juega 10 minutos, pulsa F9 y revisa que no haya errores del servidor.
6. Comparte el enlace (amigos, grupos, redes) — sin publicidad de pago (presupuesto $0).

## 4. Primeras 72 horas
| Cuándo | Qué mirar | Dónde |
|---|---|---|
| Cada día | Errores del servidor y de clientes | Creator Hub → Error Report [VERIFICAR] / F9 en una partida |
| Día 2 | Retención D1 (meta ≥ 15 %) y tiempo de sesión (meta ≥ 12 min) | Analytics |
| Día 2–3 | Embudo: ¿dónde se van? (paso 3 ≥ 70 %, paso 6 ≥ 35 %) | Analytics → embudo |
| Siempre | Comentarios de jugadores | Grupo de Roblox / Discord gratuito |

## 5. Cómo publicar un arreglo urgente (hotfix)
1. Arreglas el código (o me envías el error y lo arreglo yo en GitHub).
2. **Pull origin** en GitHub Desktop → Rojo actualiza Studio.
3. Prueba rápida en Studio del arreglo.
4. Sube la versión (`1.0.1`), commit y **Publish to Roblox**.
5. Los servidores nuevos usan la versión nueva. Para que todos la tengan: Creator Hub → **Restart servers** / "Shut down all servers" [VERIFICAR EN DOCUMENTACIÓN: "update servers"]. ProfileStore guarda los datos antes de cerrar.

## 6. Después de la 1.0 (orden aprobado en el GDD §11)
1. **Controles táctiles (móvil)** — la base ya está preparada (acciones + interfaz con tamaños relativos).
2. Más Verdantia: nivel máximo 30, más rangos de maestría y misiones.
3. Monetización solo cosmética (sin pay-to-win).
4. Nueva afinidad y nueva arma.
5. Mazmorras cooperativas.
6. Región Solkar (el portal sellado del final de la misión 8).
