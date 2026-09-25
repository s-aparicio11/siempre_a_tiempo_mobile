import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/created_alarm_summary.dart';
import 'widgets/alarm_summary_card.dart';

/// Confirmación de que la alarma quedó creada.
///
/// Reemplaza al asistente en la pila de navegación, así que cerrarla, con
/// "Entendido" o con el retroceso del sistema, regresa a Inicio.
class AlarmCreatedScreen extends StatelessWidget {
  const AlarmCreatedScreen({super.key, required this.summary});

  final CreatedAlarmSummary summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.xl,
            AppSpacing.screenH,
            AppSpacing.lg,
          ),
          child: Column(
            children: <Widget>[
              const _SuccessBadge(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '¡Listo! Tu alarma ha sido creada',
                style: AppTypography.headlineQuestion,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Te avisaremos cuando sea momento de salir.',
                style: AppTypography.bodyDefault,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AlarmSummaryCard(summary: summary),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              label: 'Entendido',
              onPressed: () => Navigator.of(context).pop(),
              expanded: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// Círculo verde con la marca de verificación. Es decorativo: el título ya
/// anuncia que la alarma se creó.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          color: AppColors.successSurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.check, size: 40, color: AppColors.success),
      ),
    );
  }
}
