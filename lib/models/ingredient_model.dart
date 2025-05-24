class IngredientModel {
  final int? id;
  final String nombre;
  final double cantidad;
  final int idUnidad;
  final String? unidadNombre;

  IngredientModel({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.idUnidad,
    this.unidadNombre,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> json) => IngredientModel(
    id: json['id'],
    nombre: json['nombre'],
    cantidad: json['cantidad'],
    idUnidad: json['id_unidad'],
    unidadNombre: json['unidadNombre'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'id_unidad': idUnidad,
  };
}
