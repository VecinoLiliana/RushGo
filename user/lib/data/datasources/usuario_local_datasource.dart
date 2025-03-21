import '../../data/models/usuario_model.dart';

abstract class UsuarioLocalDataSource {
  /// Obtiene el último usuario guardado en caché
  Future<UsuarioModel> getUltimoUsuario();

  /// Guarda un usuario en caché
  Future<void> cacheUsuario(UsuarioModel usuario);

  /// Elimina el usuario guardado en caché
  Future<void> eliminarUsuario();
}
