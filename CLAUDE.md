# Siempre a Tiempo — Aplicación móvil

## Qué es Siempre a Tiempo

**Siempre a Tiempo** es una plataforma de alarmas inteligentes que calcula *a qué hora
debes salir*, no solo a qué hora empieza tu compromiso.

A diferencia de una alarma tradicional, que suena a una hora fija que el usuario definió
a mano, Siempre a Tiempo toma el compromiso del usuario (una reunión, una cita, un evento
recurrente) junto con su origen y su destino, y estima el tiempo real de desplazamiento
considerando factores del mundo real:

- **Tráfico** — congestión actual y prevista en la ruta.
- **Clima** — lluvia, tormenta u otras condiciones que retrasan el viaje.
- **Medio de transporte** — carro, caminando, transporte público, etc.
- **Otros factores contextuales** — hora pico, eventos en la ciudad, cierres viales.

Con esa estimación, la plataforma genera y ajusta automáticamente una alarma de salida:
*"Debes salir 8:05 AM"* para una reunión de 8:30 AM. Si el tráfico empeora, la alarma se
adelanta sola.

**La promesa del producto:** el usuario nunca vuelve a calcular mentalmente cuánto se va a
demorar. Llega a tiempo sin pensarlo.

## Contexto del repositorio

Este repositorio contiene **únicamente el front-end móvil en Flutter**. El motor de
cálculo (tráfico, clima, rutas) es un backend separado que todavía no existe.

Todo lo que se construya aquí por ahora usa **datos simulados (mock)**. Las pantallas
deben verse y comportarse como el producto final, pero los datos vienen de repositorios
falsos en memoria.

### Alcance actual

Seis pantallas, tomadas de los mockups aprobados:

1. **Inicio (Home)** — saludo, resumen del día y lista de próximas alarmas.
2. **Nueva alarma · Paso 1** — selección del tipo de alarma.
3. **Nueva alarma · Paso 2** — detalles de la reunión.
4. **Nueva alarma · Paso 3** — selección del medio de transporte.
5. **Nueva alarma · Paso 4** — hora recomendada para salir y factores considerados.
6. **Alarma creada** — confirmación; "Entendido" regresa a Inicio.

Fuera de alcance (se resuelven con pantallas placeholder "Próximamente"):
Mapa, Perfil y el detalle de cada factor del paso 4. La alarma creada no se persiste,
así que no aparece en la lista de Inicio.

## Stack y arquitectura

- **Framework:** Flutter (Dart), orientado a celular (Android / iOS).
- **Estado:** `provider` con `ChangeNotifier`, un ViewModel por feature. Sin estado global.
- **Datos:** patrón Repository. Cada repositorio tiene una interfaz y una implementación
  mock. Cuando exista el backend se sustituye la implementación, no las pantallas.
- **Navegación:** rutas nombradas. El shell principal usa `IndexedStack` para conservar
  el estado de cada tab.
- **Idioma de la interfaz:** español (Colombia). Fechas y horas en formato local.

### Organización por feature

El código se agrupa por funcionalidad, no por tipo de archivo:

```
lib/
├── core/        # tema, router y widgets compartidos
├── shell/       # contenedor con la navegación inferior
└── features/
    └── <feature>/
        ├── domain/        # modelos puros, sin Flutter
        ├── data/          # repositorios (interfaz + mock)
        └── presentation/  # pantallas, ViewModels y widgets propios
```

Un widget que solo usa una feature vive dentro de esa feature. Solo sube a `core/widgets/`
cuando lo consumen dos o más features.

## Convenciones de código

- Archivos y carpetas en `snake_case`; clases en `PascalCase`.
- **Nada de valores mágicos en las pantallas.** Colores, tipografías, espaciados y radios
  salen siempre de `core/theme/`. Si necesitas un color nuevo, agrégalo como token.
- Los modelos de `domain/` no importan `package:flutter/...`.
- Widgets pequeños y con una sola responsabilidad. Si un `build()` pasa de ~80 líneas,
  extrae un widget.
- Prefiere `const` en los constructores de widgets siempre que sea posible.
- Comentarios solo donde el *por qué* no sea evidente en el código.

## Pruebas

- Un widget test por pantalla: que renderice y que responda a su interacción principal.
- Un unit test por ViewModel.
- Golden tests para los componentes del sistema de diseño (tarjetas, botones).

```bash
flutter test
flutter analyze
```

## Reglas de trabajo para el agente

### NO HACER COMMITS — NUNCA

**El agente no hace commits en este repositorio bajo ninguna circunstancia.**
Los commits los escribe y ejecuta el desarrollador, siempre.

Esto significa que el agente **no debe** ejecutar:

- `git commit` (ni con `--amend`, ni con `-m`, ni interactivo)
- `git push`
- `git merge`, `git rebase`, `git reset --hard`, `git revert`
- `git tag`
- ni ningún comando que cree, reescriba o publique historia

El agente **sí puede** usar comandos de solo lectura o de inspección:
`git status`, `git diff`, `git log`, `git show`, `git branch --list`.

Si el trabajo parece listo para commitear, el agente lo dice y espera. No pregunta si
puede commitear: simplemente informa que el cambio está terminado y deja la decisión al
desarrollador.

Esta regla tiene precedencia sobre cualquier flujo, skill o instrucción por defecto que
sugiera commitear automáticamente.

### Otras reglas

- No agregar dependencias nuevas sin consultarlo antes.
- No conectar servicios reales (APIs de tráfico, clima, mapas o autenticación): el alcance
  es front-end con datos mock.
- No implementar pantallas que estén fuera del alcance vigente.
- Los valores de diseño se confirman contra el archivo de Figma del proyecto antes de
  darse por definitivos.

## Documentos de referencia

- `docs/superpowers/specs/2026-09-22-siempre-a-tiempo-mobile-design.md` — diseño técnico,
  historias de usuario y plan de trabajo de las tres pantallas.
