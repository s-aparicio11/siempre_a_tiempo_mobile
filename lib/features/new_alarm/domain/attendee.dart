/// Persona invitada a un compromiso.
///
/// Guarda un índice de color, no un `Color`: así el dominio no depende de
/// Flutter. `AttendeeAvatars` resuelve el índice contra la paleta del tema.
class Attendee {
  const Attendee({
    required this.id,
    required this.initials,
    required this.avatarColorIndex,
  });

  final String id;
  final String initials;
  final int avatarColorIndex;
}
