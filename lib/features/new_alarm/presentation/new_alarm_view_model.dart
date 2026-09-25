import 'package:flutter/foundation.dart';

import '../../../core/domain/transport_mode.dart';
import '../data/departure_estimate_repository.dart';
import '../data/mock_departure_estimate_repository.dart';
import '../domain/alarm_draft.dart';
import '../domain/alarm_type.dart';
import '../domain/attendee.dart';
import '../domain/created_alarm_summary.dart';
import '../domain/departure_estimate.dart';
import 'departure_state.dart';

/// Estado del asistente de creación de alarmas.
class NewAlarmViewModel extends ChangeNotifier {
  NewAlarmViewModel({
    List<Attendee>? attendees,
    DepartureEstimateRepository? departureRepository,
  })  : _draft = AlarmDraft(attendees: attendees ?? _sampleAttendees),
        _departureRepository =
            departureRepository ?? MockDepartureEstimateRepository();

  final DepartureEstimateRepository _departureRepository;

  /// Pasos que muestra el indicador de progreso del diseño.
  static const int totalSteps = 4;

  /// Paso que muestra la hora recomendada de salida.
  static const int departureStep = 3;

  AlarmDraft _draft;
  AlarmDraft get draft => _draft;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool get isFirstStep => _currentStep == 0;

  bool get isLastStep => _currentStep == totalSteps - 1;

  DepartureState _departure = const DepartureIdle();
  DepartureState get departure => _departure;

  /// Identifica la última estimación pedida, para descartar respuestas de
  /// pedidos anteriores que lleguen tarde.
  int _departureRequest = 0;

  bool _disposed = false;

  bool get canAdvance => switch (_currentStep) {
        0 => _draft.isTypeStepValid,
        1 => _draft.isDetailsStepValid,
        // El medio de transporte siempre tiene valor: arranca en carro.
        2 => true,
        // Solo se puede guardar con una hora de salida calculada.
        3 => _departure is DepartureReady,
        _ => false,
      };

  void selectType(AlarmType type) {
    _draft = _draft.copyWith(type: type);
    notifyListeners();
  }

  void updateTitle(String value) {
    _draft = _draft.copyWith(title: value);
    notifyListeners();
  }

  void updateLocation(String value) {
    _draft = _draft.copyWith(location: value);
    notifyListeners();
  }

  void updateWhenAt(DateTime value) {
    _draft = _draft.copyWith(whenAt: value);
    notifyListeners();
  }

  void selectTransportMode(TransportMode mode) {
    _draft = _draft.copyWith(transportMode: mode);
    notifyListeners();
  }

  void clearTitle() => updateTitle('');

  void clearLocation() => updateLocation('');

  void clearWhenAt() {
    _draft = _draft.copyWith(clearWhenAt: true);
    notifyListeners();
  }

  /// Avanza un paso. Devuelve `false` si faltan datos o si ya está en el
  /// último paso, donde la acción principal es guardar y no avanzar.
  bool next() {
    if (!canAdvance || isLastStep) {
      return false;
    }
    _currentStep++;
    notifyListeners();
    if (_currentStep == departureStep) {
      loadDeparture();
    }
    return true;
  }

  /// Pide la hora de salida con los datos actuales del borrador.
  ///
  /// Se llama cada vez que el usuario entra al paso 4, para que la hora
  /// refleje cualquier cambio hecho en los pasos anteriores, y desde el
  /// botón "Reintentar" cuando el cálculo falla.
  Future<void> loadDeparture() async {
    final int request = ++_departureRequest;
    final DateTime? arriveAt = _draft.whenAt;
    if (arriveAt == null) {
      _setDeparture(const DepartureError('Falta la fecha del compromiso'));
      return;
    }

    _setDeparture(const DepartureLoading());
    try {
      final DepartureEstimate estimate = await _departureRepository.estimate(
        arriveAt: arriveAt,
        destination: _draft.location,
        mode: _draft.transportMode,
      );
      if (request == _departureRequest) {
        _setDeparture(DepartureReady(estimate));
      }
    } catch (_) {
      if (request == _departureRequest) {
        _setDeparture(const DepartureError('No pudimos calcular tu hora de salida'));
      }
    }
  }

  /// Resumen para la pantalla de confirmación, o `null` si todavía no hay
  /// una hora de salida calculada.
  ///
  /// La persistencia está fuera del alcance actual: guardar solo arma el
  /// resumen. Cuando exista el backend, aquí se enviará la alarma.
  CreatedAlarmSummary? save() {
    final DepartureState departure = _departure;
    final DateTime? startsAt = _draft.whenAt;
    if (departure is! DepartureReady || startsAt == null) {
      return null;
    }
    return CreatedAlarmSummary(
      title: _draft.title.trim(),
      startsAt: startsAt,
      leaveAt: departure.estimate.leaveAt,
    );
  }

  void _setDeparture(DepartureState value) {
    if (_disposed) {
      return;
    }
    _departure = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Retrocede un paso. Devuelve `false` si ya está en el primero, caso en
  /// el que la pantalla debe cerrar el asistente.
  bool back() {
    if (isFirstStep) {
      return false;
    }
    _currentStep--;
    notifyListeners();
    return true;
  }

  /// Asistentes de ejemplo del mockup. La edición de invitados está fuera
  /// del alcance actual, así que la lista es fija.
  static const List<Attendee> _sampleAttendees = <Attendee>[
    Attendee(id: '1', initials: 'MC', avatarColorIndex: 0),
    Attendee(id: '2', initials: 'JP', avatarColorIndex: 1),
    Attendee(id: '3', initials: 'LR', avatarColorIndex: 2),
    Attendee(id: '4', initials: 'AS', avatarColorIndex: 3),
    Attendee(id: '5', initials: 'DG', avatarColorIndex: 0),
    Attendee(id: '6', initials: 'VT', avatarColorIndex: 1),
  ];
}
