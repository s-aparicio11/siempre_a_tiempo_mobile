import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/alarm_type.dart';
import '../new_alarm_view_model.dart';
import '../widgets/alarm_type_card.dart';

/// Paso 1: el usuario elige qué tipo de alarma quiere crear.
class StepTypeScreen extends StatelessWidget {
  const StepTypeScreen({super.key});

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
          Text(
            '¿Qué tipo de alarma quieres crear?',
            style: AppTypography.headlineQuestion,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final AlarmType type in AlarmType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AlarmTypeCard(
                type: type,
                selected: vm.draft.type == type,
                onTap: () => vm.selectType(type),
              ),
            ),
        ],
      ),
    );
  }
}
