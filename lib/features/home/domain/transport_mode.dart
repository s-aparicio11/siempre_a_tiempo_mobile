/// Medio de transporte con el que el usuario se desplaza a su compromiso.
enum TransportMode {
  car('Carro'),
  walking('Caminando');

  const TransportMode(this.label);

  /// Etiqueta visible al usuario.
  final String label;
}
