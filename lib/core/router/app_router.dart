import 'package:flutter/material.dart';

import '../../features/new_alarm/presentation/new_alarm_flow.dart';
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
      case AppRoutes.newAlarm:
        return MaterialPageRoute<void>(
          builder: (_) => const NewAlarmFlow(),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return null;
    }
  }
}
