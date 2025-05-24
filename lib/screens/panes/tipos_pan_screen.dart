import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/tipo_model.dart';
import '../../../providers/tipo_provider.dart';

class TiposPanScreen extends StatelessWidget {
  const TiposPanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tipoProvider = Provider.of<TipoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipos de Pan'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: tipoProvider.loadTipos(),
        builder: (context, snapshot) {
          final tipos = tipoProvider.tipos;

          return ListView.builder(
            itemCount: tipos.length,
            itemBuilder: (context, index) {
              final tipo = tipos[index];
              return ListTile(
                title: Text(tipo.tipo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(context, tipoProvider, tipo);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await tipoProvider.deleteTipo(tipo.id!);
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
          _showAddDialog(context, tipoProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, TipoProvider tipoProvider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Agregar nuevo tipo de pan"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () async {
                  final nuevo = controller.text.trim();
                  if (nuevo.isNotEmpty) {
                    await tipoProvider.insertTipo(nuevo);
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
    TipoProvider tipoProvider,
    TipoModel tipo,
  ) {
    final TextEditingController controller = TextEditingController(
      text: tipo.tipo,
    );
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editar tipo de pan"),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () async {
                  final actualizado = controller.text.trim();
                  if (actualizado.isNotEmpty) {
                    await tipoProvider.updateTipo(tipo.id!, actualizado);
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
