# Diseño técnico y plan de trabajo — Siempre a Tiempo (front-end móvil)

- **Fecha:** 2026-09-22
- **Alcance:** tres pantallas, front-end Flutter para celular, datos simulados
- **Estado:** aprobado para planificación

---

## 1. Contexto

Siempre a Tiempo es una plataforma de alarmas que calcula la hora de salida del usuario a
partir del tráfico, el clima y otros factores del trayecto, en lugar de sonar a una hora
fija. El usuario registra un compromiso con su hora, su lugar y su medio de transporte; la
plataforma estima el desplazamiento real y genera una alarma de salida que se ajusta sola.

Este documento cubre la construcción del **front-end móvil** de tres pantallas de ese
producto. No hay backend: los datos provienen de repositorios simulados en memoria. Las
pantallas deben verse y comportarse como el producto final.

### 1.1 Alcance

**Dentro del alcance**

| # | Pantalla | Descripción |
|---|----------|-------------|
| P1 | Inicio | Saludo personalizado, resumen del día y lista de próximas alarmas |
| P2 | Nueva alarma · Paso 1 | Selección del tipo de alarma |
| P3 | Nueva alarma · Paso 2 | Captura de los detalles de la reunión |

Transversales: sistema de diseño (tema, tipografía, color, espaciado), shell de navegación
inferior y asistente de creación con indicador de progreso.

**Fuera del alcance** — se resuelven con una pantalla placeholder "Próximamente":

- Pestañas Mapa y Perfil.
- Pasos 3 y 4 del asistente de creación.
- Menú lateral (el ícono de hamburguesa no abre nada por ahora).
- Cualquier integración real: tráfico, clima, mapas, calendario, contactos, autenticación,
  notificaciones y persistencia.

### 1.2 Decisiones tomadas

| Decisión | Elección | Razón |
|----------|----------|-------|
| Manejo de estado | `provider` + `ChangeNotifier` | Estándar documentado por Flutter, suficiente para tres pantallas, fácil de sustentar |
| Acceso a datos | Repository con implementación mock | Permite cambiar a backend real sin tocar las pantallas |
| Controles fuera de alcance | Placeholder "Próximamente" | El prototipo se siente completo en una demo y nada se rompe |
| Origen de los tokens de diseño | Archivo de Figma del proyecto | Fidelidad exacta de color, tipografía y medidas |
| Formato de las historias | Académico con criterios Gherkin | Entregable de maestría, trazable y verificable |

---

## 2. Arquitectura

### 2.1 Estructura de carpetas

```
lib/
├── main.dart                          # runApp
├── app.dart                           # MaterialApp, tema y rutas
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # tokens de color
│   │   ├── app_typography.dart        # escala tipográfica
│   │   ├── app_spacing.dart           # espaciados y radios
│   │   └── app_theme.dart             # ThemeData ensamblado
│   ├── router/
│   │   ├── app_router.dart            # onGenerateRoute
│   │   └── app_routes.dart            # constantes de ruta
│   └── widgets/
│       ├── primary_button.dart        # botón relleno (rojo)
│       ├── secondary_button.dart      # botón con borde (azul)
│       ├── wizard_progress_bar.dart   # indicador de 4 segmentos
│       ├── wizard_bottom_bar.dart     # barra fija de dos acciones
│       └── coming_soon_screen.dart    # placeholder reutilizable
├── shell/
│   └── main_shell.dart                # Scaffold + BottomNavigationBar
└── features/
    ├── home/
    │   ├── domain/
    │   │   ├── alarm.dart
    │   │   └── transport_mode.dart
    │   ├── data/
    │   │   ├── alarm_repository.dart
    │   │   └── mock_alarm_repository.dart
    │   └── presentation/
    │       ├── home_screen.dart
    │       ├── home_view_model.dart
    │       └── widgets/
    │           ├── greeting_header.dart
    │           ├── alarm_card.dart
    │           ├── transport_chip.dart
    │           ├── alarms_skeleton.dart
    │           ├── alarms_empty_state.dart
    │           └── alarms_error_state.dart
    └── new_alarm/
        ├── domain/
        │   ├── alarm_type.dart
        │   ├── alarm_draft.dart
        │   └── attendee.dart
        └── presentation/
            ├── new_alarm_flow.dart
            ├── new_alarm_view_model.dart
            ├── steps/
            │   ├── step_type_screen.dart
            │   └── step_details_screen.dart
            └── widgets/
                ├── alarm_type_card.dart
                ├── labeled_field.dart
                └── attendee_avatars.dart
```

Regla de ubicación: un widget vive dentro de su feature hasta que lo consuman dos o más
features; solo entonces sube a `core/widgets/`.

### 2.2 Modelo de dominio

