import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/attendee.dart';

/// Fila de avatares de los invitados, con un contador para los que no caben.
///
/// Es de solo lectura: agregar o quitar invitados está fuera del alcance actual.
class AttendeeAvatars extends StatelessWidget {
  const AttendeeAvatars({
    super.key,
    required this.attendees,
    this.maxVisible = 4,
  });

  final List<Attendee> attendees;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Attendee> visibles = attendees.take(maxVisible).toList();
    final int excedentes = attendees.length - visibles.length;

    return Semantics(
      label: '${attendees.length} asistentes',
      // Las iniciales sueltas no le dicen nada a quien usa lector de pantalla;
      // basta con anunciar cuántos asistentes hay.
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          for (final Attendee asistente in visibles)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.avatarAt(asistente.avatarColorIndex),
                child: Text(
                  asistente.initials,
                  style: AppTypography.bodyDefault.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (excedentes > 0)
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Text(
                '+$excedentes',
                style: AppTypography.bodyDefault.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
