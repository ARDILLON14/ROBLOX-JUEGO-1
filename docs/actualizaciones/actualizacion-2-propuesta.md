# Actualización 2 — "Raíces Profundas" — PROPUESTA (pendiente de aprobación)

Orden aprobado en el GDD §11: 1) móvil (hecho en la Entrega 4.6) → **2) más Verdantia: nivel máximo 30, rangos de maestría nuevos, misiones** → 3) monetización cosmética…

**Recomendación del equipo:** publicar primero la v1 y mirar 1–2 semanas de métricas (retención, embudo). Si la gente abandona antes del jefe, la prioridad es arreglar el inicio, no añadir contenido final. Este documento deja el diseño listo para cuando toque.

## Propuesta de contenido (alcance pequeño, ~3–4 semanas a 16 h/sem) [PROPUESTA]
| Elemento | Detalle | Reutiliza |
|---|---|---|
| Nivel máximo **30** | Solo cambiar `MaxLevel` en `Config/Levels.luau`; recompensas en 25 (aura) y 30 (título) | Curva y recompensas actuales |
| Zona nueva **Raíces Profundas / Deep Roots** (niveles 20–30) | Cueva bajo el Árbol Primigenio, se entra tras derrotar a Vharok. Raíces de Éter brillante, poca luz | Generador del mapa, ambiente por zona, fogata, 3 Fragmentos nuevos (F11–F13) |
| 1 enemigo nuevo: **Raíz Errante / Rootwalker** | Variante grande del Brotespina que se entierra y reaparece a tu espalda (aviso en el suelo) | IA y avisos actuales + 1 ataque nuevo |
| Variantes "Corruptas" de los 3 enemigos | Mismos cuerpos, color oscuro, nivel 20–28 | Config de enemigos (solo filas nuevas) |
| Maestría **R4** y **R5** | R4: segunda mejora de la habilidad (p. ej., Tajo Ígneo deja fuego en el suelo; Paso Relámpago con 2 cargas). R5: mejora de la ulti | Tabla de rangos ampliable (decisión 5a) |
| 4 misiones nuevas (Q09–Q12) | Epílogo: investigar el portal sellado y preparar el viaje a otra región (gancho para Solkar) | Sistema de misiones (filas nuevas); la cadena se repara sola |
| **Vharok Despertado** (opcional) | Versión difícil del jefe para nivel 30, mismo modelo, más rápido y con un ataque nuevo | BossService |
| Arma legendaria | Rareza 4 (×1,75), solo de Vharok Despertado | Catálogo de armas |

## Preguntas antes de empezar
1. ¿Apruebas el alcance (zona, enemigo nuevo, R4–R5, 4 misiones)? ¿Quitarías algo?
2. ¿Incluimos **Vharok Despertado** y el arma legendaria, o lo dejamos para más adelante?
3. ¿Prefieres esperar a tener métricas de la v1 (recomendado) o empezar ya?
