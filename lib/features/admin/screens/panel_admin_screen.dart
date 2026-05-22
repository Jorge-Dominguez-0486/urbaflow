// lib/features/admin/screens/panel_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class PanelAdminScreen extends StatelessWidget {
  const PanelAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UfAppBar(title: 'Panel de Administración'),
      drawer: const AppDrawer(),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _AdminCard(
            titulo: 'Ropa (Productos)',
            icono: Icons.inventory,
            color: AppColors.primary,
            onTap: () => context.go('/admin/productos/todos'),
          ),
          _AdminCard(
            titulo: 'Pedidos',
            icono: Icons.local_shipping,
            color: AppColors.accent,
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Próximamente...'))),
          ),
          _AdminCard(
            titulo: 'Usuarios',
            icono: Icons.people,
            color: AppColors.success,
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Próximamente...'))),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard(
      {required this.titulo,
      required this.icono,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: color),
            const SizedBox(height: 12),
            Text(titulo,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
