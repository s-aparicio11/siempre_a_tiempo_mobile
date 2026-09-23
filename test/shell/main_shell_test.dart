import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/shell/main_shell.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initTestFormatting);

  testWidgets('muestra las tres pestañas con Inicio seleccionada', (tester) async {
    await pumpApp(tester, const MainShell());

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    final barra = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(barra.currentIndex, 0);

    // Inicio arranca la carga simulada de sus alarmas; se deja terminar para
    // que la prueba no cierre con ese temporizador pendiente.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('al tocar Mapa muestra el placeholder de esa sección', (tester) async {
    await pumpApp(tester, const MainShell());

    await tester.tap(find.text('Mapa'));
    await tester.pumpAndSettle();

    expect(find.text('Mapa'), findsNWidgets(2)); // pestaña + título del placeholder
    expect(find.text('Próximamente'), findsOneWidget);

    final barra = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(barra.currentIndex, 1);
  });

  testWidgets('al tocar Perfil muestra el placeholder de esa sección', (tester) async {
    await pumpApp(tester, const MainShell());

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Próximamente'), findsOneWidget);
  });
}
