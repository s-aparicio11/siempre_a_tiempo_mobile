import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_transport_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/transport_mode_card.dart';

import '../../../../helpers/pump_app.dart';

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepTransportScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

List<TransportModeCard> _seleccionadas(WidgetTester tester) => tester
    .widgetList<TransportModeCard>(find.byType(TransportModeCard))
    .where((TransportModeCard c) => c.selected)
    .toList();

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra la pregunta y los cinco medios', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(find.text('¿Cómo te vas a mover?'), findsOneWidget);
    for (final TransportMode mode in TransportMode.values) {
      expect(find.text(mode.label), findsOneWidget, reason: mode.name);
    }
    expect(find.byType(TransportModeCard), findsNWidgets(5));
  });

  testWidgets('al entrar, Carro está seleccionado', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(_seleccionadas(tester).single.mode, TransportMode.car);
    expect(find.text('Ruta más rápida según tráfico'), findsOneWidget);
  });

  testWidgets('tocar un medio lo selecciona en el ViewModel', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Transporte público'));
    await tester.pumpAndSettle();

    expect(vm.draft.transportMode, TransportMode.publicTransport);
  });

  testWidgets('la selección es excluyente', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Moto'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Caminando'));
    await tester.tap(find.text('Caminando'));
    await tester.pumpAndSettle();

    expect(_seleccionadas(tester).single.mode, TransportMode.walking);
    // Solo la opción seleccionada muestra su descripción.
    expect(find.text(TransportMode.walking.description), findsOneWidget);
    expect(find.text(TransportMode.motorcycle.description), findsNothing);
  });
}
