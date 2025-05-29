class PanModel {
  int? id;
  String nombre;
  String detalles;
  String recetaUnidad;
  double precio;

  PanModel({
    this.id,
    required this.nombre,
    required this.detalles,
    required this.recetaUnidad,
    required this.precio,
  });

  factory PanModel.fromMap(Map<String, dynamic> json) => PanModel(
    id: json['id'],
    nombre: json['nombre'],
    detalles: json['detalles'],
    recetaUnidad: json['receta_unidad'],
    precio:
        json['precio'] is int
            ? (json['precio'] as int).toDouble()
            : json['precio'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'detalles': detalles,
    'receta_unidad': recetaUnidad,
    'precio': precio,
  };
}
