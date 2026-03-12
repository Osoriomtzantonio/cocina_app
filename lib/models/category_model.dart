// Modelo de datos para una Categoría de TheMealDB
// Representa la respuesta del endpoint /categories.php
class CategoryModel {
  final String idCategory;
  final String strCategory;       // Nombre de la categoría
  final String strCategoryThumb;  // URL de la imagen
  final String strCategoryDescription;

  // Constructor principal
  const CategoryModel({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });

  // ── fromJson: convierte un Map (JSON) en un objeto CategoryModel ──
  // Se usa cuando la API nos devuelve datos y los queremos convertir a objetos Dart
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      idCategory:              json['idCategory']              ?? '',
      strCategory:             json['strCategory']             ?? '',
      strCategoryThumb:        json['strCategoryThumb']        ?? '',
      strCategoryDescription:  json['strCategoryDescription']  ?? '',
    );
  }

  // ── toJson: convierte el objeto en un Map (JSON) ──────────────────
  // Se usa para guardar en almacenamiento local (Clase 08)
  Map<String, dynamic> toJson() {
    return {
      'idCategory':             idCategory,
      'strCategory':            strCategory,
      'strCategoryThumb':       strCategoryThumb,
      'strCategoryDescription': strCategoryDescription,
    };
  }

  // toString: útil para depuración
  @override
  String toString() => 'CategoryModel(id: $idCategory, nombre: $strCategory)';
}
