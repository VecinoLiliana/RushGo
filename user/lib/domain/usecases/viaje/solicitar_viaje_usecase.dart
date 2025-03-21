import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/ubicacion.dart';
import '../../../domain/entities/viaje.dart';
import '../../../domain/repositories/viaje_repository.dart';
import '../../../domain/usecases/usecase.dart';

class SolicitarViajeUseCase implements UseCase<Viaje, SolicitarViajeParams> {
  final ViajeRepository repository;

  SolicitarViajeUseCase(this.repository);

  @override
  Future<Either<Failure, Viaje>> call(SolicitarViajeParams params) {
    return repository.solicitarViaje(
      idUsuario: params.idUsuario,
      origen: params.origen,
      destino: params.destino,
    );
  }
}

class SolicitarViajeParams {
  final String idUsuario;
  final Ubicacion origen;
  final Ubicacion destino;

  SolicitarViajeParams({
    required this.idUsuario,
    required this.origen,
    required this.destino,
  });
}
