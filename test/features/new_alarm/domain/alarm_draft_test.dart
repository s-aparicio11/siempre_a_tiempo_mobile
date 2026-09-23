import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_draft.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/alarm_type.dart';

void main() {
  group('validación del paso de tipo', () {
    test('un borrador vacío no es válido', () {
      expect(const AlarmDraft().isTypeStepValid, isFalse);
    });

    test('con un tipo elegido es válido', () {
      expect(const AlarmDraft(type: AlarmType.meeting).isTypeStepValid, isTrue);
    });
  });

  group('validación del paso de detalles', () {
    const base = AlarmDraft(type: AlarmType.meeting);

    test('faltan todos los datos', () {
      expect(base.isDetailsStepValid, isFalse);
    });

    test('con título, fecha y lugar es válido', () {
      final borrador = base.copyWith(
        title: 'Reunión con cliente',
        whenAt: DateTime(2026, 8, 20, 15),
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isTrue);
    });

    test('un título de solo espacios no cuenta como diligenciado', () {
      final borrador = base.copyWith(
        title: '   ',
        whenAt: DateTime(2026, 8, 20, 15),
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isFalse);
    });

    test('sin fecha no es válido', () {
      final borrador = base.copyWith(
        title: 'Reunión con cliente',
        location: 'Avenida El Poblado #1-25',
      );

      expect(borrador.isDetailsStepValid, isFalse);
    });
  });

  group('copyWith', () {
    test('conserva los campos que no se pasan', () {
      final original = const AlarmDraft(type: AlarmType.meeting).copyWith(
        title: 'Reunión con cliente',
        whenAt: DateTime(2026, 8, 20, 15),
      );

      final copia = original.copyWith(location: 'Avenida El Poblado #1-25');

      expect(copia.type, AlarmType.meeting);
      expect(copia.title, 'Reunión con cliente');
      expect(copia.whenAt, DateTime(2026, 8, 20, 15));
      expect(copia.location, 'Avenida El Poblado #1-25');
    });

    test('clearWhenAt borra la fecha, cosa que un null no lograría', () {
      final original =
          AlarmDraft(type: AlarmType.meeting, whenAt: DateTime(2026, 8, 20, 15));

      expect(original.copyWith().whenAt, isNotNull);
      expect(original.copyWith(clearWhenAt: true).whenAt, isNull);
    });
  });

  group('AlarmType', () {
    test('cada tipo trae el texto del diseño', () {
      expect(AlarmType.meeting.title, 'Reunión');
      expect(AlarmType.meeting.description, 'Agenda una reunión con tiempo de viaje');
      expect(AlarmType.personalReminder.title, 'Recordatorio personal');
      expect(AlarmType.recurringEvent.title, 'Evento recurrente');
    });
  });
}
