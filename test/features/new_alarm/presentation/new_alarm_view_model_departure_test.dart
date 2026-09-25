import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/new_alarm/data/departure_estimate_repository.dart';
import 'package:siempre_a_tiempo/features/new_alarm/data/mock_departure_estimate_repository.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/departure_estimate.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/travel_factor.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/departure_state.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';

/// Repositorio que responde solo cuando la prueba lo decide.
class _RepositorioControlado implements DepartureEstimateRepository {
  final List<Completer<DepartureEstimate>> pedidos = <Completer<DepartureEstimate>>[];

  @override
  Future<DepartureEstimate> estimate({
    required DateTime arriveAt,
    required String destination,
    required TransportMode mode,
  }) {
    final Completer<DepartureEstimate> pedido = Completer<DepartureEstimate>();
    pedidos.add(pedido);
    return pedido.future;
  }
}

final DateTime _llegada = DateTime(2026, 8, 20, 15);

DepartureEstimate _estimacion(int hora, int minuto) => DepartureEstimate(
      leaveAt: DateTime(2026, 8, 20, hora, minuto),
      arriveAt: _llegada,
      factors: const <TravelFactor>[],
    );

NewAlarmViewModel _conDetalles(DepartureEstimateRepository repositorio) =>
    NewAlarmViewModel(departureRepository: repositorio)
      ..updateTitle('  Reunión con cliente  ')
      ..updateWhenAt(_llegada)
      ..updateLocation('Avenida El Poblado #1-25');

void main() {
  test('arranca sin estimación', () {
    expect(NewAlarmViewModel().departure, isA<DepartureIdle>());
  });

  test('al cargar pasa por Calculando y termina en Listo', () async {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero));
    final List<DepartureState> estados = <DepartureState>[];
    vm.addListener(() => estados.add(vm.departure));

    await vm.loadDeparture();

    expect(estados.first, isA<DepartureLoading>());
    expect(estados.last, isA<DepartureReady>());
    final listo = vm.departure as DepartureReady;
    expect(listo.estimate.leaveAt, DateTime(2026, 8, 20, 14, 20));
  });

  test('la estimación usa el medio de transporte elegido', () async {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero))
      ..selectTransportMode(TransportMode.walking);

    await vm.loadDeparture();

    final listo = vm.departure as DepartureReady;
    expect(listo.estimate.leaveAt, DateTime(2026, 8, 20, 13, 50));
  });

  test('si el cálculo falla queda en Error con un mensaje', () async {
    final vm = _conDetalles(
      MockDepartureEstimateRepository(delay: Duration.zero, shouldFail: true),
    );

    await vm.loadDeparture();

    expect(vm.departure, isA<DepartureError>());
    expect((vm.departure as DepartureError).message, isNotEmpty);
  });

  test('reintentar tras un error puede terminar en Listo', () async {
    final repositorio = _RepositorioControlado();
    final vm = _conDetalles(repositorio);

    final primero = vm.loadDeparture();
    repositorio.pedidos[0].completeError(Exception('sin red'));
    await primero;
    expect(vm.departure, isA<DepartureError>());

    final segundo = vm.loadDeparture();
    repositorio.pedidos[1].complete(_estimacion(14, 20));
    await segundo;
    expect(vm.departure, isA<DepartureReady>());
  });

  test('una respuesta vieja que llega tarde se descarta', () async {
    final repositorio = _RepositorioControlado();
    final vm = _conDetalles(repositorio);

    final viejo = vm.loadDeparture();
    final nuevo = vm.loadDeparture();

    repositorio.pedidos[1].complete(_estimacion(14, 20));
    await nuevo;
    repositorio.pedidos[0].complete(_estimacion(9, 0));
    await viejo;

    final listo = vm.departure as DepartureReady;
    expect(listo.estimate.leaveAt, DateTime(2026, 8, 20, 14, 20));
  });

  test('cerrar el asistente mientras calcula no provoca errores', () async {
    final repositorio = _RepositorioControlado();
    final vm = _conDetalles(repositorio);

    final pedido = vm.loadDeparture();
    vm.dispose();
    repositorio.pedidos.single.complete(_estimacion(14, 20));

    await expectLater(pedido, completes);
  });

  test('sin estimación lista, guardar no devuelve resumen', () {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero));

    expect(vm.save(), isNull);
  });

  test('con estimación lista, guardar devuelve el resumen de la alarma', () async {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero));
    await vm.loadDeparture();

    final resumen = vm.save();

    expect(resumen, isNotNull);
    expect(resumen!.title, 'Reunión con cliente');
    expect(resumen.startsAt, _llegada);
    expect(resumen.leaveAt, DateTime(2026, 8, 20, 14, 20));
  });
}
