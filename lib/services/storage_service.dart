import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hydra_data.dart';
import '../models/user_profile.dart';

// Servicio que maneja toda la persistencia de datos
class StorageService {
  static const _keyPerfil = 'user_profile';
  static const _keyHistorial = 'historial';

  // ── Perfil ──────────────────────────────────────────
  Future<UserProfile> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyPerfil);
    if (json == null) return UserProfile(); // perfil vacío por defecto
    return UserProfile.fromMap(jsonDecode(json));
  }

  Future<void> guardarPerfil(UserProfile perfil) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPerfil, jsonEncode(perfil.toMap()));
  }

  // ── Historial ────────────────────────────────────────
  Future<List<HydraData>> cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHistorial);
    if (json == null) return [];
    final List lista = jsonDecode(json);
    return lista.map((e) => HydraData.fromMap(e)).toList();
  }

  Future<void> guardarHistorial(List<HydraData> historial) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(historial.map((e) => e.toMap()).toList());
    await prefs.setString(_keyHistorial, json);
  }

  // Devuelve el registro de hoy, o crea uno nuevo
  Future<HydraData> obtenerHoy(int metaEnVasos) async {
    final historial = await cargarHistorial();
    final hoy = DateTime.now();

    // Busca si ya existe entrada para hoy
    final idx = historial.indexWhere((d) =>
        d.fecha.year == hoy.year &&
        d.fecha.month == hoy.month &&
        d.fecha.day == hoy.day);

    if (idx != -1) return historial[idx];

    // Si no existe, crea una nueva
    final nuevo = HydraData(fecha: hoy, meta: metaEnVasos);
    historial.add(nuevo);
    await guardarHistorial(historial);
    return nuevo;
  }

  // Actualiza los vasos del día de hoy
  Future<void> actualizarVasosHoy(int vasos) async {
    final historial = await cargarHistorial();
    final hoy = DateTime.now();

    final idx = historial.indexWhere((d) =>
        d.fecha.year == hoy.year &&
        d.fecha.month == hoy.month &&
        d.fecha.day == hoy.day);

    if (idx != -1) {
      historial[idx].vasos = vasos;
      await guardarHistorial(historial);
    }
  }

  // Calcula cuántos días consecutivos se cumplió la meta
  Future<int> calcularRacha(int metaEnVasos) async {
    final historial = await cargarHistorial();
    if (historial.isEmpty) return 0;

    // Ordena de más reciente a más antiguo
    historial.sort((a, b) => b.fecha.compareTo(a.fecha));

    final hoy = DateTime.now();
    int racha = 0;

    for (int i = 0; i < historial.length; i++) {
      final d = historial[i];
      // Día esperado: hoy, ayer, anteayer, etc.
      final esperado = DateTime(hoy.year, hoy.month, hoy.day - i);
      final actual = DateTime(d.fecha.year, d.fecha.month, d.fecha.day);

      // Si el día no coincide, se rompió la racha
      if (actual != esperado) break;

      // Si ese día no cumplió la meta, se rompió la racha
      if (d.vasos < metaEnVasos) break;

      racha++;
    }

    return racha;
  }
}