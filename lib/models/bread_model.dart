class BreadModel {
  final int? id;
  final String nombre;
  final int idTipo;
  final double precio;
  final String? tipoNombre; // <- nombre del tipo (opcional)


BreadModel({
  this.id,
  required this.nombre,
  required this.idTipo,
  required this.precio,
  this.tipoNombre,
});


  factory BreadModel.fromMap(Map<String, dynamic> json) => BreadModel(
      id: json['id'],
      nombre: json['nombre'],
      idTipo: json['id_tipo'],
      precio: json['precio'],
      tipoNombre: json['tipoNombre'], // <- nombre del tipo si viene del join
    );


  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'id_tipo': idTipo,
    'precio': precio,
  };
}
