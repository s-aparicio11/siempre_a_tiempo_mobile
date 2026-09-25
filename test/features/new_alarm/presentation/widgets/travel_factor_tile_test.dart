import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siempre_a_tiempo/core/theme/app_spacing.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/travel_factor.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/travel_factor_tile.dart';

import '../../../../helpers/pump_app.dart';

const TravelFactor _clima =
    TravelFactor(kind: TravelFactorKind.weather, value: 'Lluvia ligera');

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra el nombre, el valor, el ícono y el chevron', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: TravelFactorTile(factor: _clima, onTap: _noop)),
    );

    expect(find.text('Clima'), findsOneWidget);
    expect(find.text('Lluvia ligera'), findsOneWidget);
    expect(find.byIcon(LucideIcons.cloud), findsOneWidget);
    expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);
  });

  testWidgets('cada tipo de factor tiene su propio ícono', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: Column(
          children: <Widget>[
            TravelFactorTile(
              factor: TravelFactor(kind: TravelFactorKind.traffic, value: 'Moderado'),
              onTap: _noop,
            ),
            TravelFactorTile(
              factor: TravelFactor(kind: TravelFactorKind.route, value: 'Av. El Poblado'),
              onTap: _noop,
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(LucideIcons.car), findsOneWidget);
    expect(find.byIcon(LucideIcons.route), findsOneWidget);
  });

  testWidgets('tocar la fila notifica el toque', (tester) async {
    var toques = 0;
    await pumpApp(
      tester,
      Scaffold(body: TravelFactorTile(factor: _clima, onTap: () => toques++)),
    );

    await tester.tap(find.byType(TravelFactorTile));

    expect(toques, 1);
  });

  testWidgets('se anuncia como un botón con su nombre y valor', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      const Scaffold(body: TravelFactorTile(factor: _clima, onTap: _noop)),
    );

    expect(
      tester.getSemantics(find.byType(TravelFactorTile)),
      isSemantics(label: 'Clima\nLluvia ligera', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('un valor largo se recorta sin desbordar la fila', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: SizedBox(
          width: 320,
          child: TravelFactorTile(
            factor: TravelFactor(
              kind: TravelFactorKind.route,
              value: 'Autopista Sur con calle 10 sur, salida por la avenida Las Vegas',
            ),
            onTap: _noop,
          ),
        ),
      ),
      textScale: 1.5,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('el área táctil cumple el mínimo de accesibilidad', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: TravelFactorTile(factor: _clima, onTap: _noop)),
    );

    expect(
      tester.getSize(find.byType(TravelFactorTile)).height,
      greaterThanOrEqualTo(AppSizes.minTouchTarget),
    );
  });

  testWidgets('golden: los tres factores del diseño', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TravelFactorTile(
                factor: TravelFactor(kind: TravelFactorKind.traffic, value: 'Moderado'),
                onTap: _noop,
              ),
              SizedBox(height: 16),
              TravelFactorTile(factor: _clima, onTap: _noop),
              SizedBox(height: 16),
              TravelFactorTile(
                factor: TravelFactor(kind: TravelFactorKind.route, value: 'Av. El Poblado'),
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/travel_factor_tiles.png'),
    );
  });
}

void _noop() {}
