import '../../../core/domain/transport_mode.dart';
import '../domain/alarm.dart';
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
