import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/viaje_remote_datasource.dart';
import '../../domain/entities/ubicacion.dart';
import '../../domain/entities/viaje.dart';
import '../../domain/repositories/viaje_repository.dart';

class ViajeRepositoryImpl implements ViajeRepository {
  final ViajeRemoteDataSource remoteDataSource;

  ViajeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Viaje>> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  }) async {
    try {
      final viaje = await remoteDataSource.solicitarViaje(
        idUsuario: idUsuario,
        origen: origen,
        destino: destino,
      );
      return Right(viaje);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al solicitar viaje',
          code: 'solicitar-viaje-error', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelarViaje(String idViaje) async {
    try {
      await remoteDataSource.cancelarViaje(idViaje);
      return const Right(null);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al cancelar viaje',
          code: 'cancelar-viaje-error', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Viaje>> getViaje(String idViaje) async {
    try {
      final viaje = await remoteDataSource.getViaje(idViaje);
      return Right(viaje);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al obtener viaje',
          code: 'get-viaje-error', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Viaje>>> getViajesUsuario(
      String idUsuario) async {
    try {
      final viajes = await remoteDataSource.getViajesUsuario(idUsuario);
      return Right(viajes);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al obtener viajes del usuario',
          code: 'get-viajes-usuario-error', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Viaje?>> getViajeActivo(String idUsuario) async {
    try {
      final viaje = await remoteDataSource.getViajeActivo(idUsuario);
      return Right(viaje);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al obtener viaje activo',
          code: 'get-viaje-activo-error', details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  }) async {
    try {
      await remoteDataSource.calificarViaje(
        idViaje: idViaje,
        calificacion: calificacion,
        comentario: comentario,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(ErrorHandler.handleException(e));
    } catch (e) {
      return Left(ServerFailure('Error al calificar viaje',
          code: 'calificar-viaje-error', details: e.toString()));
    }
  }
}
