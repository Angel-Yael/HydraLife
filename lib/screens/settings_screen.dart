import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _recordatoriosActivos = false;
  int _cadaHoras = 2;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recordatoriosActivos = prefs.getBool('notif_activas') ?? false;
      _cadaHoras = prefs.getInt('notif_horas') ?? 2;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_activas', _recordatoriosActivos);
    await prefs.setInt('notif_horas', _cadaHoras);

    if (_recordatoriosActivos) {
      await NotificationService.programarRecordatorios(cadaHoras: _cadaHoras);
    } else {
      await NotificationService.cancelarTodos();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_recordatoriosActivos
              ? 'Recordatorios cada $_cadaHoras horas activados'
              : 'Recordatorios desactivados'),
          backgroundColor:
              _recordatoriosActivos ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  Future<void> _probar() async {
    await NotificationService.notificacionPrueba();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

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
                'Configuración',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Tarjeta de recordatorios
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colores.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            color: colores.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Recordatorios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _recordatoriosActivos,
                          onChanged: (v) =>
                              setState(() => _recordatoriosActivos = v),
                          activeColor: colores.primary,
                        ),
                      ],
                    ),

                    if (_recordatoriosActivos) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Recordarme cada $_cadaHoras ${_cadaHoras == 1 ? "hora" : "horas"}',
                        style: TextStyle(color: colores.outline),
                      ),
                      Slider(
                        value: _cadaHoras.toDouble(),
                        min: 1,
                        max: 4,
                        divisions: 3,
                        label: '$_cadaHoras h',
                        activeColor: colores.primary,
                        onChanged: (v) =>
                            setState(() => _cadaHoras = v.toInt()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('1h', style: TextStyle(fontSize: 12)),
                          Text('2h', style: TextStyle(fontSize: 12)),
                          Text('3h', style: TextStyle(fontSize: 12)),
                          Text('4h', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botón prueba
              OutlinedButton.icon(
                onPressed: _probar,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Enviar notificación de prueba'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const Spacer(),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar configuración',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}