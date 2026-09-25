import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/retry_error_state.dart';
import '../../domain/departure_estimate.dart';
import '../../domain/travel_factor.dart';
import '../departure_state.dart';
import '../new_alarm_view_model.dart';
import '../widgets/departure_time_card.dart';
import '../widgets/travel_factor_tile.dart';

/// Paso 4: la hora recomendada de salida y los factores que la explican.
class StepDepartureScreen extends StatelessWidget {
  const StepDepartureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NewAlarmViewModel vm = context.watch<NewAlarmViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hora recomendada para salir', style: AppTypography.headlineQuestion),
          const SizedBox(height: AppSpacing.lg),
          switch (vm.departure) {
            DepartureIdle() || DepartureLoading() => const _Calculating(),
            DepartureReady(:final DepartureEstimate estimate) =>
              _EstimateDetails(estimate: estimate),
            DepartureError(:final String message) =>
              RetryErrorState(message: message, onRetry: vm.loadDeparture),
          },
        ],
      ),
    );
  }
}

class _Calculating extends StatelessWidget {
  const _Calculating();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: <Widget>[
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Calculando tu hora de salida…',
              style: AppTypography.bodyDefault,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimateDetails extends StatelessWidget {
  const _EstimateDetails({required this.estimate});

  final DepartureEstimate estimate;

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: el detalle de este factor está en construcción.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DepartureTimeCard(estimate: estimate),
        const SizedBox(height: AppSpacing.lg),
        Text('FACTORES QUE SE TUVIERON EN CUENTA', style: AppTypography.labelSection),
        const SizedBox(height: AppSpacing.md),
        for (final TravelFactor factor in estimate.factors)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TravelFactorTile(
              factor: factor,
              onTap: () => _showComingSoon(context),
            ),
          ),
      ],
    );
  }
}
