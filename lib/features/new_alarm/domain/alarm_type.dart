/// Tipos de alarma que el usuario puede crear.
enum AlarmType {
  meeting(
    title: 'Reunión',
    description: 'Agenda una reunión con tiempo de viaje',
  ),
  personalReminder(
    title: 'Recordatorio personal',
    description: 'Crea un recordatorio para cualquier cosa',
  ),
  recurringEvent(
    title: 'Evento recurrente',
    description: 'Crea alarmas que se repiten a diario',
  );

  const AlarmType({required this.title, required this.description});

  final String title;
  final String description;
}
