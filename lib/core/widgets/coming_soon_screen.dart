import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Pantalla para las secciones que están fuera del alcance actual.
///
/// Evita que un control visible del diseño lleve a una pantalla rota
/// durante una demostración.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.section});

  /// Nombre de la sección, tal como aparece en la barra inferior.
  final String section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                LucideIcons.construction,
                size: 48,
                color: AppColors.textSecondary,
                semanticLabel: 'Sección en construcción',
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Próximamente', style: AppTypography.headlineQuestion),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Esta sección todavía está en construcción.',
                style: AppTypography.bodyDefault,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
