import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/format/app_date_format.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../new_alarm_view_model.dart';
import '../widgets/attendee_avatars.dart';
import '../widgets/labeled_field.dart';

/// Paso 2: el usuario registra los datos con los que se calculará
/// su hora de salida.
class StepDetailsScreen extends StatelessWidget {
  const StepDetailsScreen({super.key});

  Future<void> _pickDateTime(
    BuildContext context,
    NewAlarmViewModel vm,
  ) async {
    final DateTime ahora = DateTime.now();
    final DateTime inicial = vm.draft.whenAt ?? ahora;
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final DateTime? fecha = await showDatePicker(
      context: context,
      // Una fecha guardada que ya pasó haría fallar al selector, que no
      // admite una fecha inicial anterior a la primera permitida.
      initialDate: inicial.isBefore(hoy) ? hoy : inicial,
      firstDate: hoy,
      lastDate: DateTime(ahora.year + 5),
      helpText: 'Selecciona la fecha',
    );
    if (fecha == null || !context.mounted) {
      return;
    }

    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      helpText: 'Selecciona la hora',
    );
    if (hora == null) {
      return;
    }

    vm.updateWhenAt(
      DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NewAlarmViewModel vm = context.watch<NewAlarmViewModel>();
    final DateTime? cuando = vm.draft.whenAt;

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
          Text('Detalles de la reunión', style: AppTypography.headlineQuestion),
          const SizedBox(height: AppSpacing.lg),
          LabeledTextField(
            label: 'Título de la reunión',
            value: vm.draft.title,
            hint: 'Escribe un título',
            onChanged: vm.updateTitle,
            onClear: vm.clearTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledTapField(
            label: '¿Cuándo es?',
            value: cuando == null ? null : AppDateFormat.longDateTime(cuando),
            hint: 'Selecciona fecha y hora',
            onTap: () => _pickDateTime(context, vm),
            onClear: vm.clearWhenAt,
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledTextField(
            label: '¿Dónde es?',
            value: vm.draft.location,
            hint: 'Escribe la dirección',
            onChanged: vm.updateLocation,
            onClear: vm.clearLocation,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('¿Quién más asistirá?', style: AppTypography.bodyDefault),
          const SizedBox(height: AppSpacing.sm),
          AttendeeAvatars(attendees: vm.draft.attendees),
        ],
      ),
    );
  }
}
