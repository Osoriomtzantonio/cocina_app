import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../repositories/recetas_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════
// RecetaFormScreen — formulario para CREAR o EDITAR una receta
//
// Modo crear: se llama sin parámetros → RecetaFormScreen()
// Modo editar: se llama con la receta → RecetaFormScreen(receta: r)
// ══════════════════════════════════════════════════════════════

class RecetaFormScreen extends StatefulWidget {
  final RecipeModel? receta; // null = modo crear, no-null = modo editar

  const RecetaFormScreen({super.key, this.receta});

  @override
  State<RecetaFormScreen> createState() => _RecetaFormScreenState();
}

class _RecetaFormScreenState extends State<RecetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo    = Get.find<RecetasRepository>();
  final _auth    = AuthService();

  // Controladores de texto para cada campo
  late final TextEditingController _nombre;
  late final TextEditingController _categoria;
  late final TextEditingController _area;
  late final TextEditingController _imagen;
  late final TextEditingController _instrucciones;

  // 5 pares de ingrediente + cantidad
  late final List<TextEditingController> _ingredientes;
  late final List<TextEditingController> _cantidades;

  bool _guardando = false;

  bool get _esEdicion => widget.receta != null;

  @override
  void initState() {
    super.initState();
    final r = widget.receta;

    // Si editamos, precargamos los valores existentes
    _nombre        = TextEditingController(text: r?.strMeal         ?? '');
    _categoria     = TextEditingController(text: r?.strCategory     ?? '');
    _area          = TextEditingController(text: r?.strArea         ?? '');
    _imagen        = TextEditingController(text: r?.strMealThumb    ?? '');
    _instrucciones = TextEditingController(text: r?.strInstructions ?? '');

    // Ingredientes y cantidades: tomamos los primeros 5 de la lista
    // r?.ingredientes es List<Map<String,String>> con claves 'ingrediente' y 'cantidad'
    String ing(int i) =>
        (r != null && r.ingredientes.length > i)
            ? r.ingredientes[i]['ingrediente'] ?? ''
            : '';
    String cant(int i) =>
        (r != null && r.ingredientes.length > i)
            ? r.ingredientes[i]['cantidad'] ?? ''
            : '';

    _ingredientes = List.generate(5, (i) => TextEditingController(text: ing(i)));
    _cantidades   = List.generate(5, (i) => TextEditingController(text: cant(i)));
  }

  @override
  void dispose() {
    // Liberar memoria de todos los controladores
    _nombre.dispose();
    _categoria.dispose();
    _area.dispose();
    _imagen.dispose();
    _instrucciones.dispose();
    for (final c in [..._ingredientes, ..._cantidades]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── GUARDAR ───────────────────────────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    // Obtenemos el token JWT guardado
    final token = await _auth.obtenerToken();
    if (token == null) {
      Get.snackbar('Error', 'Debes iniciar sesión para guardar recetas',
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _guardando = false);
      return;
    }

    // Construimos el mapa de datos en formato TheMealDB
    final datos = {
      'strMeal':         _nombre.text.trim(),
      'strCategory':     _categoria.text.trim(),
      'strArea':         _area.text.trim(),
      'strInstructions': _instrucciones.text.trim(),
      'strMealThumb':    _imagen.text.trim(),
      'strIngredient1':  _ingredientes[0].text.trim(),
      'strMeasure1':     _cantidades[0].text.trim(),
      'strIngredient2':  _ingredientes[1].text.trim(),
      'strMeasure2':     _cantidades[1].text.trim(),
      'strIngredient3':  _ingredientes[2].text.trim(),
      'strMeasure3':     _cantidades[2].text.trim(),
      'strIngredient4':  _ingredientes[3].text.trim(),
      'strMeasure4':     _cantidades[3].text.trim(),
      'strIngredient5':  _ingredientes[4].text.trim(),
      'strMeasure5':     _cantidades[4].text.trim(),
    };

    RecipeModel? resultado;

    if (_esEdicion) {
      // Modo editar: PUT /recetas/{id}
      resultado = await _repo.actualizarReceta(
          widget.receta!.idMeal, datos, token);
    } else {
      // Modo crear: POST /recetas
      resultado = await _repo.crearReceta(datos, token);
    }

    setState(() => _guardando = false);

    if (resultado != null) {
      Get.back(result: true); // regresa indicando que hubo cambio
      Get.snackbar(
        '¡Listo!',
        _esEdicion ? 'Receta actualizada' : 'Receta creada',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar('Error', 'No se pudo guardar la receta',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar receta' : 'Nueva receta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── DATOS BÁSICOS ────────────────────────────────────
              _buildSeccion('Datos básicos'),
              const SizedBox(height: 12),
              _buildCampo(
                controller: _nombre,
                label: 'Nombre de la receta',
                icono: Icons.restaurant_menu,
                obligatorio: true,
              ),
              const SizedBox(height: 12),
              _buildCampo(
                controller: _categoria,
                label: 'Categoría (ej: Pollo, Sopas)',
                icono: Icons.category_outlined,
                obligatorio: true,
              ),
              const SizedBox(height: 12),
              _buildCampo(
                controller: _area,
                label: 'Origen (ej: Mexicano)',
                icono: Icons.public_outlined,
              ),
              const SizedBox(height: 12),
              _buildCampo(
                controller: _imagen,
                label: 'URL de imagen (opcional)',
                icono: Icons.image_outlined,
              ),
              const SizedBox(height: 20),

              // ── INSTRUCCIONES ─────────────────────────────────────
              _buildSeccion('Instrucciones'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instrucciones,
                maxLines: 5,
                decoration: _inputDecoracion(
                    'Describe los pasos para preparar la receta...',
                    Icons.notes),
              ),
              const SizedBox(height: 20),

              // ── INGREDIENTES ──────────────────────────────────────
              _buildSeccion('Ingredientes (hasta 5)'),
              const SizedBox(height: 12),
              ...List.generate(5, (i) => _buildFilaIngrediente(i)),
              const SizedBox(height: 32),

              // ── BOTÓN GUARDAR ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _esEdicion ? 'Guardar cambios' : 'Crear receta',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── TÍTULO DE SECCIÓN ─────────────────────────────────────────────
  Widget _buildSeccion(String titulo) {
    return Text(titulo,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));
  }

  // ── CAMPO DE TEXTO GENÉRICO ───────────────────────────────────────
  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    bool obligatorio = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoracion(label, icono),
      validator: obligatorio
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
    );
  }

  // ── FILA DE INGREDIENTE + CANTIDAD ────────────────────────────────
  Widget _buildFilaIngrediente(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _ingredientes[index],
              decoration:
                  _inputDecoracion('Ingrediente ${index + 1}', Icons.egg_outlined),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _cantidades[index],
              decoration:
                  _inputDecoracion('Cantidad', Icons.scale_outlined),
            ),
          ),
        ],
      ),
    );
  }

  // ── DECORACIÓN REUTILIZABLE PARA INPUTS ──────────────────────────
  InputDecoration _inputDecoracion(String hint, IconData icono) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      prefixIcon: Icon(icono, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFE0CC), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFE0CC), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
