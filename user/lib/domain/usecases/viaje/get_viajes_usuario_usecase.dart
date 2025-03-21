import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/viaje.dart';
import '../../../domain/repositories/viaje_repository.dart';
import '../../../domain/usecases/usecase.dart';

class GetViajesUsuarioUseCase implements UseCase<List<Viaje>, String> {
  final ViajeRepository repository;

  GetViajesUsuarioUseCase(this.repository);

  @override
  Future<Either<Failure, List<Viaje>>> call(String idUsuario) {
    return repository.getViajesUsuario(idUsuario);
  }
}
