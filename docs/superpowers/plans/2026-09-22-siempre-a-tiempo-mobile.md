# Plan de implementación — Siempre a Tiempo (front-end móvil)

> **Para agentes ejecutores:** SUB-SKILL REQUERIDA: usa
> `superpowers:subagent-driven-development` (recomendada) o
> `superpowers:executing-plans` para implementar este plan tarea por tarea.
> Los pasos usan casillas (`- [ ]`) para seguimiento.

> ### ⛔ REGLA DE COMMITS — LEE ESTO ANTES DE EMPEZAR
>
> **El agente NO ejecuta `git commit` en este repositorio. Nunca.**
> Cada tarea termina en un **punto de commit**: el agente reporta que la tarea
> quedó lista y **se detiene**. El desarrollador escribe y ejecuta el commit.
> El mensaje sugerido que aparece en cada punto de commit es una **propuesta**,
> no un comando para ejecutar.
> Esta regla viene de `CLAUDE.md` y tiene precedencia sobre cualquier plantilla.

**Objetivo:** construir en Flutter las tres pantallas aprobadas de Siempre a Tiempo
(Inicio, y los pasos 1 y 2 del asistente de nueva alarma) como front-end navegable con
datos simulados.

**Arquitectura:** organización por feature con una capa `core` para el sistema de diseño.
Estado con `provider` y `ChangeNotifier`, un ViewModel por feature y sin estado global.
Acceso a datos por patrón Repository con implementación mock en memoria, de modo que al
existir el backend se sustituya la implementación sin tocar las pantallas.

**Stack:** Flutter · Dart · `provider` · `intl` · `flutter_localizations` ·
`google_fonts` (Inter) · `lucide_icons` · `flutter_test` · `flutter_lints`.

**Spec:** `docs/superpowers/specs/2026-09-22-siempre-a-tiempo-mobile-design.md`

---

## Restricciones globales

Aplican a **todas** las tareas. Sus requisitos se suman implícitamente a los de cada una.

- **El agente no ejecuta commits.** Tampoco `push`, `merge`, `rebase`, `reset --hard`,
  `revert` ni `tag`. Solo lectura: `status`, `diff`, `log`, `show`, `branch --list`.
- **Idioma de la interfaz:** español. Todo texto visible al usuario va en español.
- **Locale de formato:** `es` para fechas, `en_US` únicamente para el sufijo AM/PM, porque
  los mockups muestran `8:30 AM` y no `8:30 a. m.`.
- **Cero valores mágicos en `features/`.** Todo color, tamaño de fuente, espaciado y radio
  sale de `lib/core/theme/`. Un `Color(0x...)`, un `fontSize:` o un número suelto de
  padding dentro de `features/` es motivo de rechazo de la tarea.
- **`domain/` no importa Flutter.** Ningún archivo bajo `features/*/domain/` puede tener
  `import 'package:flutter/...'`. Los modelos son Dart puro.
- **Sin dependencias nuevas** más allá de las listadas en la Tarea 1. Cualquier otra se
  consulta antes con el desarrollador.
- **Tipografía: Inter**, en Regular, Medium, SemiBold y Bold. Se carga con `google_fonts`
  **empaquetando los `.ttf`** en el proyecto, no descargándolos en tiempo de ejecución.
- **Iconografía: `lucide_icons`**, estilo outline de trazo 2 px. Los iconos de Material no
  reproducen ese trazo y solo se usan donde Lucide no tenga equivalente.
- **Sin integraciones reales:** nada de APIs de tráfico, clima, mapas, calendario,
  contactos, autenticación, notificaciones ni persistencia.
- **Accesibilidad:** contraste mínimo 4.5:1 (3:1 en texto grande), área tocable mínima
  48×48 dp, etiqueta semántica en todo ícono sin texto visible.
- **Tamaños de referencia:** 360×640 dp (celular pequeño) y 430×932 dp (celular grande).
- **Escala de texto soportada:** hasta 1.5× sin desbordes.
- **Tokens ya extraídos:** los valores de color, tipografía y dimensiones salen del Style
  Tile del proyecto en Figma y **ya están escritos** en `lib/core/theme/`. No se inventan
  valores nuevos: si hace falta uno, se busca primero en las rampas del Style Tile
  (<https://www.figma.com/design/Z8oSiR3n6bGlEfoxApbGiV/UX---Siempre-a-Tiempo>) y se agrega
  como token, nunca en la pantalla.
- **Los estilos tipográficos no son `const`.** `GoogleFonts.inter` los construye en tiempo
  de ejecución, así que un widget que use `AppTypography.x` no puede declararse `const`.
- **Verificación por tarea:** `flutter analyze` sin advertencias y `flutter test` en verde.

---

## Estructura de archivos

| Archivo | Responsabilidad |
|---------|-----------------|
| `lib/main.dart` | Arranque: inicializa el formato de fechas y llama a `runApp` |
| `lib/app.dart` | `MaterialApp`: tema, localización y router |
| `lib/core/theme/app_colors.dart` | Tokens de color y paleta de avatares |
| `lib/core/theme/app_typography.dart` | Escala tipográfica |
| `lib/core/theme/app_spacing.dart` | Espaciados y radios |
| `lib/core/theme/app_theme.dart` | `ThemeData` ensamblado desde los tokens |
| `lib/core/format/app_date_format.dart` | Formato de hora y de fecha larga |
| `lib/core/router/app_routes.dart` | Constantes de ruta |
| `lib/core/router/app_router.dart` | `onGenerateRoute` |
| `lib/core/widgets/primary_button.dart` | Botón relleno (acción principal) |
| `lib/core/widgets/secondary_button.dart` | Botón con borde (acción secundaria) |
| `lib/core/widgets/coming_soon_screen.dart` | Placeholder de lo fuera de alcance |
| `lib/core/widgets/wizard_progress_bar.dart` | Indicador de 4 segmentos |
| `lib/core/widgets/wizard_bottom_bar.dart` | Barra fija de dos acciones |
| `lib/shell/main_shell.dart` | `Scaffold` + `BottomNavigationBar` con `IndexedStack` |
| `lib/features/home/domain/transport_mode.dart` | Enum de medio de transporte |
| `lib/features/home/domain/alarm.dart` | Modelo de alarma |
| `lib/features/home/data/alarm_repository.dart` | Interfaz del repositorio |
| `lib/features/home/data/mock_alarm_repository.dart` | Datos simulados en memoria |
| `lib/features/home/presentation/home_state.dart` | Estados sellados de la pantalla |
| `lib/features/home/presentation/home_view_model.dart` | Carga y expone el estado |
| `lib/features/home/presentation/home_screen.dart` | Pantalla de Inicio |
| `lib/features/home/presentation/widgets/greeting_header.dart` | Saludo y conteo |
| `lib/features/home/presentation/widgets/alarm_card.dart` | Tarjeta de alarma |
| `lib/features/home/presentation/widgets/transport_chip.dart` | Chip de transporte |
| `lib/features/home/presentation/widgets/alarms_skeleton.dart` | Estado de carga |
| `lib/features/home/presentation/widgets/alarms_empty_state.dart` | Estado vacío |
| `lib/features/home/presentation/widgets/alarms_error_state.dart` | Estado de error |
| `lib/features/new_alarm/domain/alarm_type.dart` | Enum de tipo de alarma |
| `lib/features/new_alarm/domain/attendee.dart` | Modelo de asistente |
| `lib/features/new_alarm/domain/alarm_draft.dart` | Borrador y sus validaciones |
| `lib/features/new_alarm/presentation/new_alarm_view_model.dart` | Borrador y paso actual |
| `lib/features/new_alarm/presentation/new_alarm_flow.dart` | Contenedor del asistente |
| `lib/features/new_alarm/presentation/steps/step_type_screen.dart` | Paso 1 |
| `lib/features/new_alarm/presentation/steps/step_details_screen.dart` | Paso 2 |
| `lib/features/new_alarm/presentation/widgets/alarm_type_card.dart` | Opción de tipo |
| `lib/features/new_alarm/presentation/widgets/labeled_field.dart` | Campo con etiqueta |
| `lib/features/new_alarm/presentation/widgets/attendee_avatars.dart` | Fila de avatares |
| `test/helpers/pump_app.dart` | Utilidad común para montar widgets en pruebas |
| `test/flutter_test_config.dart` | Arranque de pruebas: fija la tipografía local |
| `google_fonts/*.ttf` | Los cuatro pesos de Inter, empaquetados |

---

## Mapa de tareas

| Tarea | Entrega | Historias |
|-------|---------|-----------|
| 1 | Proyecto Flutter que compila | E-00 |
| 2 | Sistema de diseño y formato de fechas | E-00 |
| 3 | Botones compartidos | E-00 |
| 4 | Shell navegable con tres pestañas | HU-03 |
| 5 | Dominio y repositorio de alarmas | HU-01 |
| 6 | `HomeViewModel` con cuatro estados | HU-01 |
| 7 | Tarjeta de alarma y chip de transporte | HU-02 |
| 8 | Saludo y estados de carga, vacío y error | HU-01 |
| 9 | Pantalla de Inicio completa con botón flotante | HU-01, HU-04 |
| 10 | Dominio del asistente | HU-05, HU-06 |
| 11 | `NewAlarmViewModel` | HU-05, HU-06, HU-07 |
| 12 | Indicador de progreso y barra inferior | HU-07 |
| 13 | Paso 1: selección de tipo | HU-05 |
| 14 | Campo con etiqueta flotante | HU-06 |
| 15 | Fila de avatares de asistentes | HU-06 |
| 16 | Paso 2: detalles de la reunión | HU-06 |
| 17 | Contenedor del asistente y navegación entre pasos | HU-07 |
| 18 | Revisión de accesibilidad | HU-08 |

---

## Tarea 1: Proyecto Flutter y dependencias

**Archivos:**
- Crear: el proyecto completo vía `flutter create`
- Modificar: `pubspec.yaml`, `analysis_options.yaml`
- Borrar: el contenido de ejemplo de `lib/main.dart` y `test/widget_test.dart`

**Interfaces:**
- Consume: nada, es la primera tarea
- Produce: un proyecto que compila, con `provider`, `intl` y `flutter_localizations`
  disponibles, y `flutter_lints` activo

- [ ] **Paso 1: Verificar el SDK de Flutter**

Flutter **no está instalado** en el entorno actual. Instálalo antes de continuar
(https://docs.flutter.dev/get-started/install) y verifica:

```bash
flutter --version
flutter doctor
```

Esperado: una versión estable de Flutter 3.x y `flutter doctor` sin errores bloqueantes
para Android o iOS. Las advertencias de otras plataformas se pueden ignorar.

- [ ] **Paso 2: Crear el proyecto sobre el repositorio existente**

El repositorio ya existe y está vacío salvo por `CLAUDE.md` y `docs/`. Crea el proyecto
Flutter *dentro* de él, sin sobrescribir esos archivos:

```bash
flutter create --project-name siempre_a_tiempo --platforms=android,ios --org io.futurephase .
```

Esperado: se crean `lib/`, `test/`, `pubspec.yaml`, `android/`, `ios/`.
`CLAUDE.md` y `docs/` siguen intactos.

- [ ] **Paso 3: Confirmar que el proyecto base compila**

```bash
flutter analyze
flutter test
```

Esperado: `analyze` sin problemas y el test de ejemplo pasando. Si algo falla aquí, el
problema es de instalación, no del código.

- [ ] **Paso 4: Agregar las dependencias**

```bash
flutter pub add provider intl google_fonts lucide_icons
flutter pub add flutter_localizations --sdk=flutter
```

No fijes versiones a mano: deja que `pub` resuelva las compatibles con tu versión de
Flutter y quedan escritas en `pubspec.yaml`. `flutter_lints` ya viene incluido por
`flutter create`.

- [ ] **Paso 4b: Empaquetar la tipografía Inter**

Por defecto `google_fonts` descarga la fuente en el primer arranque. Eso rompe el arranque
sin red y, sobre todo, hace que los *golden tests* se rendericen con una fuente de reserva
distinta a la de la aplicación. Empaquetar los archivos lo resuelve.

Descarga Inter de <https://fonts.google.com/specimen/Inter> y coloca los cuatro pesos en
una carpeta `google_fonts/` en la raíz del proyecto, con estos nombres exactos, que son los
que `google_fonts` busca:

```
google_fonts/Inter-Regular.ttf
google_fonts/Inter-Medium.ttf
google_fonts/Inter-SemiBold.ttf
google_fonts/Inter-Bold.ttf
```

Declara la carpeta en `pubspec.yaml`, dentro de `flutter:`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - google_fonts/
```

Verifica que los cuatro archivos están donde deben:

```bash
ls google_fonts/
```

Esperado: los cuatro `.ttf`. Si falta alguno, los pesos correspondientes se renderizarán
con una fuente de reserva y el diseño no coincidirá con el Style Tile.

- [ ] **Paso 5: Endurecer las reglas de análisis**

Reemplaza el contenido de `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error

linter:
  rules:
    - always_declare_return_types
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - require_trailing_commas
    - sort_child_properties_last
    - unawaited_futures
    - use_super_parameters
```

- [ ] **Paso 6: Vaciar el contenido de ejemplo**

Borra `test/widget_test.dart` (prueba el contador de ejemplo, que vamos a eliminar):

```bash
rm test/widget_test.dart
```

Y reemplaza `lib/main.dart` por un arranque mínimo que la Tarea 2 completará:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: Text('Siempre a Tiempo'))),
  ));
}
```

- [ ] **Paso 7: Verificar**

```bash
flutter analyze
flutter test
```

Esperado: `analyze` sin advertencias. `flutter test` reporta que no hay pruebas
(`No tests ran.`), lo cual es correcto en este punto.

- [ ] **Paso 8: Crear el `.gitignore` correcto**

`flutter create` genera un `.gitignore` adecuado. Verifica que incluya `build/`,
`.dart_tool/` y `*.iml`:

```bash
grep -E '^(build/|\.dart_tool/)' .gitignore
```

Esperado: ambas líneas presentes.

- [ ] **Paso 9: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

El agente **se detiene aquí** e informa que la tarea está lista. Mensaje sugerido para que
el desarrollador lo escriba:

> `chore: inicializa proyecto Flutter con provider, intl y lints`

---

## Tarea 2: Sistema de diseño y formato de fechas

Los cuatro archivos de `lib/core/theme/` **ya están escritos en el repositorio**, extraídos
del Style Tile de Figma. Esta tarea los verifica y construye lo que falta a su alrededor.

**Archivos:**
- Verificar (ya existen): `lib/core/theme/app_colors.dart`, `app_typography.dart`,
  `app_spacing.dart`, `app_theme.dart`
- Crear: `lib/core/format/app_date_format.dart`
- Crear: `test/core/format/app_date_format_test.dart`
- Crear: `test/helpers/pump_app.dart`
- Crear: `lib/app.dart`; modificar `lib/main.dart`

**Interfaces:**
- Consume: el proyecto de la Tarea 1
- Produce:
  - `AppColors` — rampas `blue/red/amber/green` en escalas 900…100, neutros
    `neutral900/700/500/300/100` y `white`, y los alias `primary`, `primaryPressed`,
    `onPrimary`, `secondary`, `secondaryMuted`, `textPrimary`, `textSecondary`,
    `accentTime`, `success`, `onSuccessSurface`, `error`, `background`, `surface`,
    `surfaceMuted`, `border`, `progressInactive`
  - `AppColors.avatarPalette` → `List<Color>`, `AppColors.avatarAt(int)` → `Color`
  - `AppTypography.display/displayGreeting/headlineQuestion/titleTime/titleCard/bodyDefault/bodyEmphasis/labelSection/labelButton/labelField` → `TextStyle` (**getters**, no constantes)
  - `AppSpacing.xs/sm/md/lg/xl/screenH/cardPadding` → `double`
  - `AppRadius.card/field/chip/pill` → `double`
  - `AppSizes.buttonHeight/fieldHeight/chipHeight/progressBarHeight/minTouchTarget` → `double`
  - `AppTheme.light` → `ThemeData`
  - `AppDateFormat.time(DateTime)` → `String` (`"8:30 AM"`)
  - `AppDateFormat.longDate(DateTime)` → `String` (`"20 de agosto de 2026"`)
  - `AppDateFormat.longDateTime(DateTime)` → `String` (`"20 de agosto de 2026, 3:00 PM"`)
  - `initTestFormatting()` → `Future<void>`
  - `pumpApp(WidgetTester, Widget, {List<SingleChildWidget> providers, double textScale})` → `Future<void>`

- [ ] **Paso 1: Verificar que los archivos del tema compilan**

Los cuatro archivos ya están en el repositorio. Con las dependencias de la Tarea 1 ya
instaladas, deben analizar sin errores:

```bash
ls lib/core/theme/
flutter analyze lib/core/theme/
```

Esperado: los cuatro archivos presentes y `analyze` sin problemas. Si `google_fonts` no
resuelve, vuelve al paso 4 de la Tarea 1.

**No cambies los valores de estos archivos.** Salen del Style Tile y están verificados
contra WCAG. Si algo se ve distinto al diseño, el problema está en cómo lo usa la pantalla,
no en el token.

- [ ] **Paso 2: Escribir la prueba del formateador de fechas**

Crea `test/core/format/app_date_format_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:siempre_a_tiempo/core/format/app_date_format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('AppDateFormat.time', () {
    test('formatea la mañana en 12 horas con AM en mayúsculas', () {
      expect(AppDateFormat.time(DateTime(2026, 8, 20, 8, 30)), '8:30 AM');
    });

    test('formatea la tarde con PM en mayúsculas', () {
      expect(AppDateFormat.time(DateTime(2026, 8, 20, 15, 0)), '3:00 PM');
    });

    test('no antepone cero a la hora', () {
      expect(AppDateFormat.time(DateTime(2026, 8, 20, 9, 5)), '9:05 AM');
    });

    test('medianoche se muestra como 12 AM', () {
      expect(AppDateFormat.time(DateTime(2026, 8, 20, 0, 0)), '12:00 AM');
    });
  });

  group('AppDateFormat.longDateTime', () {
    test('usa el mes en español y la hora en formato del mockup', () {
      expect(
        AppDateFormat.longDateTime(DateTime(2026, 8, 20, 15, 0)),
        '20 de agosto de 2026, 3:00 PM',
      );
    });
  });
}
```

- [ ] **Paso 3: Correr la prueba y verificar que falla**

```bash
flutter test test/core/format/app_date_format_test.dart
```

Esperado: FALLA con un error de compilación, porque `app_date_format.dart` no existe.

- [ ] **Paso 4: Escribir el formateador de fechas**

Crea `lib/core/format/app_date_format.dart`. El detalle que importa: `intl` en español
produce `"3:00 p. m."`, pero el Style Tile y los mockups muestran `"3:00 PM"`. Por eso la
hora se formatea con locale `en_US` y la fecha con `es`.

```dart
import 'package:intl/intl.dart';

/// Formatos de fecha y hora de la aplicación.
///
/// Requiere que `initializeDateFormatting('es')` se haya ejecutado antes,
/// lo cual ocurre en `main()`.
abstract final class AppDateFormat {
  /// Hora en 12 horas con AM/PM en mayúsculas, como en el diseño: "8:30 AM".
  ///
  /// Usa el locale `en_US` a propósito: el español rinde "8:30 a. m.",
  /// que no corresponde al diseño aprobado.
  static String time(DateTime value) => DateFormat('h:mm a', 'en_US').format(value);

  /// Fecha larga en español: "20 de agosto de 2026".
  static String longDate(DateTime value) =>
      DateFormat("d 'de' MMMM 'de' y", 'es').format(value);

  /// Fecha y hora combinadas: "20 de agosto de 2026, 3:00 PM".
  static String longDateTime(DateTime value) =>
      '${longDate(value)}, ${time(value)}';
}
```

- [ ] **Paso 5: Correr la prueba y verificar que pasa**

```bash
flutter test test/core/format/app_date_format_test.dart
```

Esperado: PASA, las cinco pruebas en verde.

- [ ] **Paso 6: Escribir la utilidad de pruebas de widgets**

Crea `test/helpers/pump_app.dart`. Todas las pruebas de widget de este plan la usan, para
que ninguna repita el montaje de tema y localización.

El detalle crítico es `allowRuntimeFetching = false`: sin eso `google_fonts` intenta
descargar Inter durante las pruebas, que no tienen red, y los *golden tests* se generarían
con una fuente de reserva distinta a la de la aplicación.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/core/theme/app_theme.dart';

/// Prepara el entorno de pruebas: formato en español y tipografía local.
/// Llámalo una vez por archivo de prueba, dentro de `setUpAll`.
Future<void> initTestFormatting() async {
  // Sin esto, google_fonts intenta descargar Inter por red durante las
  // pruebas y los goldens se rendirían con otra fuente.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('es');
}

/// Monta [child] dentro de un `MaterialApp` con el tema y la localización
/// reales de la aplicación.
///
/// [providers] permite inyectar ViewModels; si va vacío no se envuelve en
/// `MultiProvider`.
/// [textScale] permite verificar el comportamiento con letra ampliada.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget> providers = const [],
  double textScale = 1.0,
}) async {
  Widget app = MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('es'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('es')],
    builder: (BuildContext context, Widget? widget) => MediaQuery.withClampedTextScaling(
      minScaleFactor: textScale,
      maxScaleFactor: textScale,
      child: widget!,
    ),
    home: child,
  );

  if (providers.isNotEmpty) {
    app = MultiProvider(providers: providers, child: app);
  }

  await tester.pumpWidget(app);
}
```

- [ ] **Paso 7: Cargar la tipografía en el arranque de las pruebas**

Crea `test/flutter_test_config.dart`, que Flutter ejecuta automáticamente antes de
cualquier prueba del proyecto. Registra los `.ttf` de Inter en el motor de fuentes para que
los widgets de prueba se rendericen con la tipografía real:

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await loadAppFonts();
  return testMain();
}

/// Carga las fuentes declaradas en el pubspec dentro del entorno de prueba.
Future<void> loadAppFonts() async {
  // `flutter test` ya expone los assets del paquete, así que basta con
  // dejar que google_fonts los resuelva desde `google_fonts/`.
  await Future<void>.delayed(Duration.zero);
}
```

