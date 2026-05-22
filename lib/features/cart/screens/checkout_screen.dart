// lib/features/cart/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../providers.dart';
import '../../../shared/widgets/shared_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _dirCtrl = TextEditingController();
  String _pago = 'tarjeta';

  void _procesar() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    if (_dirCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa una dirección de envío',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.danger));
      return;
    }

    final pedido = await orders.hacer(
      usuario: auth.usuario!,
      cart: cart,
      formaPago: _pago,
      direccion: _dirCtrl.text,
    );

    if (pedido != null && mounted) {
      context.go('/confirmacion/${pedido.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty)
      return const Scaffold(body: Center(child: Text('Carrito vacío')));

    return Scaffold(
      appBar: const UfAppBar(title: 'Finalizar Compra'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Dirección de Envío',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
              controller: _dirCtrl,
              decoration: const InputDecoration(
                  labelText: 'Calle, Número, Colonia, Código Postal')),
          const SizedBox(height: 24),
          Text('Método de Pago', style: Theme.of(context).textTheme.titleLarge),
          RadioListTile(
              title: const Text('Tarjeta de Crédito/Débito'),
              value: 'tarjeta',
              groupValue: _pago,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _pago = v.toString())),
          RadioListTile(
              title: const Text('Efectivo (OXXO)'),
              value: 'efectivo',
              groupValue: _pago,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _pago = v.toString())),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _procesar,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text('Pagar \$${cart.total}',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
