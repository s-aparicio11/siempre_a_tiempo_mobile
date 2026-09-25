import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/departure_estimate.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/travel_factor.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/departure_time_card.dart';

import '../../../../helpers/pump_app.dart';

final DepartureEstimate _estimacion = DepartureEstimate(
  leaveAt: DateTime(2026, 8, 20, 14, 20),
  arriveAt: DateTime(2026, 8, 20, 15),
  factors: const <TravelFactor>[],
);

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra la hora de salida, la de llegada y el margen', (tester) async {
    await pumpApp(tester, Scaffold(body: DepartureTimeCard(estimate: _estimacion)));

    expect(find.text('Debes salir a las'), findsOneWidget);
    expect(find.text('2:20 PM'), findsOneWidget);
    expect(find.text('Para llegar a las 3:00 PM · 40 min de margen'), findsOneWidget);
  });

  testWidgets('el lector de pantalla la anuncia como una sola frase', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpApp(tester, Scaffold(body: DepartureTimeCard(estimate: _estimacion)));

    expect(
      tester.getSemantics(find.byType(DepartureTimeCard)),
      isSemantics(
        label: 'Debes salir a las 2:20 PM para llegar a las 3:00 PM, '
            'con 40 minutos de margen',
      ),
    );
    handle.dispose();
  });

  testWidgets('con letra al 150 % en un celular angosto no se desborda',
      (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(width: 280, child: DepartureTimeCard(estimate: _estimacion)),
        ),
      ),
      textScale: 1.5,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('golden: tarjeta de hora de salida', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DepartureTimeCard(estimate: _estimacion),
        ),
      ),
    );

    await expectLater(
      find.byType(DepartureTimeCard),
      matchesGoldenFile('goldens/departure_time_card.png'),
    );
  });
}
