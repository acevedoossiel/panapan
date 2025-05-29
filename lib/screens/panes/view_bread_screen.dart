import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bread_model.dart';
import '../../providers/bread_provider.dart';

class VerPanesScreen extends StatefulWidget {
  const VerPanesScreen({super.key});

  @override
  State<VerPanesScreen> createState() => _VerPanesScreenState();
}

class _VerPanesScreenState extends State<VerPanesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<BreadProvider>(context, listen: false).loadBreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: const Text('Panes'),
        backgroundColor: Colors.amber[700],
      ),
      body: Consumer<BreadProvider>(
        builder: (context, breadProvider, _) {
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
                    "Precio: \$${pan.precio.toStringAsFixed(2)}",
                    style: const TextStyle(color: Color(0xFF4D3C2B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _mostrarDialogoPan(context, breadProvider, pan);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await breadProvider.deleteBread(pan.id!);
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
        onPressed: () {
          _mostrarDialogoPan(
            context,
            Provider.of<BreadProvider>(context, listen: false),
          );
        },
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoPan(
    BuildContext context,
    BreadProvider breadProvider, [
    PanModel? pan,
  ]) {
    final isEditing = pan != null;
    final nombreCtrl = TextEditingController(text: pan?.nombre ?? '');
    final detallesCtrl = TextEditingController(text: pan?.detalles ?? '');
    final recetaUnidadCtrl = TextEditingController(
      text: pan?.recetaUnidad ?? '',
    );
    final precioCtrl = TextEditingController(
      text: pan?.precio.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isEditing ? "Editar pan" : "Agregar nuevo pan"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: detallesCtrl,
                    decoration: const InputDecoration(labelText: 'Detalles'),
                  ),
                  TextField(
                    controller: recetaUnidadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unidad de receta',
                    ),
                  ),
                  TextField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    final nombre = nombreCtrl.text.trim();
                    final detalles = detallesCtrl.text.trim();
                    final recetaUnidad = recetaUnidadCtrl.text.trim();
                    final precio = double.tryParse(precioCtrl.text.trim());

                    if (nombre.isNotEmpty && precio != null) {
                      final nuevoPan = PanModel(
                        id: isEditing ? pan.id : null,
                        nombre: nombre,
                        detalles: detalles,
                        recetaUnidad: recetaUnidad,
                        precio: precio,
                      );

                      if (isEditing) {
                        await breadProvider.updateBread(nuevoPan);
                      } else {
                        await breadProvider.addBread(nuevoPan);
                      }

                      if (context.mounted) Navigator.pop(context);
                    }
                  } catch (e) {
                    // ignore: avoid_print
                    print("Error al guardar pan: $e");
                  }
                },
                child: Text(isEditing ? "Actualizar" : "Guardar"),
              ),
            ],
          ),
    );
  }
}
