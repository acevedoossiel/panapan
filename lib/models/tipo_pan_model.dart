class TipoPanModel {
  final int? id;
  final String tipo;
  final double precioBase;
  final int cantidadPorCharola;

  TipoPanModel({
    this.id,
    required this.tipo,
    required this.precioBase,
    required this.cantidadPorCharola,
  });

  factory TipoPanModel.fromMap(Map<String, dynamic> json) => TipoPanModel(
    id: json['id'],
    tipo: json['tipo'],
    precioBase: json['precio_base'],
    cantidadPorCharola: json['cantidad_por_charola'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tipo': tipo,
    'precio_base': precioBase,
    'cantidad_por_charola': cantidadPorCharola,
  };
}
