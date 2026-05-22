// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/providers.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/registro_screen.dart';
import '../features/auth/screens/perfil_screen.dart';

import '../features/shop/screens/inicio_screen.dart';
import '../features/shop/screens/tienda_screen.dart';
import '../features/shop/screens/producto_detalle_screen.dart';
import '../features/shop/screens/colecciones_screen.dart';
import '../features/shop/screens/ofertas_screen.dart';
import '../features/shop/screens/novedades_screen.dart';
import '../features/shop/screens/busqueda_screen.dart';

import '../features/cart/screens/carrito_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/cart/screens/confirmacion_screen.dart';
import '../features/orders/screens/pedidos_screen.dart';

import '../features/admin/screens/panel_admin_screen.dart';
import '../features/admin/screens/admin_productos_screen.dart';
import '../features/admin/screens/admin_producto_form_screen.dart';

GoRouter buildRouter(AuthProvider auth) => GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final enAdmin = state.matchedLocation.startsWith('/admin');
        if (enAdmin && !auth.esAdmin) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const InicioScreen()),
        GoRoute(path: '/tienda', builder: (_, __) => const TiendaScreen()),
        GoRoute(
            path: '/producto/:tipo/:id',
            builder: (_, s) => ProductoDetalleScreen(
                tipo: s.pathParameters['tipo']!, id: s.pathParameters['id']!)),
        GoRoute(
            path: '/colecciones',
            builder: (_, __) => const ColeccionesScreen()),
        GoRoute(
            path: '/colecciones/:id',
            builder: (_, s) =>
                ColeccionesScreen(coleccionId: s.pathParameters['id'])),
        GoRoute(path: '/ofertas', builder: (_, __) => const OfertasScreen()),
        GoRoute(
            path: '/novedades', builder: (_, __) => const NovedadesScreen()),
        GoRoute(path: '/buscar', builder: (_, __) => const BusquedaScreen()),
        GoRoute(path: '/carrito', builder: (_, __) => const CarritoScreen()),
        GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(
            path: '/confirmacion/:id',
            builder: (_, s) =>
                ConfirmacionScreen(pedidoId: s.pathParameters['id']!)),
        GoRoute(path: '/perfil', builder: (_, __) => const PerfilScreen()),
        GoRoute(path: '/pedidos', builder: (_, __) => const PedidosScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),
        GoRoute(path: '/admin', builder: (_, __) => const PanelAdminScreen()),
        GoRoute(
            path: '/admin/productos/:tipo',
            builder: (_, s) =>
                AdminProductosScreen(tipo: s.pathParameters['tipo']!)),
        GoRoute(
            path: '/admin/productos/:tipo/nuevo',
            builder: (_, s) =>
                AdminProductoFormScreen(tipo: s.pathParameters['tipo']!)),
        GoRoute(
            path: '/admin/productos/:tipo/:id/editar',
            builder: (_, s) => AdminProductoFormScreen(
                tipo: s.pathParameters['tipo']!,
                productoId: s.pathParameters['id']!)),
      ],
    );
