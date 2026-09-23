import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/transport_mode.dart';

/// Indicador del medio de transporte de una alarma.
class TransportChip extends StatelessWidget {
  const TransportChip({super.key, required this.mode});

  final TransportMode mode;

  IconData get _icon => switch (mode) {
        TransportMode.car => LucideIcons.car,
        TransportMode.walking => LucideIcons.footprints,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.sm - AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            mode.label,
            style: AppTypography.bodyDefault.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
