import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/created_alarm_summary.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/alarm_created_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/alarm_summary_card.dart';

import '../../../helpers/pump_app.dart';

final CreatedAlarmSummary _resumen = CreatedAlarmSummary(
  title: 'Reunión con cliente',
  startsAt: DateTime(2026, 8, 20, 15),
  leaveAt: DateTime(2026, 8, 20, 14, 20),
);

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra la confirmación con el resumen de la alarma', (tester) async {
    await pumpApp(tester, AlarmCreatedScreen(summary: _resumen));

    expect(find.text('¡Listo! Tu alarma ha sido creada'), findsOneWidget);
    expect(find.text('Te avisaremos cuando sea momento de salir.'), findsOneWidget);
    expect(find.byType(AlarmSummaryCard), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('Entendido cierra la confirmación', (tester) async {
    await pumpApp(
      tester,
      Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AlarmCreatedScreen(summary: _resumen),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(AlarmCreatedScreen), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(find.byType(AlarmCreatedScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