```dart
enum TransportMode { car, walking }

class Alarm {
  final String id;
  final String title;        // "Reunión con cliente"
  final String location;     // "Oficina zona norte"
  final DateTime startsAt;   // 8:30 AM
  final DateTime leaveAt;    // 8:05 AM — calculado por el backend
  final TransportMode transportMode;
}

enum AlarmType { meeting, personalReminder, recurringEvent }

class AlarmDraft {
  final AlarmType? type;
  final String title;
  final DateTime? whenAt;
  final String location;
  final List<Attendee> attendees;

  bool get isTypeStepValid    => type != null;
  bool get isDetailsStepValid => title.isNotEmpty && whenAt != null && location.isNotEmpty;

  AlarmDraft copyWith({
    AlarmType? type,
    String? title,
    DateTime? whenAt,
    String? location,
    List<Attendee>? attendees,
  });
}

class Attendee {
  final String id;
  final String initials;
  final int avatarColorIndex;   // índice, no Color: domain/ no importa Flutter
}
```

`Attendee` guarda un **índice** de color, no un `Color`. La traducción del índice al color
concreto ocurre en `AttendeeAvatars`, que lee la paleta de avatares desde `core/theme/`.
Así el dominio se mantiene libre de dependencias de Flutter.

`leaveAt` llega ya calculado en el modelo. La app **no** calcula la hora de salida: esa
lógica pertenece al backend. Hoy el mock la entrega como un valor fijo.

### 2.3 Flujo de datos

```
MockAlarmRepository ──> HomeViewModel ──(notifyListeners)──> HomeScreen
                        (loading/loaded/empty/error)

Interacción usuario ──> NewAlarmViewModel ──> StepTypeScreen / StepDetailsScreen
                        (AlarmDraft + currentStep)
```

- **`HomeViewModel`** llama a `AlarmRepository.getTodayAlarms()` y expone un estado
  explícito: `loading`, `loaded(List<Alarm>)`, `empty`, `error`. Cada estado tiene su
  widget dedicado.
- **`NewAlarmViewModel`** mantiene el `AlarmDraft` y el `currentStep` (0..3). Expone
  `canAdvance`, `next()`, `back()` y `cancel()`. No persiste nada: al intentar avanzar
  desde el paso 2 muestra un `SnackBar` "Próximamente".

Cada ViewModel se provee con un `ChangeNotifierProvider` en la raíz de su feature, no en
la raíz de la app. No hay estado global.

### 2.4 Navegación

| Ruta | Pantalla |
|------|----------|
| `/` | `MainShell` (tabs Inicio, Mapa, Perfil) |
| `/nueva-alarma` | `NewAlarmFlow`, ruta a pantalla completa sobre el shell |

`MainShell` usa `IndexedStack` para que cada tab conserve su estado al cambiar. Mapa y
Perfil renderizan `ComingSoonScreen`.

`NewAlarmFlow` es el contenedor del asistente: sostiene el `NewAlarmViewModel`, dibuja el
`AppBar`, la `WizardProgressBar` y la `WizardBottomBar`, y cambia el contenido con un
`PageView` sin gesto de deslizamiento —el avance se controla solo con los botones—. Así el
indicador de progreso y los botones leen un único estado.

---

## 3. Sistema de diseño

### 3.1 Origen

Los tokens salen del **Style Tile del proyecto en Figma**:
<https://www.figma.com/design/Z8oSiR3n6bGlEfoxApbGiV/UX---Siempre-a-Tiempo>
(página "Style Tiles").

El Style Tile es un documento **visual**: la paleta y la jerarquía tipográfica están
escritas como texto y rellenos, no como Figma Variables. Las únicas Variables del archivo
pertenecen al kit de Material 3 que arrastran los componentes importados y no forman parte
del sistema de diseño de Siempre a Tiempo.

Consecuencia práctica: la extracción de tokens es **manual y puntual**. Si el Style Tile
cambia, hay que volver a extraer. Convertir la paleta en Figma Variables permitiría
sincronizar de forma automática, y queda como mejora opcional.

### 3.2 Rampas de color

| Rampa | Función | Valores |
|-------|---------|---------|
| Azul | información / confianza | `#1A3A6B` `#2456A0` `#2E6BE6` `#6B9BF0` `#B8D0F7` `#E8F0FE` |
| Rojo | acción "salir ahora" | `#8A2A22` `#C0392B` `#E8503A` `#F08370` `#F7B8AD` `#FCE9E4` |
| Ámbar | destacados / horas | `#8A6D1A` `#C79417` `#F0A81E` `#F5C55A` `#FADE9A` `#FCEFD0` |
| Verde | confirmación | `#1E6B42` `#2E8B57` `#7BC59A` `#E9F7EF` |
| Neutros | — | `#1B2A4A` `#5A6472` `#B0B8C4` `#D5DCE6` `#F2F5FA` `#FFFFFF` |

