import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipográfica de Siempre a Tiempo.
///
/// Extraída del Style Tile en Figma (tarjeta "JERARQUÍA DE TEXTOS").
/// La familia es **Inter**, en los pesos Regular, Medium, SemiBold y Bold.
///
/// El Style Tile define seis niveles. La tabla indica a qué token de este
/// archivo corresponde cada uno:
///
/// | Style Tile                       | Token aquí          |
/// |----------------------------------|---------------------|
/// | Display · 48 Bold · ámbar        | `display`           |
/// | Título 1 · 28 Bold               | `displayGreeting`, `headlineQuestion` |
/// | Título 2 · 20 SemiBold           | `titleTime`         |
/// | Subtítulo · 17 SemiBold          | `titleCard`         |
/// | Destacado · 16 Bold · rojo       | `bodyEmphasis`      |
/// | Etiqueta · 13 Regular            | `bodyDefault`, `labelField` |
///
/// `labelSection` y `labelButton` no están en la jerarquía del Style Tile:
/// son derivados de Etiqueta y Subtítulo para el encabezado de sección y el
/// texto de los botones. Están marcados como tales.
///
/// Los estilos son getters y no constantes porque `GoogleFonts.inter` los
/// construye en tiempo de ejecución. Por eso los widgets que los usan no
/// pueden ser `const`.
abstract final class AppTypography {
  /// Display · 48 pt Bold · ámbar. Hora grande de una alarma a pantalla completa.
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.accentTime,
        height: 1.1,
      );

  /// Título 1 · 28 pt Bold. Saludo de la pantalla de Inicio.
  static TextStyle get displayGreeting => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  /// Título 1 · 28 pt Bold. Pregunta que encabeza cada paso del asistente.
  static TextStyle get headlineQuestion => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  /// Título 2 · 20 pt SemiBold · ámbar. Hora de inicio en la tarjeta de alarma.
  static TextStyle get titleTime => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.accentTime,
        height: 1.2,
      );

  /// Subtítulo · 17 pt SemiBold. Título de una alarma o de un tipo de alarma.
  ///
  /// El Style Tile lo muestra en azul; en la tarjeta de alarma va en azul
  /// marino. El azul se obtiene con
  /// `AppTypography.titleCard.copyWith(color: AppColors.secondary)`.
  static TextStyle get titleCard => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  /// Etiqueta · 13 pt Regular. Ubicación y descripciones.
  static TextStyle get bodyDefault => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// Destacado · 16 pt Bold · rojo. "Debes salir 8:05 AM".
  static TextStyle get bodyEmphasis => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.25,
      );

  /// Derivado de Etiqueta: encabezado de sección en versalitas.
  /// "PRÓXIMAS ALARMAS".
  static TextStyle get labelSection => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      );

  /// Derivado de Subtítulo: texto de los botones.
  static TextStyle get labelButton => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  /// Etiqueta · 13 pt Regular. Etiqueta flotante de un campo de texto.
  static TextStyle get labelField => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary,
      );
}
