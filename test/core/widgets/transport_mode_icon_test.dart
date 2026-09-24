import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siempre_a_tiempo/core/domain/transport_mode.dart';
import 'package:siempre_a_tiempo/core/widgets/transport_mode_icon.dart';

void main() {
  test('cada medio tiene etiqueta y descripción', () {
    for (final TransportMode mode in TransportMode.values) {
      expect(mode.label.trim(), isNotEmpty, reason: mode.name);
      expect(mode.description.trim(), isNotEmpty, reason: mode.name);
    }
  });

  test('cada medio tiene un ícono distinto', () {
    final Set<IconData> iconos =
        TransportMode.values.map((TransportMode m) => m.icon).toSet();

    expect(iconos, hasLength(TransportMode.values.length));
  });
}
