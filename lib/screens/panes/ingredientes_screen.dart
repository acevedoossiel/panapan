import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/ingredient_model.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../providers/unidad_provider.dart';

class IngredientesScreen extends StatelessWidget {
  const IngredientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ingredienteProvider = Provider.of<IngredientProvider>(context);
    final unidadProvider = Provider.of<UnidadProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: ingredienteProvider.loadIngredientes(),
        builder: (context, snapshot) {
          final ingredientes = ingredienteProvider.ingredientes;

          return ListView.builder(
            itemCount: ingredientes.length,
            itemBuilder: (context, index) {
              final ingrediente = ingredientes[index];
              return ListTile(
                title: Text(ingrediente.nombre),
                subtitle: Text(
                  'Stock: ${ingrediente.cantidad} ${ingrediente.unidadNombre ?? '¿?'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(
                          context,
                          ingredienteProvider,
                          unidadProvider,
                          ingrediente,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await ingredienteProvider.deleteIngrediente(
                          ingrediente.id!,
                        );
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
        onPressed: () async {
          await unidadProvider.loadUnidades();

          if (unidadProvider.unidades.isEmpty) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('No se puede agregar ingrediente'),
                      content: const Text(
                        'Debes registrar al menos una unidad antes de poder agregar un ingrediente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
              );
            }
          } else {
            _showAddDialog(context, ingredienteProvider, unidadProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    IngredientProvider ingredienteProvider,
    UnidadProvider unidadProvider,
  ) async {
    final TextEditingController nombreCtrl = TextEditingController();
    final TextEditingController cantidadCtrl = TextEditingController();
    int? selectedUnidadId;

    await unidadProvider.loadUnidades();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Agregar ingrediente"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: cantidadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
                DropdownButtonFormField<int>(
                  value: selectedUnidadId,
                  hint: const Text("Selecciona unidad"),
                  items:
                      unidadProvider.unidades
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.tipo),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedUnidadId = value!;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreCtrl.text.isNotEmpty &&
                      cantidadCtrl.text.isNotEmpty &&
                      selectedUnidadId != null) {
                    final nuevo = IngredientModel(
                      nombre: nombreCtrl.text,
                      cantidad: double.parse(cantidadCtrl.text),
                      idUnidad: selectedUnidadId!,
                    );
                    await ingredienteProvider.insertIngrediente(nuevo);
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
    IngredientProvider ingredienteProvider,
    UnidadProvider unidadProvider,
    IngredientModel ingrediente,
  ) async {
    final TextEditingController nombreCtrl = TextEditingController(
      text: ingrediente.nombre,
    );
    final TextEditingController cantidadCtrl = TextEditingController(
      text: ingrediente.cantidad.toString(),
    );
    int selectedUnidadId = ingrediente.idUnidad;

    await unidadProvider.loadUnidades();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editar ingrediente"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: cantidadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
                DropdownButtonFormField<int>(
                  value: selectedUnidadId,
                  items:
                      unidadProvider.unidades
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.tipo),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) selectedUnidadId = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final actualizado = IngredientModel(
                    id: ingrediente.id,
                    nombre: nombreCtrl.text,
                    cantidad: double.parse(cantidadCtrl.text),
                    idUnidad: selectedUnidadId,
                  );
                  await ingredienteProvider.updateIngrediente(actualizado);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Actualizar"),
              ),
            ],
          ),
    );
  }
}
