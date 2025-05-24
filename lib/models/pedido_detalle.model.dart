class PedidoDetalleModel {
  final int? id;
  final int idPedido;
  final int idPan;
  final int charolas;

  PedidoDetalleModel({
    this.id,
    required this.idPedido,
    required this.idPan,
    required this.charolas,
  });

  factory PedidoDetalleModel.fromMap(Map<String, dynamic> json) =>
      PedidoDetalleModel(
        id: json['id'],
        idPedido: json['id_pedido'],
        idPan: json['id_pan'],
        charolas: json['charolas'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_pedido': idPedido,
        'id_pan': idPan,
        'charolas': charolas,
      };
}
