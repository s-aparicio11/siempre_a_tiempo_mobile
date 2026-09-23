/// Escala de espaciado con base 8.
///
/// El Style Tile de Figma no declara una escala de espaciado, así que la
/// escala es una convención del proyecto. Lo que sí sale medido del Style
/// Tile son las dimensiones de componente de `AppSizes`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Margen horizontal estándar de pantalla.
  static const double screenH = 20;

  /// Relleno interior de las tarjetas del Style Tile.
  static const double cardPadding = 16;
}

/// Radios de esquina.
abstract final class AppRadius {
  static const double card = 12;
  static const double field = 10;
  static const double chip = 16;

  /// Forma de píldora para botones y botón flotante.
  static const double pill = 999;
}

/// Alturas de componente medidas sobre el Style Tile.
abstract final class AppSizes {
  /// Botones primario, secundario y terciario.
  static const double buttonHeight = 48;

  /// Campo de texto con etiqueta flotante.
  static const double fieldHeight = 56;

  /// Chip de estado.
  static const double chipHeight = 25;

  /// Grosor de los segmentos del indicador de progreso.
  static const double progressBarHeight = 6;

  /// Área tocable mínima exigida por la revisión de accesibilidad.
  static const double minTouchTarget = 48;
}
