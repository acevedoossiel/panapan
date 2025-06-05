import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pedido_detalle_model.dart';
import '../../providers/pedido_detalle_provider.dart';
import '../../db/db_provider.dart';

class ResumenIngredientesDiaScreen extends StatefulWidget {
  final DateTime fecha;

  const ResumenIngredientesDiaScreen({super.key, required this.fecha});

  @override
  State<ResumenIngredientesDiaScreen> createState() =>
      _ResumenIngredientesDiaScreenState();
}

class _ResumenIngredientesDiaScreenState
    extends State<ResumenIngredientesDiaScreen> {
  late Future<List<PedidoDetalleModel>> _futureDetalles;

  @override
  void initState() {
    super.initState();
    _futureDetalles = _cargarDetallesDelDia(widget.fecha);
  }

  Future<List<PedidoDetalleModel>> _cargarDetallesDelDia(DateTime fecha) async {
    final detalleProvider = Provider.of<PedidoDetalleProvider>(
      context,
      listen: false,
    );
    return await detalleProvider.loadDetallesPorFecha(fecha);
  }

  Future<List<List<Map<String, dynamic>>>> _generarIngredientesPorDetalle(
    List<PedidoDetalleModel> detalles,
  ) async {
    final db = await DBProvider.db.database;

    return await Future.wait(
      detalles.map((detalle) async {
        final receta = await db.rawQuery(
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
          [detalle.idTipoPan],
        );

        final tipoPan = await db.query(
          'tipos',
          where: 'id = ?',
          whereArgs: [detalle.idTipoPan],
        );

        final panesPorCharola =
            tipoPan.isNotEmpty
                ? tipoPan.first['cantidad_por_charola'] as int
                : 1;

        return receta.map((item) {
          final cantidadPorCharola = item['cantidad'] as double;
          final cantidadPorPan = cantidadPorCharola / panesPorCharola;
          final total = cantidadPorPan * detalle.cantidad;

          return {
            'ingrediente': item['ingrediente'] as String,
            'unidad': item['unidad'] as String,
            'cantidad': total,
            'pan': detalle.tipoPanNombre ?? 'Tipo desconocido',
            'cantidad_panes': detalle.cantidad,
          };
        }).toList();
      }),
    );
  }

  List<Map<String, dynamic>> sumarIngredientesTotales(
    List<List<Map<String, dynamic>>> listasIngredientes,
  ) {
    final Map<String, Map<String, dynamic>> totales = {};
    for (final lista in listasIngredientes) {
      for (final ingrediente in lista) {
        final String nombre = ingrediente['ingrediente'] as String;
        final String unidad = ingrediente['unidad'] as String;
        final double cantidad = ingrediente['cantidad'] as double;

        if (totales.containsKey(nombre)) {
          totales[nombre]!['cantidad'] += cantidad;
        } else {
          totales[nombre] = {
            'ingrediente': nombre,
            'unidad': unidad,
            'cantidad': cantidad,
          };
        }
      }
    }
    return totales.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat('d/M/yyyy').format(widget.fecha);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ingredientes del $fechaTexto'),
        backgroundColor: Colors.amber[800],
      ),
      body: FutureBuilder<List<PedidoDetalleModel>>(
        future: _futureDetalles,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final detalles = snapshot.data!;
          if (detalles.isEmpty) {
            return const Center(child: Text('No hay pedidos en esta fecha.'));
          }

          return FutureBuilder<List<List<Map<String, dynamic>>>>(
            future: _generarIngredientesPorDetalle(detalles),
            builder: (context, resumenSnapshot) {
              if (!resumenSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final listasIngredientes = resumenSnapshot.data!;
              final totales = sumarIngredientesTotales(listasIngredientes);

              return ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  ...List.generate(detalles.length, (index) {
                    final detalle = detalles[index];
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
                                double cantidad = ingrediente['cantidad'];
                                String unidad = ingrediente['unidad'];

                                if (unidad == 'gr' && cantidad >= 1000) {
                                  cantidad = cantidad / 1000;
                                  unidad = 'kg';
                                } else if (unidad == 'ml' && cantidad >= 1000) {
                                  cantidad = cantidad / 1000;
                                  unidad = 'L';
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(ingrediente['ingrediente']),
                                      Text(
                                        '${cantidad.toStringAsFixed(2)} $unidad',
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
                              'Ingredientes totales del día',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...totales.map((ingrediente) {
                              double cantidad = ingrediente['cantidad'];
                              String unidad = ingrediente['unidad'];

                              if (unidad == 'gr' && cantidad >= 1000) {
                                cantidad = cantidad / 1000;
                                unidad = 'kg';
                              } else if (unidad == 'ml' && cantidad >= 1000) {
                                cantidad = cantidad / 1000;
                                unidad = 'L';
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(ingrediente['ingrediente']),
                                    Text(
                                      '${cantidad.toStringAsFixed(2)} $unidad',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
