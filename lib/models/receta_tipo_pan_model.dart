class RecetaTipoPanModel {
  final int? id;
  final int idTipoPan;
  final int idIngrediente;
  final double cantidad;
  final int idUnidad;

  // opcionales para mostrar info
  final String? ingredienteNombre;
  final String? unidadNombre;

  RecetaTipoPanModel({
    this.id,
    required this.idTipoPan,
    required this.idIngrediente,
    required this.cantidad,
    required this.idUnidad,
    this.ingredienteNombre,
    this.unidadNombre,
  });

  factory RecetaTipoPanModel.fromMap(Map<String, dynamic> json) =>
      RecetaTipoPanModel(
        id: json['id'],
        idTipoPan: json['id_tipo_pan'],
        idIngrediente: json['id_ingrediente'],
        cantidad: json['cantidad'],
        idUnidad: json['id_unidad'],
        ingredienteNombre: json['ingredienteNombre'],
        unidadNombre: json['unidadNombre'],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_tipo_pan': idTipoPan,
    'id_ingrediente': idIngrediente,
    'cantidad': cantidad,
    'id_unidad': idUnidad,
  };
}
