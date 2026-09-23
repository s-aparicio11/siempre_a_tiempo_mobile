import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:siempre_a_tiempo/core/theme/app_theme.dart';

/// Prepara el entorno de pruebas: formato en español y tipografía local.
/// Llámalo una vez por archivo de prueba, dentro de `setUpAll`.
Future<void> initTestFormatting() async {
  // Sin esto, google_fonts intenta descargar Inter por red durante las
  // pruebas y los goldens se rendirían con otra fuente.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('es');
}

/// Monta [child] dentro de un `MaterialApp` con el tema y la localización
/// reales de la aplicación.
///
/// [providers] permite inyectar ViewModels; si va vacío no se envuelve en
/// `MultiProvider`.
/// [textScale] permite verificar el comportamiento con letra ampliada.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget> providers = const [],
  double textScale = 1.0,
}) async {
  Widget app = MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('es'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('es')],
    builder: (BuildContext context, Widget? widget) => MediaQuery.withClampedTextScaling(
      minScaleFactor: textScale,
      maxScaleFactor: textScale,
      child: widget!,
    ),
    home: child,
  );

  if (providers.isNotEmpty) {
    app = MultiProvider(providers: providers, child: app);
  }

  await tester.pumpWidget(app);
}
