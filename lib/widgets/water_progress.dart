import 'package:flutter/material.dart';

// Widget reutilizable que muestra el progreso circular de hidratación
class WaterProgress extends StatelessWidget {
  final int vasos;
  final int meta;

  const WaterProgress({
    super.key,
    required this.vasos,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final double progreso = meta > 0 ? (vasos / meta).clamp(0.0, 1.0) : 0.0;
    final porcentaje = (progreso * 100).round();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progreso,
                strokeWidth: 20,
                backgroundColor: colores.primaryContainer,
                color: progreso == 1.0 ? Colors.green : colores.primary,
              ),
            ),
            Column(
              children: [
                Text(
                  '$porcentaje%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colores.primary,
                  ),
                ),
                Text(
                  '$vasos de $meta vasos',
                  style: TextStyle(
                    fontSize: 16,
                    color: colores.outline,
                  ),
                ),
                Text(
                  '${(vasos * 0.25).toStringAsFixed(2)}L',
                  style: TextStyle(
                    fontSize: 14,
                    color: colores.outline,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Mensaje motivacional según progreso
        Text(
          _mensaje(progreso),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: progreso == 1.0 ? Colors.green : colores.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _mensaje(double progreso) {
    if (progreso == 0) return '¡Empieza tu día hidratado!';
    if (progreso < 0.25) return 'Buen inicio, sigue así';
    if (progreso < 0.50) return 'Un cuarto del camino ¡vamos!';
    if (progreso < 0.75) return '¡Ya vas a la mitad!';
    if (progreso < 1.0) return '¡Casi llegas a tu meta!';
    return '¡Meta del día alcanzada!';
  }
}