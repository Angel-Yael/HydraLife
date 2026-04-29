// Perfil del usuario para calcular su meta de agua diaria
class UserProfile {
  String nombre;
  double peso;      // kg
  int edad;
  String actividad; // sedentario, moderado, activo

  UserProfile({
    this.nombre = '',
    this.peso = 70,
    this.edad = 25,
    this.actividad = 'moderado',
  });

  // Cálculo de meta diaria en litros según peso y actividad
  double calcularMeta() {
    double base = peso * 0.033; // 33ml por kg de peso

    switch (actividad) {
      case 'sedentario':
        return base;
      case 'moderado':
        return base + 0.5;
      case 'activo':
        return base + 1.0;
      default:
        return base;
    }
  }

  // Cuántos vasos de 250ml equivalen a la meta
  int metaEnVasos() => (calcularMeta() / 0.25).round();

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'peso': peso,
        'edad': edad,
        'actividad': actividad,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        nombre: map['nombre'] ?? '',
        peso: map['peso'] ?? 70,
        edad: map['edad'] ?? 25,
        actividad: map['actividad'] ?? 'moderado',
      );
}