import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Saludo y resumen del día.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.alarmCount,
  });

  final String userName;
  final int alarmCount;

  String get _summary => switch (alarmCount) {
        0 => 'No tienes alarmas para hoy',
        1 => 'Tienes 1 alarma para hoy',
        _ => 'Tienes $alarmCount alarmas para hoy',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('¡Hola, $userName!', style: AppTypography.displayGreeting),
        const SizedBox(height: AppSpacing.xs),
        Text(_summary, style: AppTypography.bodyDefault),
      ],
    );
  }
}
