// lib/features/cart/screens/carrito_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      appBar: const UfAppBar(title: 'Mi Carrito'),
      body: cart.items.isEmpty
          ? const UfEmptyState(
              mensaje: 'Tu carrito está vacío.\n¡Agrega algo de estilo urbano!',
              icono: Icons.shopping_cart_outlined,
            )
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final item = cart.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: [
                          // Imagen
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: item.imagenUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: item.imagenUrl!,
                                      fit: BoxFit.cover)
                                  : Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.checkroom,
                                          color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Detalles
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nombreProducto,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(fmt.format(item.precioUnitario),
                                      style: const TextStyle(
                                          color: AppColors.primary)),
                                  Row(children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 20),
                                      onPressed: () => cart.actualizar(
                                          item.productoId, item.cantidad - 1),
                                    ),
                                    Text('${item.cantidad}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          size: 20),
                                      onPressed: () => cart.actualizar(
                                          item.productoId, item.cantidad + 1),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppColors.danger),
                                      onPressed: () =>
                                          cart.eliminar(item.productoId),
                                    )
                                  ])
                                ]),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              // Resumen de pago
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(color: AppColors.textMuted)),
                          Text(fmt.format(cart.subtotal),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a pagar',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(fmt.format(cart.total),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary)),
                        ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Por ahora lo mandamos al inicio, después haremos la pantalla de checkout real
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('¡Simulación de compra exitosa!')));
                          cart.vaciar();
                          context.go('/');
                        },
                        child: const Text('Proceder al Pago',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ]),
                ),
              )
            ]),
    );
  }
}