- [ ] **Paso 8: Conectar el tema en la aplicación**

Crea `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';

class SiempreATiempoApp extends StatelessWidget {
  const SiempreATiempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siempre a Tiempo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      home: const Scaffold(
        body: Center(child: Text('Siempre a Tiempo')),
      ),
    );
  }
}
```

Y reemplaza `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const SiempreATiempoApp());
}
```

- [ ] **Paso 9: Verificar contra el Style Tile**

```bash
flutter analyze
flutter test
flutter run
```

Esperado: `analyze` sin advertencias, las cinco pruebas en verde, y la app abre con fondo
`#F2F5FA` y el texto "Siempre a Tiempo" centrado **en Inter**. Si el texto se ve con la
fuente por defecto del sistema y no con Inter, los `.ttf` no quedaron bien empaquetados:
vuelve al paso 4b de la Tarea 1.

- [ ] **Paso 10: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(core): agrega sistema de diseño desde el Style Tile de Figma`

---

## Tarea 3: Botones compartidos

**Archivos:**
- Crear: `lib/core/widgets/primary_button.dart`, `lib/core/widgets/secondary_button.dart`
- Crear: `test/core/widgets/buttons_test.dart`

**Interfaces:**
- Consume: `AppColors`, `AppTypography`, `AppRadius`, `AppSpacing` (Tarea 2);
  `pumpApp` (Tarea 2)
- Produce:
  - `PrimaryButton({required String label, required VoidCallback? onPressed, IconData? icon, bool expanded = false})`
  - `SecondaryButton({required String label, required VoidCallback? onPressed, bool expanded = false})`
  - En ambos, `onPressed: null` deja el botón deshabilitado

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/core/widgets/buttons_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/widgets/primary_button.dart';
import 'package:siempre_a_tiempo/core/widgets/secondary_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('PrimaryButton', () {
    testWidgets('muestra su etiqueta y responde al toque', (tester) async {
      var pulsado = false;
      await pumpApp(
        tester,
        Scaffold(
          body: PrimaryButton(
            label: 'Siguiente',
            onPressed: () => pulsado = true,
          ),
        ),
      );

      expect(find.text('Siguiente'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      expect(pulsado, isTrue);
    });

    testWidgets('queda deshabilitado cuando onPressed es null', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: PrimaryButton(label: 'Siguiente', onPressed: null),
        ),
      );

      final boton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(boton.onPressed, isNull);
    });

    testWidgets('respeta el área tocable mínima de 48 dp', (tester) async {
      await pumpApp(
        tester,
        Scaffold(body: PrimaryButton(label: 'Ok', onPressed: () {})),
      );

      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(48.0));
    });
  });

  group('SecondaryButton', () {
    testWidgets('muestra su etiqueta y responde al toque', (tester) async {
      var pulsado = false;
      await pumpApp(
        tester,
        Scaffold(
          body: SecondaryButton(
            label: 'Cancelar',
            onPressed: () => pulsado = true,
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      expect(pulsado, isTrue);
    });
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/core/widgets/buttons_test.dart
```

Esperado: FALLA por error de compilación, los widgets no existen.

- [ ] **Paso 3: Implementar `PrimaryButton`**

Crea `lib/core/widgets/primary_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Botón de acción principal: relleno en el color primario.
///
/// Pasar `onPressed: null` lo deja deshabilitado.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Si es `true`, ocupa todo el ancho disponible.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.progressInactive,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: const StadiumBorder(),
        textStyle: AppTypography.labelButton,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

- [ ] **Paso 4: Implementar `SecondaryButton`**

Crea `lib/core/widgets/secondary_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Botón de acción secundaria: contorno en el color secundario.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        disabledForegroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.secondary, width: 1.5),
        minimumSize: const Size(0, AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: const StadiumBorder(),
        textStyle: AppTypography.labelButton,
      ),
      child: Text(label),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

- [ ] **Paso 5: Correr las pruebas y verificar que pasan**

```bash
flutter test test/core/widgets/buttons_test.dart
flutter analyze
```

Esperado: las cuatro pruebas en verde y `analyze` limpio.

- [ ] **Paso 6: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(core): agrega botones primario y secundario`

---
## Tarea 4: Shell navegable con tres pestañas · HU-03

**Archivos:**
- Crear: `lib/core/widgets/coming_soon_screen.dart`
- Crear: `lib/core/router/app_routes.dart`, `lib/core/router/app_router.dart`
- Crear: `lib/shell/main_shell.dart`
- Crear: `lib/features/home/presentation/home_screen.dart` (versión mínima; las Tareas 8 y
  9 la completan)
- Crear: `test/shell/main_shell_test.dart`
- Modificar: `lib/app.dart`

**Interfaces:**
- Consume: `AppColors`, `AppTypography`, `AppSpacing` (Tarea 2); `pumpApp` (Tarea 2)
- Produce:
  - `ComingSoonScreen({required String section})`
  - `AppRoutes.home` = `'/'`, `AppRoutes.newAlarm` = `'/nueva-alarma'`
  - `AppRouter.onGenerateRoute(RouteSettings)` → `Route<dynamic>?`
  - `MainShell()` — `StatefulWidget` con tres pestañas en `IndexedStack`
  - `HomeScreen()` — pantalla de Inicio, por ahora solo con su `AppBar`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/shell/main_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra las tres pestañas con Inicio seleccionada', (tester) async {
    await pumpApp(tester, const MainShell());

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    final barra = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(barra.currentIndex, 0);
  });

  testWidgets('al tocar Mapa muestra el placeholder de esa sección', (tester) async {
    await pumpApp(tester, const MainShell());

    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();

    expect(find.text('Mapa'), findsNWidgets(2)); // pestaña + título del placeholder
    expect(find.text('Próximamente'), findsOneWidget);

    final barra = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(barra.currentIndex, 1);
  });

  testWidgets('al tocar Perfil muestra el placeholder de esa sección', (tester) async {
    await pumpApp(tester, const MainShell());

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente'), findsOneWidget);
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/shell/main_shell_test.dart
```

