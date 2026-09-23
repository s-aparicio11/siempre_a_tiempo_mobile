import 'package:flutter/material.dart';

import '../../shell/main_shell.dart';
import '../widgets/coming_soon_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      case AppRoutes.newAlarm:
        // La Tarea 17 reemplaza este placeholder por NewAlarmFlow.
        return MaterialPageRoute<void>(
          builder: (_) => const ComingSoonScreen(section: 'Nueva alarma'),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}
