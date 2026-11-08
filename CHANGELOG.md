# Registro de cambios — ECLIPSE: The Fragments of Dawn

## 1.0.0-rc3 — versión candidata
- **Animaciones provisionales generadas por código** (solo en Studio, si no hay animación publicada):
  3 golpes ligeros, pesado/remate, esquiva y bloqueo para avatares R15.
- Comprobaciones automáticas en GitHub Actions y `tools/check_project.py`.

## 1.0.0-rc2 — versión candidata
- **Controles táctiles (móvil)**, primera actualización del GDD §11, adelantada: botones de combate, habilidad,
  ulti (visible al cargarse), poción, inventario y diario; HUD reorganizado en pantallas táctiles.
  En PC no cambia nada. Mantener "solo PC" en la página del juego hasta probarlo en móvil.

## 1.0.0-rc1 — versión candidata (pendiente de pruebas en Studio y prueba pública)
Primera versión completa según el GDD v1.

**Combate**
- Cámara en tercera persona sobre el hombro; controles por acciones (preparados para móvil).
- Ataque ligero, combo de 3, pesado, remate, esquiva con invulnerabilidad, bloqueo y bloqueo perfecto.
- Katana y mandoble con 3 rarezas (común, rara, épica).
- Afinidades Fuego y Rayo: habilidad, mejora y ulti por maestría (3 rangos por afinidad); Quemado y Resonancia.
- Números de daño, hitstop, sacudida de cámara, partículas, estelas del arma.

**Mundo y contenido**
- Verdantia: Campamento del Alba, Linde Esmeralda, Ruinas de Aelith, Hondonada Marchita y Corazón del Bosque (bloques estilizados).
- 3 enemigos (Brotespina, Lanzador, Centinela) y el jefe Vharok con 2 fases.
- 8 misiones con diálogos, 10 Fragmentos de Amanecer, 5 fogatas con viaje rápido, Santuario de afinidad.

**Progresión**
- Niveles 1–20 (ampliable), recompensas por nivel, títulos y auras cosméticos, pociones.

**Sistemas**
- Guardado con ProfileStore (bloqueo de sesión), servidor autoritativo, límites de mensajes, anticheat de velocidad.
- Cooperativo hasta 12 jugadores con recompensas por contribución y jefe escalado.
- Español e inglés (CSV / LocalizationTable), Ajustes, Diario, inventario, HUD, panel de rendimiento (F7).
- Métricas: embudo de bienvenida de 9 pasos en Roblox Analytics.

## Versiones de desarrollo
| Versión | Entrega | Contenido |
|---|---|---|
| 0.1.0 | 3.1 | Red, controles, cámara |
| 0.2.0 | 3.2 | Combate local |
| 0.3.0 | 3.3 | Combate en red, números de daño |
| 0.4.0 | 3.4 | Guardado, XP, niveles |
| 0.5.0 | 3.5 | Brotespina |
| 0.6.0 | 3.6 | Slice vertical |
| 0.7.0 | 3.7 | Armas e inventario |
| 0.8.0 | 3.8 | Afinidades |
| 0.9.0 | 3.9 | Lanzador y Centinela |
| 0.10.0 | 3.10 | 8 misiones |
| 0.11.0 | 3.11 | Verdantia completa, fogatas, Fragmentos, Diario |
| 0.12.0 | 3.12 | Jefe Vharok |
| 0.13.0 | 3.13 | Ajustes, muerte, CSV |
| 0.14.0 | 4.1 | Arte e iluminación |
| 0.15.0 | 4.2 | VFX, sonido, sensación |
| 0.16.0 | 4.3 | Rendimiento y seguridad |
| 0.17.0 | 4.4 | Equilibrado y métricas |
