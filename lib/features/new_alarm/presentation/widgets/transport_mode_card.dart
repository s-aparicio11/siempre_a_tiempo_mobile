import 'package:flutter/material.dart';

import '../../../../core/domain/transport_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/transport_mode_icon.dart';

/// Opción seleccionable del paso de transporte del asistente.
///
/// Se comporta como un radio: la descripción solo aparece en la opción
/// seleccionada, para que la lista se lea de un vistazo.
class TransportModeCard extends StatelessWidget {
  const TransportModeCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final TransportMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.card);

    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        child: Material(
          color: selected ? AppColors.selectedSurface : AppColors.surface,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  _IconBadge(mode: mode, selected: selected),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(mode.label, style: AppTypography.titleCard),
                        if (selected) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs / 2),
                          Text(mode.description, style: AppTypography.bodyDefault),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RadioIndicator(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Recuadro vertical con el ícono del medio.
///
/// En la opción seleccionada pasa a blanco, porque el azul claro se perdería
/// contra el fondo rosado de la tarjeta.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.mode, required this.selected});

  final TransportMode mode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : AppColors.iconBadge,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Icon(
        mode.icon,
        size: 20,
        color: selected ? AppColors.primary : AppColors.secondary,
      ),
    );
  }
}

/// Radio dibujado a mano: el `Radio` de Material trae su propia área táctil
/// y competiría con la de la tarjeta, que es la que debe recibir el toque.
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.radioInactive,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}
