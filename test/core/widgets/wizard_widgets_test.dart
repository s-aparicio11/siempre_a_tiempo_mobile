import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/theme/app_colors.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_bottom_bar.dart';
import 'package:siempre_a_tiempo/core/widgets/wizard_progress_bar.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('WizardProgressBar', () {
    testWidgets('dibuja un segmento por paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 0, totalSteps: 4),
        ),
      );

      expect(find.byKey(const Key('wizard-progress-segment')), findsNWidgets(4));
    });

    testWidgets('resalta un segmento en el primer paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 0, totalSteps: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(_segmentosActivos(tester), 1);
    });

    testWidgets('resalta dos segmentos en el segundo paso', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 1, totalSteps: 4),
        ),
      );
      await tester.pumpAndSettle();

      expect(_segmentosActivos(tester), 2);
    });

    testWidgets('se anuncia como progreso al lector de pantalla', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: WizardProgressBar(currentStep: 1, totalSteps: 4),
        ),
      );

      expect(find.bySemanticsLabel('Paso 2 de 4'), findsOneWidget);
    });
  });

  group('WizardBottomBar', () {
    testWidgets('muestra ambas etiquetas y responde a los toques', (tester) async {
      var atras = 0;
      var siguiente = 0;

      await pumpApp(
        tester,
        Scaffold(
          body: WizardBottomBar(
            leadingLabel: 'Cancelar',
            onLeading: () => atras++,
            trailingLabel: 'Siguiente',
            onTrailing: () => siguiente++,
          ),
        ),
      );

      await tester.tap(find.text('Cancelar'));
      await tester.tap(find.text('Siguiente'));

      expect(atras, 1);
      expect(siguiente, 1);
    });

    testWidgets('deshabilita la acción principal cuando onTrailing es null',
        (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: WizardBottomBar(
            leadingLabel: 'Cancelar',
            onLeading: () {},
            trailingLabel: 'Siguiente',
            onTrailing: null,
          ),
        ),
      );

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });
}

/// Cuenta los segmentos pintados con el color primario.
int _segmentosActivos(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(find.byKey(const Key('wizard-progress-segment')))
      .where((AnimatedContainer c) =>
          (c.decoration as BoxDecoration?)?.color == AppColors.primary)
      .length;
}
