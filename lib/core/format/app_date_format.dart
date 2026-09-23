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
