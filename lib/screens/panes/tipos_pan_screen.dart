import 'package:flutter/material.dart';
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
                        _showEditDialog(context, tipoPanProvider, tipo);
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
          _showAddDialog(context, tipoPanProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, TipoPanProvider provider) {
    final TextEditingController tipoCtrl = TextEditingController();
    final TextEditingController precioCtrl = TextEditingController();
    final TextEditingController cantidadCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Agregar nuevo tipo de pan"),
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
                  final tipo = tipoCtrl.text.trim();
                  final precio = double.tryParse(precioCtrl.text.trim());
                  final cantidad = int.tryParse(cantidadCtrl.text.trim());

                  if (tipo.isNotEmpty && precio != null && cantidad != null) {
                    final nuevo = TipoPanModel(
                      tipo: tipo,
                      precioBase: precio,
                      cantidadPorCharola: cantidad,
                    );
                    await provider.insertTipo(nuevo);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    TipoPanProvider provider,
    TipoPanModel tipo,
  ) {
    final TextEditingController tipoCtrl = TextEditingController(
      text: tipo.tipo,
    );
    final TextEditingController precioCtrl = TextEditingController(
      text: tipo.precioBase.toString(),
    );
    final TextEditingController cantidadCtrl = TextEditingController(
      text: tipo.cantidadPorCharola.toString(),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editar tipo de pan"),
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
                    final actualizado = TipoPanModel(
                      id: tipo.id,
                      tipo: tipoText,
                      precioBase: precio,
                      cantidadPorCharola: cantidad,
                    );
                    await provider.updateTipo(actualizado);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Actualizar"),
              ),
            ],
          ),
    );
  }
}