Esperado: FALLA por error de compilación, `main_shell.dart` no existe.

- [ ] **Paso 3: Implementar `ComingSoonScreen`**

Crea `lib/core/widgets/coming_soon_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Pantalla para las secciones que están fuera del alcance actual.
///
/// Evita que un control visible del diseño lleve a una pantalla rota
/// durante una demostración.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.section});

  /// Nombre de la sección, tal como aparece en la barra inferior.
  final String section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                LucideIcons.construction,
                size: 48,
                color: AppColors.textSecondary,
                semanticLabel: 'Sección en construcción',
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Próximamente', style: AppTypography.headlineQuestion),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Esta sección todavía está en construcción.',
                style: AppTypography.bodyDefault,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Paso 4: Implementar la versión mínima de `HomeScreen`**

Crea `lib/features/home/presentation/home_screen.dart`. Por ahora solo la barra superior
del mockup; las Tareas 8 y 9 le agregan el contenido:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          tooltip: 'Abrir menú',
          // El menú lateral está fuera del alcance actual.
          onPressed: null,
        ),
        title: const Text('Siempre a Tiempo'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.screenH),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(LucideIcons.user, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Paso 5: Implementar `MainShell`**

Crea `lib/shell/main_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/widgets/coming_soon_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Contenedor principal con la barra de navegación inferior.
///
/// Usa `IndexedStack` para que cada pestaña conserve su estado —incluida la
/// posición de desplazamiento de Inicio— al cambiar de sección.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    ComingSoonScreen(section: 'Mapa'),
    ComingSoonScreen(section: 'Perfil'),
  ];

  void _onTabSelected(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const <BottomNavigationBarItem>[
          // Lucide no trae variantes rellenas, así que la pestaña activa se
          // distingue por color, que el tema ya resuelve.
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Perfil'),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 6: Implementar las rutas**

Crea `lib/core/router/app_routes.dart`:

```dart
abstract final class AppRoutes {
  static const String home = '/';
  static const String newAlarm = '/nueva-alarma';
}
```

Crea `lib/core/router/app_router.dart`. La ruta del asistente se registra en la Tarea 9 y
recibe su pantalla definitiva en la Tarea 13:

```dart
import 'package:flutter/material.dart';

import '../../shell/main_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
```

- [ ] **Paso 7: Conectar el router en la aplicación**

En `lib/app.dart`, reemplaza `home: const Scaffold(...)` por el router. El archivo queda:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';

class SiempreATiempoApp extends StatelessWidget {
  const SiempreATiempoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siempre a Tiempo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
```

- [ ] **Paso 8: Correr las pruebas y verificar que pasan**

```bash
flutter test test/shell/main_shell_test.dart
flutter analyze
flutter run
```

Esperado: las tres pruebas en verde, `analyze` limpio, y la app abre en Inicio con la barra
inferior funcionando y los placeholders en Mapa y Perfil.

- [ ] **Paso 9: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(shell): agrega navegación inferior con tres pestañas`

---

## Tarea 5: Dominio y repositorio de alarmas · HU-01

**Archivos:**
- Crear: `lib/features/home/domain/transport_mode.dart`, `lib/features/home/domain/alarm.dart`
- Crear: `lib/features/home/data/alarm_repository.dart`, `lib/features/home/data/mock_alarm_repository.dart`
- Crear: `test/features/home/data/mock_alarm_repository_test.dart`

**Interfaces:**
- Consume: nada de tareas anteriores
- Produce:
  - `enum TransportMode { car, walking }`
  - `class Alarm` con `id`, `title`, `location`, `startsAt`, `leaveAt`, `transportMode`
  - `abstract interface class AlarmRepository { Future<List<Alarm>> getTodayAlarms(); }`
  - `MockAlarmRepository({Duration delay, bool shouldFail, List<Alarm>? alarms})`

- [ ] **Paso 1: Escribir la prueba que falla**

Crea `test/features/home/data/mock_alarm_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/features/home/domain/transport_mode.dart';

void main() {
  test('devuelve las tres alarmas del diseño', () async {
    final repositorio = MockAlarmRepository(delay: Duration.zero);

    final alarmas = await repositorio.getTodayAlarms();

    expect(alarmas, hasLength(3));
    expect(alarmas.first.title, 'Reunión con cliente');
    expect(alarmas.first.location, 'Oficina zona norte');
    expect(alarmas.first.transportMode, TransportMode.car);
  });

  test('la hora de salida siempre es anterior a la de inicio', () async {
    final repositorio = MockAlarmRepository(delay: Duration.zero);

    final alarmas = await repositorio.getTodayAlarms();

    for (final alarma in alarmas) {
      expect(alarma.leaveAt.isBefore(alarma.startsAt), isTrue,
          reason: 'La alarma "${alarma.title}" tiene una hora de salida inválida');
    }
  });

  test('puede simular una lista vacía', () async {
    final repositorio = MockAlarmRepository(delay: Duration.zero, alarms: const []);

    expect(await repositorio.getTodayAlarms(), isEmpty);
  });

  test('puede simular una falla', () async {
    final repositorio = MockAlarmRepository(delay: Duration.zero, shouldFail: true);

    expect(repositorio.getTodayAlarms(), throwsA(isA<Exception>()));
  });
}
```

- [ ] **Paso 2: Correr la prueba y verificar que falla**

```bash
flutter test test/features/home/data/mock_alarm_repository_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar el enum de transporte**

Crea `lib/features/home/domain/transport_mode.dart`. **Dart puro, sin importar Flutter:**

```dart
/// Medio de transporte con el que el usuario se desplaza a su compromiso.
enum TransportMode {
  car('Carro'),
  walking('Caminando');

  const TransportMode(this.label);

  /// Etiqueta visible al usuario.
  final String label;
}
```

- [ ] **Paso 4: Implementar el modelo de alarma**

Crea `lib/features/home/domain/alarm.dart`:

```dart
import 'transport_mode.dart';

/// Un compromiso del usuario con su hora de salida ya calculada.
///
/// `leaveAt` llega calculado desde la fuente de datos: la aplicación no
/// estima tiempos de viaje, eso corresponde al backend de Siempre a Tiempo,
/// que considera tráfico, clima y otros factores del trayecto.
class Alarm {
  const Alarm({
    required this.id,
    required this.title,
    required this.location,
    required this.startsAt,
    required this.leaveAt,
    required this.transportMode,
  });

  final String id;
  final String title;
  final String location;

  /// Hora de inicio del compromiso.
  final DateTime startsAt;

  /// Hora a la que el usuario debe salir para llegar a tiempo.
  final DateTime leaveAt;

  final TransportMode transportMode;
}
```

- [ ] **Paso 5: Implementar la interfaz del repositorio**

Crea `lib/features/home/data/alarm_repository.dart`:

```dart
import '../domain/alarm.dart';

/// Fuente de las alarmas del usuario.
///
/// Hoy solo existe una implementación simulada. Cuando exista el backend de
/// Siempre a Tiempo se agrega una implementación que consuma la API, sin que
/// ninguna pantalla tenga que cambiar.
abstract interface class AlarmRepository {
  /// Alarmas del día en curso. Puede lanzar si la consulta falla.
  Future<List<Alarm>> getTodayAlarms();
}
```

- [ ] **Paso 6: Implementar el repositorio simulado**

Crea `lib/features/home/data/mock_alarm_repository.dart`. Los datos son exactamente los
del mockup de Inicio:

```dart
import '../domain/alarm.dart';
import '../domain/transport_mode.dart';
import 'alarm_repository.dart';

/// Implementación en memoria con los datos del diseño aprobado.
///
/// `delay` simula la latencia de red para que el estado de carga sea visible.
/// `shouldFail` y `alarms` permiten forzar los estados de error y vacío.
class MockAlarmRepository implements AlarmRepository {
  MockAlarmRepository({
    this.delay = const Duration(milliseconds: 600),
    this.shouldFail = false,
    List<Alarm>? alarms,
  }) : _alarms = alarms ?? _defaultAlarms();

  final Duration delay;
  final bool shouldFail;
  final List<Alarm> _alarms;

  @override
  Future<List<Alarm>> getTodayAlarms() async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('No se pudo consultar la agenda del día');
    }
    return List<Alarm>.unmodifiable(_alarms);
  }

  static List<Alarm> _defaultAlarms() {
    final DateTime now = DateTime.now();
    DateTime at(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);

    return <Alarm>[
      Alarm(
        id: '1',
        title: 'Reunión con cliente',
        location: 'Oficina zona norte',
        startsAt: at(8, 30),
        leaveAt: at(8, 5),
        transportMode: TransportMode.car,
      ),
      Alarm(
        id: '2',
        title: 'Reunión interna',
        location: 'Oficina principal',
        startsAt: at(11, 0),
        leaveAt: at(10, 45),
        transportMode: TransportMode.walking,
      ),
      Alarm(
        id: '3',
        title: 'Presentación proyecto',
        location: 'Cliente zona sur',
        startsAt: at(15, 0),
        leaveAt: at(14, 20),
        transportMode: TransportMode.car,
      ),
    ];
  }
}
```

- [ ] **Paso 7: Verificar que las pruebas pasan y que el dominio está limpio**

```bash
flutter test test/features/home/data/mock_alarm_repository_test.dart
flutter analyze
grep -r "package:flutter/" lib/features/home/domain/ || echo "OK: domain sin dependencias de Flutter"
```

Esperado: las cuatro pruebas en verde, `analyze` limpio, y el `grep` sin coincidencias.

- [ ] **Paso 8: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(home): agrega modelo de alarma y repositorio simulado`

---

## Tarea 6: `HomeViewModel` con cuatro estados · HU-01

**Archivos:**
- Crear: `lib/features/home/presentation/home_state.dart`, `lib/features/home/presentation/home_view_model.dart`
- Crear: `test/features/home/presentation/home_view_model_test.dart`

**Interfaces:**
- Consume: `Alarm`, `AlarmRepository`, `MockAlarmRepository` (Tarea 5)
- Produce:
  - `sealed class HomeState` con `HomeLoading`, `HomeLoaded(List<Alarm> alarms)`,
    `HomeEmpty`, `HomeError(String message)`
  - `HomeViewModel(AlarmRepository repository, {String userName = 'Cristian'})`
  - `HomeViewModel.state` → `HomeState`, `HomeViewModel.userName` → `String`,
    `HomeViewModel.load()` → `Future<void>`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/home/presentation/home_view_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/features/home/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_view_model.dart';

Alarm _alarma(String id, int hora) => Alarm(
      id: id,
      title: 'Compromiso $id',
      location: 'Lugar $id',
      startsAt: DateTime(2026, 8, 20, hora),
      leaveAt: DateTime(2026, 8, 20, hora - 1),
      transportMode: TransportMode.car,
    );

void main() {
  test('arranca en estado de carga', () {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));

    expect(vm.state, isA<HomeLoading>());
  });

  test('pasa a cargado con las alarmas ordenadas por hora de inicio', () async {
    final vm = HomeViewModel(
      MockAlarmRepository(
        delay: Duration.zero,
        alarms: <Alarm>[_alarma('tarde', 15), _alarma('temprano', 8)],
      ),
    );

    await vm.load();

    final estado = vm.state;
    expect(estado, isA<HomeLoaded>());
    expect((estado as HomeLoaded).alarms.map((a) => a.id).toList(),
        <String>['temprano', 'tarde']);
  });

  test('pasa a vacío cuando no hay alarmas', () async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, alarms: const <Alarm>[]),
    );

    await vm.load();

    expect(vm.state, isA<HomeEmpty>());
  });

  test('pasa a error cuando el repositorio falla', () async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, shouldFail: true),
    );

    await vm.load();

    expect(vm.state, isA<HomeError>());
    expect((vm.state as HomeError).message, isNotEmpty);
  });

  test('reintentar después de un error vuelve a consultar', () async {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero, shouldFail: true));
    await vm.load();
    expect(vm.state, isA<HomeError>());

    vm.repository = MockAlarmRepository(delay: Duration.zero);
    await vm.load();

    expect(vm.state, isA<HomeLoaded>());
  });

  test('notifica a sus oyentes en cada cambio de estado', () async {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));
    var notificaciones = 0;
    vm.addListener(() => notificaciones++);

    await vm.load();

    // Una notificación al entrar en carga y otra al terminar.
    expect(notificaciones, 2);
  });

  test('expone el nombre del usuario', () {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));

    expect(vm.userName, 'Cristian');
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/home/presentation/home_view_model_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar los estados**

Crea `lib/features/home/presentation/home_state.dart`:

```dart
import '../domain/alarm.dart';

/// Estados posibles de la pantalla de Inicio.
///
/// Es una jerarquía sellada para que la pantalla tenga que resolver los
/// cuatro casos y ninguno quede sin dibujar.
sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.alarms);

  final List<Alarm> alarms;
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}
```

- [ ] **Paso 4: Implementar el ViewModel**

Crea `lib/features/home/presentation/home_view_model.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../data/alarm_repository.dart';
import '../domain/alarm.dart';
import 'home_state.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this.repository, {this.userName = 'Cristian'});

  /// Mutable para permitir sustituirlo en pruebas de reintento.
  AlarmRepository repository;

  /// Hoy es un valor fijo: la autenticación está fuera del alcance.
  final String userName;

  HomeState _state = const HomeLoading();
  HomeState get state => _state;

  Future<void> load() async {
    _state = const HomeLoading();
    notifyListeners();

    try {
      final List<Alarm> alarms = List<Alarm>.of(await repository.getTodayAlarms())
        ..sort((Alarm a, Alarm b) => a.startsAt.compareTo(b.startsAt));

      _state = alarms.isEmpty ? const HomeEmpty() : HomeLoaded(alarms);
    } on Exception {
      _state = const HomeError('No pudimos cargar tus alarmas.');
    }

    notifyListeners();
  }
}
```

