import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/features/new_alarm/data/mock_departure_estimate_repository.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/travel_factor.dart';

void main() {
  final llegada = DateTime(2026, 8, 20, 15);

  test('en carro devuelve la hora del diseño: 2:20 PM para llegar 3:00 PM', () async {
    final repositorio = MockDepartureEstimateRepository(delay: Duration.zero);

    final estimacion = await repositorio.estimate(
      arriveAt: llegada,
      destination: 'Avenida El Poblado #1-25',
      mode: TransportMode.car,
    );

    expect(estimacion.leaveAt, DateTime(2026, 8, 20, 14, 20));
    expect(estimacion.arriveAt, llegada);
    expect(estimacion.margin, const Duration(minutes: 40));
  });

  test('cada medio sale antes de la llegada', () async {
    final repositorio = MockDepartureEstimateRepository(delay: Duration.zero);

    for (final TransportMode mode in TransportMode.values) {
      final estimacion = await repositorio.estimate(
        arriveAt: llegada,
        destination: 'Avenida El Poblado #1-25',
        mode: mode,
      );

      expect(estimacion.leaveAt.isBefore(llegada), isTrue, reason: mode.name);
    }
  });

  test('el medio cambia la hora de salida', () async {
    final repositorio = MockDepartureEstimateRepository(delay: Duration.zero);

    final carro = await repositorio.estimate(
      arriveAt: llegada,
      destination: 'Avenida El Poblado #1-25',
      mode: TransportMode.car,
    );
    final caminando = await repositorio.estimate(
      arriveAt: llegada,
      destination: 'Avenida El Poblado #1-25',
      mode: TransportMode.walking,
    );

    expect(caminando.leaveAt.isBefore(carro.leaveAt), isTrue);
  });

  test('devuelve los tres factores del diseño en orden', () async {
    final repositorio = MockDepartureEstimateRepository(delay: Duration.zero);

    final estimacion = await repositorio.estimate(
      arriveAt: llegada,
      destination: 'Avenida El Poblado #1-25',
      mode: TransportMode.car,
    );

    expect(
      estimacion.factors.map((TravelFactor f) => f.kind),
      <TravelFactorKind>[
        TravelFactorKind.traffic,
        TravelFactorKind.weather,
        TravelFactorKind.route,
      ],
    );
    expect(estimacion.factors.first.value, 'Moderado');
  });

  test('puede simular una falla', () async {
    final repositorio =
        MockDepartureEstimateRepository(delay: Duration.zero, shouldFail: true);

    expect(
      repositorio.estimate(
        arriveAt: llegada,
        destination: 'Avenida El Poblado #1-25',
        mode: TransportMode.car,
      ),
      throwsA(isA<Exception>()),
    );
  });
}
