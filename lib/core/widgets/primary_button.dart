import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Botón de acción principal: relleno en el color primario.
///
/// Pasar `onPressed: null` lo deja deshabilitado.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Si es `true`, ocupa todo el ancho disponible.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.progressInactive,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, AppSizes.buttonHeight),
        // Relleno contenido para que dos botones quepan lado a lado con la
        // letra ampliada al 150 % en un celular de 360 dp.
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const StadiumBorder(),
        textStyle: AppTypography.labelButton,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
