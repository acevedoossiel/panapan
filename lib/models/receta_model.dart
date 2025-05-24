class RecetaIngredienteModel {
  final int? id;
  final int idPan;
  final int idIngrediente;
  final double cantidad;
  final String? ingredienteNombre;
  final String? unidadNombre;

  RecetaIngredienteModel({
    this.id,
    required this.idPan,
    required this.idIngrediente,
    required this.cantidad,
    this.ingredienteNombre,
    this.unidadNombre,
  });

  factory RecetaIngredienteModel.fromMap(Map<String, dynamic> json) =>
      RecetaIngredienteModel(
        id: json['id'],
        idPan: json['id_pan'],
        idIngrediente: json['id_ingrediente'],
        cantidad: json['cantidad'],
        ingredienteNombre: json['ingredienteNombre'],
        unidadNombre: json['unidadNombre'],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_pan': idPan,
    'id_ingrediente': idIngrediente,
    'cantidad': cantidad,
  };
}
