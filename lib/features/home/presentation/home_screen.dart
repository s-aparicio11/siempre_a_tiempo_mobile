import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const IconButton(
          icon: Icon(LucideIcons.menu),
          tooltip: 'Abrir menú',
          // El menú lateral está fuera del alcance actual.
          onPressed: null,
        ),
        title: const Text('Siempre a Tiempo'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.screenH),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(LucideIcons.user, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