- [ ] **Paso 5: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/home/presentation/home_view_model_test.dart
flutter analyze
```

Esperado: las siete pruebas en verde y `analyze` limpio.

- [ ] **Paso 6: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(home): agrega HomeViewModel con estados de carga, vacío y error`

---
## Tarea 7: Tarjeta de alarma y chip de transporte · HU-02

**Archivos:**
- Crear: `lib/features/home/presentation/widgets/transport_chip.dart`, `lib/features/home/presentation/widgets/alarm_card.dart`
- Crear: `test/features/home/presentation/widgets/alarm_card_test.dart`
- Crear: `test/features/home/presentation/widgets/goldens/` (generado)

**Interfaces:**
- Consume: `Alarm`, `TransportMode` (Tarea 5); `AppDateFormat`, tokens del tema (Tarea 2);
  `pumpApp` (Tarea 2)
- Produce:
  - `TransportChip({required TransportMode mode})`
  - `AlarmCard({required Alarm alarm})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/home/presentation/widgets/alarm_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/features/home/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarm_card.dart';

import '../../../../helpers/pump_app.dart';

Alarm _alarma({
  String title = 'Reunión con cliente',
  String location = 'Oficina zona norte',
  TransportMode mode = TransportMode.car,
}) =>
    Alarm(
      id: '1',
      title: title,
      location: location,
      startsAt: DateTime(2026, 8, 20, 8, 30),
      leaveAt: DateTime(2026, 8, 20, 8, 5),
      transportMode: mode,
    );

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra hora, título, lugar y hora de salida', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.text('8:30 AM'), findsOneWidget);
    expect(find.text('Reunión con cliente'), findsOneWidget);
    expect(find.text('Oficina zona norte'), findsOneWidget);
    expect(find.text('Debes salir 8:05 AM'), findsOneWidget);
  });

  testWidgets('muestra el chip de carro', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.text('Carro'), findsOneWidget);
    expect(find.byIcon(LucideIcons.car), findsOneWidget);
  });

  testWidgets('muestra el chip de caminando', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AlarmCard(alarm: _alarma(mode: TransportMode.walking))),
    );

    expect(find.text('Caminando'), findsOneWidget);
    expect(find.byIcon(LucideIcons.footprints), findsOneWidget);
  });

  testWidgets('trunca textos largos sin desbordarse', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SizedBox(
          width: 280,
          child: AlarmCard(
            alarm: _alarma(
              title: 'Reunión de seguimiento trimestral con el equipo comercial ampliado',
              location: 'Centro empresarial de la zona norte, torre B, piso 14, oficina 1402',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final titulo = tester.widget<Text>(find.textContaining('Reunión de seguimiento'));
    expect(titulo.maxLines, 1);
    expect(titulo.overflow, TextOverflow.ellipsis);
  });

  testWidgets('se anuncia como un solo elemento accesible', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.byType(MergeSemantics), findsOneWidget);
  });

  testWidgets('golden: tarjeta con transporte en carro', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(width: 340, child: AlarmCard(alarm: _alarma())),
        ),
      ),
    );

    await expectLater(
      find.byType(AlarmCard),
      matchesGoldenFile('goldens/alarm_card_car.png'),
    );
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/home/presentation/widgets/alarm_card_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `TransportChip`**

Crea `lib/features/home/presentation/widgets/transport_chip.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/transport_mode.dart';

/// Indicador del medio de transporte de una alarma.
class TransportChip extends StatelessWidget {
  const TransportChip({super.key, required this.mode});

  final TransportMode mode;

  IconData get _icon => switch (mode) {
        TransportMode.car => LucideIcons.car,
        TransportMode.walking => LucideIcons.footprints,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.sm - AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            mode.label,
            style: AppTypography.bodyDefault.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 4: Implementar `AlarmCard`**

Crea `lib/features/home/presentation/widgets/alarm_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm.dart';
import 'transport_chip.dart';

/// Tarjeta de una alarma: cuándo empieza el compromiso y, sobre todo,
/// a qué hora hay que salir.
class AlarmCard extends StatelessWidget {
  const AlarmCard({super.key, required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppDateFormat.time(alarm.startsAt), style: AppTypography.titleTime),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alarm.title,
              style: AppTypography.titleCard,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alarm.location,
              style: AppTypography.bodyDefault,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Debes salir ${AppDateFormat.time(alarm.leaveAt)}',
                    style: AppTypography.bodyEmphasis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TransportChip(mode: alarm.transportMode),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Paso 5: Generar la imagen de referencia del golden**

```bash
flutter test --update-goldens test/features/home/presentation/widgets/alarm_card_test.dart
```

Esperado: se crea `test/features/home/presentation/widgets/goldens/alarm_card_car.png`.
Ábrela y compárala visualmente con el mockup antes de continuar: es la referencia contra
la que se van a validar los cambios futuros, así que no debe nacer con un error visual.

Los goldens dependen del renderizado de la máquina. Si en otro equipo fallan por
diferencias de fuente, regenéralos ahí; no los edites a mano.

- [ ] **Paso 6: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/home/presentation/widgets/alarm_card_test.dart
flutter analyze
```

Esperado: las seis pruebas en verde y `analyze` limpio.

- [ ] **Paso 7: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Recuerda incluir el archivo `.png` del golden en el commit. Mensaje sugerido:

> `feat(home): agrega tarjeta de alarma con chip de transporte`

---

## Tarea 8: Saludo y estados de carga, vacío y error · HU-01

**Archivos:**
- Crear: `lib/features/home/presentation/widgets/greeting_header.dart`,
  `alarms_skeleton.dart`, `alarms_empty_state.dart`, `alarms_error_state.dart`
  (todos bajo `lib/features/home/presentation/widgets/`)
- Crear: `test/features/home/presentation/widgets/home_states_test.dart`

**Interfaces:**
- Consume: tokens del tema (Tarea 2); `pumpApp` (Tarea 2)
- Produce:
  - `GreetingHeader({required String userName, required int alarmCount})`
  - `AlarmsSkeleton()`
  - `AlarmsEmptyState()`
  - `AlarmsErrorState({required String message, required VoidCallback onRetry})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/home/presentation/widgets/home_states_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_empty_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_error_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_skeleton.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/greeting_header.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('GreetingHeader', () {
    testWidgets('saluda al usuario y anuncia el conteo en plural', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 3)),
      );

      expect(find.text('¡Hola, Cristian!'), findsOneWidget);
      expect(find.text('Tienes 3 alarmas para hoy'), findsOneWidget);
    });

    testWidgets('usa el singular cuando hay una sola alarma', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 1)),
      );

      expect(find.text('Tienes 1 alarma para hoy'), findsOneWidget);
    });

    testWidgets('anuncia que no hay alarmas cuando el conteo es cero', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 0)),
      );

      expect(find.text('No tienes alarmas para hoy'), findsOneWidget);
    });
  });

  group('AlarmsSkeleton', () {
    testWidgets('dibuja tres bloques de carga', (tester) async {
      await pumpApp(tester, const Scaffold(body: AlarmsSkeleton()));

      expect(find.byKey(const Key('alarm-skeleton-item')), findsNWidgets(3));
    });
  });

  group('AlarmsEmptyState', () {
    testWidgets('explica que no hay alarmas', (tester) async {
      await pumpApp(tester, const Scaffold(body: AlarmsEmptyState()));

      expect(find.text('No tienes alarmas para hoy'), findsOneWidget);
    });
  });

  group('AlarmsErrorState', () {
    testWidgets('muestra el mensaje y reintenta al tocar el botón', (tester) async {
      var reintentos = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: AlarmsErrorState(
            message: 'No pudimos cargar tus alarmas.',
            onRetry: () => reintentos++,
          ),
        ),
      );

      expect(find.text('No pudimos cargar tus alarmas.'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      expect(reintentos, 1);
    });
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/home/presentation/widgets/home_states_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `GreetingHeader`**

Crea `lib/features/home/presentation/widgets/greeting_header.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Saludo y resumen del día.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.alarmCount,
  });

  final String userName;
  final int alarmCount;

  String get _summary => switch (alarmCount) {
        0 => 'No tienes alarmas para hoy',
        1 => 'Tienes 1 alarma para hoy',
        _ => 'Tienes $alarmCount alarmas para hoy',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('¡Hola, $userName!', style: AppTypography.displayGreeting),
        const SizedBox(height: AppSpacing.xs),
        Text(_summary, style: AppTypography.bodyDefault),
      ],
    );
  }
}
```

- [ ] **Paso 4: Implementar `AlarmsSkeleton`**

Crea `lib/features/home/presentation/widgets/alarms_skeleton.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Esqueleto que ocupa el lugar de las tarjetas mientras cargan,
/// para que la pantalla no aparezca en blanco.
class AlarmsSkeleton extends StatelessWidget {
  const AlarmsSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando tus alarmas',
      child: Column(
        children: List<Widget>.generate(
          itemCount,
          (int index) => Padding(
            key: const Key('alarm-skeleton-item'),
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Paso 5: Implementar `AlarmsEmptyState`**

Crea `lib/features/home/presentation/widgets/alarms_empty_state.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AlarmsEmptyState extends StatelessWidget {
  const AlarmsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          const Icon(
            LucideIcons.calendarCheck,
            size: 48,
            color: AppColors.textSecondary,
            semanticLabel: 'Agenda vacía',
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No tienes alarmas para hoy', style: AppTypography.titleCard),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Crea una nueva alarma y te avisamos a qué hora salir.',
            style: AppTypography.bodyDefault,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 6: Implementar `AlarmsErrorState`**

Crea `lib/features/home/presentation/widgets/alarms_error_state.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/secondary_button.dart';

class AlarmsErrorState extends StatelessWidget {
  const AlarmsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          const Icon(
            LucideIcons.cloudOff,
            size: 48,
            color: AppColors.textSecondary,
            semanticLabel: 'Sin conexión con el servicio',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.titleCard,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(label: 'Reintentar', onPressed: onRetry),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 7: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/home/presentation/widgets/home_states_test.dart
flutter analyze
```

Esperado: las seis pruebas en verde y `analyze` limpio.

- [ ] **Paso 8: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(home): agrega saludo y estados de carga, vacío y error`

---

## Tarea 9: Pantalla de Inicio completa con botón flotante · HU-01, HU-04

**Archivos:**
- Modificar: `lib/features/home/presentation/home_screen.dart` (reemplaza la versión
  mínima de la Tarea 4)
- Modificar: `lib/core/router/app_router.dart` (registra `/nueva-alarma`)
- Crear: `test/features/home/presentation/home_screen_test.dart`

**Interfaces:**
- Consume: `HomeViewModel`, `HomeState` y sus variantes (Tarea 6); `AlarmCard` (Tarea 7);
  `GreetingHeader`, `AlarmsSkeleton`, `AlarmsEmptyState`, `AlarmsErrorState` (Tarea 8);
  `MockAlarmRepository` (Tarea 5); `AppRoutes` (Tarea 4)
- Produce: `HomeScreen()` completa, y la ruta `/nueva-alarma` registrada

> **Estado intermedio deliberado:** en esta tarea la ruta `/nueva-alarma` apunta a
> `ComingSoonScreen(section: 'Nueva alarma')`. La Tarea 17 la cambia por `NewAlarmFlow`,
> que todavía no existe. Esto permite verificar la navegación del botón flotante (HU-04)
> sin depender del asistente completo.

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/home/presentation/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/router/app_router.dart';
import 'package:siempre_a_tiempo/core/router/app_routes.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_screen.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_view_model.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarm_card.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_empty_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_error_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_skeleton.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../../../helpers/pump_app.dart';

/// Monta `HomeScreen` con un ViewModel controlado por la prueba.
Future<void> _pumpHome(WidgetTester tester, HomeViewModel vm) async {
  await pumpApp(tester, HomeScreen(viewModel: vm));
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el esqueleto mientras carga', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: const Duration(milliseconds: 50)),
    );
    unawaited(vm.load());
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsSkeleton), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('muestra el saludo, el encabezado y las tres tarjetas', (tester) async {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));
    await vm.load();
    await _pumpHome(tester, vm);

    expect(find.text('¡Hola, Cristian!'), findsOneWidget);
    expect(find.text('Tienes 3 alarmas para hoy'), findsOneWidget);
    expect(find.text('PRÓXIMAS ALARMAS'), findsOneWidget);
    expect(find.byType(AlarmCard), findsNWidgets(3));
  });

  testWidgets('muestra el estado vacío cuando no hay alarmas', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, alarms: const <Alarm>[]),
    );
    await vm.load();
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsEmptyState), findsOneWidget);
    expect(find.text('No tienes alarmas para hoy'), findsNWidgets(2));
  });

  testWidgets('muestra el estado de error y permite reintentar', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, shouldFail: true),
    );
    await vm.load();
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsErrorState), findsOneWidget);

    vm.repository = MockAlarmRepository(delay: Duration.zero);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(AlarmCard), findsNWidgets(3));
  });

  testWidgets('el botón flotante lleva al asistente de nueva alarma', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva alarma'), findsOneWidget);

    await tester.tap(find.text('Nueva alarma'));
    await tester.pumpAndSettle();

    // Se navegó fuera del shell.
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('conserva el desplazamiento de Inicio al volver de otra pestaña',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await tester.pumpAndSettle();
    final double desplazamiento =
        tester.widget<Scrollable>(find.byType(Scrollable).first).controller?.offset ?? 0;

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();

    final double despues =
        tester.widget<Scrollable>(find.byType(Scrollable).first).controller?.offset ?? 0;
    expect(despues, desplazamiento);
  });
}
```

Agrega al inicio del archivo el import de `dart:async`, necesario para `unawaited`:

```dart
import 'dart:async';
```

Este archivo ya no necesita importar `provider`: `HomeScreen` recibe el ViewModel por
parámetro.

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/home/presentation/home_screen_test.dart
```

