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

    testWidgets('una etiqueta larga con letra ampliada no se sale del botón',
        (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: Center(
            child: SizedBox(
              width: 150,
              child: PrimaryButton(
                label: 'Guardar alarma',
                onPressed: _noop,
                expanded: true,
              ),
            ),
          ),
        ),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Guardar alarma'), findsOneWidget);
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

void _noop() {}
