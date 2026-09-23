import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Botón de acción secundaria: contorno en el color secundario.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        disabledForegroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.secondary, width: 1.5),
        minimumSize: const Size(0, AppSizes.buttonHeight),
        // Relleno contenido para que dos botones quepan lado a lado con la
        // letra ampliada al 150 % en un celular de 360 dp.
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const StadiumBorder(),
        textStyle: AppTypography.labelButton,
      ),
      child: Text(label),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
