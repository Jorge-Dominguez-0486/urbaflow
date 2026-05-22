// lib/features/admin/screens/admin_producto_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminProductoFormScreen extends StatefulWidget {
  final String tipo;
  final String? productoId;
  const AdminProductoFormScreen(
      {super.key, required this.tipo, this.productoId});

  @override
  State<AdminProductoFormScreen> createState() =>
      _AdminProductoFormScreenState();
}

class _AdminProductoFormScreenState extends State<AdminProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  TipoProducto _tipoSeleccionado = TipoProducto.zapato;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final prov = context.read<ProductProvider>();

      final nuevoProducto = Producto(
        nombre: _nombreCtrl.text,
        descripcion: _descCtrl.text,
        precio: double.parse(_precioCtrl.text),
        stock: int.parse(_stockCtrl.text),
        tipo: _tipoSeleccionado,
        fechaAgregado: DateTime.now(),
      );

      final exito = await prov.crearProducto(nuevoProducto);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prenda guardada exitosamente')));
        context.pop(); // Regresamos a la lista
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UfAppBar(title: 'Añadir Prenda'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la prenda'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Precio', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Stock (Cantidad)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoProducto>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: TipoProducto.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.etiqueta));
                }).toList(),
                onChanged: (v) => setState(() => _tipoSeleccionado = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar Prenda',
                      style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
