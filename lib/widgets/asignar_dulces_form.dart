import 'package:flutter/material.dart';

class AsignarDulcesForm extends StatelessWidget {
  final int cantidadTotal;
  final TextEditingController criolloCtrl;
  final TextEditingController finoCtrl;

  const AsignarDulcesForm({
    super.key,
    required this.cantidadTotal,
    required this.criolloCtrl,
    required this.finoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Cantidad total: $cantidadTotal'),
        TextField(
          controller: criolloCtrl,
          decoration: const InputDecoration(labelText: 'Dulce Criollo'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: finoCtrl,
          decoration: const InputDecoration(labelText: 'Dulce Fino'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
