import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/repositories/usuario_repository.dart';
import '../../../domain/usecases/usecase.dart';

class RegistrarUsuarioUseCase
    implements UseCase<Usuario, RegistrarUsuarioParams> {
  final UsuarioRepository repository;

  RegistrarUsuarioUseCase(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(RegistrarUsuarioParams params) async {
    try {
      final usuario = await repository.registrarUsuario(
        email: params.email,
        password: params.password,
        nombre: params.nombre,
        telefono: params.telefono,
      );
      return Right(usuario);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error al registrar usuario: ${e.toString()}'));
    }
  }
}

class RegistrarUsuarioParams {
  final String email;
  final String password;
  final String nombre;
  final String? telefono;

  RegistrarUsuarioParams({
    required this.email,
    required this.password,
    required this.nombre,
    this.telefono,
  });
}
