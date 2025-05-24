class UnidadModel {
  final int? id;
  final String tipo;
  

  UnidadModel({this.id, required this.tipo});

  factory UnidadModel.fromMap(Map<String, dynamic> json) => UnidadModel(
        id: json['id'],
        tipo: json['tipo'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo,
      };
}
