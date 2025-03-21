import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure: $message (Code: $code)';
}

/// Fallo para errores de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// Fallo para errores de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

/// Fallo para errores de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

/// Fallo para errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

/// Fallo para errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

/// Fallo para errores de ubicación
class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code, super.details});
}
