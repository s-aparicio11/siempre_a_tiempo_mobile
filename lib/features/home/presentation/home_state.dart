import '../domain/alarm.dart';

/// Estados posibles de la pantalla de Inicio.
///
/// Es una jerarquía sellada para que la pantalla tenga que resolver los
/// cuatro casos y ninguno quede sin dibujar.
sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.alarms);

  final List<Alarm> alarms;
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}
