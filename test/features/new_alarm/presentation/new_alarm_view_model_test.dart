import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';

void main() {
  test('arranca en el primer paso con un borrador vacío', () {
    final vm = NewAlarmViewModel();

    expect(vm.currentStep, 0);
    expect(vm.isFirstStep, isTrue);
    expect(vm.draft.type, isNull);
    expect(NewAlarmViewModel.totalSteps, 4);
  });

  test('no puede avanzar sin haber elegido un tipo', () {
    final vm = NewAlarmViewModel();

    expect(vm.canAdvance, isFalse);
    expect(vm.next(), isFalse);
    expect(vm.currentStep, 0);
  });

  test('al elegir un tipo se habilita el avance y notifica', () {
    final vm = NewAlarmViewModel();
    var notificaciones = 0;
    vm.addListener(() => notificaciones++);

    vm.selectType(AlarmType.meeting);

    expect(vm.draft.type, AlarmType.meeting);
    expect(vm.canAdvance, isTrue);
    expect(notificaciones, 1);
  });

  test('seleccionar otro tipo reemplaza el anterior', () {
    final vm = NewAlarmViewModel()..selectType(AlarmType.meeting);

    vm.selectType(AlarmType.recurringEvent);

    expect(vm.draft.type, AlarmType.recurringEvent);
  });

  test('avanza al paso 2 cuando hay tipo elegido', () {
    final vm = NewAlarmViewModel()..selectType(AlarmType.meeting);

    expect(vm.next(), isTrue);
    expect(vm.currentStep, 1);
    expect(vm.isFirstStep, isFalse);
  });

  test('no avanza más allá del último paso implementado', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');

    expect(vm.next(), isTrue);
    expect(vm.currentStep, 2);

    // El paso de transporte siempre está completo, pero el paso 4 está
    // fuera del alcance: next() informa que no pudo avanzar.
    expect(vm.canAdvance, isTrue);
    expect(vm.next(), isFalse);
    expect(vm.currentStep, 2);
  });

  test('volver desde el paso 3 conserva el medio elegido', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25')
      ..next()
      ..selectTransportMode(TransportMode.bicycle);

    expect(vm.back(), isTrue);
    expect(vm.currentStep, 1);

    expect(vm.next(), isTrue);
    expect(vm.draft.transportMode, TransportMode.bicycle);
  });

  test('retroceder conserva los datos ya escritos', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente');

    expect(vm.back(), isTrue);
    expect(vm.currentStep, 0);
    expect(vm.draft.type, AlarmType.meeting);

    vm.next();
    expect(vm.draft.title, 'Reunión con cliente');
  });

  test('no retrocede desde el primer paso', () {
    final vm = NewAlarmViewModel();

    expect(vm.back(), isFalse);
    expect(vm.currentStep, 0);
  });

  test('el paso de detalles exige título, fecha y lugar', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next();

    expect(vm.canAdvance, isFalse);

    vm.updateTitle('Reunión con cliente');
    expect(vm.canAdvance, isFalse);

    vm.updateWhenAt(DateTime(2026, 8, 20, 15));
    expect(vm.canAdvance, isFalse);

    vm.updateLocation('Avenida El Poblado #1-25');
    expect(vm.canAdvance, isTrue);
  });

  test('limpiar un campo lo vacía sin tocar los demás', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..next()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');

    vm.clearWhenAt();

    expect(vm.draft.whenAt, isNull);
    expect(vm.draft.title, 'Reunión con cliente');
    expect(vm.draft.location, 'Avenida El Poblado #1-25');
    expect(vm.canAdvance, isFalse);
  });

  test('el medio de transporte arranca en carro', () {
    expect(NewAlarmViewModel().draft.transportMode, TransportMode.car);
  });

  test('elegir un medio lo guarda en el borrador y notifica', () {
    final vm = NewAlarmViewModel();
    var notificaciones = 0;
    vm.addListener(() => notificaciones++);

    vm.selectTransportMode(TransportMode.publicTransport);

    expect(vm.draft.transportMode, TransportMode.publicTransport);
    expect(notificaciones, 1);
  });

  test('elegir otro medio reemplaza el anterior', () {
    final vm = NewAlarmViewModel()..selectTransportMode(TransportMode.motorcycle);

    vm.selectTransportMode(TransportMode.walking);

    expect(vm.draft.transportMode, TransportMode.walking);
  });

  test('elegir un medio no borra los datos ya escritos', () {
    final vm = NewAlarmViewModel()
      ..selectType(AlarmType.meeting)
      ..updateTitle('Reunión con cliente');

    vm.selectTransportMode(TransportMode.bicycle);

    expect(vm.draft.type, AlarmType.meeting);
    expect(vm.draft.title, 'Reunión con cliente');
  });
}