Esperado: FALLA. Las pruebas de estados fallan porque `HomeScreen` todavía no consume el
ViewModel, y las de navegación porque la ruta no existe.

- [ ] **Paso 3: Reemplazar `HomeScreen` por la versión completa**

Reemplaza el contenido de `lib/features/home/presentation/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/mock_alarm_repository.dart';
import '../domain/alarm.dart';
import 'home_state.dart';
import 'home_view_model.dart';
import 'widgets/alarm_card.dart';
import 'widgets/alarms_empty_state.dart';
import 'widgets/alarms_error_state.dart';
import 'widgets/alarms_skeleton.dart';
import 'widgets/greeting_header.dart';

/// Pantalla de Inicio.
///
/// Crea su propio `HomeViewModel` con el repositorio simulado. Las pruebas
/// pasan el suyo por `viewModel` para controlar el estado que se dibuja.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.viewModel});

  /// Solo para pruebas: si viene, se usa en lugar de crear uno nuevo.
  final HomeViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final HomeViewModel? inyectado = viewModel;

    if (inyectado != null) {
      return ChangeNotifierProvider<HomeViewModel>.value(
        value: inyectado,
        child: const _HomeView(),
      );
    }

    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => HomeViewModel(MockAlarmRepository())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final HomeViewModel vm = context.watch<HomeViewModel>();
    final HomeState estado = vm.state;

    final int conteo = estado is HomeLoaded ? estado.alarms.length : 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          tooltip: 'Abrir menú',
          // El menú lateral está fuera del alcance actual.
          onPressed: null,
        ),
        title: const Text('Siempre a Tiempo'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.screenH),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(LucideIcons.user, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.md,
              AppSpacing.screenH,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: GreetingHeader(userName: vm.userName, alarmCount: conteo),
            ),
          ),
          if (estado is HomeLoaded)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              sliver: SliverToBoxAdapter(
                child: Text('PRÓXIMAS ALARMAS', style: AppTypography.labelSection),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              // Espacio para que el botón flotante no tape la última tarjeta.
              AppSpacing.xl * 3,
            ),
            sliver: switch (estado) {
              HomeLoading() => const SliverToBoxAdapter(child: AlarmsSkeleton()),
              HomeEmpty() => const SliverToBoxAdapter(child: AlarmsEmptyState()),
              HomeError(:final String message) => SliverToBoxAdapter(
                  child: AlarmsErrorState(message: message, onRetry: vm.load),
                ),
              HomeLoaded(:final List<Alarm> alarms) => SliverList.separated(
                  itemCount: alarms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, int index) => AlarmCard(alarm: alarms[index]),
                ),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newAlarm),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nueva alarma'),
        shape: const StadiumBorder(),
      ),
    );
  }
}
```

- [ ] **Paso 4: Registrar la ruta del asistente**

En `lib/core/router/app_router.dart`, agrega el caso de `/nueva-alarma` apuntando por ahora
al placeholder. El archivo queda:

```dart
import 'package:flutter/material.dart';

import '../../shell/main_shell.dart';
import '../widgets/coming_soon_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      case AppRoutes.newAlarm:
        // La Tarea 17 reemplaza este placeholder por NewAlarmFlow.
        return MaterialPageRoute<void>(
          builder: (_) => const ComingSoonScreen(section: 'Nueva alarma'),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}
```

- [ ] **Paso 5: Correr las pruebas y verificar que pasan**

```bash
flutter test
flutter analyze
```

Esperado: toda la suite en verde y `analyze` limpio.

- [ ] **Paso 6: Verificar en el dispositivo**

```bash
flutter run
```

Esperado: Inicio muestra el esqueleto durante ~600 ms, luego el saludo, el encabezado
"PRÓXIMAS ALARMAS" y las tres tarjetas. El botón flotante se mantiene fijo al desplazar y
abre la pantalla "Próximamente". Comprueba que la última tarjeta no queda tapada por el
botón.

- [ ] **Paso 7: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(home): completa pantalla de Inicio con lista de alarmas y botón flotante`

---
## Tarea 10: Dominio del asistente · HU-05, HU-06

**Archivos:**
- Crear: `lib/features/new_alarm/domain/alarm_type.dart`, `attendee.dart`, `alarm_draft.dart`
- Crear: `test/features/new_alarm/domain/alarm_draft_test.dart`

**Interfaces:**
- Consume: nada de tareas anteriores
- Produce:
  - `enum AlarmType { meeting, personalReminder, recurringEvent }` con `title` y `description`
  - `class Attendee({required String id, required String initials, required int avatarColorIndex})`
  - `class AlarmDraft({AlarmType? type, String title, DateTime? whenAt, String location, List<Attendee> attendees})`
  - `AlarmDraft.isTypeStepValid` → `bool`, `AlarmDraft.isDetailsStepValid` → `bool`
  - `AlarmDraft.copyWith({AlarmType? type, String? title, DateTime? whenAt, String? location, List<Attendee>? attendees, bool clearWhenAt = false})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/domain/alarm_draft_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_draft.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';

