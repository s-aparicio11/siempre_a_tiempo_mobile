/// Resumen de una alarma recién creada, el que muestra la confirmación.
class CreatedAlarmSummary {
  const CreatedAlarmSummary({
    required this.title,
    required this.startsAt,
    required this.leaveAt,
  });

  final String title;
  final DateTime startsAt;
  final DateTime leaveAt;
}
