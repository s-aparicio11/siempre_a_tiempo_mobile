import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/created_alarm_summary.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/alarm_created_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../helpers/new_alarm_steps.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  for (final double escala in <double>[1.0, 1.3, 1.5]) {
    for (final Size tamano in <Size>[const Size(360, 640), const Size(430, 932)]) {
      testWidgets(
        'Inicio no se desborda con escala $escala en ${tamano.width.toInt()}x${tamano.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await pumpApp(tester, const MainShell(), textScale: escala);
          // Deja terminar la carga simulada para revisar las tarjetas reales
          // y no solo el esqueleto de carga.
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'El asistente no se desborda con escala $escala en ${tamano.width.toInt()}x${tamano.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await pumpApp(tester, const NewAlarmFlow(), textScale: escala);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);

          // Recorre los pasos 2 y 3; cada transición vuelve a revisar
          // desbordes en la pantalla que queda visible.
          await goToTransportStep(tester);

          expect(find.text('¿Cómo te vas a mover?'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Siguiente'));
          // Deja terminar el cálculo simulado para revisar la hora y los
          // factores, no solo el indicador de carga.
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          expect(find.text('2:20 PM'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'La confirmación no se desborda con escala $escala en ${tamano.width.toInt()}x${tamano.height.toInt()}',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await pumpApp(
            tester,
            AlarmCreatedScreen(
              summary: CreatedAlarmSummary(
                title: 'Reunión con cliente',
                startsAt: DateTime(2026, 8, 20, 15),
                leaveAt: DateTime(2026, 8, 20, 14, 20),
              ),
            ),
            textScale: escala,
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
