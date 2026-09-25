/// Aspectos del trayecto que la estimación de salida tuvo en cuenta.
enum TravelFactorKind {
  traffic('Tráfico actual'),
  weather('Clima'),
  route('Ruta sugerida');

  const TravelFactorKind(this.label);

  /// Nombre visible del factor.
  final String label;
}

/// Un factor considerado junto con su valor: "Clima · Lluvia ligera".
class TravelFactor {
  const TravelFactor({required this.kind, required this.value});

  final TravelFactorKind kind;

  /// Resumen del factor tal como lo reporta la fuente de datos.
  final String value;
}
