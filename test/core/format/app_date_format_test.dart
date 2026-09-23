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
