import 'travel_factor.dart';

/// Hora recomendada de salida para llegar a tiempo a un compromiso.
///
/// La calcula la fuente de datos: la aplicación no estima tiempos de viaje.
class DepartureEstimate {
  const DepartureEstimate({
    required this.leaveAt,
    required this.arriveAt,
    required this.factors,
  });

  final DateTime leaveAt;

  /// Hora del compromiso, a la que el usuario debe llegar.
  final DateTime arriveAt;

  final List<TravelFactor> factors;

  /// Tiempo entre la salida y la llegada.
  ///
  /// Se deriva en lugar de guardarse para que nunca contradiga a las dos
  /// horas de las que sale.
  Duration get margin => arriveAt.difference(leaveAt);
}
