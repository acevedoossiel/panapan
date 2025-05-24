class TipoModel {
  final int? id;
  final String tipo;

  TipoModel({this.id, required this.tipo});

  factory TipoModel.fromMap(Map<String, dynamic> json) => TipoModel(
        id: json['id'],
        tipo: json['tipo'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo,
      };
}
