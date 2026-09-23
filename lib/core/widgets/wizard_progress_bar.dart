import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Indicador de avance del asistente: un segmento por paso.
class WizardProgressBar extends StatelessWidget {
  const WizardProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// Índice del paso actual, base cero.
  final int currentStep;

  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Paso ${currentStep + 1} de $totalSteps',
      child: Row(
        children: List<Widget>.generate(totalSteps, (int index) {
          final bool completado = index <= currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == totalSteps - 1 ? 0 : AppSpacing.sm,
              ),
              child: AnimatedContainer(
                key: const Key('wizard-progress-segment'),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: AppSizes.progressBarHeight,
                decoration: BoxDecoration(
                  color: completado ? AppColors.primary : AppColors.progressInactive,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
