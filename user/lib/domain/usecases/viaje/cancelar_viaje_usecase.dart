import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/viaje_repository.dart';
import '../../../domain/usecases/usecase.dart';

class CancelarViajeUseCase implements UseCase<void, String> {
  final ViajeRepository repository;

  CancelarViajeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String idViaje) {
    return repository.cancelarViaje(idViaje);
  }
}
