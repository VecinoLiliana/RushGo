import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/usuario_remote_datasource.dart';
import '../../data/datasources/usuario_local_datasource.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioRemoteDataSource remoteDataSource;
  final UsuarioLocalDataSource localDataSource;

  UsuarioRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Usuario> actualizarUsuario({
    required String id,
    String? nombre,
    String? telefono,
    String? fotoPerfil,
  }) async {
    try {
      final usuario = await remoteDataSource.actualizarUsuario(
        id: id,
        nombre: nombre,
        telefono: telefono,
        fotoPerfil: fotoPerfil,
      );
      await localDataSource.cacheUsuario(usuario);
      return usuario;
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await remoteDataSource.cerrarSesion();
      await localDataSource.eliminarUsuario();
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }

  @override
  Future<bool> estaAutenticado() async {
    try {
      return await remoteDataSource.estaAutenticado();
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }

  @override
  Future<Usuario?> getUsuarioActual() async {
    try {
      final usuario = await remoteDataSource.getUsuarioActual();
      if (usuario != null) {
        await localDataSource.cacheUsuario(usuario);
      }
      return usuario;
    } on ServerException {
      try {
        return await localDataSource.getUltimoUsuario();
      } on CacheException {
        return null;
      }
    }
  }

  @override
  Future<Usuario> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final usuario = await remoteDataSource.iniciarSesion(
        email: email,
        password: password,
      );
      await localDataSource.cacheUsuario(usuario);
      return usuario;
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }

  @override
  Future<Usuario> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  }) async {
    try {
      final usuario = await remoteDataSource.registrarUsuario(
        email: email,
        password: password,
        nombre: nombre,
        telefono: telefono,
      );
      await localDataSource.cacheUsuario(usuario);
      return usuario;
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }

  @override
  Future<void> restablecerContrasena({required String email}) async {
    try {
      await remoteDataSource.restablecerContrasena(email: email);
    } on ServerException {
      throw ServerFailure('Error en el servidor');
    }
  }
}
