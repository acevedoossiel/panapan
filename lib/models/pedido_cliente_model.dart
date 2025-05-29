class PedidoClienteModel {
  int? id;
  int idCliente;
  String fecha;
  double total;
  String? nombreCliente; // este campo solo para mostrar en UI

  PedidoClienteModel({
    this.id,
    required this.idCliente,
    required this.fecha,
    required this.total,
    this.nombreCliente,
  });

  Map<String, dynamic> toMap() => {
    'id_cliente': idCliente,
    'fecha': fecha,
    'total': total,
  };

  factory PedidoClienteModel.fromMap(Map<String, dynamic> map) =>
      PedidoClienteModel(
        id: map['id'],
        idCliente: map['id_cliente'],
        fecha: map['fecha'],
        total: map['total'],
        nombreCliente: map['nombre_cliente'], // null si no se usa el JOIN
      );
}
