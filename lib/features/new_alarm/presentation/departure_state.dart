import '../domain/departure_estimate.dart';

/// Estados del cálculo de la hora de salida en el paso 4.
///
/// Es una jerarquía sellada para que la pantalla tenga que resolver todos
/// los casos y ninguno quede sin dibujar.
sealed class DepartureState {
  const DepartureState();
}

/// Todavía no se ha pedido la estimación: el usuario no llega al paso 4.
class DepartureIdle extends DepartureState {
  const DepartureIdle();
}

class DepartureLoading extends DepartureState {
  const DepartureLoading();
}

class DepartureReady extends DepartureState {
  const DepartureReady(this.estimate);

  final DepartureEstimate estimate;
}

class DepartureError extends DepartureState {
  const DepartureError(this.message);

  final String message;
}
