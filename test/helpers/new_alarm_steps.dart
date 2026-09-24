import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';

/// Recorre los pasos 1 y 2 del asistente con datos válidos y lo deja en el 3.
///
/// Espera un `NewAlarmFlow` ya montado en el paso 1.
Future<void> goToTransportStep(WidgetTester tester) async {
  await tester.tap(find.text('Reunión'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Siguiente'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, 'Reunión con cliente');
  await tester.enterText(find.byType(TextField).last, 'Avenida El Poblado #1-25');
  // La fecha se fija directamente: el selector de Material ya está cubierto
  // por las pruebas del paso 2.
  tester
      .state<NewAlarmFlowState>(find.byType(NewAlarmFlow))
      .viewModel
      .updateWhenAt(DateTime(2026, 8, 20, 15));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Siguiente'));
  await tester.pumpAndSettle();
}
