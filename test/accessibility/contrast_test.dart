import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/theme/app_colors.dart';

/// Razón de contraste WCAG 2.1 entre dos colores opacos.
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double claro = math.max(la, lb);
  final double oscuro = math.min(la, lb);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  group('texto normal sobre su fondo: mínimo 4.5:1', () {
    test('texto principal sobre el fondo de pantalla', () {
      expect(_contrast(AppColors.textPrimary, AppColors.background),
          greaterThanOrEqualTo(4.5));
    });

    test('texto principal sobre superficie', () {
      expect(_contrast(AppColors.textPrimary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre el fondo de pantalla', () {
      expect(_contrast(AppColors.textSecondary, AppColors.background),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre superficie', () {
      expect(_contrast(AppColors.textSecondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto secundario sobre el fondo de los campos y chips', () {
      expect(_contrast(AppColors.textSecondary, AppColors.surfaceMuted),
          greaterThanOrEqualTo(4.5));
    });

    test('hora de salida en rojo sobre superficie', () {
      expect(_contrast(AppColors.primary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('texto sobre el botón primario', () {
      expect(_contrast(AppColors.onPrimary, AppColors.primary),
          greaterThanOrEqualTo(4.5));
    });

    test('etiqueta del botón secundario sobre superficie', () {
      expect(_contrast(AppColors.secondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });
  });

  group('texto grande: mínimo 3:1', () {
    test('hora de inicio en oliva sobre superficie', () {
      expect(_contrast(AppColors.accentTime, AppColors.surface),
          greaterThanOrEqualTo(3.0));
    });
  });
}
