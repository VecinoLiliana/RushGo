import '../../data/models/usuario_model.dart';

abstract class UsuarioRemoteDataSource {
  /// Obtiene el usuario actual autenticado
  Future<UsuarioModel?> getUsuarioActual();

  /// Registra un nuevo usuario
  Future<UsuarioModel> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  });

  /// Inicia sesión con email y contraseña
  Future<UsuarioModel> iniciarSesion({
    required String email,
    required String password,
  });

  /// Cierra la sesión del usuario actual
  Future<void> cerrarSesion();

  /// Actualiza los datos del usuario
  Future<UsuarioModel> actualizarUsuario({
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
