import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/labeled_field.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('LabeledTextField', () {
    testWidgets('muestra la etiqueta y el valor', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      expect(find.text('Título de la reunión'), findsOneWidget);
      expect(find.text('Reunión con cliente'), findsOneWidget);
    });

    testWidgets('notifica cada cambio de texto', (tester) async {
      String? ultimo;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: '',
            onChanged: (String v) => ultimo = v,
            onClear: () {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Almuerzo');

      expect(ultimo, 'Almuerzo');
    });

    testWidgets('el botón de limpiar solo aparece cuando hay valor',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: '',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('limpiar vacía el campo', (tester) async {
      var limpiados = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () => limpiados++,
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.x));
      expect(limpiados, 1);
    });

    testWidgets('el botón de limpiar cumple el área tocable mínima',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTextField(
            label: 'Título de la reunión',
            value: 'Reunión con cliente',
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      );

      final Size tamano = tester.getSize(find.byType(IconButton));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
    });
  });

  group('LabeledTapField', () {
    testWidgets('muestra la pista cuando no hay valor', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTapField(
            label: '¿Cuándo es?',
            value: null,
            hint: 'Selecciona fecha y hora',
            onTap: () {},
            onClear: () {},
          ),
        ),
      );

      expect(find.text('Selecciona fecha y hora'), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('muestra el valor y responde al toque', (tester) async {
      var toques = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: LabeledTapField(
            label: '¿Cuándo es?',
            value: '20 de agosto de 2026, 3:00 PM',
            hint: 'Selecciona fecha y hora',
            onTap: () => toques++,
            onClear: () {},
          ),
        ),
      );

      expect(find.text('20 de agosto de 2026, 3:00 PM'), findsOneWidget);

      await tester.tap(find.text('20 de agosto de 2026, 3:00 PM'));
      expect(toques, 1);
    });
  });
}