### 3.3 Alias semánticos

Las pantallas consumen estos alias, nunca las rampas directamente.

| Token | Valor | Uso |
|-------|-------|-----|
| `primary` | `#C0392B` | Botón principal, botón flotante, pestaña activa, hora de salida |
| `primaryPressed` | `#8A2A22` | Botón principal presionado |
| `onPrimary` | `#FFFFFF` | Texto sobre rojo |
| `secondary` | `#2456A0` | Botón con borde, foco de campo, enlaces |
| `secondaryMuted` | `#E8F0FE` | Fondo del botón secundario presionado |
| `textPrimary` | `#1B2A4A` | Títulos y encabezados |
| `textSecondary` | `#5A6472` | Subtítulos, ubicaciones, descripciones |
| `accentTime` | `#8A6D1A` | Hora de inicio de una alarma |
| `success` | `#2E8B57` | Interruptor activo, chip de confirmación |
| `onSuccessSurface` | `#1E6B42` | Texto sobre fondos de confirmación |
| `error` | `#C0392B` | Error de validación en un campo |
| `background` | `#F2F5FA` | Fondo de pantalla |
| `surface` | `#FFFFFF` | Tarjetas y barras |
| `surfaceMuted` | `#F2F5FA` | Relleno de campos y chips neutros |
| `border` | `#D5DCE6` | Bordes y divisores |
| `progressInactive` | `#D5DCE6` | Segmentos pendientes del indicador |

**Decisión sobre el ámbar.** El Style Tile usa el ámbar brillante (`#F0A81E`) en el Display
de 48 pt. Sobre blanco ese tono da 2.03:1 de contraste y `#C79417` da 2.74:1: ninguno
alcanza el mínimo de 3:1 que WCAG exige incluso para texto grande. Para **texto** se usa
`#8A6D1A` (4.90:1), que pertenece a la misma rampa del Style Tile. Los ámbares claros
quedan para rellenos, chips y decoración, donde el requisito de contraste no aplica.

Verificación de los demás pares, calculada sobre los valores reales:

| Par | Contraste | Mínimo |
|-----|-----------|--------|
| `textPrimary` sobre `background` | 13.01:1 | 4.5 |
| `textPrimary` sobre `surface` | 14.22:1 | 4.5 |
| `textSecondary` sobre `background` | 5.49:1 | 4.5 |
| `textSecondary` sobre `surface` | 6.00:1 | 4.5 |
| `primary` sobre `surface` | 5.44:1 | 4.5 |
| `onPrimary` sobre `primary` | 5.44:1 | 4.5 |
| `secondary` sobre `surface` | 7.21:1 | 4.5 |
| `accentTime` sobre `surface` | 4.90:1 | 3.0 |
| `onSuccessSurface` sobre verde claro | 5.87:1 | 4.5 |

### 3.4 Tipografía

Familia **Inter**, en los pesos Regular, Medium, SemiBold y Bold. El Style Tile define seis
niveles; la última columna indica el token que los representa en código.

| Nivel del Style Tile | Tamaño / peso | Color | Token |
|----------------------|---------------|-------|-------|
| Display | 48 / Bold | ámbar | `display` |
| Título 1 | 28 / Bold | `textPrimary` | `displayGreeting`, `headlineQuestion` |
| Título 2 | 20 / SemiBold | `accentTime` | `titleTime` |
| Subtítulo | 17 / SemiBold | `textPrimary` | `titleCard` |
| Destacado | 16 / Bold | `primary` | `bodyEmphasis` |
| Etiqueta | 13 / Regular | `textSecondary` | `bodyDefault`, `labelField` |

