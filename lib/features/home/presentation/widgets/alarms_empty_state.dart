import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AlarmsEmptyState extends StatelessWidget {
  const AlarmsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          const Icon(
            LucideIcons.calendarCheck,
            size: 48,
            color: AppColors.textSecondary,
            semanticLabel: 'Agenda vacía',
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No tienes alarmas para hoy', style: AppTypography.titleCard),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Crea una nueva alarma y te avisamos a qué hora salir.',
            style: AppTypography.bodyDefault,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
