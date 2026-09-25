# Alarmas Siempre a Tiempo · App móvil

**Alarmas Siempre a Tiempo** es una aplicación móvil construida con Flutter que ayuda al
usuario a salir a tiempo a sus reuniones. En lugar de sonar a una hora fija, calcula *a qué
hora debe salir* según el tráfico, el clima y el medio de transporte. Este proyecto fue
desarrollado como trabajo académico para el curso de Desarrollo Móvil de la Universidad de
los Andes.

Esta primera versión incluye 6 pantallas con interacción:

1. **Inicio**, con el saludo, el resumen del día y la lista de próximas alarmas.
2. **El flujo de crear una alarma**, compuesto por 5 pantallas: 4 pasos y la confirmación
   de éxito.
   - **Tipo de alarma:** reunión, recordatorio personal o evento recurrente.
   - **Detalles de la reunión:** título, fecha y hora, lugar y asistentes.
   - **¿Cómo te vas a mover?:** carro, transporte público, moto, bicicleta o caminando.
   - **Hora recomendada para salir:** la hora de salida calculada y los factores que se
     tuvieron en cuenta (tráfico, clima y ruta).
   - **Alarma creada:** resumen de la alarma; "Entendido" regresa a Inicio.

Para probarlo: **Inicio → + Nueva alarma → Reunión**, llenar los datos, elegir el medio de
transporte y tocar **Guardar alarma**.

La aplicación no tiene backend: los datos son de ejemplo y viven en memoria, en
repositorios simulados (`MockAlarmRepository` y `MockDepartureEstimateRepository`) que se
reinician al cerrar la app. La hora de salida se calcula restando a la hora de la reunión un
tiempo de viaje fijo por medio de transporte, y la alarma creada no se guarda, así que no
aparece en la lista de Inicio. Las pestañas Mapa y Perfil, y el detalle de cada factor del
paso 4, aparecen como "Próximamente".

## Diseño

Prototipo en Figma: [UX - Siempre a Tiempo](https://www.figma.com/proto/Z8oSiR3n6bGlEfoxApbGiV/UX---Siempre-a-Tiempo?node-id=2373-414&starting-point-node-id=2373%3A414&t=JoRE4R6cKe5YKTxp-1)

## Integrantes

| Nombre | Usuario GitHub | Correo Uniandes |
|--------|----------------|-----------------|
| Pedro Camargo | pcamargoj | p.camargoj@uniandes.edu.co |
| Santiago Aparicio | s-aparicio11 | s.aparicio11@uniandes.edu.co |

## Tecnologías

- Flutter 3.38 o superior, con Dart 3
- `provider` para el estado: un `ChangeNotifier` como ViewModel por funcionalidad
- `intl` y `flutter_localizations` para fechas y horas en español
- `google_fonts` para la tipografía Inter
- `lucide_icons_flutter` para los íconos

El código se organiza por funcionalidad (`lib/features/home` y `lib/features/new_alarm`),
cada una con sus capas `domain`, `data` y `presentation`. Los colores, tipografías y
espaciados salen de `lib/core/theme/`. Cuando exista el backend, basta con reemplazar las
implementaciones simuladas de los repositorios; las pantallas no cambian.

## Requisitos previos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.38 o superior (incluye Dart)
- Para Android: Android Studio con un emulador configurado
- Para iOS (solo macOS): Xcode con un simulador de iPhone y CocoaPods

Para verificar que el entorno está listo:

```bash
flutter doctor
```

## Instalación

Clonar el repositorio:

```bash
git clone https://github.com/s-aparicio11/siempre_a_tiempo_mobile.git
cd siempre_a_tiempo_mobile
```

Instalar las dependencias:

```bash
flutter pub get
```

## Ejecutar el proyecto en local

Abrir un emulador o simulador y ejecutar:

```bash
flutter run
```

Si hay varios dispositivos conectados, se elige uno con `flutter run -d <id>` (los
disponibles se listan con `flutter devices`). Mientras la app corre, `r` aplica los cambios
del código en segundos (*hot reload*), `R` reinicia la app y `q` la cierra.

## Otros comandos disponibles

| Comando | Descripción |
|---------|-------------|
| `flutter run` | Ejecuta la app en el emulador o dispositivo conectado |
| `flutter devices` | Lista los dispositivos disponibles |
| `flutter emulators --launch <id>` | Abre un emulador de Android |
| `flutter analyze` | Revisa el código con las reglas de estilo del proyecto |
| `flutter test` | Ejecuta las pruebas unitarias, de widgets, de accesibilidad y *golden* |
| `flutter test --update-goldens` | Regenera las imágenes de referencia de las pruebas *golden* |
| `flutter build apk` | Compila la app para Android en `build/app/outputs/` |
