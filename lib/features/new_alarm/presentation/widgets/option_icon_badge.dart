import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Recuadro vertical con el ícono de una opción o de un factor.
///
/// Resaltado pasa a blanco con ícono rojo, porque el azul claro se perdería
/// contra el fondo rosado de una opción seleccionada.
class OptionIconBadge extends StatelessWidget {
  const OptionIconBadge({
    super.key,
    required this.icon,
    this.highlighted = false,
  });

  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 44,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.surface : AppColors.iconBadge,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Icon(
        icon,
        size: 20,
        color: highlighted ? AppColors.primary : AppColors.secondary,
      ),
    );
  }
}
