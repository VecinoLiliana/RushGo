import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/viaje.dart';
import '../../../domain/repositories/viaje_repository.dart';
import '../../../domain/usecases/usecase.dart';

class GetViajeUseCase implements UseCase<Viaje, String> {
  final ViajeRepository repository;

  GetViajeUseCase(this.repository);

  @override
  Future<Either<Failure, Viaje>> call(String idViaje) {
    return repository.getViaje(idViaje);
  }
}
