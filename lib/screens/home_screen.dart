import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetita/models/bread_model.dart';
import 'package:recetita/providers/bread_providers.dart';
import 'package:recetita/screens/bread_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Espera un frame para evitar conflicto con el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final breadProvider = Provider.of<BreadProvider>(context, listen: false);

      if (breadProvider.breads.isEmpty) {
        breadProvider.fetchBreads();
        print("Panes cargados desde initState");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Panadería Artesanal'),
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
        ],
      ),
      body: Consumer<BreadProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (provider.breads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bakery_dining_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay panes disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.breads.length,
            itemBuilder: (context, index) {
              return _breadCard(context, provider.breads[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBreadModal(context),
        backgroundColor: Colors.amber[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddBreadModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.8,
            child: AddBreadForm(),
          ),
    );
  }

  Widget _breadCard(BuildContext context, BreadModel bread) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreadDetails(breadData: bread),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Hero(
                  tag: 'bread-image-${bread.id}',
                  child: Image.network(bread.imageLink, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bread.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    bread.type,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${bread.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Consumer<BreadProvider>(
                        builder: (context, provider, _) {
                          return IconButton(
                            icon: Icon(
                              provider.favoriteBreads.contains(bread)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.amber[700],
                            ),
                            onPressed:
                                () => provider.toggleFavoriteStatus(bread),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBreadForm extends StatefulWidget {
  const AddBreadForm({super.key});

  @override
  State<AddBreadForm> createState() => _AddBreadFormState();
}

class _AddBreadFormState extends State<AddBreadForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bakerController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bakerController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final breadProvider = Provider.of<BreadProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Agregar Nuevo Pan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: "Nombre del pan",
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Ingresa el nombre' : null,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _bakerController,
              label: "Panadero/Horneador",
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Ingresa el panadero' : null,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _typeController,
              label: "Tipo de pan (ej. Baguette, Integral, Brioche)",
              validator:
                  (value) => value?.isEmpty ?? true ? 'Ingresa el tipo' : null,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _imageController,
              label: "URL de la imagen",
              validator:
                  (value) => value?.isEmpty ?? true ? 'Ingresa la URL' : null,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: "Descripción",
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Ingresa la descripción' : null,
              maxLines: 3,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _priceController,
              label: "Precio (ej. 25.50)",
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Ingresa el precio';
                if (double.tryParse(value!) == null) return 'Número inválido';
                return null;
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final newBread = BreadModel(
                      id: breadProvider.breads.length + 1,
                      name: _nameController.text,
                      baker: _bakerController.text,
                      type: _typeController.text,
                      imageLink: _imageController.text,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                    );

                    final success = await breadProvider.saveBread(newBread);
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Pan agregado con éxito!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Guardar Pan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.amber, width: 2),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
