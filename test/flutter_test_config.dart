import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await loadAppFonts();
  return testMain();
}

/// Carga las fuentes declaradas en el pubspec dentro del entorno de prueba.
Future<void> loadAppFonts() async {
  // `flutter test` ya expone los assets del paquete, así que basta con
  // dejar que google_fonts los resuelva desde `google_fonts/`.
  await Future<void>.delayed(Duration.zero);
}
