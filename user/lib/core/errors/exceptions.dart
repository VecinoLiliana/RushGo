/// Excepciones personalizadas para la aplicación
library;

/// Excepción base para todas las excepciones de la aplicación
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Excepción para errores de servidor
class ServerException extends AppException {
  ServerException(super.message, {super.code, super.details});
}

/// Excepción para errores de caché
class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

/// Excepción para errores de red
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

/// Excepción para errores de validación
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

/// Excepción para errores de ubicación
class LocationException extends AppException {
  LocationException(super.message, {super.code, super.details});
}