void main() {
  group('validación del paso de tipo', () {
    test('un borrador vacío no es válido', () {
      expect(const AlarmDraft().isTypeStepValid, isFalse);
    });

    test('con un tipo elegido es válido', () {
      expect(const AlarmDraft(type: AlarmType.meeting).isTypeStepValid, isTrue);
    });
  });

  group('validación del paso de detalles', () {
    const base = AlarmDraft(type: AlarmType.meeting);

    test('faltan todos los datos', () {
      expect(base.isDetailsStepValid, isFalse);
    });

    test('con título, fecha y lugar es válido', () {
      final borrador = base.copyWith(
        title: 'Reunión con cliente',
        whenAt: DateTime(2026, 8, 20, 15),
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isTrue);
    });

    test('un título de solo espacios no cuenta como diligenciado', () {
      final borrador = base.copyWith(
        title: '   ',
        whenAt: DateTime(2026, 8, 20, 15),
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isFalse);
    });

    test('sin fecha no es válido', () {
      final borrador = base.copyWith(
        title: 'Reunión con cliente',
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isFalse);
    });
  });

  group('copyWith', () {
    test('conserva los campos que no se pasan', () {
      final original = const AlarmDraft(type: AlarmType.meeting).copyWith(
        title: 'Reunión con cliente',
        whenAt: DateTime(2026, 8, 20, 15),
      );

      final copia = original.copyWith(location: 'Avenida El Poblado #1-25');

      expect(copia.type, AlarmType.meeting);
      expect(copia.title, 'Reunión con cliente');
      expect(copia.whenAt, DateTime(2026, 8, 20, 15));
      expect(copia.location, 'Avenida El Poblado #1-25');
    });

    test('clearWhenAt borra la fecha, cosa que un null no lograría', () {
      final original =
          AlarmDraft(type: AlarmType.meeting, whenAt: DateTime(2026, 8, 20, 15));

      expect(original.copyWith().whenAt, isNotNull);
      expect(original.copyWith(clearWhenAt: true).whenAt, isNull);
    });
  });

  group('AlarmType', () {
    test('cada tipo trae el texto del diseño', () {
      expect(AlarmType.meeting.title, 'Reunión');
      expect(AlarmType.meeting.description, 'Agenda una reunión con tiempo de viaje');
      expect(AlarmType.personalReminder.title, 'Recordatorio personal');
      expect(AlarmType.recurringEvent.title, 'Evento recurrente');
    });
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/domain/alarm_draft_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `AlarmType`**

Crea `lib/features/new_alarm/domain/alarm_type.dart`. **Sin iconos:** `IconData` es de
Flutter y el dominio no lo importa. El ícono lo resuelve el widget.

```dart
/// Tipos de alarma que el usuario puede crear.
enum AlarmType {
  meeting(
    title: 'Reunión',
    description: 'Agenda una reunión con tiempo de viaje',
  ),
  personalReminder(
    title: 'Recordatorio personal',
    description: 'Crea un recordatorio para cualquier cosa',
  ),
  recurringEvent(
    title: 'Evento recurrente',
    description: 'Crea alarmas que se repiten a diario',
  );

  const AlarmType({required this.title, required this.description});

  final String title;
  final String description;
}
```

- [ ] **Paso 4: Implementar `Attendee`**

Crea `lib/features/new_alarm/domain/attendee.dart`:

```dart
/// Persona invitada a un compromiso.
///
/// Guarda un índice de color, no un `Color`: así el dominio no depende de
/// Flutter. `AttendeeAvatars` resuelve el índice contra la paleta del tema.
class Attendee {
  const Attendee({
    required this.id,
    required this.initials,
    required this.avatarColorIndex,
  });

  final String id;
  final String initials;
  final int avatarColorIndex;
}
```

- [ ] **Paso 5: Implementar `AlarmDraft`**

Crea `lib/features/new_alarm/domain/alarm_draft.dart`:

```dart
import 'alarm_type.dart';
import 'attendee.dart';

/// Datos que el usuario va acumulando dentro del asistente de creación.
///
/// Es inmutable: cada cambio produce una copia. El ViewModel es el único
/// que lo sustituye.
class AlarmDraft {
  const AlarmDraft({
    this.type,
    this.title = '',
    this.whenAt,
    this.location = '',
    this.attendees = const <Attendee>[],
  });

  final AlarmType? type;
  final String title;
  final DateTime? whenAt;
  final String location;
  final List<Attendee> attendees;

  bool get isTypeStepValid => type != null;

  bool get isDetailsStepValid =>
      title.trim().isNotEmpty && whenAt != null && location.trim().isNotEmpty;

  /// Copia con los campos indicados sustituidos.
  ///
  /// `clearWhenAt` existe porque pasar `whenAt: null` es indistinguible de
  /// no pasarlo: es la única forma de vaciar la fecha.
  AlarmDraft copyWith({
    AlarmType? type,
    String? title,
    DateTime? whenAt,
    String? location,
    List<Attendee>? attendees,
    bool clearWhenAt = false,
  }) {
    return AlarmDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      whenAt: clearWhenAt ? null : (whenAt ?? this.whenAt),
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
    );
  }
}
```

- [ ] **Paso 6: Verificar que pasan y que el dominio está limpio**

```bash
flutter test test/features/new_alarm/domain/alarm_draft_test.dart
flutter analyze
grep -r "package:flutter/" lib/features/new_alarm/domain/ || echo "OK: domain sin dependencias de Flutter"
```

Esperado: las nueve pruebas en verde, `analyze` limpio y el `grep` sin coincidencias.

- [ ] **Paso 7: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega dominio del asistente de creación`

---

## Tarea 11: `NewAlarmViewModel` · HU-05, HU-06, HU-07

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/new_alarm_view_model.dart`
- Crear: `test/features/new_alarm/presentation/new_alarm_view_model_test.dart`

**Interfaces:**
- Consume: `AlarmDraft`, `AlarmType`, `Attendee` (Tarea 10)
- Produce:
  - `NewAlarmViewModel()` con `totalSteps` = 4, `lastImplementedStep` = 1
  - `draft` → `AlarmDraft`, `currentStep` → `int`, `canAdvance` → `bool`, `isFirstStep` → `bool`
  - `selectType(AlarmType)`, `updateTitle(String)`, `updateLocation(String)`,
    `updateWhenAt(DateTime)`, `clearTitle()`, `clearLocation()`, `clearWhenAt()`
  - `next()` → `bool` (false si no hay paso implementado al que avanzar)
  - `back()` → `bool` (false si ya está en el primer paso)

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/new_alarm_view_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';

void main() {
  test('arranca en el primer paso con un borrador vacío', () {
    final vm = NewAlarmViewModel();

    expect(vm.currentStep, 0);
    expect(vm.isFirstStep, isTrue);
    expect(vm.draft.type, isNull);
    expect(NewAlarmViewModel.totalSteps, 4);
  });

  test('no puede avanzar sin haber elegido un tipo', () {
    final vm = NewAlarmViewModel();

    expect(vm.canAdvance, isFalse);
    expect(vm.next(), isFalse);
    expect(vm.currentStep, 0);
  });

  test('al elegir un tipo se habilita el avance y notifica', () {
    final vm = NewAlarmViewModel();
    var notificaciones = 0;
    vm.addListener(() => notificaciones++);

    vm.selectType(AlarmType.meeting);

    expect(vm.draft.type, AlarmType.meeting);
    expect(vm.canAdvance, isTrue);
    expect(notificaciones, 1);
  });

  test('seleccionar otro tipo reemplaza el anterior', () {
    final vm = NewAlarmViewModel()..selectType(AlarmType.meeting);

    vm.selectType(AlarmType.recurringEvent);

    expect(vm.draft.type, AlarmType.recurringEvent);
  });

  test('avanza al paso 2 cuando hay tipo elegido', () {
    final vm = NewAlarmViewModel()..selectType(AlarmType.meeting);

    expect(vm.next(), isTrue);
    expect(vm.currentStep, 1);
    expect(vm.isFirstStep, isFalse);
  });

  test('no avanza más allá del último paso implementado', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');

    expect(vm.canAdvance, isTrue);
    // El paso 3 está fuera del alcance: next() informa que no pudo avanzar.
    expect(vm.next(), isFalse);
    expect(vm.currentStep, 1);
  });

  test('retroceder conserva los datos ya escritos', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente');

    expect(vm.back(), isTrue);
    expect(vm.currentStep, 0);
    expect(vm.draft.type, AlarmType.meeting);

    vm.next();
    expect(vm.draft.title, 'Reunión con cliente');
  });

  test('no retrocede desde el primer paso', () {
    final vm = NewAlarmViewModel();

    expect(vm.back(), isFalse);
    expect(vm.currentStep, 0);
  });

  test('el paso de detalles exige título, fecha y lugar', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next();

    expect(vm.canAdvance, isFalse);

    vm.updateTitle('Reunión con cliente');
    expect(vm.canAdvance, isFalse);

    vm.updateWhenAt(DateTime(2026, 8, 20, 15));
    expect(vm.canAdvance, isFalse);

    vm.updateLocation('Avenida El Poblado #1-25');
    expect(vm.canAdvance, isTrue);
  });

  test('limpiar un campo lo vacía sin tocar los demás', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');

    vm.clearWhenAt();

    expect(vm.draft.whenAt, isNull);
    expect(vm.draft.title, 'Reunión con cliente');
    expect(vm.draft.location, 'Avenida El Poblado #1-25');
    expect(vm.canAdvance, isFalse);
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/new_alarm_view_model_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar el ViewModel**

Crea `lib/features/new_alarm/presentation/new_alarm_view_model.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../domain/alarm_draft.dart';
import '../domain/alarm_type.dart';
import '../domain/attendee.dart';

/// Estado del asistente de creación de alarmas.
class NewAlarmViewModel extends ChangeNotifier {
  NewAlarmViewModel({List<Attendee>? attendees})
      : _draft = AlarmDraft(attendees: attendees ?? _sampleAttendees);

  /// Pasos que muestra el indicador de progreso del diseño.
  static const int totalSteps = 4;

  /// Último paso construido. Los pasos 3 y 4 están fuera del alcance actual.
  static const int lastImplementedStep = 1;

  AlarmDraft _draft;
  AlarmDraft get draft => _draft;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool get isFirstStep => _currentStep == 0;

  bool get canAdvance => switch (_currentStep) {
        0 => _draft.isTypeStepValid,
        1 => _draft.isDetailsStepValid,
        _ => false,
      };

  void selectType(AlarmType type) {
    _draft = _draft.copyWith(type: type);
    notifyListeners();
  }

  void updateTitle(String value) {
    _draft = _draft.copyWith(title: value);
    notifyListeners();
  }

  void updateLocation(String value) {
    _draft = _draft.copyWith(location: value);
    notifyListeners();
  }

  void updateWhenAt(DateTime value) {
    _draft = _draft.copyWith(whenAt: value);
    notifyListeners();
  }

  void clearTitle() => updateTitle('');

  void clearLocation() => updateLocation('');

  void clearWhenAt() {
    _draft = _draft.copyWith(clearWhenAt: true);
    notifyListeners();
  }

  /// Avanza un paso. Devuelve `false` si no hay a dónde avanzar, sea porque
  /// faltan datos o porque el siguiente paso todavía no está construido;
  /// la pantalla usa ese `false` para avisar que la función viene después.
  bool next() {
    if (!canAdvance || _currentStep >= lastImplementedStep) {
      return false;
    }
    _currentStep++;
    notifyListeners();
    return true;
  }

  /// Retrocede un paso. Devuelve `false` si ya está en el primero, caso en
  /// el que la pantalla debe cerrar el asistente.
  bool back() {
    if (isFirstStep) {
      return false;
    }
    _currentStep--;
    notifyListeners();
    return true;
  }

  /// Asistentes de ejemplo del mockup. La edición de invitados está fuera
  /// del alcance actual, así que la lista es fija.
  static const List<Attendee> _sampleAttendees = <Attendee>[
    Attendee(id: '1', initials: 'MC', avatarColorIndex: 0),
    Attendee(id: '2', initials: 'JP', avatarColorIndex: 1),
    Attendee(id: '3', initials: 'LR', avatarColorIndex: 2),
    Attendee(id: '4', initials: 'AS', avatarColorIndex: 3),
    Attendee(id: '5', initials: 'DG', avatarColorIndex: 0),
    Attendee(id: '6', initials: 'VT', avatarColorIndex: 1),
  ];
}
```

- [ ] **Paso 4: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/new_alarm/presentation/new_alarm_view_model_test.dart
flutter analyze
```

Esperado: las diez pruebas en verde y `analyze` limpio.

- [ ] **Paso 5: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega NewAlarmViewModel con borrador y control de pasos`

---

## Tarea 12: Indicador de progreso y barra inferior · HU-07

**Archivos:**
- Crear: `lib/core/widgets/wizard_progress_bar.dart`, `lib/core/widgets/wizard_bottom_bar.dart`
- Crear: `test/core/widgets/wizard_widgets_test.dart`

**Interfaces:**
- Consume: tokens del tema (Tarea 2); `PrimaryButton`, `SecondaryButton` (Tarea 3)
- Produce:
  - `WizardProgressBar({required int currentStep, required int totalSteps})`
  - `WizardBottomBar({required String leadingLabel, required VoidCallback onLeading, required String trailingLabel, required VoidCallback? onTrailing})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/core/widgets/wizard_widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/theme/app_colors.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_bottom_bar.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_progress_bar.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('WizardProgressBar', () {
    testWidgets('dibuja un segmento por paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 0, totalSteps: 4),
        ),
      );

      expect(find.byKey(const Key('wizard-progress-segment')), findsNWidgets(4));
    });

    testWidgets('resalta un segmento en el primer paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 0, totalSteps: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(_segmentosActivos(tester), 1);
    });

    testWidgets('resalta dos segmentos en el segundo paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 1, totalSteps: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(_segmentosActivos(tester), 2);
    });

    testWidgets('se anuncia como progreso al lector de pantalla', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 1, totalSteps: 4),
        ),
      );

      expect(find.bySemanticsLabel('Paso 2 de 4'), findsOneWidget);
    });
  });

  group('WizardBottomBar', () {
    testWidgets('muestra ambas etiquetas y responde a los toques', (tester) async {
      var atras = 0;
      var siguiente = 0;

      await pumpApp(
        tester,
        Scaffold(
          body: WizardBottomBar(
            leadingLabel: 'Cancelar',
            onLeading: () => atras++,
            trailingLabel: 'Siguiente',
            onTrailing: () => siguiente++,
          ),
        ),
      );

      await tester.tap(find.text('Cancelar'));
      await tester.tap(find.text('Siguiente'));

      expect(atras, 1);
      expect(siguiente, 1);
    });

    testWidgets('deshabilita la acción principal cuando onTrailing es null',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: WizardBottomBar(
            leadingLabel: 'Cancelar',
            onLeading: () {},
            trailingLabel: 'Siguiente',
            onTrailing: null,
          ),
        ),
      );

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });
}

/// Cuenta los segmentos pintados con el color primario.
int _segmentosActivos(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(find.byKey(const Key('wizard-progress-segment')))
      .where((AnimatedContainer c) =>
          (c.decoration as BoxDecoration?)?.color == AppColors.primary)
      .length;
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/core/widgets/wizard_widgets_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `WizardProgressBar`**

Crea `lib/core/widgets/wizard_progress_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Indicador de avance del asistente: un segmento por paso.
class WizardProgressBar extends StatelessWidget {
  const WizardProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// Índice del paso actual, base cero.
  final int currentStep;

  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Paso ${currentStep + 1} de $totalSteps',
      child: Row(
        children: List<Widget>.generate(totalSteps, (int index) {
          final bool completado = index <= currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == totalSteps - 1 ? 0 : AppSpacing.sm,
              ),
              child: AnimatedContainer(
                key: const Key('wizard-progress-segment'),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: AppSizes.progressBarHeight,
                decoration: BoxDecoration(
                  color: completado ? AppColors.primary : AppColors.progressInactive,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Paso 4: Implementar `WizardBottomBar`**

Crea `lib/core/widgets/wizard_bottom_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Barra fija con las dos acciones de navegación del asistente.
///
/// `onTrailing: null` deja deshabilitada la acción principal, que es como se
/// bloquea el avance mientras falten datos.
class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({
    super.key,
    required this.leadingLabel,
    required this.onLeading,
    required this.trailingLabel,
    required this.onTrailing,
  });

  final String leadingLabel;
  final VoidCallback onLeading;
  final String trailingLabel;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(
                  label: leadingLabel,
                  onPressed: onLeading,
                  expanded: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: trailingLabel,
                  onPressed: onTrailing,
                  expanded: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Paso 5: Correr las pruebas y verificar que pasan**

```bash
flutter test test/core/widgets/wizard_widgets_test.dart
flutter analyze
```

Esperado: las seis pruebas en verde y `analyze` limpio.

- [ ] **Paso 6: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(core): agrega indicador de progreso y barra inferior del asistente`

---
## Tarea 13: Paso 1 — selección de tipo · HU-05

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/widgets/alarm_type_card.dart`
- Crear: `lib/features/new_alarm/presentation/steps/step_type_screen.dart`
- Crear: `test/features/new_alarm/presentation/steps/step_type_screen_test.dart`

**Interfaces:**
- Consume: `AlarmType` (Tarea 10); `NewAlarmViewModel` (Tarea 11); tokens del tema (Tarea 2)
- Produce:
  - `AlarmTypeCard({required AlarmType type, required bool selected, required VoidCallback onTap})`
  - `StepTypeScreen()` — lee el `NewAlarmViewModel` del árbol

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/steps/step_type_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_type_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/alarm_type_card.dart';

import '../../../../helpers/pump_app.dart';

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepTypeScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra la pregunta y las tres opciones con su descripción',
      (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);

    expect(find.text('Reunión'), findsOneWidget);
    expect(find.text('Agenda una reunión con tiempo de viaje'), findsOneWidget);
    expect(find.text('Recordatorio personal'), findsOneWidget);
    expect(find.text('Crea un recordatorio para cualquier cosa'), findsOneWidget);
    expect(find.text('Evento recurrente'), findsOneWidget);
    expect(find.text('Crea alarmas que se repiten a diario'), findsOneWidget);

    expect(find.byType(AlarmTypeCard), findsNWidgets(3));
  });

  testWidgets('ninguna opción está seleccionada al entrar', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    final seleccionadas = tester
        .widgetList<AlarmTypeCard>(find.byType(AlarmTypeCard))
        .where((AlarmTypeCard c) => c.selected);

    expect(seleccionadas, isEmpty);
  });

  testWidgets('tocar una opción la selecciona en el ViewModel', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();

    expect(vm.draft.type, AlarmType.meeting);
  });

  testWidgets('la selección es excluyente', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evento recurrente'));
    await tester.pumpAndSettle();

    final seleccionadas = tester
        .widgetList<AlarmTypeCard>(find.byType(AlarmTypeCard))
        .where((AlarmTypeCard c) => c.selected)
        .toList();

    expect(seleccionadas, hasLength(1));
    expect(seleccionadas.single.type, AlarmType.recurringEvent);
  });

  testWidgets('cada opción se anuncia como seleccionable', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(find.byType(MergeSemantics), findsNWidgets(3));
  });

  testWidgets('golden: opción sin seleccionar y seleccionada', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              AlarmTypeCard(
                type: AlarmType.meeting,
                selected: false,
                onTap: _noop,
              ),
              SizedBox(height: 16),
              AlarmTypeCard(
                type: AlarmType.meeting,
                selected: true,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/alarm_type_card_states.png'),
    );
  });
}

void _noop() {}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/steps/step_type_screen_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `AlarmTypeCard`**

Crea `lib/features/new_alarm/presentation/widgets/alarm_type_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm_type.dart';

/// Opción seleccionable del primer paso del asistente.
class AlarmTypeCard extends StatelessWidget {
  const AlarmTypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AlarmType type;
  final bool selected;
  final VoidCallback onTap;

  /// El ícono vive aquí y no en el enum: `IconData` es de Flutter y el
  /// dominio no depende de Flutter.
  IconData get _icon => switch (type) {
        AlarmType.meeting => LucideIcons.briefcase,
        AlarmType.personalReminder => LucideIcons.bell,
        AlarmType.recurringEvent => LucideIcons.repeat,
      };

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    ),
                    child: Icon(
                      _icon,
                      size: 22,
                      color: selected ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(type.title, style: AppTypography.titleCard),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(type.description, style: AppTypography.bodyDefault),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    selected ? LucideIcons.checkCircle : LucideIcons.chevronRight,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Paso 4: Implementar `StepTypeScreen`**

Crea `lib/features/new_alarm/presentation/steps/step_type_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm_type.dart';
import '../new_alarm_view_model.dart';
import '../widgets/alarm_type_card.dart';

/// Paso 1: el usuario elige qué tipo de alarma quiere crear.
class StepTypeScreen extends StatelessWidget {
  const StepTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NewAlarmViewModel vm = context.watch<NewAlarmViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '¿Qué tipo de alarma quieres crear?',
            style: AppTypography.headlineQuestion,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final AlarmType type in AlarmType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AlarmTypeCard(
                type: type,
                selected: vm.draft.type == type,
                onTap: () => vm.selectType(type),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 5: Generar el golden y verificar**

```bash
flutter test --update-goldens test/features/new_alarm/presentation/steps/step_type_screen_test.dart
flutter test test/features/new_alarm/presentation/steps/step_type_screen_test.dart
flutter analyze
```

Esperado: se genera `goldens/alarm_type_card_states.png`, las seis pruebas pasan y
`analyze` está limpio. Revisa la imagen: el estado seleccionado debe distinguirse
claramente del normal.

- [ ] **Paso 6: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega paso de selección de tipo de alarma`

---

## Tarea 14: Campo con etiqueta flotante · HU-06

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/widgets/labeled_field.dart`
- Crear: `test/features/new_alarm/presentation/widgets/labeled_field_test.dart`

**Interfaces:**
- Consume: tokens del tema (Tarea 2); `pumpApp` (Tarea 2)
- Produce, los tres en el mismo archivo:
  - `LabeledField({required String label, required Widget child, required VoidCallback? onClear, bool focused = false})` — la decoración compartida
  - `LabeledTextField({required String label, required String value, required ValueChanged<String> onChanged, required VoidCallback onClear, String? hint})`
  - `LabeledTapField({required String label, required String? value, required String hint, required VoidCallback onTap, required VoidCallback onClear})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/widgets/labeled_field_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/labeled_field.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('LabeledTextField', () {
    testWidgets('muestra la etiqueta y el valor', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      expect(find.text('Título de la reunión'), findsOneWidget);
      expect(find.text('Reunión con cliente'), findsOneWidget);
    });

    testWidgets('notifica cada cambio de texto', (tester) async {
      String? ultimo;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: '',
            onChanged: (String v) => ultimo = v,
            onClear: () {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Almuerzo');

      expect(ultimo, 'Almuerzo');
    });

    testWidgets('el botón de limpiar solo aparece cuando hay valor',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: '',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('limpiar vacía el campo', (tester) async {
      var limpiados = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () => limpiados++,
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.x));
      expect(limpiados, 1);
    });

    testWidgets('el botón de limpiar cumple el área tocable mínima',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      final Size tamano = tester.getSize(find.byType(IconButton));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
    });
  });

  group('LabeledTapField', () {
    testWidgets('muestra la pista cuando no hay valor', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTapField(
            label: '¿Cuándo es?',
            value: null,
            hint: 'Selecciona fecha y hora',
            onTap: () {},
            onClear: () {},
          ),
        ),
      );

      expect(find.text('Selecciona fecha y hora'), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('muestra el valor y responde al toque', (tester) async {
      var toques = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTapField(
            label: '¿Cuándo es?',
            value: '20 de agosto de 2026, 3:00 PM',
            hint: 'Selecciona fecha y hora',
            onTap: () => toques++,
            onClear: () {},
          ),
        ),
      );

      expect(find.text('20 de agosto de 2026, 3:00 PM'), findsOneWidget);

      await tester.tap(find.text('20 de agosto de 2026, 3:00 PM'));
      expect(toques, 1);
    });
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/widgets/labeled_field_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar los tres widgets**

Crea `lib/features/new_alarm/presentation/widgets/labeled_field.dart`. Los tres viven en
el mismo archivo porque comparten decoración y siempre cambian juntos:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Decoración compartida de los campos del asistente: etiqueta arriba,
/// contenido debajo y un botón para vaciarlo.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    required this.onClear,
    this.focused = false,
  });

  final String label;
  final Widget child;

  /// `null` oculta el botón de limpiar, que es lo que ocurre con el campo vacío.
  final VoidCallback? onClear;

  final bool focused;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: focused ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(
          color: focused ? AppColors.secondary : AppColors.border,
          width: focused ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTypography.labelField.copyWith(
                      color: focused ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Limpiar $label',
              onPressed: onClear,
            )
          else
            const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Campo de texto editable con etiqueta.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String? hint;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  void _onFocusChanged() => setState(() {});

  @override
  void didUpdateWidget(LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El ViewModel es la fuente de verdad: si el valor cambió por fuera
    // (por ejemplo al limpiarlo), el controlador se sincroniza.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.label,
      focused: _focusNode.hasFocus,
      onClear: widget.value.isEmpty ? null : widget.onClear,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: AppTypography.titleCard,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.hint,
          hintStyle: AppTypography.bodyDefault,
        ),
      ),
    );
  }
}

/// Campo de solo lectura que abre un selector al tocarlo.
class LabeledTapField extends StatelessWidget {
  const LabeledTapField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool tieneValor = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: LabeledField(
        label: label,
        onClear: tieneValor ? onClear : null,
        child: Text(
          tieneValor ? value! : hint,
          style: tieneValor ? AppTypography.titleCard : AppTypography.bodyDefault,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
```

- [ ] **Paso 4: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/new_alarm/presentation/widgets/labeled_field_test.dart
flutter analyze
```

Esperado: las siete pruebas en verde y `analyze` limpio.

- [ ] **Paso 5: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega campos con etiqueta flotante y botón de limpiar`

---

## Tarea 15: Fila de avatares de asistentes · HU-06

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/widgets/attendee_avatars.dart`
- Crear: `test/features/new_alarm/presentation/widgets/attendee_avatars_test.dart`

**Interfaces:**
- Consume: `Attendee` (Tarea 10); `AppColors.avatarAt` (Tarea 2)
- Produce: `AttendeeAvatars({required List<Attendee> attendees, int maxVisible = 4})`

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/widgets/attendee_avatars_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/attendee.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/attendee_avatars.dart';

import '../../../../helpers/pump_app.dart';

List<Attendee> _asistentes(int cantidad) => List<Attendee>.generate(
      cantidad,
      (int i) => Attendee(id: '$i', initials: 'A$i', avatarColorIndex: i),
    );

void main() {
  setUpAll(initTestFormatting);

  testWidgets('dibuja un avatar por asistente cuando caben todos', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(3))),
    );

    expect(find.byType(CircleAvatar), findsNWidgets(3));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('muestra el contador de excedentes cuando hay más de los visibles',
      (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(6))),
    );

    expect(find.byType(CircleAvatar), findsNWidgets(4));
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('no dibuja nada cuando no hay asistentes', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: AttendeeAvatars(attendees: <Attendee>[])),
    );

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('se anuncia con el número total de asistentes', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(6))),
    );

    expect(find.bySemanticsLabel('6 asistentes'), findsOneWidget);
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/widgets/attendee_avatars_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar el widget**

