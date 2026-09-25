import '../../../core/domain/transport_mode.dart';
import '../domain/departure_estimate.dart';

/// Fuente de la hora recomendada de salida.
///
/// Hoy solo existe una implementación simulada. Cuando exista el backend de
/// Siempre a Tiempo, que considera tráfico, clima y rutas, se agrega una
/// implementación que lo consuma sin que ninguna pantalla tenga que cambiar.
abstract interface class DepartureEstimateRepository {
  /// Estima a qué hora salir para llegar a [destination] a las [arriveAt]
  /// usando [mode]. Puede lanzar si el cálculo falla.
  Future<DepartureEstimate> estimate({
    required DateTime arriveAt,
    required String destination,
    required TransportMode mode,
  });
}
