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
