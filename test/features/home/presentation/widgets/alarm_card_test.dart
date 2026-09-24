import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/domain/alarm.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarm_card.dart';

import '../../../../helpers/pump_app.dart';

Alarm _alarma({
  String title = 'Reunión con cliente',
  String location = 'Oficina zona norte',
  TransportMode mode = TransportMode.car,
}) =>
    Alarm(
      id: '1',
      title: title,
      location: location,
      startsAt: DateTime(2026, 8, 20, 8, 30),
      leaveAt: DateTime(2026, 8, 20, 8, 5),
      transportMode: mode,
    );

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra hora, título, lugar y hora de salida', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.text('8:30 AM'), findsOneWidget);
    expect(find.text('Reunión con cliente'), findsOneWidget);
    expect(find.text('Oficina zona norte'), findsOneWidget);
    expect(find.text('Debes salir 8:05 AM'), findsOneWidget);
  });

  testWidgets('muestra el chip de carro', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.text('Carro'), findsOneWidget);
    expect(find.byIcon(LucideIcons.car), findsOneWidget);
  });

  testWidgets('muestra el chip de caminando', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AlarmCard(alarm: _alarma(mode: TransportMode.walking))),
    );

    expect(find.text('Caminando'), findsOneWidget);
    expect(find.byIcon(LucideIcons.footprints), findsOneWidget);
  });

  testWidgets('trunca textos largos sin desbordarse', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: SizedBox(
          width: 280,
          child: AlarmCard(
            alarm: _alarma(
              title: 'Reunión de seguimiento trimestral con el equipo comercial ampliado',
              location: 'Centro empresarial de la zona norte, torre B, piso 14, oficina 1402',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final titulo = tester.widget<Text>(find.textContaining('Reunión de seguimiento'));
    expect(titulo.maxLines, 1);
    expect(titulo.overflow, TextOverflow.ellipsis);
  });

  testWidgets('se ajusta al alto de su contenido', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: Center(child: AlarmCard(alarm: _alarma()))),
    );

    final alto = tester.getSize(find.byType(AlarmCard)).height;
    final altoPantalla = tester.getSize(find.byType(Scaffold)).height;
    expect(alto, lessThan(altoPantalla / 2));
  });

  testWidgets('se anuncia como un solo elemento accesible', (tester) async {
    await pumpApp(tester, Scaffold(body: AlarmCard(alarm: _alarma())));

    expect(find.byType(MergeSemantics), findsOneWidget);
  });

  testWidgets('golden: tarjeta con transporte en carro', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(width: 340, child: AlarmCard(alarm: _alarma())),
        ),
      ),
    );

    await expectLater(
      find.byType(AlarmCard),
      matchesGoldenFile('goldens/alarm_card_car.png'),
    );
  });
}
