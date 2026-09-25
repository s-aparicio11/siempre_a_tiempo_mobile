import 'package:flutter/material.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/created_alarm_summary.dart';

/// Resumen de la alarma recién creada en la pantalla de confirmación.
class AlarmSummaryCard extends StatelessWidget {
  const AlarmSummaryCard({super.key, required this.summary});

  final CreatedAlarmSummary summary;

  @override
  Widget build(BuildContext context) {
    final String startsAt =
        '${AppDateFormat.longDate(summary.startsAt)} · ${AppDateFormat.time(summary.startsAt)}';

    return MergeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(summary.title, style: AppTypography.titleCard),
            const SizedBox(height: AppSpacing.sm),
            Text(startsAt, style: AppTypography.bodyDefault),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Debes salir a las ${AppDateFormat.time(summary.leaveAt)}',
              style: AppTypography.bodyEmphasis,
            ),
          ],
        ),
      ),
    );
  }
}
