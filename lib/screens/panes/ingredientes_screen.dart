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
                        _showIngredienteDialog(
                          context,
                          ingredienteProvider,
                          unidadProvider,
                          isEditing: true,
                          ingrediente: ingrediente,
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
              _showAlertaSinUnidades(context);
            }
          } else {
            if (!context.mounted) return;
            _showIngredienteDialog(
              context,
              ingredienteProvider,
              unidadProvider,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAlertaSinUnidades(BuildContext context) {
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

  void _showIngredienteDialog(
    BuildContext context,
    IngredientProvider ingredienteProvider,
    UnidadProvider unidadProvider, {
    bool isEditing = false,
    IngredientModel? ingrediente,
  }) async {
    final nombreCtrl = TextEditingController(
      text: isEditing ? ingrediente!.nombre : '',
    );
    final cantidadCtrl = TextEditingController(
      text: isEditing ? ingrediente!.cantidad.toString() : '',
    );
    int? selectedUnidadId = isEditing ? ingrediente!.idUnidad : null;

    await unidadProvider.loadUnidades();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              isEditing ? "Editar ingrediente" : "Agregar ingrediente",
            ),
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
                  onChanged: (value) => selectedUnidadId = value!,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreCtrl.text.isEmpty ||
                      cantidadCtrl.text.isEmpty ||
                      selectedUnidadId == null)
                    return;

                  final model = IngredientModel(
                    id: isEditing ? ingrediente!.id : null,
                    nombre: nombreCtrl.text,
                    cantidad: double.parse(cantidadCtrl.text),
                    idUnidad: selectedUnidadId!,
                  );

                  if (isEditing) {
                    await ingredienteProvider.updateIngrediente(model);
                  } else {
                    await ingredienteProvider.insertIngrediente(model);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? "Actualizar" : "Guardar"),
              ),
            ],
          ),
    );
  }
}
