import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/created_alarm_summary.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/alarm_summary_card.dart';

import '../../../../helpers/pump_app.dart';

final CreatedAlarmSummary _resumen = CreatedAlarmSummary(
  title: 'Reunión con cliente',
  startsAt: DateTime(2026, 8, 20, 15),
  leaveAt: DateTime(2026, 8, 20, 14, 20),
);

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el título, la fecha y la hora de salida', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmSummaryCard(summary: _resumen)));

    expect(find.text('Reunión con cliente'), findsOneWidget);
    expect(find.text('20 de agosto de 2026 · 3:00 PM'), findsOneWidget);
    expect(find.text('Debes salir a las 2:20 PM'), findsOneWidget);
  });

  testWidgets('golden: resumen de la alarma creada', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AlarmSummaryCard(summary: _resumen),
        ),
      ),
    );

    await expectLater(
      find.byType(AlarmSummaryCard),
      matchesGoldenFile('goldens/alarm_summary_card.png'),
    );
  });
}
