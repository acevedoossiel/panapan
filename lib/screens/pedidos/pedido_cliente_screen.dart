import 'package:flutter/material.dart';
import 'package:panes_app/screens/pedidos/detalle_pedido_screen.dart';
import 'package:provider/provider.dart';
import '../../db/db_provider.dart';
import '../../models/pedido_cliente_model.dart';
import '../../models/pedido_detalle_model.dart';
import '../../providers/pedido_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/tipo_pan_provider.dart';
import '../../providers/pedido_detalle_provider.dart';
import 'package:intl/intl.dart';

class PedidoClienteScreen extends StatefulWidget {
  const PedidoClienteScreen({super.key});

  @override
  State<PedidoClienteScreen> createState() => _PedidoClienteScreenState();
}

class _PedidoClienteScreenState extends State<PedidoClienteScreen> {
  DateTime? fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    fechaSeleccionada = DateTime.now();
    Provider.of<PedidoProvider>(
      context,
      listen: false,
    ).loadPedidosConClientes();
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = Provider.of<PedidoProvider>(context);
    final clienteProvider = Provider.of<ClienteProvider>(context);

    final pedidosFiltrados =
        pedidoProvider.pedidos.where((pedido) {
          final fechaPedido = DateTime.parse(pedido.fecha);
          return fechaPedido.year == fechaSeleccionada!.year &&
              fechaPedido.month == fechaSeleccionada!.month &&
              fechaPedido.day == fechaSeleccionada!.day;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pedidos de Clientes', style: TextStyle(fontSize: 20)),
            Text(
              '📅 ${DateFormat('dd/MM/yyyy').format(fechaSeleccionada!)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // FILTRO SUPERIOR
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      fechaSeleccionada = DateTime.now();
                    });
                  },
                  child: const Text('Hoy'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada!,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (fecha != null) {
                      setState(() {
                        fechaSeleccionada = fecha;
                      });
                    }
                  },
                  child: const Text('Seleccionar fecha'),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),

          Expanded(
            child:
                pedidosFiltrados.isEmpty
                    ? const Center(
                      child: Text('No hay pedidos para esta fecha'),
                    )
                    : ListView.builder(
                      itemCount: pedidosFiltrados.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidosFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 4,
                          child: ListTile(
                            title: Text('Pedido ID: ${pedido.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente: ${pedido.nombreCliente ?? 'Desconocido'}',
                                ),
                                Text('Fecha: ${formatearFecha(pedido.fecha)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () async {
                                final idPedido = pedido.id;
                                final detallesProvider =
                                    Provider.of<PedidoDetalleProvider>(
                                      context,
                                      listen: false,
                                    );
                                await detallesProvider.loadDetallesForPedido(
                                  idPedido!,
                                );

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => DetallePedidoScreen(
                                            detalles: detallesProvider.detalles,
                                          ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await clienteProvider.loadClientes();
          await Provider.of<TipoPanProvider>(
            context,
            listen: false,
          ).loadTipos();
          if (!context.mounted) return;
          _mostrarFormularioNuevoPedido(context);
        },
        backgroundColor: Colors.amber[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  String formatearFecha(String iso) {
    final fecha = DateTime.parse(iso);
    return DateFormat('dd/MM/yyyy – hh:mm a').format(fecha);
  }

  void _mostrarFormularioNuevoPedido(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    final tipoPanProvider = Provider.of<TipoPanProvider>(
      context,
      listen: false,
    );
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final detalleProvider = Provider.of<PedidoDetalleProvider>(
      context,
      listen: false,
    );

    final cantidadControllers = <int, TextEditingController>{};
    int? clienteSeleccionado;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nuevo Pedido"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      hint: const Text("Selecciona un cliente"),
                      value: clienteSeleccionado,
                      items:
                          clienteProvider.clientes
                              .map(
                                (cliente) => DropdownMenuItem(
                                  value: cliente.id,
                                  child: Text(cliente.nombre),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              setState(() => clienteSeleccionado = value),
                    ),
                    const SizedBox(height: 10),
                    ...tipoPanProvider.tipos
                        .where(
                          (tipo) =>
                              tipo.tipo == 'Dulce' ||
                              !tipo.tipo.startsWith('Dulce '),
                        )
                        .map((tipo) {
                          final controller = TextEditingController();
                          cantidadControllers[tipo.id!] = controller;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(child: Text(tipo.tipo)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Cantidad',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (clienteSeleccionado == null) return;

                double total = 0;
                List<Map<String, dynamic>> detalles = [];

                for (var tipo in tipoPanProvider.tipos.where(
                  (tipo) =>
                      tipo.tipo == 'Dulce' || !tipo.tipo.startsWith('Dulce '),
                )) {
                  final controller = cantidadControllers[tipo.id!];
                  if (controller == null) continue;

                  final cantidad = int.tryParse(controller.text) ?? 0;
                  if (cantidad > 0) {
                    total += cantidad * tipo.precioBase;
                    detalles.add({'id_tipo': tipo.id!, 'cantidad': cantidad});
                  }
                }

                if (detalles.isEmpty) return;

                final nuevoPedido = PedidoClienteModel(
                  idCliente: clienteSeleccionado!,
                  fecha: DateTime.now().toIso8601String(),
                  total: total,
                );

                final idPedido = await pedidoProvider.insertPedido(nuevoPedido);

                for (var det in detalles) {
                  await detalleProvider.insertDetalle(
                    idPedido,
                    det['id_tipo'],
                    det['cantidad'],
                  );
                }

                await pedidoProvider.loadPedidosConClientes();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Guardar Pedido"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarResumenDetalles(
    BuildContext context,
    List<PedidoDetalleModel> detalles,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Detalle del pedido'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: detalles.length,
                itemBuilder: (context, index) {
                  final detalle = detalles[index];
                  return ListTile(
                    title: Text(detalle.tipoPanNombre ?? 'Tipo desconocido'),
                    trailing: Text('x${detalle.cantidad}'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _mostrarModalAsignarDulces(
    BuildContext context,
    PedidoDetalleModel dulce,
  ) {
    final criolloCtrl = TextEditingController();
    final finoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Asignar dulces'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cantidad total: ${dulce.cantidad}'),
                TextField(
                  controller: criolloCtrl,
                  decoration: const InputDecoration(labelText: 'Dulce Criollo'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: finoCtrl,
                  decoration: const InputDecoration(labelText: 'Dulce Fino'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final criollo = int.tryParse(criolloCtrl.text) ?? 0;
                  final fino = int.tryParse(finoCtrl.text) ?? 0;
                  final total = criollo + fino;

                  if (total != dulce.cantidad) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('La suma debe ser ${dulce.cantidad}'),
                      ),
                    );
                    return;
                  }

                  final detalleProvider = Provider.of<PedidoDetalleProvider>(
                    context,
                    listen: false,
                  );
                  final db = await DBProvider.db.database;

                  await db.delete(
                    'pedido_cliente_detalle',
                    where: 'id = ?',
                    whereArgs: [dulce.id],
                  );

                  final idPedido = dulce.idPedidoCliente;
                  final idCriollo = await db.query(
                    'tipos',
                    where: "tipo = ?",
                    whereArgs: ['Dulce Criollo'],
                  );
                  final idFino = await db.query(
                    'tipos',
                    where: "tipo = ?",
                    whereArgs: ['Dulce Fino'],
                  );

                  if (idCriollo.isNotEmpty && idFino.isNotEmpty) {
                    await detalleProvider.insertDetalle(
                      idPedido,
                      idCriollo.first['id'] as int,
                      criollo,
                    );
                    await detalleProvider.insertDetalle(
                      idPedido,
                      idFino.first['id'] as int,
                      fino,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
    );
  }
}
