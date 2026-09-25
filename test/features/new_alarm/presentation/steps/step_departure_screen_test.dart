import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/core/widgets/retry_error_state.dart';
import 'package:siempre_a_tiempo/features/new_alarm/data/departure_estimate_repository.dart';
import 'package:siempre_a_tiempo/features/new_alarm/data/mock_departure_estimate_repository.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/departure_estimate.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_departure_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/departure_time_card.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/travel_factor_tile.dart';

import '../../../../helpers/pump_app.dart';

/// Falla la primera vez y responde bien después, para probar "Reintentar".
class _FallaUnaVez implements DepartureEstimateRepository {
  final MockDepartureEstimateRepository _bueno =
      MockDepartureEstimateRepository(delay: Duration.zero);
  var _intentos = 0;

  @override
  Future<DepartureEstimate> estimate({
    required DateTime arriveAt,
    required String destination,
    required TransportMode mode,
  }) async {
    _intentos++;
    if (_intentos == 1) {
      throw Exception('sin red');
    }
    return _bueno.estimate(arriveAt: arriveAt, destination: destination, mode: mode);
  }
}

NewAlarmViewModel _conDetalles(DepartureEstimateRepository repositorio) =>
    NewAlarmViewModel(departureRepository: repositorio)
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepDepartureScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('mientras calcula muestra el título y el indicador de carga',
      (tester) async {
    final vm = _conDetalles(
      MockDepartureEstimateRepository(delay: const Duration(seconds: 1)),
    );
    await _pumpStep(tester, vm);

    // Sin esperar: la prueba necesita ver el estado intermedio.
    unawaited(vm.loadDeparture());
    await tester.pump();

    expect(find.text('Hora recomendada para salir'), findsOneWidget);
    expect(find.text('Calculando tu hora de salida…'), findsOneWidget);
    expect(find.byType(DepartureTimeCard), findsNothing);

    // Deja terminar el cálculo para no dejar temporizadores pendientes.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('con la hora lista muestra la tarjeta y los tres factores',
      (tester) async {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero));
    // El reloj de testWidgets es simulado: sin runAsync, esperar al
    // repositorio no terminaría nunca.
    await tester.runAsync(vm.loadDeparture);
    await _pumpStep(tester, vm);

    expect(find.byType(DepartureTimeCard), findsOneWidget);
    expect(find.text('2:20 PM'), findsOneWidget);
    expect(find.text('FACTORES QUE SE TUVIERON EN CUENTA'), findsOneWidget);
    expect(find.byType(TravelFactorTile), findsNWidgets(3));
    expect(find.text('Moderado'), findsOneWidget);
    expect(find.text('Lluvia ligera'), findsOneWidget);
    expect(find.text('Av. El Poblado'), findsOneWidget);
  });

  testWidgets('tocar un factor avisa que su detalle viene después', (tester) async {
    final vm = _conDetalles(MockDepartureEstimateRepository(delay: Duration.zero));
    // El reloj de testWidgets es simulado: sin runAsync, esperar al
    // repositorio no terminaría nunca.
    await tester.runAsync(vm.loadDeparture);
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Clima'));
    await tester.pump();

    expect(
      find.text('Próximamente: el detalle de este factor está en construcción.'),
      findsOneWidget,
    );
  });

  testWidgets('si falla muestra el error y Reintentar recalcula', (tester) async {
    final vm = _conDetalles(_FallaUnaVez());
    // El reloj de testWidgets es simulado: sin runAsync, esperar al
    // repositorio no terminaría nunca.
    await tester.runAsync(vm.loadDeparture);
    await _pumpStep(tester, vm);

    expect(find.byType(RetryErrorState), findsOneWidget);
    expect(find.text('No pudimos calcular tu hora de salida'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(RetryErrorState), findsNothing);
    expect(find.text('2:20 PM'), findsOneWidget);
  });
}
