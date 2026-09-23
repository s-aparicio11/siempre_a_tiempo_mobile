import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/core/format/app_date_format.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/new_alarm_view_model.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/steps/step_details_screen.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/attendee_avatars.dart';

import '../../../../helpers/pump_app.dart';

NewAlarmViewModel _vmEnPaso2() => NewAlarmViewModel()
  ..selectType(AlarmType.meeting)
  ..next();

Future<void> _pumpStep(WidgetTester tester, NewAlarmViewModel vm) async {
  await pumpApp(
    tester,
    const Scaffold(body: StepDetailsScreen()),
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<NewAlarmViewModel>.value(value: vm),
    ],
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el título y los tres campos del diseño', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.text('Detalles de la reunión'), findsOneWidget);
    expect(find.text('Título de la reunión'), findsOneWidget);
    expect(find.text('¿Cuándo es?'), findsOneWidget);
    expect(find.text('¿Dónde es?'), findsOneWidget);
    expect(find.text('¿Quién más asistirá?'), findsOneWidget);
  });

  testWidgets('escribir el título lo guarda en el borrador', (tester) async {
    final vm = _vmEnPaso2();
    await _pumpStep(tester, vm);

    await tester.enterText(find.byType(TextField).first, 'Reunión con cliente');
    await tester.pumpAndSettle();

    expect(vm.draft.title, 'Reunión con cliente');
  });

  testWidgets('escribir el lugar lo guarda en el borrador', (tester) async {
    final vm = _vmEnPaso2();
    await _pumpStep(tester, vm);

    await tester.enterText(find.byType(TextField).last, 'Avenida El Poblado #1-25');
    await tester.pumpAndSettle();

    expect(vm.draft.location, 'Avenida El Poblado #1-25');
  });

  testWidgets('muestra la fecha ya elegida con el formato del diseño',
      (tester) async {
    final vm = _vmEnPaso2()..updateWhenAt(DateTime(2026, 8, 20, 15));
    await _pumpStep(tester, vm);

    expect(find.text('20 de agosto de 2026, 3:00 PM'), findsOneWidget);
  });

  testWidgets('tocar el campo de fecha abre el selector', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    await tester.tap(find.text('Selecciona fecha y hora'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('abre el selector aunque la fecha guardada ya haya pasado',
      (tester) async {
    final DateTime ayer = DateTime.now().subtract(const Duration(days: 1));
    await _pumpStep(tester, _vmEnPaso2()..updateWhenAt(ayer));

    await tester.tap(find.text(AppDateFormat.longDateTime(ayer)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('limpiar la fecha la borra sin tocar los demás campos',
      (tester) async {
    final vm = _vmEnPaso2()
      ..updateTitle('Reunión con cliente')
      ..updateWhenAt(DateTime(2026, 8, 20, 15))
      ..updateLocation('Avenida El Poblado #1-25');
    await _pumpStep(tester, vm);

    await tester.tap(find.widgetWithIcon(IconButton, LucideIcons.x).at(1));
    await tester.pumpAndSettle();

    expect(vm.draft.whenAt, isNull);
    expect(vm.draft.title, 'Reunión con cliente');
    expect(vm.draft.location, 'Avenida El Poblado #1-25');
  });

  testWidgets('muestra los avatares de los asistentes', (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.byType(AttendeeAvatars), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('el contenido se desplaza cuando aparece el teclado',
      (tester) async {
    await _pumpStep(tester, _vmEnPaso2());

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
