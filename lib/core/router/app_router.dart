import 'package:flutter/material.dart';

import '../../features/new_alarm/domain/created_alarm_summary.dart';
import '../../features/new_alarm/presentation/alarm_created_screen.dart';
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
      case AppRoutes.alarmCreated:
        final Object? summary = settings.arguments;
        if (summary is! CreatedAlarmSummary) {
          return null;
        }
        return MaterialPageRoute<void>(
          builder: (_) => AlarmCreatedScreen(summary: summary),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
