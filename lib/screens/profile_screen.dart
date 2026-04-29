import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  String _actividad = 'moderado';
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final perfil = await _storage.cargarPerfil();
    setState(() {
      _nombreCtrl.text = perfil.nombre;
      _pesoCtrl.text = perfil.peso.toString();
      _edadCtrl.text = perfil.edad.toString();
      _actividad = perfil.actividad;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final perfil = UserProfile(
      nombre: _nombreCtrl.text.trim(),
      peso: double.parse(_pesoCtrl.text),
      edad: int.parse(_edadCtrl.text),
      actividad: _actividad,
    );

    await _storage.guardarPerfil(perfil);
    setState(() => _guardando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Perfil guardado — Meta: ${perfil.calcularMeta().toStringAsFixed(1)}L (${perfil.metaEnVasos()} vasos)',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pesoCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu perfil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculamos tu meta de agua según estos datos',
                  style: TextStyle(color: colores.outline),
                ),

                const SizedBox(height: 32),

                // Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _inputDecor('Nombre', Icons.person),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                ),

                const SizedBox(height: 16),

                // Peso
                TextFormField(
                  controller: _pesoCtrl,
                  decoration: _inputDecor('Peso (kg)', Icons.monitor_weight),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 20 || n > 300) {
                      return 'Ingresa un peso válido (20-300 kg)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Edad
                TextFormField(
                  controller: _edadCtrl,
                  decoration: _inputDecor('Edad', Icons.cake),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 5 || n > 120) {
                      return 'Ingresa una edad válida (5-120)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Actividad física
                Text(
                  'Nivel de actividad física',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colores.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                _opcionActividad(
                  valor: 'sedentario',
                  titulo: 'Sedentario',
                  subtitulo: 'Poco o nada de ejercicio',
                  icono: Icons.chair,
                ),
                _opcionActividad(
                  valor: 'moderado',
                  titulo: 'Moderado',
                  subtitulo: 'Ejercicio 2-4 veces por semana',
                  icono: Icons.directions_walk,
                ),
                _opcionActividad(
                  valor: 'activo',
                  titulo: 'Activo',
                  subtitulo: 'Ejercicio intenso diario',
                  icono: Icons.directions_run,
                ),

                const SizedBox(height: 32),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colores.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar perfil',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _opcionActividad({
    required String valor,
    required String titulo,
    required String subtitulo,
    required IconData icono,
  }) {
    final colores = Theme.of(context).colorScheme;
    final seleccionado = _actividad == valor;

    return GestureDetector(
      onTap: () => setState(() => _actividad = valor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado ? colores.primaryContainer : colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? colores.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icono,
                color: seleccionado ? colores.primary : colores.outline),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: seleccionado
                          ? colores.primary
                          : colores.onSurface,
                    )),
                Text(subtitulo,
                    style: TextStyle(
                        fontSize: 12, color: colores.outline)),
              ],
            ),
            const Spacer(),
            if (seleccionado)
              Icon(Icons.check_circle, color: colores.primary),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}