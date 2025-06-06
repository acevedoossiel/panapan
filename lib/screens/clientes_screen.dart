import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cliente_model.dart';
import '../../../providers/cliente_provider.dart';
import '../../../widgets/cliente_form.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder(
        future: clienteProvider.loadClientes(),
        builder: (context, snapshot) {
          final clientes = clienteProvider.clientes;

          return ListView.builder(
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return ListTile(
                title: Text(cliente.nombre),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.teal),
                      onPressed: () {
                        _showEditDialog(context, clienteProvider, cliente);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await clienteProvider.deleteCliente(cliente.id!);
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
        onPressed: () => _showAddDialog(context, clienteProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, ClienteProvider clienteProvider) {
    final nombreCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Nuevo cliente"),
            content: ClienteForm(
              nombreCtrl: nombreCtrl,
              direccionCtrl: direccionCtrl,
              telefonoCtrl: telefonoCtrl,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreCtrl.text.isNotEmpty) {
                    final nuevo = ClienteModel(
                      nombre: nombreCtrl.text,
                      direccion: direccionCtrl.text,
                      telefono: telefonoCtrl.text,
                    );
                    await clienteProvider.insertCliente(nuevo);
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
    ClienteProvider clienteProvider,
    ClienteModel cliente,
  ) {
    final nombreCtrl = TextEditingController(text: cliente.nombre);
    final direccionCtrl = TextEditingController(text: cliente.direccion);
    final telefonoCtrl = TextEditingController(text: cliente.telefono);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Ver/Editar cliente"),
            content: ClienteForm(
              nombreCtrl: nombreCtrl,
              direccionCtrl: direccionCtrl,
              telefonoCtrl: telefonoCtrl,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final actualizado = ClienteModel(
                    id: cliente.id,
                    nombre: nombreCtrl.text,
                    direccion: direccionCtrl.text,
                    telefono: telefonoCtrl.text,
                  );
                  await clienteProvider.updateCliente(actualizado);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Actualizar"),
              ),
            ],
          ),
    );
  }
}
