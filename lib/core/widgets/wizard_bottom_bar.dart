import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Barra fija con las dos acciones de navegación del asistente.
///
/// `onTrailing: null` deja deshabilitada la acción principal, que es como se
/// bloquea el avance mientras falten datos.
class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({
    super.key,
    required this.leadingLabel,
    required this.onLeading,
    required this.trailingLabel,
    required this.onTrailing,
  });

  final String leadingLabel;
  final VoidCallback onLeading;
  final String trailingLabel;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(
                  label: leadingLabel,
                  onPressed: onLeading,
                  expanded: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: trailingLabel,
                  onPressed: onTrailing,
                  expanded: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
