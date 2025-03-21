import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/repositories/usuario_repository.dart';
import '../../../domain/usecases/usecase.dart';

class IniciarSesionUseCase implements UseCase<Usuario, IniciarSesionParams> {
  final UsuarioRepository repository;

  IniciarSesionUseCase(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(IniciarSesionParams params) async {
    try {
      final usuario = await repository.iniciarSesion(
        email: params.email,
        password: params.password,
      );
      return Right(usuario);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Error al iniciar sesión: ${e.toString()}'));
    }
  }
}

class IniciarSesionParams {
  final String email;
  final String password;

  IniciarSesionParams({required this.email, required this.password});
}
