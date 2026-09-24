import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/core/theme/app_spacing.dart';
import 'package:siempre_a_tiempo/core/widgets/transport_mode_icon.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/transport_mode_card.dart';

import '../../../../helpers/pump_app.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  TransportMode mode = TransportMode.car,
  bool selected = false,
  VoidCallback? onTap,
}) {
  return pumpApp(
    tester,
    Scaffold(
      body: TransportModeCard(
        mode: mode,
        selected: selected,
        onTap: onTap ?? _noop,
      ),
    ),
  );
}

void main() {
  setUpAll(initTestFormatting);

  testWidgets('sin seleccionar muestra la etiqueta y el ícono, sin descripción',
      (tester) async {
    await _pumpCard(tester);

    expect(find.text('Carro'), findsOneWidget);
    expect(find.byIcon(TransportMode.car.icon), findsOneWidget);
    expect(find.text('Ruta más rápida según tráfico'), findsNothing);
  });

  testWidgets('seleccionada muestra además la descripción', (tester) async {
    await _pumpCard(tester, selected: true);

    expect(find.text('Carro'), findsOneWidget);
    expect(find.text('Ruta más rápida según tráfico'), findsOneWidget);
  });

  testWidgets('tocar la tarjeta notifica el toque', (tester) async {
    var toques = 0;
    await _pumpCard(tester, onTap: () => toques++);

    await tester.tap(find.byType(TransportModeCard));

    expect(toques, 1);
  });

  testWidgets('se anuncia como un radio con su estado', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pumpCard(tester, mode: TransportMode.walking, selected: true);

    expect(
      tester.getSemantics(find.byType(TransportModeCard)),
      isSemantics(
        label: 'Caminando\nRuta peatonal más corta',
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('el área táctil cumple el mínimo de accesibilidad', (tester) async {
    await _pumpCard(tester);

    expect(
      tester.getSize(find.byType(TransportModeCard)).height,
      greaterThanOrEqualTo(AppSizes.minTouchTarget),
    );
  });

  testWidgets('golden: opción sin seleccionar y seleccionada', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TransportModeCard(
                mode: TransportMode.publicTransport,
                selected: false,
                onTap: _noop,
              ),
              SizedBox(height: 16),
              TransportModeCard(
                mode: TransportMode.car,
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
      matchesGoldenFile('goldens/transport_mode_card_states.png'),
    );
  });
}

void _noop() {}
