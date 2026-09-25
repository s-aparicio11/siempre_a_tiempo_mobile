import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/travel_factor.dart';
import 'option_icon_badge.dart';

/// Fila de un factor considerado en la estimación de salida.
class TravelFactorTile extends StatelessWidget {
  const TravelFactorTile({
    super.key,
    required this.factor,
    required this.onTap,
  });

  final TravelFactor factor;
  final VoidCallback onTap;

  /// El ícono vive aquí y no en el enum: `IconData` es de Flutter y el
  /// dominio no depende de Flutter.
  IconData get _icon => switch (factor.kind) {
        TravelFactorKind.traffic => LucideIcons.car,
        TravelFactorKind.weather => LucideIcons.cloud,
        TravelFactorKind.route => LucideIcons.route,
      };

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: AppColors.surface,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: <Widget>[
                  OptionIconBadge(icon: _icon),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(factor.kind.label, style: AppTypography.titleCard),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      factor.value,
                      style: AppTypography.bodyDefault,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: AppColors.textSecondary,
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
