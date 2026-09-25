import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/departure_estimate.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/travel_factor.dart';

void main() {
  test('el margen es el tiempo entre la salida y la llegada', () {
    final estimacion = DepartureEstimate(
      leaveAt: DateTime(2026, 8, 20, 14, 20),
      arriveAt: DateTime(2026, 8, 20, 15),
      factors: const <TravelFactor>[],
    );

    expect(estimacion.margin, const Duration(minutes: 40));
  });

  test('cada tipo de factor trae el texto del diseño', () {
    expect(TravelFactorKind.traffic.label, 'Tráfico actual');
    expect(TravelFactorKind.weather.label, 'Clima');
    expect(TravelFactorKind.route.label, 'Ruta sugerida');
  });
}
