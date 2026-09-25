abstract final class AppRoutes {
  static const String home = '/';
  static const String newAlarm = '/nueva-alarma';

  /// Confirmación de alarma creada. Recibe un `CreatedAlarmSummary`.
  static const String alarmCreated = '/nueva-alarma/lista';
}
