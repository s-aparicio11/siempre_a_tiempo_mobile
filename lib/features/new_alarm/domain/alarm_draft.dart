import 'alarm_type.dart';
import 'attendee.dart';

/// Datos que el usuario va acumulando dentro del asistente de creación.
///
/// Es inmutable: cada cambio produce una copia. El ViewModel es el único
/// que lo sustituye.
class AlarmDraft {
  const AlarmDraft({
    this.type,
    this.title = '',
    this.whenAt,
    this.location = '',
    this.attendees = const <Attendee>[],
  });

  final AlarmType? type;
  final String title;
  final DateTime? whenAt;
  final String location;
  final List<Attendee> attendees;

  bool get isTypeStepValid => type != null;

  bool get isDetailsStepValid =>
      title.trim().isNotEmpty && whenAt != null && location.trim().isNotEmpty;

  /// Copia con los campos indicados sustituidos.
  ///
  /// `clearWhenAt` existe porque pasar `whenAt: null` es indistinguible de
  /// no pasarlo: es la única forma de vaciar la fecha.
  AlarmDraft copyWith({
    AlarmType? type,
    String? title,
    DateTime? whenAt,
    String? location,
    List<Attendee>? attendees,
    bool clearWhenAt = false,
  }) {
    return AlarmDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      whenAt: clearWhenAt ? null : (whenAt ?? this.whenAt),
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
    );
  }
}
