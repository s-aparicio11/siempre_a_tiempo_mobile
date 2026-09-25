import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_empty_state.dart';
import 'package:siempre_a_tiempo/core/widgets/retry_error_state.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/alarms_skeleton.dart';
import 'package:siempre_a_tiempo/features/home/presentation/widgets/greeting_header.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  group('GreetingHeader', () {
    testWidgets('saluda al usuario y anuncia el conteo en plural', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 3)),
      );

      expect(find.text('¡Hola, Cristian!'), findsOneWidget);
      expect(find.text('Tienes 3 alarmas para hoy'), findsOneWidget);
    });

    testWidgets('usa el singular cuando hay una sola alarma', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 1)),
      );

      expect(find.text('Tienes 1 alarma para hoy'), findsOneWidget);
    });

    testWidgets('anuncia que no hay alarmas cuando el conteo es cero', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: GreetingHeader(userName: 'Cristian', alarmCount: 0)),
      );

      expect(find.text('No tienes alarmas para hoy'), findsOneWidget);
    });
  });

  group('AlarmsSkeleton', () {
    testWidgets('dibuja tres bloques de carga', (tester) async {
      await pumpApp(tester, const Scaffold(body: AlarmsSkeleton()));

      expect(find.byKey(const Key('alarm-skeleton-item')), findsNWidgets(3));
    });
  });

  group('AlarmsEmptyState', () {
    testWidgets('explica que no hay alarmas', (tester) async {
      await pumpApp(tester, const Scaffold(body: AlarmsEmptyState()));

      expect(find.text('No tienes alarmas para hoy'), findsOneWidget);
    });
  });

  group('RetryErrorState', () {
    testWidgets('muestra el mensaje y reintenta al tocar el botón', (tester) async {
      var reintentos = 0;
      await pumpApp(
        tester,
        Scaffold(
          body: RetryErrorState(
            message: 'No pudimos cargar tus alarmas.',
            onRetry: () => reintentos++,
          ),
        ),
      );

      expect(find.text('No pudimos cargar tus alarmas.'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      expect(reintentos, 1);
    });
  });
}
