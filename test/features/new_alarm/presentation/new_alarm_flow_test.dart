import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/core/router/app_router.dart';
import 'package:siempre_a_tiempo/core/router/app_routes.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_progress_bar.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/alarm_created_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_flow.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../../../helpers/new_alarm_steps.dart';
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

  testWidgets('con los datos completos, Siguiente avanza al paso 3', (tester) async {
    await pumpApp(tester, const NewAlarmFlow());

    await goToTransportStep(tester);

    expect(find.text('¿Cómo te vas a mover?'), findsOneWidget);
    expect(
      tester.widget<WizardProgressBar>(find.byType(WizardProgressBar)).currentStep,
      2,
    );
    // Carro viene elegido, así que se puede avanzar sin tocar nada.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('del paso 3 avanza al 4, que calcula y luego muestra la hora',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());
    await goToTransportStep(tester);

    await tester.tap(find.text('Siguiente'));
    // Solo la transición de página: pumpAndSettle esperaría también al
    // indicador de carga y el cálculo ya habría terminado. El primer pump
    // arranca la animación y el segundo la lleva hasta el final.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hora recomendada para salir'), findsOneWidget);
    expect(find.text('Calculando tu hora de salida…'), findsOneWidget);
    expect(
      tester.widget<WizardProgressBar>(find.byType(WizardProgressBar)).currentStep,
      3,
    );

    // El mock tarda 800 ms en responder.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('2:20 PM'), findsOneWidget);
    expect(find.text('Tráfico actual'), findsOneWidget);
  });

  testWidgets('Guardar alarma solo se habilita con la hora calculada',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());
    await goToTransportStep(tester);
    await tester.tap(find.text('Siguiente'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Calculando tu hora de salida…'), findsOneWidget);
    expect(find.text('Guardar alarma'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('recorrido completo: Inicio, asistente, confirmación y de vuelta a Inicio',
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
    await goToTransportStep(tester);
    await tester.tap(find.text('Siguiente'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar alarma'));
    await tester.pumpAndSettle();

    expect(find.byType(NewAlarmFlow), findsNothing);
    expect(find.text('¡Listo! Tu alarma ha sido creada'), findsOneWidget);
    expect(find.text('Reunión con cliente'), findsOneWidget);
    expect(find.text('Debes salir a las 2:20 PM'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // El asistente fue reemplazado: debajo de la confirmación estaba Inicio.
    expect(find.byType(AlarmCreatedScreen), findsNothing);
    expect(find.byType(NewAlarmFlow), findsNothing);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('Atrás desde el paso 3 vuelve al 2 y conserva el medio elegido',
      (tester) async {
    await pumpApp(tester, const NewAlarmFlow());
    await goToTransportStep(tester);

    await tester.ensureVisible(find.text('Bicicleta'));
    await tester.tap(find.text('Bicicleta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();

    expect(find.text('Detalles de la reunión'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    final vm = tester.state<NewAlarmFlowState>(find.byType(NewAlarmFlow)).viewModel;
    expect(vm.draft.transportMode, TransportMode.bicycle);
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
