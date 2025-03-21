import 'dart:io';

import './exceptions.dart';
import './failures.dart';

/// Clase para manejar errores y convertirlos en excepciones o fallos
class ErrorHandler {
  /// Convierte una excepción en un fallo
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code, details: exception.details);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, code: exception.code, details: exception.details);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code, details: exception.details);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code, details: exception.details);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, code: exception.code, details: exception.details);
    } else if (exception is LocationException) {
      return LocationFailure(exception.message, code: exception.code, details: exception.details);
    } else {
      return ServerFailure(exception.toString(), code: 'unknown_exception');
    }
  }

  /// Maneja errores generales y los convierte en excepciones
  static Exception handleError(dynamic error) {
    if (error is SocketException) {
      return NetworkException(
        'Error de conexión. Por favor, verifica tu conexión a internet.',
        code: 'socket_error',
      );
    } else if (error is HttpException) {
      return NetworkException(
        'Error HTTP. No se pudo completar la solicitud.',
        code: 'http_error',
      );
    } else if (error is FormatException) {
      return ServerException(
        'Error de formato. Los datos recibidos no son válidos.',
        code: 'format_error',
      );
    } else if (error is Exception) {
      return ServerException(
        error.toString(),
        code: 'unknown_exception',
      );
    } else {
      return ServerException(
        'Ocurrió un error inesperado',
        code: 'unknown_error',
        details: error.toString(),
      );
    }
  }
}
