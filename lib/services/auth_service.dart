import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart' show ApiService;

// ══════════════════════════════════════════════════════════════
// AuthService — maneja el registro, login y sesión del usuario
// ══════════════════════════════════════════════════════════════
//
// El token JWT se guarda en SharedPreferences para persistir
// la sesión entre reinicios de la app.

class AuthService {
  static const String _claveToken   = 'jwt_token';
  static const String _claveUsuario = 'usuario_json';

  // ── TOKEN: guardar y leer ─────────────────────────────────────────

  Future<void> _guardarSesion(String token, Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken,   token);
    await prefs.setString(_claveUsuario, jsonEncode(usuario));
  }

  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveToken);
  }

  Future<Map<String, dynamic>?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_claveUsuario);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<bool> estaLogueado() async {
    final token = await obtenerToken();
    return token != null;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveToken);
    await prefs.remove(_claveUsuario);
  }

  // ── REGISTRO ──────────────────────────────────────────────────────
  // Devuelve null si fue exitoso, o un mensaje de error
  Future<String?> registro({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre':   nombre,
          'email':    email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        await _guardarSesion(
          data['access_token'] as String,
          data['usuario']      as Map<String, dynamic>,
        );
        return null; // éxito
      }

      return data['detail']?.toString() ?? 'Error al registrarse';
    } catch (e) {
      return 'Sin conexión al servidor';
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────
  // Devuelve null si fue exitoso, o un mensaje de error
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':    email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _guardarSesion(
          data['access_token'] as String,
          data['usuario']      as Map<String, dynamic>,
        );
        return null; // éxito
      }

      return data['detail']?.toString() ?? 'Email o contraseña incorrectos';
    } catch (e) {
      return 'Sin conexión al servidor';
    }
  }
}
