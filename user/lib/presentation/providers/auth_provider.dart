import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../core/services/service_locator.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/usecases/usuario/iniciar_sesion_usecase.dart';
import '../../domain/usecases/usuario/registrar_usuario_usecase.dart';

/// Estados posibles para la autenticación
enum AuthStatus { authenticated, unauthenticated, loading, error }

/// Estado del provider de autenticación
class AuthState {
  final AuthStatus status;
  final Usuario? usuario;
  final String? errorMessage;

  const AuthState({required this.status, this.usuario, this.errorMessage});

  /// Estado inicial
  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.unauthenticated);

  /// Crea una copia del estado con los campos actualizados
  AuthState copyWith({
    AuthStatus? status,
    Usuario? usuario,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider para manejar la autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final IniciarSesionUseCase _iniciarSesionUseCase;
  final RegistrarUsuarioUseCase _registrarUsuarioUseCase;
  final UsuarioRepository _usuarioRepository;

  AuthNotifier({
    required IniciarSesionUseCase iniciarSesionUseCase,
    required RegistrarUsuarioUseCase registrarUsuarioUseCase,
    required UsuarioRepository usuarioRepository,
  })  : _iniciarSesionUseCase = iniciarSesionUseCase,
        _registrarUsuarioUseCase = registrarUsuarioUseCase,
        _usuarioRepository = usuarioRepository,
        super(AuthState.initial());

  /// Inicia sesión con email y contraseña
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _iniciarSesionUseCase.call(
        IniciarSesionParams(email: email, password: password),
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (usuario) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            usuario: usuario,
            errorMessage: null,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al iniciar sesión',
      );
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _registrarUsuarioUseCase.call(
        RegistrarUsuarioParams(
          email: email,
          password: password,
          nombre: nombre,
          telefono: telefono,
        ),
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          );
          return false;
        },
        (usuario) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            usuario: usuario,
            errorMessage: null,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al registrar usuario',
      );
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> cerrarSesion() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _usuarioRepository.cerrarSesion();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        usuario: null,
        errorMessage: null,
      );
    } on ServerFailure catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al cerrar sesión',
      );
    }
  }

  /// Envía un correo para restablecer la contraseña
  Future<bool> restablecerContrasena({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _usuarioRepository.restablecerContrasena(email: email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
      return true;
    } on ServerFailure catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al enviar el correo de recuperación',
      );
      return false;
    }
  }
}

/// Provider para el estado de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    iniciarSesionUseCase: sl<IniciarSesionUseCase>(),
    registrarUsuarioUseCase: sl<RegistrarUsuarioUseCase>(),
    usuarioRepository: sl<UsuarioRepository>(),
  );
});
