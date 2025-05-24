class PedidoModel {
  final int? id;
  final String fecha;
  final double total;

  PedidoModel({
    this.id,
    required this.fecha,
    required this.total,
  });

  factory PedidoModel.fromMap(Map<String, dynamic> json) => PedidoModel(
        id: json['id'],
        fecha: json['fecha'],
        total: json['total'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'fecha': fecha,
        'total': total,
      };
}
