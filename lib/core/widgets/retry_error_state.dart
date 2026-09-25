import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'secondary_button.dart';

/// Mensaje de error con la opción de reintentar.
///
/// Lo comparten Inicio y el paso de hora de salida del asistente.
class RetryErrorState extends StatelessWidget {
  const RetryErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          const Icon(
            LucideIcons.cloudOff,
            size: 48,
            color: AppColors.textSecondary,
            semanticLabel: 'Sin conexión con el servicio',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.titleCard,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(label: 'Reintentar', onPressed: onRetry),
        ],
      ),
    );
  }
}