Crea `lib/features/new_alarm/presentation/widgets/attendee_avatars.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/attendee.dart';

/// Fila de avatares de los invitados, con un contador para los que no caben.
///
/// Es de solo lectura: agregar o quitar invitados está fuera del alcance actual.
class AttendeeAvatars extends StatelessWidget {
  const AttendeeAvatars({
    super.key,
    required this.attendees,
    this.maxVisible = 4,
  });

  final List<Attendee> attendees;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Attendee> visibles = attendees.take(maxVisible).toList();
    final int excedentes = attendees.length - visibles.length;

    return Semantics(
      label: '${attendees.length} asistentes',
      child: Row(
        children: <Widget>[
          for (final Attendee asistente in visibles)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.avatarAt(asistente.avatarColorIndex),
                child: Text(
                  asistente.initials,
                  style: AppTypography.bodyDefault.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (excedentes > 0)
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Text(
                '+$excedentes',
                style: AppTypography.bodyDefault.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 4: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/new_alarm/presentation/widgets/attendee_avatars_test.dart
flutter analyze
```

Esperado: las cuatro pruebas en verde y `analyze` limpio.

- [ ] **Paso 5: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega fila de avatares de asistentes`

---
## Tarea 16: Paso 2 — detalles de la reunión · HU-06

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/steps/step_details_screen.dart`
- Crear: `test/features/new_alarm/presentation/steps/step_details_screen_test.dart`

**Interfaces:**
- Consume: `NewAlarmViewModel` (Tarea 11); `LabeledTextField`, `LabeledTapField`
  (Tarea 14); `AttendeeAvatars` (Tarea 15); `AppDateFormat` (Tarea 2)
- Produce: `StepDetailsScreen()` — lee el `NewAlarmViewModel` del árbol

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/steps/step_details_screen_test.dart`.

Sobre el selector de fecha: las pruebas comprueban que **se abre**, no que se confirme
tocando su botón. La etiqueta de confirmación viene de las traducciones de Material y
cambiarlas de versión rompería la prueba sin que haya un defecto real; el formato del
valor ya está cubierto por las pruebas de `AppDateFormat`.

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_details_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/attendee_avatars.dart';

import '../../../../helpers/pump_app.dart';

NewAlarmViewModel _vmEnPaso2() => NewAlarmViewModel()
  ..selectType(AlarmType.meeting)
  ..next();

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepDetailsScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el título y los tres campos del diseño', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.text('Detalles de la reunión'), findsOneWidget);
    expect(find.text('Título de la reunión'), findsOneWidget);
    expect(find.text('¿Cuándo es?'), findsOneWidget);
    expect(find.text('¿Dónde es?'), findsOneWidget);
    expect(find.text('¿Quién más asistirá?'), findsOneWidget);
  });

  testWidgets('escribir el título lo guarda en el borrador', (tester) async {
    final vm = _vmEnPaso2();
    await _pumpStep(tester, vm);

    await tester.enterText(find.byType(TextField).first, 'Reunión con cliente');
    await tester.pumpAndSettle();

    expect(vm.draft.title, 'Reunión con cliente');
  });

  testWidgets('escribir el lugar lo guarda en el borrador', (tester) async {
    final vm = _vmEnPaso2();
    await _pumpStep(tester, vm);

    await tester.enterText(find.byType(TextField).last, 'Avenida El Poblado #1-25');
    await tester.pumpAndSettle();

    expect(vm.draft.location, 'Avenida El Poblado #1-25');
  });

  testWidgets('muestra la fecha ya elegida con el formato del diseño',
      (tester) async {
    final vm = _vmEnPaso2()..updateWhenAt(DateTime(2026, 8, 20, 15));
    await _pumpStep(tester, vm);

    expect(find.text('20 de agosto de 2026, 3:00 PM'), findsOneWidget);
  });

  testWidgets('tocar el campo de fecha abre el selector', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    await tester.tap(find.text('Selecciona fecha y hora'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('limpiar la fecha la borra sin tocar los demás campos',
      (tester) async {
    final vm = _vmEnPaso2()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');
    await _pumpStep(tester, vm);

    await tester.tap(find.widgetWithIcon(IconButton, LucideIcons.x).at(1));
    await tester.pumpAndSettle();

    expect(vm.draft.whenAt, isNull);
    expect(vm.draft.title, 'Reunión con cliente');
    expect(vm.draft.location, 'Avenida El Poblado #1-25');
  });

  testWidgets('muestra los avatares de los asistentes', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.byType(AttendeeAvatars), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('el contenido se desplaza cuando aparece el teclado',
      (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/steps/step_details_screen_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar la pantalla**

Crea `lib/features/new_alarm/presentation/steps/step_details_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../new_alarm_view_model.dart';
import '../widgets/attendee_avatars.dart';
import '../widgets/labeled_field.dart';

/// Paso 2: el usuario registra los datos con los que se calculará
/// su hora de salida.
class StepDetailsScreen extends StatelessWidget {
  const StepDetailsScreen({super.key});

  Future<void> _pickDateTime(
    BuildContext context,
    NewAlarmViewModel vm,
  ) async {
    final DateTime ahora = DateTime.now();
    final DateTime inicial = vm.draft.whenAt ?? ahora;

    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(ahora.year, ahora.month, ahora.day),
      lastDate: DateTime(ahora.year + 5),
      helpText: 'Selecciona la fecha',
    );
    if (fecha == null || !context.mounted) {
      return;
    }

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      helpText: 'Selecciona la hora',
    );
    if (hora == null) {
      return;
    }

    vm.updateWhenAt(
      DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NewAlarmViewModel vm = context.watch<NewAlarmViewModel>();
    final DateTime? cuando = vm.draft.whenAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Detalles de la reunión', style: AppTypography.headlineQuestion),
          const SizedBox(height: AppSpacing.lg),
          LabeledTextField(
            label: 'Título de la reunión',
            value: vm.draft.title,
            hint: 'Escribe un título',
            onChanged: vm.updateTitle,
            onClear: vm.clearTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledTapField(
            label: '¿Cuándo es?',
            value: cuando == null ? null : AppDateFormat.longDateTime(cuando),
            hint: 'Selecciona fecha y hora',
            onTap: () => _pickDateTime(context, vm),
            onClear: vm.clearWhenAt,
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledTextField(
            label: '¿Dónde es?',
            value: vm.draft.location,
            hint: 'Escribe la dirección',
            onChanged: vm.updateLocation,
            onClear: vm.clearLocation,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('¿Quién más asistirá?', style: AppTypography.bodyDefault),
          const SizedBox(height: AppSpacing.sm),
          AttendeeAvatars(attendees: vm.draft.attendees),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 4: Correr las pruebas y verificar que pasan**

```bash
flutter test test/features/new_alarm/presentation/steps/step_details_screen_test.dart
flutter analyze
```

Esperado: las ocho pruebas en verde y `analyze` limpio.

- [ ] **Paso 5: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): agrega paso de detalles de la reunión`

---

## Tarea 17: Contenedor del asistente y navegación entre pasos · HU-07

Esta es la tarea de integración: une los dos pasos, el indicador de progreso y la barra
inferior, y reemplaza el placeholder de la ruta `/nueva-alarma`.

**Archivos:**
- Crear: `lib/features/new_alarm/presentation/new_alarm_flow.dart`
- Modificar: `lib/core/router/app_router.dart` (sustituye el placeholder de la Tarea 9)
- Crear: `test/features/new_alarm/presentation/new_alarm_flow_test.dart`

**Interfaces:**
- Consume: `NewAlarmViewModel` (Tarea 11); `WizardProgressBar`, `WizardBottomBar`
  (Tarea 12); `StepTypeScreen` (Tarea 13); `StepDetailsScreen` (Tarea 16)
- Produce: `NewAlarmFlow()`, y la ruta `/nueva-alarma` apuntando a él

- [ ] **Paso 1: Escribir las pruebas que fallan**

Crea `test/features/new_alarm/presentation/new_alarm_flow_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_progress_bar.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  testWidgets('abre en el paso 1 con Siguiente deshabilitado', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    expect(find.text('Nueva alarma'), findsOneWidget);
    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
  });

  testWidgets('el indicador refleja el paso actual', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    final barra = tester.widget<WizardProgressBar>(find.byType(WizardProgressBar));
    expect(barra.currentStep, 0);
    expect(barra.totalSteps, 4);
  });

  testWidgets('seleccionar un tipo habilita Siguiente y avanza al paso 2',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Detalles de la reunión'), findsOneWidget);
    expect(
      tester.widget<WizardProgressBar>(find.byType(WizardProgressBar)).currentStep,
      1,
    );
  });

  testWidgets('la acción izquierda dice Cancelar en el paso 1 y Atrás en el 2',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    expect(find.text('Cancelar'), findsOneWidget);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Atrás'), findsOneWidget);
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('Atrás vuelve al paso 1 conservando la selección', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
    // Siguiente sigue habilitado: la selección no se perdió.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('con los datos completos, Siguiente avisa que falta construirlo',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Reunión con cliente');
    await tester.enterText(find.byType(TextField).last, 'Avenida El Poblado #1-25');
    await tester.pumpAndSettle();

    // La fecha se fija directamente: el selector de Material ya está cubierto
    // por las pruebas del paso 2.
    final estado = tester.state<NewAlarmFlowState>(find.byType(NewAlarmFlow));
    estado.viewModel.updateWhenAt(DateTime(2026, 8, 20, 15));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente: este paso está en construcción.'), findsOneWidget);
    expect(find.text('Detalles de la reunión'), findsOneWidget);
  });

  testWidgets('no se puede cambiar de paso deslizando', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
  });
}
```

- [ ] **Paso 2: Correr las pruebas y verificar que fallan**

```bash
flutter test test/features/new_alarm/presentation/new_alarm_flow_test.dart
```

Esperado: FALLA por error de compilación.

- [ ] **Paso 3: Implementar `NewAlarmFlow`**

Crea `lib/features/new_alarm/presentation/new_alarm_flow.dart`. El estado se expone como
`NewAlarmFlowState` público para que las pruebas puedan fijar la fecha sin pasar por el
selector de Material:

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/wizard_bottom_bar.dart';
import '../../../core/widgets/wizard_progress_bar.dart';
import 'new_alarm_view_model.dart';
import 'steps/step_details_screen.dart';
import 'steps/step_type_screen.dart';

/// Asistente de creación de alarmas.
///
/// Es dueño del `NewAlarmViewModel`: el borrador vive mientras el asistente
/// esté abierto y se descarta al cerrarlo.
class NewAlarmFlow extends StatefulWidget {
  const NewAlarmFlow({super.key});

  @override
  NewAlarmFlowState createState() => NewAlarmFlowState();
}

class NewAlarmFlowState extends State<NewAlarmFlow> {
  final NewAlarmViewModel viewModel = NewAlarmViewModel();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _goToCurrentStep() {
    _pageController.animateToPage(
      viewModel.currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Acción izquierda: retrocede o, si ya está en el primer paso, cierra.
  void _onLeading() {
    if (viewModel.back()) {
      _goToCurrentStep();
      return;
    }
    Navigator.of(context).pop();
  }

  /// Acción derecha: avanza o avisa que el siguiente paso no existe todavía.
  void _onTrailing() {
    if (viewModel.next()) {
      _goToCurrentStep();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente: este paso está en construcción.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NewAlarmViewModel>.value(
      value: viewModel,
      child: Consumer<NewAlarmViewModel>(
        builder: (BuildContext context, NewAlarmViewModel vm, _) {
          return PopScope<void>(
            // El retroceso del sistema debe comportarse igual que la acción
            // izquierda: retroceder de paso antes de cerrar el asistente.
            canPop: false,
            onPopInvokedWithResult: (bool didPop, _) {
              if (didPop) {
                return;
              }
              _onLeading();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  tooltip: 'Volver',
                  onPressed: _onLeading,
                ),
                title: const Text('Nueva alarma'),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.sm,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: WizardProgressBar(
                      currentStep: vm.currentStep,
                      totalSteps: NewAlarmViewModel.totalSteps,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // El avance se controla solo con los botones.
                      physics: const NeverScrollableScrollPhysics(),
                      children: const <Widget>[
                        StepTypeScreen(),
                        StepDetailsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: WizardBottomBar(
                leadingLabel: vm.isFirstStep ? 'Cancelar' : 'Atrás',
                onLeading: _onLeading,
                trailingLabel: 'Siguiente',
                onTrailing: vm.canAdvance ? _onTrailing : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Paso 4: Reemplazar el placeholder de la ruta**

En `lib/core/router/app_router.dart`, cambia el caso de `AppRoutes.newAlarm` para que
apunte al asistente. Sustituye el import de `ComingSoonScreen` por el de `NewAlarmFlow`:

```dart
import 'package:flutter/material.dart';