Dos estilos **derivados**, que no están en la jerarquía del Style Tile y se documentan como
tales: `labelSection` (13 SemiBold en versalitas con `letterSpacing` 0.8, para "PRÓXIMAS
ALARMAS") y `labelButton` (16 SemiBold, para el texto de los botones).

### 3.5 Iconografía

Estilo **outline, trazo 2 px, esquinas suaves**, familia Lucide / Feather. Se usa el
paquete `lucide_icons`; los iconos de Material no reproducen ese trazo.

### 3.6 Espaciado, forma y dimensiones

El Style Tile no declara una escala de espaciado, así que la escala es una convención del
proyecto: base 8 — `xs 4 · sm 8 · md 16 · lg 24 · xl 32`, con margen horizontal de pantalla
de 20 y relleno de tarjeta de 16.

Radios: tarjeta 12 · campo 10 · chip 16 · botón y botón flotante en forma de píldora.

Dimensiones medidas sobre los componentes del Style Tile:

| Componente | Alto |
|------------|------|
| Botón (primario, secundario, terciario) | 48 |
| Campo de texto | 56 |
| Chip de estado | 25 |
| Segmento del indicador de progreso | 6 |
| Área tocable mínima | 48 |

### 3.7 Estados definidos en el Style Tile

El Style Tile documenta estados que los mockups de pantalla no mostraban y que el código
debe soportar: botón primario **presionado** y **deshabilitado**; botón secundario
presionado; campo de texto **enfocado** y **con error**; ítem de lista **seleccionado**
(borde rojo, fondo `#FCE9E4`, marca de verificación); e interruptor activo en verde.

De estos, el alcance actual usa: botón deshabilitado (HU-05, HU-06), campo enfocado
(HU-06) y tarjeta de tipo seleccionada (HU-05). Los demás quedan disponibles en el tema
para cuando se construyan los pasos 3 y 4.

---

## 4. Componentes por pantalla

### P1 · Inicio

| Componente | Descripción |
|------------|-------------|
| `AppBar` | Ícono de menú (sin acción), título "Siempre a Tiempo", avatar circular |
| `GreetingHeader` | "¡Hola, {nombre}!" + "Tienes {n} alarmas para hoy" |
| `labelSection` | "PRÓXIMAS ALARMAS" |
| `AlarmCard` | Hora de inicio, título, ubicación, divisor, hora de salida en rojo y `TransportChip` |
| `TransportChip` | Ícono + etiqueta del medio de transporte |
| `FloatingActionButton.extended` | "+ Nueva alarma", abre `/nueva-alarma` |
| `BottomNavigationBar` | Inicio / Mapa / Perfil |
| Estados | `AlarmsSkeleton`, `AlarmsEmptyState`, `AlarmsErrorState` |

### P2 · Nueva alarma · Paso 1

| Componente | Descripción |
|------------|-------------|
| `AppBar` | Flecha atrás + "Nueva alarma" |
| `WizardProgressBar` | 4 segmentos, 1 activo |
| `headlineQuestion` | "¿Qué tipo de alarma quieres crear?" |
| `AlarmTypeCard` ×3 | Ícono en recuadro, título, descripción, chevron; estado seleccionado |
| `WizardBottomBar` | "Cancelar" (borde) + "Siguiente" (relleno) |

### P3 · Nueva alarma · Paso 2

| Componente | Descripción |
|------------|-------------|
| `WizardProgressBar` | 4 segmentos, 2 activos |
| `headlineQuestion` | "Detalles de la reunión" |
| `LabeledField` | Etiqueta flotante, valor, botón de limpiar; variantes enfocado y relleno |
| Campos | "Título de la reunión", "¿Cuándo es?", "¿Dónde es?" |
| `AttendeeAvatars` | Fila de avatares de color + contador "+n" |
| `WizardBottomBar` | "Atrás" (borde) + "Siguiente" (relleno) |

---

## 5. Historias de usuario

Estimación en puntos de historia con escala de Fibonacci (1, 2, 3, 5, 8).

### E-00 · Configuración del proyecto y sistema de diseño — 5 puntos

> **Como** desarrollador del equipo,
> **quiero** un proyecto Flutter configurado con el sistema de diseño centralizado,
> **para** construir las pantallas sin repetir valores visuales ni improvisar estructura.

**Criterios de aceptación**

- **Dado** un entorno con Flutter instalado, **cuando** ejecuto `flutter run`, **entonces**
  la aplicación compila y abre sin errores en un emulador de celular.
- **Dado** el proyecto creado, **cuando** reviso `lib/`, **entonces** existe la estructura
  `core/`, `shell/` y `features/` descrita en la sección 2.1.
- **Dado** el archivo de Figma del proyecto, **cuando** comparo los tokens de
  `core/theme/`, **entonces** los colores, tipografías y espaciados coinciden con las
  variables del archivo.
- **Dado** cualquier archivo dentro de `features/`, **cuando** lo reviso, **entonces** no
  contiene colores ni tamaños escritos a mano.
- **Dado** el proyecto, **cuando** ejecuto `flutter analyze`, **entonces** no se reporta
  ninguna advertencia.

**Actividades**

1. Instalar el SDK de Flutter y verificar con `flutter doctor` (hoy no está instalado).
2. Crear el proyecto con `flutter create` y limpiar el contador de ejemplo.
3. Agregar dependencias: `provider`, `intl`. Dev: `flutter_test`, `flutter_lints`.
4. Configurar `analysis_options.yaml` con `flutter_lints`.
5. Extraer variables y medidas del archivo de Figma.
6. Escribir `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`.
7. Ensamblar `app_theme.dart` y conectarlo en `app.dart`.
8. Definir `app_routes.dart` y `app_router.dart`.
9. Crear el andamiaje de carpetas de `features/`.
10. Configurar la localización a español y `intl` para fechas y horas.

**Terminado cuando:** el proyecto compila, `flutter analyze` está limpio y el tema se
aplica desde un único punto.

---

### HU-01 · Ver mis alarmas del día al abrir la app — 5 puntos

> **Como** usuario de Siempre a Tiempo,
> **quiero** ver mis alarmas de hoy apenas abro la aplicación,
> **para** saber de un vistazo qué compromisos tengo y no revisar mi calendario.

**Criterios de aceptación**

- **Dado** que abro la aplicación, **cuando** carga la pantalla de Inicio, **entonces** veo
  el saludo "¡Hola, {nombre}!" y el conteo "Tienes {n} alarmas para hoy".
- **Dado** que tengo alarmas registradas, **cuando** se muestra la lista, **entonces**
  aparecen bajo el encabezado "PRÓXIMAS ALARMAS" ordenadas por hora de inicio ascendente.
- **Dado** que los datos se están cargando, **cuando** la petición aún no responde,
  **entonces** veo un esqueleto de carga en lugar de una pantalla en blanco.
- **Dado** que no tengo alarmas para hoy, **cuando** carga la pantalla, **entonces** veo el
  mensaje "No tienes alarmas para hoy" y el conteo dice "0 alarmas".
- **Dado** que la carga falla, **cuando** se produce el error, **entonces** veo un mensaje
  de error con un botón "Reintentar" que vuelve a solicitar los datos.
- **Dado** que la lista es más larga que la pantalla, **cuando** desplazo, **entonces** el
  contenido se desplaza sin que la barra inferior ni el botón flotante se muevan.

**Actividades**

1. Definir `Alarm` y `TransportMode` en `home/domain/`.
2. Definir la interfaz `AlarmRepository`.
3. Implementar `MockAlarmRepository` con las tres alarmas del mockup y un retardo simulado.
4. Implementar `HomeViewModel` con los estados `loading`, `loaded`, `empty` y `error`.
5. Maquetar `HomeScreen` con `CustomScrollView` y márgenes del sistema de diseño.
6. Construir `GreetingHeader`.
7. Construir `AlarmsSkeleton`, `AlarmsEmptyState` y `AlarmsErrorState`.
8. Conectar el `ChangeNotifierProvider` y renderizar cada estado.
9. Unit tests del ViewModel para los cuatro estados.
10. Widget test: la pantalla muestra el saludo y tres tarjetas con datos mock.

**Terminado cuando:** los cuatro estados se ven correctamente y sus pruebas pasan.

---

### HU-02 · Saber a qué hora debo salir y en qué medio — 3 puntos

> **Como** usuario con una reunión agendada,
> **quiero** que cada alarma me diga a qué hora salir y en qué medio de transporte,
> **para** salir con el tiempo justo sin calcularlo yo mismo.

**Criterios de aceptación**

- **Dado** que veo una alarma, **cuando** observo la tarjeta, **entonces** muestra la hora
  de inicio, el título del compromiso y su ubicación.
- **Dado** que veo una alarma, **cuando** observo la parte inferior de la tarjeta,
  **entonces** leo "Debes salir {hora}" resaltado en el color de alerta, separado del
  resto por un divisor.
- **Dado** que la alarma tiene un medio de transporte, **cuando** observo la tarjeta,
  **entonces** veo un chip con el ícono y el nombre del medio ("Carro" o "Caminando").
- **Dado** el formato de hora, **cuando** se muestra cualquier hora, **entonces** aparece
  en formato de 12 horas con indicador AM/PM.
- **Dado** que el título o la ubicación son muy largos, **cuando** se renderiza la tarjeta,
  **entonces** el texto se trunca con puntos suspensivos en una sola línea y el diseño no
  se desborda.

**Actividades**

1. Construir `AlarmCard` con su jerarquía visual y su divisor.
2. Construir `TransportChip` con ícono y etiqueta por cada `TransportMode`.
3. Crear un formateador de horas con `intl` en formato de 12 horas y locale español.
4. Aplicar truncado a título y ubicación.
5. Widget test de `AlarmCard` con ambos medios de transporte.
6. Widget test de desbordamiento con textos largos.
7. Golden test de `AlarmCard`.

**Terminado cuando:** la tarjeta reproduce el mockup y resiste textos largos.

---

### HU-03 · Navegar entre las secciones de la app — 2 puntos

> **Como** usuario,
> **quiero** moverme entre Inicio, Mapa y Perfil desde la barra inferior,
> **para** entender cómo está organizada la aplicación.

**Criterios de aceptación**

- **Dado** que abro la aplicación, **cuando** aparece la pantalla inicial, **entonces** la
  barra inferior muestra Inicio, Mapa y Perfil, con Inicio resaltado en el color primario.
- **Dado** que toco una pestaña, **cuando** cambia la sección, **entonces** solo esa
  pestaña queda resaltada y el contenido corresponde a la sección elegida.
- **Dado** que Mapa y Perfil están fuera del alcance, **cuando** entro a cualquiera de
  ellas, **entonces** veo una pantalla "Próximamente" con el nombre de la sección.
- **Dado** que salgo de Inicio y regreso, **cuando** vuelvo a la pestaña, **entonces** la
  posición de desplazamiento de la lista se conserva.

**Actividades**

1. Implementar `MainShell` con `IndexedStack` y `BottomNavigationBar`.
2. Construir `ComingSoonScreen` parametrizada con el nombre de la sección.
3. Aplicar los colores de pestaña activa e inactiva desde el tema.
4. Registrar `/` en el router apuntando al shell.
5. Widget test: al tocar "Mapa" se muestra el placeholder correspondiente.
6. Widget test: el desplazamiento de Inicio se conserva al volver.

**Terminado cuando:** las tres pestañas responden y conservan su estado.

---

### HU-04 · Iniciar la creación de una alarma — 1 punto

> **Como** usuario,
> **quiero** un acceso siempre visible para crear una alarma nueva,
> **para** registrar un compromiso sin buscar dónde hacerlo.

**Criterios de aceptación**

- **Dado** que estoy en Inicio, **cuando** miro la pantalla, **entonces** veo un botón
  flotante "+ Nueva alarma" en la esquina inferior derecha, sobre la lista.
- **Dado** que desplazo la lista, **cuando** el contenido se mueve, **entonces** el botón
  permanece fijo en su posición.
- **Dado** que toco el botón, **cuando** se abre la siguiente pantalla, **entonces** llego
  al paso 1 del asistente de creación a pantalla completa.
- **Dado** que estoy en el asistente, **cuando** toco la flecha de retroceso, **entonces**
  regreso a Inicio.

**Actividades**

1. Agregar el `FloatingActionButton.extended` a `HomeScreen`.
2. Registrar la ruta `/nueva-alarma` en el router.
3. Conectar el botón a la navegación.
4. Widget test: tocar el botón lleva al paso 1.

**Terminado cuando:** el botón navega al asistente y el retroceso funciona.

---

### HU-05 · Elegir el tipo de alarma que quiero crear — 3 puntos

> **Como** usuario que va a crear una alarma,
> **quiero** elegir primero qué tipo de alarma necesito,
> **para** que el asistente me pida solo los datos que corresponden.

**Criterios de aceptación**

- **Dado** que entro al asistente, **cuando** carga el paso 1, **entonces** veo la pregunta
  "¿Qué tipo de alarma quieres crear?" y las tres opciones: Reunión, Recordatorio personal
  y Evento recurrente, cada una con su ícono y su descripción.
- **Dado** que no he elegido un tipo, **cuando** miro la barra inferior, **entonces**
  "Siguiente" está deshabilitado.
- **Dado** que toco una opción, **cuando** queda seleccionada, **entonces** esa tarjeta
  muestra el estado seleccionado, ninguna otra lo hace, y "Siguiente" se habilita.
- **Dado** que seleccioné un tipo, **cuando** toco "Siguiente", **entonces** avanzo al paso
  2 y el indicador de progreso muestra dos segmentos activos.
- **Dado** que toco "Cancelar", **cuando** se cierra el asistente, **entonces** vuelvo a
  Inicio y el borrador se descarta.

**Actividades**

1. Definir `AlarmType`, `AlarmDraft` y `Attendee` en `new_alarm/domain/`.
2. Implementar `NewAlarmViewModel` con `currentStep`, `draft`, `canAdvance`, `next()`,
   `back()` y `cancel()`.
3. Construir `NewAlarmFlow` con `AppBar`, `WizardProgressBar` y `PageView` sin deslizamiento.
4. Construir `AlarmTypeCard` con estado normal y seleccionado.
5. Maquetar `StepTypeScreen` con las tres opciones.
6. Construir `WizardBottomBar` con soporte para acción deshabilitada.
7. Unit test del ViewModel: selección, validación y avance.
8. Widget test: seleccionar habilita "Siguiente" y avanza al paso 2.
9. Golden test de `AlarmTypeCard` en ambos estados.

**Terminado cuando:** la selección es excluyente, la validación bloquea el avance y las
pruebas pasan.

---

### HU-06 · Registrar los detalles de la reunión — 5 puntos

> **Como** usuario creando una alarma de reunión,
> **quiero** registrar el título, la fecha y hora, el lugar y los asistentes,
> **para** que la plataforma pueda calcular cuándo debo salir.

**Criterios de aceptación**

- **Dado** que llego al paso 2, **cuando** carga la pantalla, **entonces** veo el título
  "Detalles de la reunión" y los campos "Título de la reunión", "¿Cuándo es?" y
  "¿Dónde es?".
- **Dado** un campo con valor, **cuando** lo observo, **entonces** muestra su etiqueta
  flotante arriba, el valor debajo y un botón para limpiarlo.
- **Dado** que toco el botón de limpiar de un campo, **cuando** se ejecuta la acción,
  **entonces** ese campo queda vacío y los demás no cambian.
- **Dado** que enfoco un campo, **cuando** recibe el foco, **entonces** su borde toma el
  color secundario y su fondo cambia al estado enfocado.
- **Dado** el campo "¿Cuándo es?", **cuando** lo toco, **entonces** se abre un selector de
  fecha y hora, y el valor elegido se muestra en formato "20 de agosto de 2026, 3:00 PM".
- **Dado** el bloque "¿Quién más asistirá?", **cuando** lo observo, **entonces** veo los
  avatares de colores de los asistentes y un contador "+n" cuando hay más de los que caben.
- **Dado** que algún campo obligatorio está vacío, **cuando** miro la barra inferior,
  **entonces** "Siguiente" está deshabilitado.
- **Dado** que todos los campos están completos, **cuando** toco "Siguiente", **entonces**
  aparece un mensaje "Próximamente" y permanezco en el paso 2.
- **Dado** que toco "Atrás", **cuando** regreso al paso 1, **entonces** el tipo que había
  elegido sigue seleccionado y los datos ya escritos se conservan al volver a avanzar.
- **Dado** que abro el teclado, **cuando** escribo en un campo, **entonces** el contenido se
  desplaza y ningún campo queda oculto tras el teclado.

**Actividades**

1. Construir `LabeledField` con etiqueta flotante, botón de limpiar y estados normal,
   enfocado y con error.
2. Maquetar `StepDetailsScreen` con los tres campos y el bloque de asistentes.
3. Extender `AlarmDraft` y el ViewModel con los campos y su validación.
4. Integrar `showDatePicker` y `showTimePicker` en español.
5. Formatear la fecha con `intl` en el formato del mockup.
6. Definir la paleta de colores de avatar en `core/theme/app_colors.dart`.
7. Construir `AttendeeAvatars`: resuelve el índice de color de cada `Attendee` contra esa
   paleta y dibuja la fila con el contador de excedentes.
8. Manejar el teclado con `SingleChildScrollView` y `resizeToAvoidBottomInset`.
9. Mostrar el `SnackBar` "Próximamente" al intentar avanzar.
10. Conservar el borrador al navegar entre pasos.
11. Unit tests de validación del borrador.
12. Widget tests: limpiar un campo, seleccionar fecha, habilitar "Siguiente".

**Terminado cuando:** los campos funcionan, la validación es correcta y el borrador
sobrevive a la navegación entre pasos.

---

### HU-07 · Ver mi avance y moverme entre pasos — 2 puntos

> **Como** usuario dentro del asistente,
> **quiero** ver en qué paso voy y poder retroceder,
> **para** entender cuánto falta y corregir sin empezar de nuevo.

**Criterios de aceptación**

- **Dado** que estoy en el asistente, **cuando** miro bajo la barra superior, **entonces**
  veo un indicador de cuatro segmentos.
- **Dado** que estoy en el paso {n}, **cuando** observo el indicador, **entonces** los
  primeros {n} segmentos están en el color primario y el resto en el color inactivo.
- **Dado** que cambio de paso, **cuando** avanza la transición, **entonces** el contenido se
  desliza y el indicador se actualiza de forma animada.
- **Dado** que estoy en el paso 1, **cuando** miro la barra inferior, **entonces** la acción
  izquierda dice "Cancelar"; **dado** que estoy en un paso posterior, **entonces** dice
  "Atrás".
- **Dado** que estoy en cualquier paso, **cuando** uso el gesto o el botón de retroceso del
  sistema, **entonces** el comportamiento es el mismo que el de la acción izquierda.
- **Dado** el asistente, **cuando** intento deslizar el contenido lateralmente, **entonces**
  no cambia de paso: el avance se controla solo con los botones.

**Actividades**

1. Construir `WizardProgressBar` con animación entre estados.
2. Parametrizar `WizardBottomBar` para la etiqueta variable de la acción izquierda.
3. Conectar `PopScope` al retroceso del sistema.
4. Deshabilitar el gesto de deslizamiento del `PageView`.
5. Widget test: el indicador refleja el paso actual.
6. Widget test: el retroceso del sistema se comporta como la acción izquierda.

**Terminado cuando:** el indicador y los botones responden a un solo estado y el retroceso
del sistema es coherente.

---

### HU-08 · Percibir una app accesible y consistente — 3 puntos

> **Como** usuario, incluido quien usa lector de pantalla o tamaño de letra grande,
> **quiero** que la aplicación sea legible y operable,
> **para** poder usarla sin barreras.

**Criterios de aceptación**

- **Dado** cualquier texto de la aplicación, **cuando** se mide su contraste contra el
  fondo, **entonces** cumple una razón mínima de 4.5:1 (3:1 para texto grande).
- **Dado** cualquier elemento tocable, **cuando** se mide su área, **entonces** es de al
  menos 48×48 dp.
- **Dado** un lector de pantalla activo, **cuando** recorro una tarjeta de alarma,
  **entonces** se anuncia como un solo elemento con su hora, título, lugar y hora de salida.
- **Dado** que aumento el tamaño de letra del sistema hasta 1.5×, **cuando** reviso las tres
  pantallas, **entonces** ningún texto se desborda ni queda cortado.
- **Dado** un ícono sin texto visible, **cuando** lo alcanza el lector, **entonces** tiene
  una etiqueta semántica descriptiva.
- **Dado** cualquiera de las tres pantallas, **cuando** la abro en un celular pequeño
  (360×640) y en uno grande (430×932), **entonces** el diseño se adapta sin desbordes.

**Actividades**

1. Verificar el contraste de todos los pares de color del tema.
2. Auditar las áreas táctiles y ajustar rellenos donde falte.
3. Envolver `AlarmCard` y `AlarmTypeCard` en `Semantics` con `mergeSemantics`.
4. Agregar etiquetas semánticas a íconos sin texto.
5. Probar las tres pantallas con `textScaleFactor` en 1.0, 1.3 y 1.5 y corregir desbordes.
6. Verificar en dos tamaños de dispositivo.
7. Widget tests con escala de texto aumentada.

**Terminado cuando:** las tres pantallas pasan la revisión de contraste, área táctil,
escalado de texto y semántica.

---

## 6. Plan de trabajo por fases

| Fase | Contenido | Puntos | Entregable verificable |
|------|-----------|--------|------------------------|
| 1 | E-00 | 5 | Proyecto que compila con el tema aplicado desde `core/theme/` |
| 2 | HU-03, HU-04 | 3 | Shell navegable con las tres pestañas y ruta al asistente |
| 3 | HU-01, HU-02 | 8 | Pantalla de Inicio completa con sus cuatro estados |
| 4 | HU-07, HU-05 | 5 | Asistente con indicador de progreso y paso 1 funcional |
| 5 | HU-06 | 5 | Paso 2 con captura y validación de datos |
| 6 | HU-08 | 3 | Revisión de accesibilidad y consistencia sobre las tres pantallas |
| | **Total** | **29** | |

El orden pone primero el andamiaje (tema y navegación) para que las pantallas se construyan
sobre una base estable, y deja la accesibilidad como una revisión transversal al final,
cuando ya existe todo lo que hay que auditar.

---

## 7. Riesgos y supuestos

| Riesgo o supuesto | Impacto | Manejo |
|-------------------|---------|--------|
| Flutter no está instalado en el entorno actual | Bloquea la fase 1 completa | Primera actividad de E-00: instalar el SDK y validar con `flutter doctor` |
| El Style Tile no usa Figma Variables | Cada cambio de diseño obliga a re-extraer los tokens a mano | Aceptado. Convertir la paleta en Variables de Figma queda como mejora opcional |
| `google_fonts` descarga Inter en tiempo de ejecución | Arranque sin red roto y *golden tests* con otra tipografía | Empaquetar los cuatro `.ttf` en `google_fonts/` y desactivar la descarga en pruebas |
| Los nombres de `lucide_icons` pueden variar entre versiones | Un icono no compila | Si un nombre no resuelve, buscarlo en el listado del paquete; no sustituir por Material sin anotarlo |
| El ámbar del Style Tile no cumple contraste sobre blanco | Texto ilegible para baja visión | Resuelto: `accentTime` usa `amber900` de la misma rampa. La prueba de contraste lo protege |
| Los pasos 3 y 4 del asistente no tienen diseño | El flujo queda incompleto | Aceptado: fuera de alcance, se resuelve con "Próximamente" |
| El cálculo de la hora de salida no existe | La app no demuestra la propuesta de valor real | Aceptado: `leaveAt` llega precalculado en el mock, tal como llegará del backend |
| El selector de asistentes no tiene diseño de edición | El bloque es solo de lectura | Aceptado: se muestran los avatares sin permitir agregar ni quitar |

---

## 8. Definición de terminado del proyecto

1. Las tres pantallas reproducen los mockups aprobados.
2. `flutter analyze` no reporta advertencias.
3. `flutter test` pasa en su totalidad.
4. Existe al menos un widget test por pantalla y un unit test por ViewModel.
5. Ninguna pantalla contiene valores de color, tipografía o espaciado escritos a mano.
6. Ningún control de la interfaz produce un error al tocarlo: todo lo fuera de alcance
   responde con un placeholder.
7. Las tres pantallas pasan la revisión de accesibilidad de HU-08.
8. El repositorio no tiene commits hechos por el agente.
