import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Clase base para todos los casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
