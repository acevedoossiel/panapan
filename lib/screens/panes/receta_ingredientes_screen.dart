import 'package:flutter/material.dart';
import 'package:panes_app/models/receta_model.dart';
import 'package:panes_app/providers/ingredient_provider.dart';
import 'package:panes_app/providers/receta_provider.dart';
import 'package:provider/provider.dart';

class RecetaIngredientesScreen extends StatelessWidget {
  final int idPan;
  final String nombrePan;

  const RecetaIngredientesScreen({
    super.key,
    required this.idPan,
    required this.nombrePan,
  });

  @override
  Widget build(BuildContext context) {
    final recetaProvider = Provider.of<RecetaProvider>(context);
    final ingredienteProvider = Provider.of<IngredientProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Receta: $nombrePan'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder(
        future: recetaProvider.loadRecetaForPan(idPan),
        builder: (context, snapshot) {
          final recetas = recetaProvider.recetas;
          return ListView.builder(
            itemCount: recetas.length,
            itemBuilder: (context, index) {
              final r = recetas[index];
              return ListTile(
                title: Text(r.ingredienteNombre ?? '¿?'),
                subtitle: Text('${r.cantidad} ${r.unidadNombre ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    recetaProvider.deleteReceta(r.id!, idPan);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ingredienteProvider.loadIngredientes();

          if (!context.mounted) return;

          _showAddDialog(context, recetaProvider, ingredienteProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    RecetaProvider recetaProvider,
    IngredientProvider ingredienteProvider,
  ) {
    int? ingredienteId;
    String? unidadNombre;
    final cantidadCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Agregar ingrediente"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      hint: const Text("Ingrediente"),
                      items:
                          ingredienteProvider.ingredientes.map((i) {
                            return DropdownMenuItem(
                              value: i.id,
                              child: Text(i.nombre),
                            );
                          }).toList(),
                      onChanged: (v) {
                        final ingrediente = ingredienteProvider.ingredientes
                            .firstWhere((i) => i.id == v);
                        setState(() {
                          ingredienteId = v;
                          unidadNombre = ingrediente.unidadNombre;
                        });
                      },
                    ),
                    if (unidadNombre != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Unidad: $unidadNombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    TextField(
                      controller: cantidadCtrl,
                      decoration: const InputDecoration(labelText: "Cantidad"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (ingredienteId != null &&
                          cantidadCtrl.text.isNotEmpty) {
                        final receta = RecetaIngredienteModel(
                          idPan: idPan,
                          idIngrediente: ingredienteId!,
                          cantidad: double.parse(cantidadCtrl.text),
                        );
                        await recetaProvider.insertReceta(receta);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text("Guardar"),
                  ),
                ],
              );
            },
          ),
    );
  }
}
