import 'dart:convert';

import '../../../core/errors/exceptions.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/datasources/usuario_local_datasource.dart';
import '../../../data/models/usuario_model.dart';

class UsuarioLocalDataSourceImpl implements UsuarioLocalDataSource {
  final StorageService storageService;
  final String _cacheKey = 'CACHED_USUARIO';

  UsuarioLocalDataSourceImpl({required this.storageService});

  @override
  Future<void> cacheUsuario(UsuarioModel usuario) async {
    try {
      await storageService.setString(_cacheKey, jsonEncode(usuario.toJson()));
    } catch (e) {
      throw CacheException('Error al guardar usuario en caché');
    }
  }

  @override
  Future<void> eliminarUsuario() async {
    try {
      await storageService.remove(_cacheKey);
    } catch (e) {
      throw CacheException('Error al eliminar usuario de caché');
    }
  }

  @override
  Future<UsuarioModel> getUltimoUsuario() async {
    try {
      final jsonString = storageService.getString(_cacheKey);
      if (jsonString == null) {
        throw CacheException('No se encontró usuario en caché');
      }
      return UsuarioModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Error al obtener usuario de caché');
    }
  }
}
