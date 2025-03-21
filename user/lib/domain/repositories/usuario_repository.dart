
import '../entities/usuario.dart';

abstract class UsuarioRepository {
  /// Obtiene el usuario actual
  Future<Usuario?> getUsuarioActual();

  /// Registra un nuevo usuario
  Future<Usuario> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  });

  /// Inicia sesión con email y contraseña
  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> cerrarSesion();

  /// Actualiza los datos del usuario
  Future<Usuario> actualizarUsuario({
    required String id,
    String? nombre,
    String? telefono,
    String? fotoPerfil,
  });

  /// Verifica si hay un usuario autenticado
  Future<bool> estaAutenticado();

  /// Envía un correo para restablecer la contraseña
  Future<void> restablecerContrasena({required String email});
}
