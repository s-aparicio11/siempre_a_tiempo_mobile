import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_type_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/alarm_type_card.dart';

import '../../../../helpers/pump_app.dart';

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepTypeScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra la pregunta y las tres opciones con su descripción',
      (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(find.text('¿Qué tipo de alarma quieres crear?'), findsOneWidget);

    expect(find.text('Reunión'), findsOneWidget);
    expect(find.text('Agenda una reunión con tiempo de viaje'), findsOneWidget);
    expect(find.text('Recordatorio personal'), findsOneWidget);
    expect(find.text('Crea un recordatorio para cualquier cosa'), findsOneWidget);
    expect(find.text('Evento recurrente'), findsOneWidget);
    expect(find.text('Crea alarmas que se repiten a diario'), findsOneWidget);

    expect(find.byType(AlarmTypeCard), findsNWidgets(3));
  });

  testWidgets('ninguna opción está seleccionada al entrar', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    final seleccionadas = tester
        .widgetList<AlarmTypeCard>(find.byType(AlarmTypeCard))
        .where((AlarmTypeCard c) => c.selected);

    expect(seleccionadas, isEmpty);
  });

  testWidgets('tocar una opción la selecciona en el ViewModel', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();

    expect(vm.draft.type, AlarmType.meeting);
  });

  testWidgets('la selección es excluyente', (tester) async {
    final vm = NewAlarmViewModel();
    await _pumpStep(tester, vm);

    await tester.tap(find.text('Reunión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evento recurrente'));
    await tester.pumpAndSettle();

    final seleccionadas = tester
        .widgetList<AlarmTypeCard>(find.byType(AlarmTypeCard))
        .where((AlarmTypeCard c) => c.selected)
        .toList();

    expect(seleccionadas, hasLength(1));
    expect(seleccionadas.single.type, AlarmType.recurringEvent);
  });

  testWidgets('cada opción se anuncia como seleccionable', (tester) async {
    await _pumpStep(tester, NewAlarmViewModel());

    expect(find.byType(MergeSemantics), findsNWidgets(3));
  });

  testWidgets('golden: opción sin seleccionar y seleccionada', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              AlarmTypeCard(
                type: AlarmType.meeting,
                selected: false,
                onTap: _noop,
              ),
              SizedBox(height: 16),
              AlarmTypeCard(
                type: AlarmType.meeting,
                selected: true,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/alarm_type_card_states.png'),
    );
  });
}

void _noop() {}
