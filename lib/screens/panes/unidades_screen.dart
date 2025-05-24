import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/unidad_model.dart';
import '../../../providers/unidad_provider.dart';

class UnidadesScreen extends StatelessWidget {
  const UnidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unidadProvider = Provider.of<UnidadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unidades'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: unidadProvider.loadUnidades(),
        builder: (context, snapshot) {
          final unidades = unidadProvider.unidades;

          return ListView.builder(
            itemCount: unidades.length,
            itemBuilder: (context, index) {
              final unidad = unidades[index];
              return ListTile(
                title: Text(unidad.tipo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(context, unidadProvider, unidad);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await unidadProvider.deleteUnidad(unidad.id!);
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
        onPressed: () => _showAddDialog(context, unidadProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, UnidadProvider unidadProvider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar unidad"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              final texto = controller.text.trim();
              if (texto.isNotEmpty) {
                await unidadProvider.insertUnidad(texto);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, UnidadProvider unidadProvider, UnidadModel unidad) {
    final TextEditingController controller = TextEditingController(text: unidad.tipo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar unidad"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              final texto = controller.text.trim();
              if (texto.isNotEmpty) {
                await unidadProvider.updateUnidad(unidad.id!, texto);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Actualizar"),
          )
        ],
      ),
    );
  }
}
