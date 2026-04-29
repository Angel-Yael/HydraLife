// Modelo que representa los datos de un día de hidratación
class HydraData {
  final DateTime fecha;
  int vasos;
  int meta; // CAMBIADO: ahora es en vasos, no litros

  HydraData({
    required this.fecha,
    this.vasos = 0,
    required this.meta,
  });

  Map<String, dynamic> toMap() => {
        'fecha': fecha.toIso8601String(),
        'vasos': vasos,
        'meta': meta,
      };

  factory HydraData.fromMap(Map<String, dynamic> map) => HydraData(
        fecha: DateTime.parse(map['fecha']),
        vasos: map['vasos'],
        meta: map['meta'],
      );
}