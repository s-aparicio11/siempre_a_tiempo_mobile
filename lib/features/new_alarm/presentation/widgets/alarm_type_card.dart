import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm_type.dart';

/// Opción seleccionable del primer paso del asistente.
class AlarmTypeCard extends StatelessWidget {
  const AlarmTypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AlarmType type;
  final bool selected;
  final VoidCallback onTap;

  /// El ícono vive aquí y no en el enum: `IconData` es de Flutter y el
  /// dominio no depende de Flutter.
  IconData get _icon => switch (type) {
        AlarmType.meeting => LucideIcons.briefcase,
        AlarmType.personalReminder => LucideIcons.bell,
        AlarmType.recurringEvent => LucideIcons.repeat,
      };

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    ),
                    child: Icon(
                      _icon,
                      size: 22,
                      color: selected ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(type.title, style: AppTypography.titleCard),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(type.description, style: AppTypography.bodyDefault),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    selected ? LucideIcons.circleCheck : LucideIcons.chevronRight,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
