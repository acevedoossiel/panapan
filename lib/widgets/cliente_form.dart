import 'package:flutter/material.dart';

class ClienteForm extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController direccionCtrl;
  final TextEditingController telefonoCtrl;

  const ClienteForm({
    super.key,
    required this.nombreCtrl,
    required this.direccionCtrl,
    required this.telefonoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        TextField(
          controller: direccionCtrl,
          decoration: const InputDecoration(labelText: 'Dirección'),
        ),
        TextField(
          controller: telefonoCtrl,
          decoration: const InputDecoration(labelText: 'Teléfono'),
        ),
      ],
    );
  }
}
