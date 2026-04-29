import 'package:flutter/material.dart';

void main() {
  runApp(const HydraLifeApp());
}

// Widget raíz de la app — define el tema global
class HydraLifeApp extends StatelessWidget {
  const HydraLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydraLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6), // Azul agua
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Pantalla principal
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _vasos = 0;          // Vasos tomados hoy
  final int _meta = 8;     // Meta diaria (fija por ahora, después será dinámica)

  // Agrega un vaso y actualiza la pantalla
  void _agregarVaso() {
    setState(() {
      if (_vasos < _meta) _vasos++;
    });
  }

  // Reinicia el contador
  void _reiniciar() {
    setState(() {
      _vasos = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progreso = _vasos / _meta; // 0.0 a 1.0
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      appBar: AppBar(
        title: const Text('HydraLife'),
        backgroundColor: colores.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar',
            onPressed: _reiniciar,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Indicador circular de progreso
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progreso,
                      strokeWidth: 16,
                      backgroundColor: colores.primaryContainer,
                      color: colores.primary,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_vasos',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: colores.primary,
                        ),
                      ),
                      Text(
                        'de $_meta vasos',
                        style: TextStyle(color: colores.outline),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Mensaje según progreso
              Text(
                _vasos == _meta
                    ? '🎉 ¡Meta alcanzada!'
                    : '${_meta - _vasos} vasos restantes',
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              // Botón principal
              ElevatedButton.icon(
                onPressed: _vasos < _meta ? _agregarVaso : null,
                icon: const Icon(Icons.water_drop),
                label: const Text('Tomé un vaso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colores.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}