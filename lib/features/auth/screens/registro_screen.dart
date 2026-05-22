// lib/features/auth/screens/registro_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_passCtrl.text != _pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: AppColors.danger),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.registrar(
        _nombreCtrl.text.trim(), _correoCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              const Icon(Icons.store, color: AppColors.primary, size: 64),
              const SizedBox(height: 8),
              Text('URBA & FLOW',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: 28)),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    Text('Crear cuenta',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 20)),
                    const SizedBox(height: 24),
                    if (auth.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEDED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(auth.error!,
                            style: const TextStyle(color: AppColors.danger)),
                      ),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _correoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass2Ctrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: Icon(Icons.lock_outlined)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: auth.cargando
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _registrar,
                              child: const Text('Registrarse')),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
