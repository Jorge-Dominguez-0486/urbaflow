// lib/features/admin/screens/admin_producto_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';
import '../../../services/firebase_services.dart'; // Agregamos los servicios

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
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // ESTO FALTABA: Rellenar los datos si es edición
    if (widget.productoId != null && widget.productoId != 'nuevo') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prov = context.read<ProductProvider>();
        // Buscamos el producto en la lista cargada
        final p =
            prov.productos.firstWhere((prod) => prod.id == widget.productoId);
        setState(() {
          _nombreCtrl.text = p.nombre;
          _descCtrl.text = p.descripcion;
          _precioCtrl.text = p.precio.toString();
          _stockCtrl.text = p.stock.toString();
          _tipoSeleccionado = p.tipo;
        });
      });
    }
  }

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
      setState(() => _cargando = true);

      final nuevoProducto = Producto(
        id: widget.productoId != 'nuevo' ? widget.productoId : null,
        nombre: _nombreCtrl.text,
        descripcion: _descCtrl.text,
        precio: double.parse(_precioCtrl.text),
        stock: int.parse(_stockCtrl.text),
        tipo: _tipoSeleccionado,
        fechaAgregado: DateTime.now(),
      );

      try {
        if (widget.productoId != null && widget.productoId != 'nuevo') {
          await ProductService()
              .actualizar(nuevoProducto); // Actualiza si ya existe
        } else {
          await ProductService().crear(nuevoProducto); // Crea si es nuevo
        }

        // Recargamos la lista en el proveedor
        await context.read<ProductProvider>().cargar();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Guardado exitosamente'),
              backgroundColor: AppColors.success));
          context.pop(); // <-- ESTO TE REGRESA A LA PANTALLA ANTERIOR
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al guardar'),
              backgroundColor: AppColors.danger));
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cambiamos el título dinámicamente
      appBar: UfAppBar(
          title:
              widget.productoId != 'nuevo' ? 'Editar Prenda' : 'Añadir Prenda'),
      body: _cargando
          ? const UfLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la prenda'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
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
                          decoration: const InputDecoration(
                              labelText: 'Stock (Cantidad)'),
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
                        return DropdownMenuItem(
                            value: t, child: Text(t.etiqueta));
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
