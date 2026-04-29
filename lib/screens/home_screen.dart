import 'package:flutter/material.dart';
import '../models/hydra_data.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../widgets/water_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _storage = StorageService();

  UserProfile _perfil = UserProfile();
  HydraData? _hoy;
  int _racha = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarDatos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cargarDatos();
  }

  void recargar() => _cargarDatos();

  Future<void> _cargarDatos() async {
    final perfil = await _storage.cargarPerfil();
    final hoy = await _storage.obtenerHoy(perfil.metaEnVasos());
    final racha = await _storage.calcularRacha(perfil.metaEnVasos());
    setState(() {
      _perfil = perfil;
      _hoy = hoy;
      _racha = racha;
      _cargando = false;
    });
  }

  Future<void> _agregarVaso() async {
    if (_hoy == null) return;
    if (_hoy!.vasos >= _perfil.metaEnVasos()) return;
    setState(() => _hoy!.vasos++);
    await _storage.actualizarVasosHoy(_hoy!.vasos);
  }

  Future<void> _quitarVaso() async {
    if (_hoy == null || _hoy!.vasos == 0) return;
    setState(() => _hoy!.vasos--);
    await _storage.actualizarVasosHoy(_hoy!.vasos);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final meta = _perfil.metaEnVasos();
    final vasos = _hoy?.vasos ?? 0;

    return Scaffold(
      backgroundColor: colores.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Saludo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _perfil.nombre.isEmpty
                            ? 'Hola'
                            : 'Hola, ${_perfil.nombre}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tu meta hoy: ${_perfil.calcularMeta().toStringAsFixed(1)}L',
                        style: TextStyle(color: colores.outline),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colores.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _fechaHoy(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colores.primary),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Progreso circular
              WaterProgress(vasos: vasos, meta: meta),

              const SizedBox(height: 16),

              // Racha de días
              if (_racha > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _racha >= 7
                        ? Colors.orange.shade100
                        : colores.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _racha >= 7 ? '🔥' : '⚡',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _racha == 1
                            ? '1 día de racha'
                            : '$_racha días de racha',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _racha >= 7
                              ? Colors.orange.shade800
                              : colores.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.outlined(
                    onPressed: vasos > 0 ? _quitarVaso : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 28,
                  ),

                  const SizedBox(width: 16),

                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: vasos < meta ? _agregarVaso : null,
                      icon: const Icon(Icons.water_drop, size: 24),
                      label: const Text(
                        'Tomé un vaso',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colores.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _fechaHoy() {
    final now = DateTime.now();
    const meses = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${now.day} ${meses[now.month]}';
  }
}