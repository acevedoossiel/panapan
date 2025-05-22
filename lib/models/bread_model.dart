class BreadModel {
  int id;
  String name;
  String baker; // Panadero/horneador (antes "developer")
  String type; // Tipo de pan (antes "genre")
  String imageLink;
  String description;
  double price;

  BreadModel({
    required this.id,
    required this.name,
    required this.baker,
    required this.type,
    required this.imageLink,
    required this.description,
    required this.price,
  });

  factory BreadModel.fromJSON(Map<String, dynamic> json) {
    return BreadModel(
      id: json['id'],
      name: json['name'],
      baker: json['baker'],
      type: json['type'],
      imageLink: json['imageLink'],
      description: json['description'],
      price: (json['price'] as num).toDouble(), // Asegura que sea double
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'baker': baker,
      'type': type,
      'imageLink': imageLink,
      'description': description,
      'price': price,
    };
  }
}
