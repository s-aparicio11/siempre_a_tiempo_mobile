import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/router/app_router.dart';
import 'package:siempre_a_tiempo/core/router/app_routes.dart';
import 'package:siempre_a_tiempo/core/theme/app_typography.dart';
import 'package:siempre_a_tiempo/features/home/data/mock_alarm_repository.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_screen.dart';
import 'package:siempre_a_tiempo/features/home/presentation/home_view_model.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarm_card.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_empty_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_error_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_skeleton.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../../../helpers/pump_app.dart';

/// Monta `HomeScreen` con un ViewModel controlado por la prueba.
Future<void> _pumpHome(WidgetTester tester, HomeViewModel vm) async {
  await pumpApp(tester, HomeScreen(viewModel: vm));
}

/// Ejecuta la carga con tiempo real. Dentro de `testWidgets` el reloj es
/// simulado y el `Future.delayed` del repositorio nunca se cumpliría.
Future<void> _cargar(WidgetTester tester, HomeViewModel vm) =>
    tester.runAsync(vm.load);

/// Posición de desplazamiento de la lista de Inicio.
double _desplazamientoInicio(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .pixels;

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el esqueleto mientras carga', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: const Duration(milliseconds: 50)),
    );
    unawaited(vm.load());
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsSkeleton), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('muestra el saludo, el encabezado y las tres tarjetas', (tester) async {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));
    await _cargar(tester, vm);
    await _pumpHome(tester, vm);

    expect(find.text('¡Hola, Cristian!'), findsOneWidget);
    expect(find.text('Tienes 3 alarmas para hoy'), findsOneWidget);
    expect(find.text('PRÓXIMAS ALARMAS'), findsOneWidget);
    expect(find.byType(AlarmCard), findsNWidgets(3));
  });

  testWidgets('muestra el estado vacío cuando no hay alarmas', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, alarms: const <Alarm>[]),
    );
    await _cargar(tester, vm);
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsEmptyState), findsOneWidget);
    expect(find.text('No tienes alarmas para hoy'), findsNWidgets(2));
  });

  testWidgets('muestra el estado de error y permite reintentar', (tester) async {
    final vm = HomeViewModel(
      MockAlarmRepository(delay: Duration.zero, shouldFail: true),
    );
    await _cargar(tester, vm);
    await _pumpHome(tester, vm);

    expect(find.byType(AlarmsErrorState), findsOneWidget);

    vm.repository = MockAlarmRepository(delay: Duration.zero);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(AlarmCard), findsNWidgets(3));
  });

  testWidgets('el botón flotante lleva al asistente de nueva alarma', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva alarma'), findsOneWidget);

    await tester.tap(find.text('Nueva alarma'));
    await tester.pumpAndSettle();

    // Se navegó fuera del shell.
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('el botón flotante usa la tipografía de botones', (tester) async {
    final vm = HomeViewModel(MockAlarmRepository(delay: Duration.zero));
    await _cargar(tester, vm);
    await _pumpHome(tester, vm);

    final RenderParagraph etiqueta =
        tester.renderObject<RenderParagraph>(find.text('Nueva alarma'));
    expect(etiqueta.text.style?.fontFamily, AppTypography.labelButton.fontFamily);
  });

  testWidgets('conserva el desplazamiento de Inicio al volver de otra pestaña',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await tester.pumpAndSettle();
    final double desplazamiento = _desplazamientoInicio(tester);
    // Sin esto la prueba pasaría aunque la lista nunca se hubiera movido.
    expect(desplazamiento, greaterThan(0));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();

    expect(_desplazamientoInicio(tester), desplazamiento);
  });
}
