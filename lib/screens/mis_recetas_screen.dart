import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/recipe_model.dart';
import '../repositories/recetas_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'receta_form_screen.dart';

// ══════════════════════════════════════════════════════════════
// MisRecetasScreen — lista todas las recetas con opciones CRUD
//
// Solo accesible si el usuario está logueado.
// Permite crear, editar y eliminar recetas.
// ══════════════════════════════════════════════════════════════

class MisRecetasScreen extends StatefulWidget {
  const MisRecetasScreen({super.key});

  @override
  State<MisRecetasScreen> createState() => _MisRecetasScreenState();
}

class _MisRecetasScreenState extends State<MisRecetasScreen> {
  final _repo     = Get.find<RecetasRepository>();
  final _auth     = AuthService();
  final _authCtrl = Get.find<AuthController>();

  List<RecipeModel> _recetas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // ── CARGAR TODAS LAS RECETAS ──────────────────────────────────────
  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });

    try {
      final lista = await _repo.obtenerTodas(limite: 100);
      setState(() { _recetas = lista; _cargando = false; });
    } catch (_) {
      setState(() {
        _error = 'No se pudieron cargar las recetas';
        _cargando = false;
      });
    }
  }

  // ── NAVEGAR AL FORMULARIO (crear o editar) ────────────────────────
  Future<void> _abrirFormulario({RecipeModel? receta}) async {
    // result = true si el usuario guardó cambios
    final guardado = await Get.to(
      () => RecetaFormScreen(receta: receta),
      transition: Transition.rightToLeft,
    );
    if (guardado == true) _cargar(); // recargamos la lista
  }

  // ── CONFIRMAR Y ELIMINAR ──────────────────────────────────────────
  Future<void> _eliminar(RecipeModel receta) async {
    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Eliminar "${receta.strMeal}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Eliminar',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final token = await _auth.obtenerToken();
    if (token == null) return;

    final ok = await _repo.eliminarReceta(receta.idMeal, token);

    if (ok) {
      setState(() => _recetas.removeWhere((r) => r.idMeal == receta.idMeal));
      Get.snackbar('Eliminada', '"${receta.strMeal}" fue eliminada',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'No se pudo eliminar la receta',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si no está logueado, mostramos pantalla de acceso
    if (!_authCtrl.estaLogueado.value) {
      return _buildSinSesion();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis recetas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Botón flotante para crear nueva receta
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva receta'),
      ),
      body: _buildCuerpo(),
    );
  }

  // ── CUERPO SEGÚN ESTADO ───────────────────────────────────────────
  Widget _buildCuerpo() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_recetas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu,
                size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Aún no hay recetas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Crea la primera con el botón +',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _recetas.length,
        itemBuilder: (_, index) => _buildTarjeta(_recetas[index]),
      ),
    );
  }

  // ── TARJETA DE RECETA CON BOTONES EDITAR/ELIMINAR ─────────────────
  Widget _buildTarjeta(RecipeModel receta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── IMAGEN ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16)),
            child: receta.strMealThumb.isNotEmpty
                ? Image.network(
                    receta.strMealThumb,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, err, stack) => _imagenPlaceholder(),
                  )
                : _imagenPlaceholder(),
          ),

          // ── TEXTO ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.strMeal,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    receta.strCategory,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTONES EDITAR / ELIMINAR ─────────────────────────────
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
                tooltip: 'Editar',
                onPressed: () => _abrirFormulario(receta: receta),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade400, size: 20),
                tooltip: 'Eliminar',
                onPressed: () => _eliminar(receta),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── PLACEHOLDER CUANDO NO HAY IMAGEN ─────────────────────────────
  Widget _imagenPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFFFE0CC),
      child: const Icon(Icons.restaurant,
          size: 36, color: AppColors.primary),
    );
  }

  // ── PANTALLA SI NO HAY SESIÓN ─────────────────────────────────────
  Widget _buildSinSesion() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis recetas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline,
                  size: 72,
                  color: AppColors.primary.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('Inicia sesión para gestionar recetas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.to(() => const LoginScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Iniciar sesión',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
