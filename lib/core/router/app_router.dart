import 'package:flutter/material.dart';

import '../../shell/main_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
