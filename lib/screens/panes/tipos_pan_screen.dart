import 'package:flutter/material.dart';
import 'package:panes_app/screens/calculadora/calculadora_screens.dart';
import 'package:provider/provider.dart';
import '../../../models/tipo_pan_model.dart';
import '../../../providers/tipo_pan_provider.dart';

class TiposPanScreen extends StatelessWidget {
  const TiposPanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tipoPanProvider = Provider.of<TipoPanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Pan HD'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: tipoPanProvider.loadTipos(),
        builder: (context, snapshot) {
          final tipos = tipoPanProvider.tipos;

          return ListView.builder(
            itemCount: tipos.length,
            itemBuilder: (context, index) {
              final tipo = tipos[index];
              return ListTile(
                title: Text(tipo.tipo),
                subtitle: Text(
                  'Precio: \$${tipo.precioBase} - Charolas: ${tipo.cantidadPorCharola}',
                ),
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () {
        _mostrarDialogoTipoPan(
          context,
          tipoPanProvider,
          isEditing: true,
          tipoPan: tipo,
        );
      },
    ),
    if (tipo.tipo != 'Dulce') // 👈 solo si no es "Dulce"
      IconButton(
        icon: const Icon(Icons.calculate, color: Colors.deepPurple),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CalculadoraScreen(tipo: tipo),
            ),
          );
        },
      ),
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        await tipoPanProvider.deleteTipo(tipo.id!);
      },
    ),
  ],
),


              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoTipoPan(context, tipoPanProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoTipoPan(
    BuildContext context,
    TipoPanProvider provider, {
    bool isEditing = false,
    TipoPanModel? tipoPan,
  }) {
    final tipoCtrl = TextEditingController(
      text: isEditing ? tipoPan!.tipo : '',
    );
    final precioCtrl = TextEditingController(
      text: isEditing ? tipoPan!.precioBase.toString() : '',
    );
    final cantidadCtrl = TextEditingController(
      text: isEditing ? tipoPan!.cantidadPorCharola.toString() : '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              isEditing ? "Editar tipo de pan" : "Agregar nuevo tipo de pan",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tipoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del tipo',
                  ),
                ),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio Base'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cantidadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Panes por charola',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final tipoText = tipoCtrl.text.trim();
                  final precio = double.tryParse(precioCtrl.text.trim());
                  final cantidad = int.tryParse(cantidadCtrl.text.trim());

                  if (tipoText.isNotEmpty &&
                      precio != null &&
                      cantidad != null) {
                    final model = TipoPanModel(
                      id: isEditing ? tipoPan!.id : null,
                      tipo: tipoText,
                      precioBase: precio,
                      cantidadPorCharola: cantidad,
                    );

                    if (isEditing) {
                      await provider.updateTipo(model);
                    } else {
                      await provider.insertTipo(model);
                    }

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? "Actualizar" : "Guardar"),
              ),
            ],
          ),
    );
  }
}
