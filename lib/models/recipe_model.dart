// Modelo de datos para una Receta de TheMealDB
// Representa la respuesta del endpoint /lookup.php y /search.php
class RecipeModel {
  final String idMeal;
  final String strMeal;          // Nombre de la receta
  final String strCategory;      // Categoría (Chicken, Beef, etc.)
  final String strArea;          // País de origen (Japanese, Italian, etc.)
  final String strInstructions;  // Instrucciones de preparación
  final String strMealThumb;     // URL de la imagen
  // Lista de ingredientes con sus cantidades (máximo 20 en la API)
  final List<Map<String, String>> ingredientes;

  const RecipeModel({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredientes,
  });

  // ── fromJson: convierte el JSON de la API en un objeto RecipeModel ─
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // La API devuelve los ingredientes como strIngredient1..20 y strMeasure1..20
    // Los convertimos a una lista de mapas {ingrediente, cantidad}
    final List<Map<String, String>> listaIngredientes = [];

    for (int i = 1; i <= 20; i++) {
      final ingrediente = json['strIngredient$i']?.toString().trim() ?? '';
      final cantidad    = json['strMeasure$i']?.toString().trim()    ?? '';

      // Solo agregamos si el ingrediente no está vacío
      if (ingrediente.isNotEmpty) {
        listaIngredientes.add({
          'ingrediente': ingrediente,
          'cantidad':    cantidad,
        });
      }
    }

    return RecipeModel(
      idMeal:          json['idMeal']          ?? '',
      strMeal:         json['strMeal']         ?? '',
      strCategory:     json['strCategory']     ?? '',
      strArea:         json['strArea']         ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb:    json['strMealThumb']    ?? '',
      ingredientes:    listaIngredientes,
    );
  }

  // ── toJson: convierte el objeto a Map para almacenamiento local ────
  Map<String, dynamic> toJson() {
    // Convertimos la lista de ingredientes de vuelta a los campos strIngredient/strMeasure
    final Map<String, dynamic> json = {
      'idMeal':          idMeal,
      'strMeal':         strMeal,
      'strCategory':     strCategory,
      'strArea':         strArea,
      'strInstructions': strInstructions,
      'strMealThumb':    strMealThumb,
    };

    for (int i = 0; i < ingredientes.length; i++) {
      json['strIngredient${i + 1}'] = ingredientes[i]['ingrediente'];
      json['strMeasure${i + 1}']    = ingredientes[i]['cantidad'];
    }

    return json;
  }

  // ── copyWith: crea una copia del objeto con campos modificados ─────
  // Útil cuando queremos cambiar solo algunos campos sin modificar el original
  RecipeModel copyWith({
    String? idMeal,
    String? strMeal,
    String? strCategory,
    String? strArea,
    String? strInstructions,
    String? strMealThumb,
    List<Map<String, String>>? ingredientes,
  }) {
    return RecipeModel(
      idMeal:          idMeal          ?? this.idMeal,
      strMeal:         strMeal         ?? this.strMeal,
      strCategory:     strCategory     ?? this.strCategory,
      strArea:         strArea         ?? this.strArea,
      strInstructions: strInstructions ?? this.strInstructions,
      strMealThumb:    strMealThumb    ?? this.strMealThumb,
      ingredientes:    ingredientes    ?? this.ingredientes,
    );
  }

  @override
  String toString() => 'RecipeModel(id: $idMeal, nombre: $strMeal)';
}
