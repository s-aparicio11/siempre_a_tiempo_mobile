import '../../../core/domain/transport_mode.dart';
import '../domain/departure_estimate.dart';
import '../domain/travel_factor.dart';
import 'departure_estimate_repository.dart';

/// Implementación en memoria con los datos del diseño aprobado.
///
/// Resta a la hora de llegada un tiempo de viaje fijo por medio de
/// transporte; los factores son constantes. `delay` simula la latencia del
/// cálculo para que el estado de carga sea visible, y `shouldFail` permite
/// forzar el estado de error.
class MockDepartureEstimateRepository implements DepartureEstimateRepository {
  MockDepartureEstimateRepository({
    this.delay = const Duration(milliseconds: 800),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  /// Tiempo de viaje simulado. El de carro es el del mockup: 40 minutos.
  static const Map<TransportMode, Duration> travelTimes = <TransportMode, Duration>{
    TransportMode.car: Duration(minutes: 40),
    TransportMode.publicTransport: Duration(minutes: 55),
    TransportMode.motorcycle: Duration(minutes: 30),
    TransportMode.bicycle: Duration(minutes: 45),
    TransportMode.walking: Duration(minutes: 70),
  };

  @override
  Future<DepartureEstimate> estimate({
    required DateTime arriveAt,
    required String destination,
    required TransportMode mode,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw Exception('No se pudo calcular la hora de salida');
    }
    return DepartureEstimate(
      leaveAt: arriveAt.subtract(travelTimes[mode]!),
      arriveAt: arriveAt,
      factors: const <TravelFactor>[
        TravelFactor(kind: TravelFactorKind.traffic, value: 'Moderado'),
        TravelFactor(kind: TravelFactorKind.weather, value: 'Lluvia ligera'),
        TravelFactor(kind: TravelFactorKind.route, value: 'Av. El Poblado'),
      ],
    );
  }
}
