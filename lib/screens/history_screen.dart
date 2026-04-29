import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/hydra_data.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<HydraData> _historial = [];
  UserProfile _perfil = UserProfile();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void recargar() => _cargar();

  Future<void> _cargar() async {
    final historial = await _storage.cargarHistorial();
    final perfil = await _storage.cargarPerfil();
    historial.sort((a, b) => a.fecha.compareTo(b.fecha));
    setState(() {
      _historial = historial.length > 7
          ? historial.sublist(historial.length - 7)
          : historial;
      _perfil = perfil;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    // Misma fórmula que HomeScreen
    final metaVasos = _perfil.metaEnVasos();

    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colores.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historial',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Últimos 7 días', style: TextStyle(color: colores.outline)),

              const SizedBox(height: 32),

              if (_historial.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Icon(Icons.water_drop_outlined,
                          size: 64, color: colores.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Sin registros aún.\n¡Empieza a hidratarte hoy!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colores.outline),
                      ),
                    ],
                  ),
                )
              else ...[
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: metaVasos * 1.3,
                      barGroups: _barras(colores, metaVasos),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= _historial.length) return const SizedBox();
                              final dia = _historial[idx].fecha;
                              const dias = ['L','M','M','J','V','S','D'];
                              return Text(
                                dias[dia.weekday - 1],
                                style: TextStyle(
                                    color: colores.outline, fontSize: 12),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: ListView.separated(
                    itemCount: _historial.length,
                    separatorBuilder: (a, b) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final d = _historial[_historial.length - 1 - i];
                      // Usa metaVasos del perfil actual — misma fuente que Home
                      final pct = (d.vasos / metaVasos).clamp(0.0, 1.0);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colores.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatFecha(d.fecha),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${d.vasos} vasos · ${(d.vasos * 0.25).toStringAsFixed(2)}L',
                                  style: TextStyle(
                                      color: colores.outline, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '${(pct * 100).round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: pct >= 1.0 ? Colors.green : colores.primary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              pct >= 1.0
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: pct >= 1.0 ? Colors.green : colores.outline,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _barras(ColorScheme colores, int metaVasos) {
    return List.generate(_historial.length, (i) {
      final d = _historial[i];
      final completo = d.vasos >= metaVasos;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: d.vasos.toDouble(),
            color: completo ? Colors.green : colores.primary,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  String _formatFecha(DateTime d) {
    const meses = ['','Ene','Feb','Mar','Abr','May','Jun',
        'Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${meses[d.month]}';
  }
}