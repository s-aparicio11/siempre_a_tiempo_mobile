import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/transport_mode.dart';

/// Ícono de cada medio de transporte.
///
/// Vive fuera del enum porque `IconData` es de Flutter y el dominio no
/// depende de Flutter. Es el único mapeo: así Inicio y el asistente no
/// pueden mostrar íconos distintos para el mismo medio.
extension TransportModeIcon on TransportMode {
  IconData get icon => switch (this) {
        TransportMode.car => LucideIcons.car,
        TransportMode.publicTransport => LucideIcons.bus,
        TransportMode.motorcycle => LucideIcons.motorbike,
        TransportMode.bicycle => LucideIcons.bike,
        TransportMode.walking => LucideIcons.footprints,
      };
}
