import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
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