import '../../features/new_alarm/presentation/new_alarm_flow.dart';
import '../../shell/main_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      case AppRoutes.newAlarm:
        return MaterialPageRoute<void>(
          builder: (_) => const NewAlarmFlow(),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}
```

`ComingSoonScreen` sigue usándose en `MainShell` para Mapa y Perfil, así que no se borra.

- [ ] **Paso 5: Correr toda la suite**

```bash
flutter test
flutter analyze
```

Esperado: todas las pruebas en verde y `analyze` limpio. La prueba de la Tarea 9 sobre el
botón flotante sigue pasando, porque comprueba que se salió del shell y no el contenido
de la pantalla destino.

- [ ] **Paso 6: Recorrer el flujo completo en el dispositivo**

```bash
flutter run
```

Recorre: Inicio → botón flotante → seleccionar "Reunión" → Siguiente → llenar los tres
campos (incluido el selector de fecha y hora) → Siguiente → aparece el aviso
"Próximamente" → Atrás → la selección de tipo sigue puesta → gesto de retroceso del
sistema → se cierra el asistente y vuelve a Inicio.

- [ ] **Paso 7: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `feat(new-alarm): conecta el asistente completo y su navegación entre pasos`

---

## Tarea 18: Revisión de accesibilidad · HU-08

Auditoría transversal sobre las tres pantallas ya construidas.

**Archivos:**
- Crear: `test/accessibility/contrast_test.dart`, `test/accessibility/text_scale_test.dart`
- Modificar: los archivos donde la auditoría encuentre defectos

**Interfaces:**
- Consume: todo lo construido en las Tareas 1 a 17
- Produce: ningún widget nuevo; correcciones y dos pruebas de regresión

- [ ] **Paso 1: Escribir la prueba de contraste**

Crea `test/accessibility/contrast_test.dart`. Calcula la razón de contraste según WCAG 2.1
directamente sobre los tokens, así que cualquier cambio futuro de paleta que rompa la
accesibilidad falla en CI:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/theme/app_colors.dart';

/// Razón de contraste WCAG 2.1 entre dos colores opacos.
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double claro = math.max(la, lb);
  final double oscuro = math.min(la, lb);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  group('texto normal sobre su fondo: mínimo 4.5:1', () {
    test('texto principal sobre el fondo de pantalla', () {
      expect(_contrast(AppColors.textPrimary, AppColors.background),
          greaterThanOrEqualTo(4.5));
    });

    test('texto principal sobre superficie', () {
      expect(_contrast(AppColors.textPrimary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre el fondo de pantalla', () {
      expect(_contrast(AppColors.textSecondary, AppColors.background),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre superficie', () {
      expect(_contrast(AppColors.textSecondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre el fondo de los campos y chips', () {
      expect(_contrast(AppColors.textSecondary, AppColors.surfaceMuted),
          greaterThanOrEqualTo(4.5));
    });

    test('hora de salida en rojo sobre superficie', () {
      expect(_contrast(AppColors.primary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto sobre el botón primario', () {
      expect(_contrast(AppColors.onPrimary, AppColors.primary),
          greaterThanOrEqualTo(4.5));
    });

    test('etiqueta del botón secundario sobre superficie', () {
      expect(_contrast(AppColors.secondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });
  });

  group('texto grande: mínimo 3:1', () {
    test('hora de inicio en oliva sobre superficie', () {
      expect(_contrast(AppColors.accentTime, AppColors.surface),
          greaterThanOrEqualTo(3.0));
    });
  });
}
```

- [ ] **Paso 2: Correr la prueba de contraste y corregir los tokens que fallen**

```bash
flutter test test/accessibility/contrast_test.dart
```

Los tokens vienen del Style Tile y ya se verificaron uno por uno, así que **se espera que
las nueve pruebas pasen a la primera**. Si alguna falla es señal de que alguien cambió un
token: revisa ese cambio contra el Style Tile.

Si hay que corregir, corrige **solo el token**, nunca la prueba: bajar el umbral anula el
propósito de la verificación. Y busca el reemplazo dentro de la misma rampa del Style Tile
en vez de inventar un color.

Ten presente el caso del ámbar, ya resuelto en los tokens: `amber500` (`#F0A81E`) y
`amber700` (`#C79417`) dan 2.03:1 y 2.74:1 sobre blanco, y no alcanzan ni el mínimo de 3:1
de texto grande. Por eso `accentTime` es `amber900` (`#8A6D1A`, 4.90:1). No lo "corrijas"
hacia el ámbar brillante del Style Tile: rompe la accesibilidad.

- [ ] **Paso 3: Escribir la prueba de escalado de texto**

Crea `test/accessibility/text_scale_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  for (final double escala in <double>[1.0, 1.3, 1.5]) {
    for (final Size tamano in <Size>[const Size(360, 640), const Size(430, 932)]) {
      testWidgets(
        'Inicio no se desborda con escala $escala en ${tamano.width.toInt()}x${tamano.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await pumpApp(tester, const MainShell(), textScale: escala);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'El asistente no se desborda con escala $escala en ${tamano.width.toInt()}x${tamano.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await pumpApp(tester, const NewAlarmFlow(), textScale: escala);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Reunión'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Siguiente'));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
```

- [ ] **Paso 4: Correr la prueba de escalado y corregir los desbordes**

```bash
flutter test test/accessibility/text_scale_test.dart
```

Los desbordes típicos y su corrección:

- Texto largo en una fila que no cabe → envuélvelo en `Expanded` y ponle `maxLines` con
  `overflow: TextOverflow.ellipsis`.
- Una `Column` que crece más que la pantalla → envuélvela en `SingleChildScrollView`.
- Un `Container` con `height` fijo cuyo texto ya no cabe → sustituye la altura fija por
  `constraints: BoxConstraints(minHeight: ...)`.
- Los dos botones de `WizardBottomBar` que no caben lado a lado → deja que cada `Expanded`
  conserve su mitad y reduce el `padding` horizontal de los botones; no reduzcas el tamaño
  de la letra.

- [ ] **Paso 5: Auditar las áreas tocables**

Recorre los elementos interactivos y confirma que cada uno mide al menos 48×48 dp:

| Elemento | Dónde | Cómo se cumple |
|----------|-------|----------------|
| Pestañas de la barra inferior | `MainShell` | `BottomNavigationBar` ya lo garantiza |
| Botón flotante | `HomeScreen` | `FloatingActionButton.extended` ya lo garantiza |
| Botón de menú y avatar | `HomeScreen` | `IconButton` ya lo garantiza |
| Botón "Reintentar" | `AlarmsErrorState` | `SecondaryButton` usa `AppSizes.buttonHeight` |
| Tarjeta de tipo de alarma | `AlarmTypeCard` | Su alto supera 48 con el relleno del diseño |
| Botón de limpiar campo | `LabeledField` | `IconButton` ya lo garantiza; cubierto por prueba |
| Campo de fecha | `LabeledTapField` | El `InkWell` cubre todo el campo |
| Botones del asistente | `WizardBottomBar` | `AppSizes.buttonHeight` = 48 |

Verifica en el emulador con **Ajustes → Accesibilidad → Tamaño de pantalla y texto**, y
corrige con `padding` cualquier elemento que se quede corto. No uses `Transform.scale`.

- [ ] **Paso 6: Auditar las etiquetas semánticas**

Con TalkBack (Android) o VoiceOver (iOS) activo, recorre las tres pantallas y confirma:

- Cada tarjeta de alarma se anuncia como **un solo** elemento, con hora, título, lugar y
  hora de salida. Lo garantiza el `MergeSemantics` de `AlarmCard`.
- Cada tarjeta de tipo se anuncia como botón e indica si está seleccionada.
- El indicador de progreso anuncia "Paso N de 4".
- La fila de avatares anuncia el total de asistentes.
- Los íconos sin texto tienen etiqueta: menú, avatar del usuario, flecha de volver, botones
  de limpiar, y los íconos de los estados vacío, de error y "Próximamente".

Agrega `semanticLabel` o envuelve en `Semantics` cualquier ícono que se anuncie sin
descripción.

- [ ] **Paso 7: Verificación final completa**

```bash
flutter analyze
flutter test
grep -rnE "Color\(0x|fontSize:" lib/features/ lib/shell/ || echo "OK: sin valores de diseño escritos a mano"
grep -r "package:flutter/" lib/features/*/domain/ || echo "OK: domain sin dependencias de Flutter"
git status --short
```

Esperado: `analyze` limpio, toda la suite en verde, los dos `grep` sin coincidencias, y
`git status` mostrando solo los archivos que tú aún no has commiteado.

- [ ] **Paso 8: ⛔ PUNTO DE COMMIT — lo ejecuta el desarrollador**

Mensaje sugerido:

> `fix(a11y): corrige contraste, escalado de texto y etiquetas semánticas`

---

## Verificación de terminado del proyecto

Antes de dar el trabajo por cerrado, confirma con evidencia cada punto:

- [ ] Las tres pantallas reproducen los mockups aprobados (comparación visual lado a lado)
- [ ] `flutter analyze` no reporta advertencias
- [ ] `flutter test` pasa completo
- [ ] Hay al menos un widget test por pantalla y un unit test por ViewModel
- [ ] Ninguna pantalla tiene colores, tipografías ni espaciados escritos a mano
- [ ] Ningún control de la interfaz produce un error al tocarlo
- [ ] Las pruebas de contraste y de escalado de texto pasan
- [ ] El repositorio no tiene ningún commit hecho por el agente

## Lo que este plan deja fuera a propósito

Documentado para que nadie lo confunda con un olvido:

- Pasos 3 y 4 del asistente: no tienen diseño. El indicador muestra cuatro segmentos y al
  intentar avanzar desde el paso 2 aparece el aviso "Próximamente".
- Pantallas Mapa y Perfil: placeholders navegables.
- Menú lateral: el ícono de hamburguesa está visible y sin acción, como en el mockup.
- Edición de asistentes: la fila de avatares es de solo lectura.
- Cálculo de la hora de salida: `leaveAt` llega precalculado, tal como llegará del backend.
- Persistencia: cerrar el asistente descarta el borrador.
