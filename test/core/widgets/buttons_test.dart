import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/widgets/primary_button.dart';
import 'package:siempre_a_tiempo/core/widgets/secondary_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('PrimaryButton', () {
    testWidgets('muestra su etiqueta y responde al toque', (tester) async {
      var pulsado = false;
      await pumpApp(
        tester,
        Scaffold(
          body: PrimaryButton(
            label: 'Siguiente',
            onPressed: () => pulsado = true,
          ),
        ),
      );

      expect(find.text('Siguiente'), findsOneWidget);
      await tester.tap(find.text('Siguiente'));
      expect(pulsado, isTrue);
    });

    testWidgets('queda deshabilitado cuando onPressed es null', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: PrimaryButton(label: 'Siguiente', onPressed: null),
        ),
      );

      final boton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(boton.onPressed, isNull);
    });

    testWidgets('respeta el área tocable mínima de 48 dp', (tester) async {
      await pumpApp(
        tester,
        Scaffold(body: PrimaryButton(label: 'Ok', onPressed: () {})),
      );

      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(48.0));
    });
  });

  group('SecondaryButton', () {
    testWidgets('muestra su etiqueta y responde al toque', (tester) async {
      var pulsado = false;
      await pumpApp(
        tester,
        Scaffold(
          body: SecondaryButton(
            label: 'Cancelar',
            onPressed: () => pulsado = true,
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      expect(pulsado, isTrue);
    });
  });
}
