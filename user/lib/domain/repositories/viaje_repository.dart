import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/ubicacion.dart';
import '../entities/viaje.dart';

abstract class ViajeRepository {
  /// Solicita un nuevo viaje
  Future<Either<Failure, Viaje>> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  });

  /// Cancela un viaje
  Future<Either<Failure, void>> cancelarViaje(String idViaje);

  /// Obtiene un viaje por su ID
  Future<Either<Failure, Viaje>> getViaje(String idViaje);

  /// Obtiene los viajes del usuario
  Future<Either<Failure, List<Viaje>>> getViajesUsuario(String idUsuario);

  /// Obtiene el viaje activo del usuario (si existe)
  Future<Either<Failure, Viaje?>> getViajeActivo(String idUsuario);

  /// Califica un viaje completado
  Future<Either<Failure, void>> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  });
}
