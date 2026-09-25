import 'package:flutter/material.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/departure_estimate.dart';

/// Tarjeta destacada con la hora recomendada de salida.
class DepartureTimeCard extends StatelessWidget {
  const DepartureTimeCard({super.key, required this.estimate});

  final DepartureEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final String leaveAt = AppDateFormat.time(estimate.leaveAt);
    final String arriveAt = AppDateFormat.time(estimate.arriveAt);
    final int minutes = estimate.margin.inMinutes;

    // Una sola frase para el lector de pantalla: leídos por separado, el
    // "·" y la abreviatura "min" no se entienden.
    return Semantics(
      container: true,
      label: 'Debes salir a las $leaveAt para llegar a las $arriveAt, '
          'con $minutes minutos de margen',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.highlightSurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Debes salir a las', style: AppTypography.bodyDefault),
              const SizedBox(height: AppSpacing.xs),
              // Con letra ampliada la hora podría no caber: se reduce en lugar
              // de partirse en dos líneas.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(leaveAt, style: AppTypography.display),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Para llegar a las $arriveAt · $minutes min de margen',
                style: AppTypography.bodyDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
