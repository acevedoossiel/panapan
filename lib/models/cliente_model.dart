class ClienteModel {
  final int? id;
  final String nombre;
  final String direccion;
  final String telefono;

  ClienteModel({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
  });

  factory ClienteModel.fromMap(Map<String, dynamic> json) => ClienteModel(
    id: json['id'],
    nombre: json['nombre'],
    direccion: json['direccion'],
    telefono: json['telefono'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'direccion': direccion,
    'telefono': telefono,
  };
}
