import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await loadAppFonts();
  return testMain();
}

/// Carga las fuentes declaradas en el pubspec dentro del entorno de prueba.
///
/// Inter la resuelve google_fonts desde `google_fonts/`. Las fuentes de
/// íconos no: `flutter test` no las registra por sí solo y los goldens
/// mostrarían cada ícono como un cuadro vacío.
Future<void> loadAppFonts() async {
  final FontLoader lucide = FontLoader('packages/lucide_icons_flutter/Lucide')
    ..addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
  await lucide.load();
}
