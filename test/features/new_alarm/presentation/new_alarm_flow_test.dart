import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/router/app_router.dart';
import 'package:siempre_a_tiempo/core/router/app_routes.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_progress_bar.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  testWidgets('abre en el paso 1 con Siguiente deshabilitado', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    expect(find.text('Nueva alarma'), findsOneWidget);
    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
  });

  testWidgets('el indicador refleja el paso actual', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    final barra = tester.widget<WizardProgressBar>(find.byType(WizardProgressBar));
    expect(barra.currentStep, 0);
    expect(barra.totalSteps, 4);
  });

  testWidgets('seleccionar un tipo habilita Siguiente y avanza al paso 2',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Detalles de la reunión'), findsOneWidget);
    expect(
      tester.widget<WizardProgressBar>(find.byType(WizardProgressBar)).currentStep,
      1,
    );
  });

  testWidgets('la acción izquierda dice Cancelar en el paso 1 y Atrás en el 2',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    expect(find.text('Cancelar'), findsOneWidget);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Atrás'), findsOneWidget);
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('Atrás vuelve al paso 1 conservando la selección', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
    // Siguiente sigue habilitado: la selección no se perdió.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('con los datos completos, Siguiente avisa que falta construirlo',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Reunión con cliente');
    await tester.enterText(find.byType(TextField).last, 'Avenida El Poblado #1-25');
    await tester.pumpAndSettle();

    // La fecha se fija directamente: el selector de Material ya está cubierto
    // por las pruebas del paso 2.
    final estado = tester.state<NewAlarmFlowState>(find.byType(NewAlarmFlow));
    estado.viewModel.updateWhenAt(DateTime(2026, 8, 20, 15));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente: este paso está en construcción.'), findsOneWidget);
    expect(find.text('Detalles de la reunión'), findsOneWidget);
  });

  testWidgets('recorrido desde Inicio: el retroceso del sistema va paso a paso',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nueva alarma'));
    await tester.pumpAndSettle();
    expect(find.byType(NewAlarmFlow), findsOneWidget);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Detalles de la reunión'), findsOneWidget);

    // Primer retroceso del sistema: vuelve al paso 1 sin cerrar el asistente.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);

    // Segundo retroceso: cierra el asistente y vuelve a Inicio.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(NewAlarmFlow), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('no se puede cambiar de paso deslizando', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);
  });
}
