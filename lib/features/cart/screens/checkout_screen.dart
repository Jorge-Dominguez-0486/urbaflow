// lib/features/cart/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _dirCtrl = TextEditingController();
  final _numTarjetaCtrl = TextEditingController();
  final _nombreTarjetaCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  String _pago = 'tarjeta';
  bool _procesando = false;

  @override
  void dispose() {
    _dirCtrl.dispose();
    _numTarjetaCtrl.dispose();
    _nombreTarjetaCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _procesar() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    if (_dirCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa una dirección de envío'),
          backgroundColor: AppColors.danger));
      return;
    }

    if (_pago == 'tarjeta') {
      if (_numTarjetaCtrl.text.replaceAll(' ', '').length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ingresa un número de tarjeta válido (16 dígitos)'),
            backgroundColor: AppColors.danger));
        return;
      }
      if (_nombreTarjetaCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ingresa el nombre del titular'),
            backgroundColor: AppColors.danger));
        return;
      }
      if (_expCtrl.text.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ingresa la fecha de expiración (MM/AA)'),
            backgroundColor: AppColors.danger));
        return;
      }
      if (_cvvCtrl.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ingresa el CVV'),
            backgroundColor: AppColors.danger));
        return;
      }
    }

    setState(() => _procesando = true);

    try {
      final pedido = await orders.hacer(
        usuario: auth.usuario!,
        cart: cart,
        formaPago: _pago,
        direccion: _dirCtrl.text,
      );

      if (pedido != null && mounted) {
        context.go('/confirmacion/${pedido.id}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al procesar pago'),
          backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  // Formatea el número de tarjeta con espacios cada 4 dígitos
  String _formatearTarjeta(String value) {
    value = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty)
      return const Scaffold(body: Center(child: Text('Carrito vacío')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop()),
      ),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── SECCIÓN 1: Dirección ──
                const Text('1. Dirección de Envío',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                    controller: _dirCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Calle, Número, Colonia, C.P.',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder())),
                const SizedBox(height: 32),

                // ── SECCIÓN 2: Método de pago ──
                const Text('2. Método de Pago',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      RadioListTile(
                        title: const Text('Tarjeta de Crédito / Débito'),
                        subtitle: const Text('Visa, Mastercard, AMEX'),
                        secondary: const Icon(Icons.credit_card,
                            color: AppColors.primary),
                        value: 'tarjeta',
                        groupValue: _pago,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _pago = v.toString()),
                      ),
                      const Divider(height: 1),
                      RadioListTile(
                        title: const Text('Efectivo en OXXO'),
                        subtitle: const Text('Paga en tu sucursal más cercana'),
                        secondary: const Icon(Icons.storefront,
                            color: AppColors.success),
                        value: 'efectivo',
                        groupValue: _pago,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _pago = v.toString()),
                      ),
                    ],
                  ),
                ),

                // ── CAMPOS DE TARJETA (solo si eligió tarjeta) ──
                if (_pago == 'tarjeta') ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Datos de la tarjeta',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 16),

                        // Número de tarjeta
                        TextField(
                          controller: _numTarjetaCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _TarjetaFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Número de tarjeta',
                            hintText: '0000 0000 0000 0000',
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nombre del titular
                        TextField(
                          controller: _nombreTarjetaCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del titular',
                            hintText: 'Como aparece en la tarjeta',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Fecha y CVV en la misma fila
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _FechaFormatter(),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Expiración',
                                  hintText: 'MM/AA',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _cvvCtrl,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  hintText: '•••',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.lock, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text('Pago 100% seguro y encriptado',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Info OXXO ──
                if (_pago == 'efectivo') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200)),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Al confirmar recibirás un código de pago. Tienes 48 horas para pagar en cualquier OXXO.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── RESUMEN DE COMPRA ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('IVA (16%)'),
                          Text('\$${cart.impuestos.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _procesar,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary),
                  child: Text(
                      _pago == 'tarjeta'
                          ? 'Confirmar y Pagar \$${cart.total.toStringAsFixed(2)}'
                          : 'Generar Código OXXO',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// Formateador para número de tarjeta: 0000 0000 0000 0000
class _TarjetaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newValue.copyWith(
        text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

// Formateador para fecha: MM/AA
class _FechaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}
