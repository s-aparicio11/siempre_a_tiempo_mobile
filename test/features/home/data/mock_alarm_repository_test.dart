import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';

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
