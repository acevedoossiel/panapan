import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pedido_detalle_model.dart';
import '../../providers/pedido_detalle_provider.dart';
import '../../db/db_provider.dart';

class DetallePedidoScreen extends StatefulWidget {
  final List<PedidoDetalleModel> detalles;

  const DetallePedidoScreen({
    super.key,
    required this.detalles,
  });

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panDulceList = widget.detalles
          .where((d) => d.tipoPanNombre == 'Dulce')
          .toList();

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
body: ListView.builder(
  itemCount: widget.detalles.length,
  itemBuilder: (context, index) {
    final detalle = widget.detalles[index];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: cargarReceta(detalle.idTipoPan).then((receta) async {
        final db = await DBProvider.db.database;
        final tipoPan = await db.query(
          'tipos',
          where: 'id = ?',
          whereArgs: [detalle.idTipoPan],
        );

        final panesPorCharola = tipoPan.isNotEmpty
            ? tipoPan.first['cantidad_por_charola'] as int
            : 1;

        return calcularIngredientesPorPedido(
          receta: receta,
          panesPorCharola: panesPorCharola,
          totalPanesPedido: detalle.cantidad,
        );
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListTile(
            title: Text(detalle.tipoPanNombre ?? 'Tipo desconocido'),
            trailing: Text('x${detalle.cantidad}'),
          );
        }

        final ingredientes = snapshot.data!;

        return ExpansionTile(
          title: Text(detalle.tipoPanNombre ?? 'Tipo desconocido'),
          trailing: Text('x${detalle.cantidad}'),
          children: ingredientes.map((ingrediente) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ingrediente['ingrediente']),
                  Text('${ingrediente['cantidadNecesaria'].toStringAsFixed(2)} ${ingrediente['unidad']}'),
                ],
              ),
            );
          }).toList(),
        );
      },
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
      builder: (_) => AlertDialog(
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

  final resultado = await db.rawQuery('''
    SELECT 
      ic.nombre AS ingrediente,
      rtp.cantidad,
      u.nombre AS unidad
    FROM receta_tipo_pan rtp
    JOIN ingredientes_catalogo ic ON ic.id = rtp.id_ingrediente
    JOIN unidades u ON u.id = rtp.id_unidad
    WHERE rtp.id_tipo_pan = ?
  ''', [idTipoPan]);

  print('Receta para tipoPan $idTipoPan: $resultado'); // 👈 importante

  return resultado;
}



}
