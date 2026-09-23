import 'package:flutter/material.dart';

/// Tokens de color de Siempre a Tiempo.
///
/// Extraídos del Style Tile del proyecto en Figma:
/// https://www.figma.com/design/Z8oSiR3n6bGlEfoxApbGiV/UX---Siempre-a-Tiempo
/// (página "Style Tiles", tarjeta "PALETA DE COLORES").
///
/// Las rampas son la fuente de verdad. Los alias semánticos de más abajo
/// son los que consumen las pantallas: si el diseño cambia de opinión sobre
/// qué tono usar para una función, se cambia el alias y no cada widget.
abstract final class AppColors {
  // --- Rampa azul · información / confianza ---
  static const Color blue900 = Color(0xFF1A3A6B);
  static const Color blue700 = Color(0xFF2456A0);
  static const Color blue500 = Color(0xFF2E6BE6);
  static const Color blue300 = Color(0xFF6B9BF0);
  static const Color blue200 = Color(0xFFB8D0F7);
  static const Color blue100 = Color(0xFFE8F0FE);

  // --- Rampa roja · acción "salir ahora" ---
  static const Color red900 = Color(0xFF8A2A22);
  static const Color red700 = Color(0xFFC0392B);
  static const Color red500 = Color(0xFFE8503A);
  static const Color red300 = Color(0xFFF08370);
  static const Color red200 = Color(0xFFF7B8AD);
  static const Color red100 = Color(0xFFFCE9E4);

  // --- Rampa ámbar · destacados / horas ---
  static const Color amber900 = Color(0xFF8A6D1A);
  static const Color amber700 = Color(0xFFC79417);
  static const Color amber500 = Color(0xFFF0A81E);
  static const Color amber300 = Color(0xFFF5C55A);
  static const Color amber200 = Color(0xFFFADE9A);
  static const Color amber100 = Color(0xFFFCEFD0);

  // --- Rampa verde · confirmación ---
  static const Color green900 = Color(0xFF1E6B42);
  static const Color green700 = Color(0xFF2E8B57);
  static const Color green500 = Color(0xFF7BC59A);
  static const Color green100 = Color(0xFFE9F7EF);

  // --- Neutros ---
  static const Color neutral900 = Color(0xFF1B2A4A);
  static const Color neutral700 = Color(0xFF5A6472);
  static const Color neutral500 = Color(0xFFB0B8C4);
  static const Color neutral300 = Color(0xFFD5DCE6);
  static const Color neutral100 = Color(0xFFF2F5FA);
  static const Color white = Color(0xFFFFFFFF);

  // --- Alias semánticos: lo que usan las pantallas ---

  /// Acción principal y urgencia: botón primario, hora de salida, pestaña activa.
  static const Color primary = red700;

  /// Estado presionado del botón primario.
  static const Color primaryPressed = red900;

  static const Color onPrimary = white;

  /// Acción secundaria, enlaces y foco de campo.
  static const Color secondary = blue700;

  /// Fondo del botón secundario presionado.
  static const Color secondaryMuted = blue100;

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;

  /// Hora de inicio de una alarma.
  ///
  /// El Style Tile muestra el ámbar brillante (`amber500`) en el Display de
  /// 48 pt, pero sobre blanco ese tono da 2.0:1 de contraste y no alcanza ni
  /// el mínimo de 3:1 de texto grande. Para texto se usa `amber900`, que da
  /// 4.9:1; los ámbares claros quedan para rellenos y chips.
  static const Color accentTime = amber900;

  /// Confirmación: interruptor activo y chip "Llegaste a tiempo".
  static const Color success = green700;

  /// Texto sobre fondos de confirmación.
  static const Color onSuccessSurface = green900;

  /// Error de validación en un campo.
  static const Color error = red700;

  static const Color background = neutral100;
  static const Color surface = white;

  /// Relleno de campos y chips neutros.
  static const Color surfaceMuted = neutral100;

  static const Color border = neutral300;

  /// Segmentos pendientes del indicador de progreso del asistente.
  static const Color progressInactive = neutral300;

  /// Fondos de los avatares de asistentes.
  ///
  /// Son los tonos más claros de las cuatro rampas cromáticas del Style Tile.
  /// `Attendee.avatarColorIndex` indexa esta lista con módulo, de forma que el
  /// dominio no necesita conocer la clase `Color` de Flutter.
  static const List<Color> avatarPalette = <Color>[
    blue100,
    amber100,
    green100,
    red100,
  ];

  static Color avatarAt(int index) =>
      avatarPalette[index.abs() % avatarPalette.length];
}
