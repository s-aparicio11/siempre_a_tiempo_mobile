import 'package:flutter/material.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm.dart';
import 'transport_chip.dart';

/// Tarjeta de una alarma: cuándo empieza el compromiso y, sobre todo,
/// a qué hora hay que salir.
class AlarmCard extends StatelessWidget {
  const AlarmCard({super.key, required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppDateFormat.time(alarm.startsAt), style: AppTypography.titleTime),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alarm.title,
              style: AppTypography.titleCard,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alarm.location,
              style: AppTypography.bodyDefault,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Debes salir ${AppDateFormat.time(alarm.leaveAt)}',
                    style: AppTypography.bodyEmphasis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TransportChip(mode: alarm.transportMode),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
