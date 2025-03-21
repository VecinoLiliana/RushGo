import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/viaje_repository.dart';
import '../../../domain/usecases/usecase.dart';

class CalificarViajeUseCase implements UseCase<void, CalificarViajeParams> {
  final ViajeRepository repository;

  CalificarViajeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CalificarViajeParams params) {
    return repository.calificarViaje(
      idViaje: params.idViaje,
      calificacion: params.calificacion,
      comentario: params.comentario,
    );
  }
}

class CalificarViajeParams {
  final String idViaje;
  final double calificacion;
  final String? comentario;

  CalificarViajeParams({
    required this.idViaje,
    required this.calificacion,
    this.comentario,
  });
}
