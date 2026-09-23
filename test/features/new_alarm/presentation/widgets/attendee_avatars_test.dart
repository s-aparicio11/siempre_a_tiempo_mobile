import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/features/new_alarm/domain/attendee.dart';
import 'package:siempre_a_tiempo/features/new_alarm/presentation/widgets/attendee_avatars.dart';

import '../../../../helpers/pump_app.dart';

List<Attendee> _asistentes(int cantidad) => List<Attendee>.generate(
      cantidad,
      (int i) => Attendee(id: '$i', initials: 'A$i', avatarColorIndex: i),
    );

void main() {
  setUpAll(initTestFormatting);

  testWidgets('dibuja un avatar por asistente cuando caben todos', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(3))),
    );

    expect(find.byType(CircleAvatar), findsNWidgets(3));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('muestra el contador de excedentes cuando hay más de los visibles',
      (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(6))),
    );

    expect(find.byType(CircleAvatar), findsNWidgets(4));
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('no dibuja nada cuando no hay asistentes', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: AttendeeAvatars(attendees: <Attendee>[])),
    );

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('se anuncia con el número total de asistentes', (tester) async {
    await pumpApp(
      tester,
      Scaffold(body: AttendeeAvatars(attendees: _asistentes(6))),
    );

    expect(find.bySemanticsLabel('6 asistentes'), findsOneWidget);
  });
}
