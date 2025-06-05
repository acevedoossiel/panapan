import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pedido_detalle_model.dart';
import '../../providers/pedido_detalle_provider.dart';
import '../../db/db_provider.dart';
import '../../widgets/asignar_dulces_form.dart';

class DetallePedidoScreen extends StatefulWidget {
  final List<PedidoDetalleModel> detalles;

  const DetallePedidoScreen({super.key, required this.detalles});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panDulceList =
          widget.detalles.where((d) => d.tipoPanNombre == 'Dulce').toList();

      if (panDulceList.isNotEmpty) {
        _mostrarModalAsignarDulces(context, panDulceList.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        backgroundColor: Colors.amber[800],
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: Future.wait(
          widget.detalles.map((detalle) async {
            final receta = await cargarReceta(detalle.idTipoPan);
            final db = await DBProvider.db.database;
            final tipoPan = await db.query(
              'tipos',
              where: 'id = ?',
              whereArgs: [detalle.idTipoPan],
            );

            final panesPorCharola =
                tipoPan.isNotEmpty
                    ? tipoPan.first['cantidad_por_charola'] as int
                    : 1;

            return calcularIngredientesPorPedido(
              receta: receta,
              panesPorCharola: panesPorCharola,
              totalPanesPedido: detalle.cantidad,
            );
          }),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final listasIngredientes = snapshot.data!;
          final totales = sumarIngredientesTotales(listasIngredientes);

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              ...List.generate(widget.detalles.length, (index) {
                final detalle = widget.detalles[index];
                final ingredientes = listasIngredientes[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detalle.tipoPanNombre ?? 'Tipo desconocido',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Piezas solicitadas: x${detalle.cantidad}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const Divider(height: 20, thickness: 1.5),
                          ...ingredientes.map((ingrediente) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ingrediente['ingrediente'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${ingrediente['cantidadNecesaria'].toStringAsFixed(2)} ${ingrediente['unidad']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  color: Colors.amber[100],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredientes totales del pedido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...totales.map((ingrediente) {
                          String nombre = ingrediente['ingrediente'];
                          String unidad = ingrediente['unidad'];
                          double cantidad = ingrediente['cantidad'];

                          // Convertimos si es posible
                          if (unidad == 'gr' && cantidad >= 1000) {
                            cantidad = cantidad / 1000;
                            unidad = 'kg';
                          } else if (unidad == 'ml' && cantidad >= 1000) {
                            cantidad = cantidad / 1000;
                            unidad = 'L';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(nombre),
                                Text('${cantidad.toStringAsFixed(2)} $unidad'),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
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
            content: AsignarDulcesForm(
              cantidadTotal: dulce.cantidad,
              criolloCtrl: criolloCtrl,
              finoCtrl: finoCtrl,
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

  List<Map<String, dynamic>> calcularIngredientesPorPedido({
    required List<Map<String, dynamic>> receta,
    required int panesPorCharola,
    required int totalPanesPedido,
  }) {
    return receta.map((item) {
      final cantidadPorCharola = item['cantidad'] as double;
      final cantidadPorPan = cantidadPorCharola / panesPorCharola;
      final total = cantidadPorPan * totalPanesPedido;

      return {
        'ingrediente': item['ingrediente'],
        'unidad': item['unidad'],
        'cantidadNecesaria': total,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> cargarReceta(int idTipoPan) async {
    final db = await DBProvider.db.database;

    final resultado = await db.rawQuery(
      '''
    SELECT 
      ic.nombre AS ingrediente,
      rtp.cantidad,
      u.tipo AS unidad 
    FROM receta_tipo_pan rtp
    JOIN ingredientes_catalogo ic ON ic.id = rtp.id_ingrediente
    JOIN unidades u ON u.id = rtp.id_unidad
    WHERE rtp.id_tipo_pan = ?
  ''',
      [idTipoPan],
    );

    // ignore: avoid_print
    print('Receta para tipoPan $idTipoPan: $resultado'); // 👈 importante

    return resultado;
  }

  List<Map<String, dynamic>> sumarIngredientesTotales(
    List<List<Map<String, dynamic>>> listasIngredientes,
  ) {
    final Map<String, Map<String, dynamic>> mapaTotales = {};

    for (final lista in listasIngredientes) {
      for (final ingrediente in lista) {
        final nombre = ingrediente['ingrediente'];
        final unidad = ingrediente['unidad'];
        final cantidad = ingrediente['cantidadNecesaria'] as double;

        if (mapaTotales.containsKey(nombre)) {
          mapaTotales[nombre]!['cantidad'] += cantidad;
        } else {
          mapaTotales[nombre] = {
            'ingrediente': nombre,
            'unidad': unidad,
            'cantidad': cantidad,
          };
        }
      }
    }

    return mapaTotales.values.toList();
  }
}
