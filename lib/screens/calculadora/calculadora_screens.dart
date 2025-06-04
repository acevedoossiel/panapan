import 'package:flutter/material.dart';
import '../../../models/tipo_pan_model.dart';
import '../../db/db_provider.dart';

class CalculadoraScreen extends StatefulWidget {
  final TipoPanModel tipo;

  const CalculadoraScreen({super.key, required this.tipo});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  List<Map<String, dynamic>> ingredientes = [];
  List<Map<String, dynamic>> unidades = [];
  List<Map<String, dynamic>> receta = [];

  int? selectedIngredienteId;
  int? selectedUnidadId;
  final cantidadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = await DBProvider.db.database;

    final ingr = await db.query('ingredientes_catalogo');
    final unid = await db.query('unidades');

    setState(() {
      ingredientes = ingr;
      unidades = unid;
    });

    await _cargarReceta(); // Cargar lo que ya se ha guardado
  }

  Future<void> _cargarReceta() async {
    final db = await DBProvider.db.database;

    final data = await db.rawQuery('''
      SELECT r.id, i.nombre AS ingrediente, r.cantidad, u.tipo AS unidad
      FROM receta_tipo_pan r
      JOIN ingredientes_catalogo i ON r.id_ingrediente = i.id
      JOIN unidades u ON r.id_unidad = u.id
      WHERE r.id_tipo_pan = ?
    ''', [widget.tipo.id]);

    setState(() {
      receta = data;
    });
  }

  Future<void> _insertarRecetaTipoPan() async {
    final db = await DBProvider.db.database;

    await db.insert('receta_tipo_pan', {
      'id_tipo_pan': widget.tipo.id,
      'id_ingrediente': selectedIngredienteId,
      'cantidad': double.tryParse(cantidadCtrl.text),
      'id_unidad': selectedUnidadId,
    });

    if (mounted) {
      Navigator.pop(context); // cerrar el modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrediente guardado con éxito')),
      );
    }

    await _cargarReceta(); // Actualizar lista
  }

  void _mostrarModalAgregar() {
    cantidadCtrl.clear();
    selectedIngredienteId = null;
    selectedUnidadId = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar ingrediente a receta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Ingrediente"),
              value: selectedIngredienteId,
              items: ingredientes.map((ing) {
                return DropdownMenuItem<int>(
                  value: ing['id'],
                  child: Text(ing['nombre']),
                );
              }).toList(),
              onChanged: (val) => selectedIngredienteId = val,
            ),
            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad"),
            ),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Unidad"),
              value: selectedUnidadId,
              items: unidades.map((u) {
                return DropdownMenuItem<int>(
                  value: u['id'],
                  child: Text(u['tipo']),
                );
              }).toList(),
              onChanged: (val) => selectedUnidadId = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (selectedIngredienteId != null &&
                  selectedUnidadId != null &&
                  cantidadCtrl.text.isNotEmpty) {
                await _insertarRecetaTipoPan();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipo = widget.tipo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cálculo para ${tipo.tipo}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de pan: ${tipo.tipo}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Precio base: \$${tipo.precioBase}'),
            Text('Charolas: ${tipo.cantidadPorCharola}'),
            const SizedBox(height: 16),
            const Text('Ingredientes:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: receta.isEmpty
                  ? const Center(child: Text("Aún no hay ingredientes agregados."))
                  : ListView.builder(
                      itemCount: receta.length,
                      itemBuilder: (context, index) {
                        final item = receta[index];
                        return ListTile(
                          title: Text('${item['ingrediente']} - ${item['cantidad']} ${item['unidad']}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
