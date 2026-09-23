import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Esqueleto que ocupa el lugar de las tarjetas mientras cargan,
/// para que la pantalla no aparezca en blanco.
class AlarmsSkeleton extends StatelessWidget {
  const AlarmsSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando tus alarmas',
      child: Column(
        children: List<Widget>.generate(
          itemCount,
          (int index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            // La clave va en el bloque y no en el Padding: los hijos directos
            // de la Column son hermanos y no pueden repetir clave.
            child: Container(
              key: const Key('alarm-skeleton-item'),
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
