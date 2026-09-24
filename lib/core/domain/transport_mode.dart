/// Medio de transporte con el que el usuario se desplaza a su compromiso.
///
/// Vive en `core/` porque lo consumen Inicio y el asistente de creación.
enum TransportMode {
  car(
    label: 'Carro',
    description: 'Ruta más rápida según tráfico',
  ),
  publicTransport(
    label: 'Transporte público',
    description: 'Considera frecuencias y transbordos',
  ),
  motorcycle(
    label: 'Moto',
    description: 'Ruta rápida, atenta al clima',
  ),
  bicycle(
    label: 'Bicicleta',
    description: 'Prioriza ciclorrutas',
  ),
  walking(
    label: 'Caminando',
    description: 'Ruta peatonal más corta',
  );

  const TransportMode({required this.label, required this.description});

  /// Etiqueta visible al usuario.
  final String label;

  /// Detalle que acompaña a la opción seleccionada en el asistente.
  final String description;
}
