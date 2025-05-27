import 'package:flutter/material.dart';
import 'package:panes_app/screens/panes/receta_ingredientes_screen.dart';
import 'package:provider/provider.dart';
import '../../models/bread_model.dart';
import '../../providers/bread_provider.dart';
import '../../providers/tipo_provider.dart';

class VerPanesScreen extends StatelessWidget {
  const VerPanesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breadProvider = Provider.of<BreadProvider>(context);
    final tipoProvider = Provider.of<TipoProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: const Text('Panes'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: breadProvider.loadBreads(),
        builder: (context, snapshot) {
          final panes = breadProvider.breads;

          if (panes.isEmpty) {
            return const Center(
              child: Text(
                "No hay panes aún.",
                style: TextStyle(fontSize: 16, color: Color(0xFF4D3C2B)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: panes.length,
            itemBuilder: (context, index) {
              final pan = panes[index];
              return Card(
                color: const Color(0xFFF2EDE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(
                    pan.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4D3C2B),
                    ),
                  ),
                  subtitle: Text(
                    "Precio: \$${pan.precio.toStringAsFixed(2)} - Tipo: ${pan.tipoNombre ?? 'Desconocido'}",
                    style: const TextStyle(color: Color(0xFF4D3C2B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(
                            context,
                            breadProvider,
                            tipoProvider,
                            pan,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await breadProvider.deleteBread(pan.id!);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.receipt_long,
                          color: Colors.green,
                        ),
                        tooltip: 'Asignar ingredientes',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RecetaIngredientesScreen(
                                    idPan: pan.id!,
                                    nombrePan: pan.nombre,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await tipoProvider.loadTipos();
          if (tipoProvider.tipos.isEmpty) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('No se puede agregar pan'),
                      content: const Text(
                        'Debes registrar al menos un tipo de pan antes de poder agregar uno.',
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
            if (!context.mounted) return;
            _showAddDialog(context, breadProvider, tipoProvider);
          }
        },
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    BreadProvider breadProvider,
    TipoProvider tipoProvider,
  ) async {
    final TextEditingController nombreCtrl = TextEditingController();
    final TextEditingController precioCtrl = TextEditingController();
    int? selectedTipoId;

    await tipoProvider.loadTipos();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Agregar nuevo pan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<int>(
                  value: selectedTipoId,
                  hint: const Text("Selecciona un tipo"),
                  items:
                      tipoProvider.tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo.id,
                              child: Text(tipo.tipo),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedTipoId = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreCtrl.text.isNotEmpty &&
                      precioCtrl.text.isNotEmpty &&
                      selectedTipoId != null) {
                    final nuevo = BreadModel(
                      nombre: nombreCtrl.text,
                      precio: double.parse(precioCtrl.text),
                      idTipo: selectedTipoId!,
                    );
                    await breadProvider.addBread(nuevo);
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
    BreadProvider breadProvider,
    TipoProvider tipoProvider,
    BreadModel pan,
  ) async {
    final TextEditingController nombreCtrl = TextEditingController(
      text: pan.nombre,
    );
    final TextEditingController precioCtrl = TextEditingController(
      text: pan.precio.toString(),
    );
    int selectedTipoId = pan.idTipo;

    await tipoProvider.loadTipos();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Editar pan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<int>(
                  value: selectedTipoId,
                  items:
                      tipoProvider.tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo.id,
                              child: Text(tipo.tipo),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) selectedTipoId = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreCtrl.text.isNotEmpty &&
                      precioCtrl.text.isNotEmpty) {
                    final actualizado = BreadModel(
                      id: pan.id,
                      nombre: nombreCtrl.text,
                      precio: double.parse(precioCtrl.text),
                      idTipo: selectedTipoId,
                    );
                    await breadProvider.updateBread(actualizado);
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
