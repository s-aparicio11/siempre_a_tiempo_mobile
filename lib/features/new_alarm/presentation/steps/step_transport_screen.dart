import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/domain/transport_mode.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../new_alarm_view_model.dart';
import '../widgets/transport_mode_card.dart';

/// Paso 3: el usuario elige cómo se va a desplazar.
class StepTransportScreen extends StatelessWidget {
  const StepTransportScreen({super.key});

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
          Text('¿Cómo te vas a mover?', style: AppTypography.headlineQuestion),
          const SizedBox(height: AppSpacing.lg),
          for (final TransportMode mode in TransportMode.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TransportModeCard(
                mode: mode,
                selected: vm.draft.transportMode == mode,
                onTap: () => vm.selectTransportMode(mode),
              ),
            ),
        ],
      ),
    );
  }
}
