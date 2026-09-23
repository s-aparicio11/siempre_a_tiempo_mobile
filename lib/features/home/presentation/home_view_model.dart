import 'package:flutter/foundation.dart';

import '../data/alarm_repository.dart';
import '../domain/alarm.dart';
import 'home_state.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this.repository, {this.userName = 'Cristian'});

  /// Mutable para permitir sustituirlo en pruebas de reintento.
  AlarmRepository repository;

  /// Hoy es un valor fijo: la autenticación está fuera del alcance.
  final String userName;

  HomeState _state = const HomeLoading();
  HomeState get state => _state;

  Future<void> load() async {
    _state = const HomeLoading();
    notifyListeners();

    try {
      final List<Alarm> alarms = List<Alarm>.of(await repository.getTodayAlarms())
        ..sort((Alarm a, Alarm b) => a.startsAt.compareTo(b.startsAt));

      _state = alarms.isEmpty ? const HomeEmpty() : HomeLoaded(alarms);
    } on Exception {
      _state = const HomeError('No pudimos cargar tus alarmas.');
    }

    notifyListeners();
  }
}
