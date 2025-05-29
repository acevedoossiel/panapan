class PedidoDetalleModel {
  final int? id;
  final int idPedidoCliente;
  final int idTipoPan;
  final int cantidad;

  // opcional para mostrar nombre de pan
  final String? tipoPanNombre;

  PedidoDetalleModel({
    this.id,
    required this.idPedidoCliente,
    required this.idTipoPan,
    required this.cantidad,
    this.tipoPanNombre,
  });

  factory PedidoDetalleModel.fromMap(Map<String, dynamic> json) =>
      PedidoDetalleModel(
        id: json['id'],
        idPedidoCliente: json['id_pedido_cliente'],
        idTipoPan: json['id_tipo_pan'],
        cantidad: json['cantidad'],
        tipoPanNombre: json['tipoPanNombre'],
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_pedido_cliente': idPedidoCliente,
    'id_tipo_pan': idTipoPan,
    'cantidad': cantidad,
  };
}
