# Sección 4 — Entrega 4.8 (colchón)
## Autodiagnóstico al pulsar Play

Para que probar en Studio sea lo más fácil posible: al pulsar **Play**, el juego comprueba solo si cada sistema arrancó bien y escribe un informe en **Output**. Solo tienes que copiarlo y enviármelo.

Comprobado fuera de Studio: Rojo construye, sin errores de tipos, formato correcto, comprobador de coherencia OK. **No probado en Studio.** Versión: `1.0.0-rc4`.

## Qué comprueba
**Servidor** (`src/server/Services/SmokeTestService.luau`), unos 3 s después de entrar:
- Mensajeros de red, tabla de textos y textos cargados.
- Misiones apuntando a enemigos existentes; arma por defecto.
- Tus datos cargados (ProfileStore) y la columna Lv.
- Arma en la mano y sus atributos (detecta si el avatar no es R15).
- Enemigos aparecidos, Maestra Ilen, muñeco, Santuario, jefe Vharok, fogatas con aviso.
- FPS del servidor.

**Cliente** (`src/client/Controllers/SmokeTestController.luau`), unos 6 s después de entrar:
- Datos recibidos, textos cargados, las 7 pantallas principales, grupo de sonido.

No modifica tus datos guardados. Solo se ejecuta en Studio (`Debug.RunSmokeTest`); en el juego publicado se desactiva solo.

## Qué hacer
1. **Pull origin** y abre `builds/ECLIPSE-dev.rbxl`.
2. **View → Output** y pulsa **Play**.
3. Espera ~10 segundos sin hacer nada.
4. Copia **todas las líneas que empiecen por `[SMOKE]`** y **todo lo que salga en rojo**, y envíamelo.

Ejemplo de lo que verás:
```
[SMOKE] ===== Autodiagnóstico del servidor =====
[SMOKE] ✅ Mensajeros de red creados
[SMOKE] ✅ Datos del jugador cargados (ProfileStore)
[SMOKE] ❌ Arma en la mano — falta el modelo Weapon (¿avatar R15?)
...
[SMOKE] RESUMEN SERVIDOR: 15/16 correctos
[SMOKE] RESUMEN CLIENTE: 11/11 correctos
```
