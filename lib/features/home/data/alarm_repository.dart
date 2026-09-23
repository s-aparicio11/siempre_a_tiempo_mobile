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
