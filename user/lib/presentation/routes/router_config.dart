import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/perfil_screen.dart';
import '../../presentation/screens/solicitar_viaje_screen.dart';
import '../../presentation/screens/viaje_activo_screen.dart';
import '../../presentation/screens/historial_viajes_screen.dart';

/// Proveedor del router para la aplicación
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Rutas de autenticación
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Rutas principales
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: '/solicitar-viaje',
        builder: (context, state) => const SolicitarViajeScreen(),
      ),
      GoRoute(
        path: '/viaje-activo/:id',
        builder:
            (context, state) =>
                ViajeActivoScreen(idViaje: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/historial',
        builder: (context, state) => const HistorialViajesScreen(),
      ),
    ],
  );
});
