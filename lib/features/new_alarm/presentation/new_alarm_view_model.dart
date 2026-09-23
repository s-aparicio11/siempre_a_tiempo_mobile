import 'package:flutter/foundation.dart';

import '../domain/alarm_draft.dart';
import '../domain/alarm_type.dart';
import '../domain/attendee.dart';

/// Estado del asistente de creación de alarmas.
class NewAlarmViewModel extends ChangeNotifier {
  NewAlarmViewModel({List<Attendee>? attendees})
      : _draft = AlarmDraft(attendees: attendees ?? _sampleAttendees);

  /// Pasos que muestra el indicador de progreso del diseño.
  static const int totalSteps = 4;

  /// Último paso construido. Los pasos 3 y 4 están fuera del alcance actual.
  static const int lastImplementedStep = 1;

  AlarmDraft _draft;
  AlarmDraft get draft => _draft;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool get isFirstStep => _currentStep == 0;

  bool get canAdvance => switch (_currentStep) {
        0 => _draft.isTypeStepValid,
        1 => _draft.isDetailsStepValid,
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

  void clearTitle() => updateTitle('');

  void clearLocation() => updateLocation('');

  void clearWhenAt() {
    _draft = _draft.copyWith(clearWhenAt: true);
    notifyListeners();
  }

  /// Avanza un paso. Devuelve `false` si no hay a dónde avanzar, sea porque
  /// faltan datos o porque el siguiente paso todavía no está construido;
  /// la pantalla usa ese `false` para avisar que la función viene después.
  bool next() {
    if (!canAdvance || _currentStep >= lastImplementedStep) {
      return false;
    }
    _currentStep++;
    notifyListeners();
    return true;
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
