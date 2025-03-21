import '../../domain/entities/ubicacion.dart';

/// Modelo para mapear datos de Firestore a la entidad Ubicacion
class UbicacionModel extends Ubicacion {
  UbicacionModel({
    required super.latitud,
    required super.longitud,
    super.direccion,
    super.ciudad,
    super.pais,
    super.codigoPostal,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory UbicacionModel.fromJson(Map<String, dynamic> json) {
    return UbicacionModel(
      latitud: json['latitud'] ?? 0.0,
      longitud: json['longitud'] ?? 0.0,
      direccion: json['direccion'],
      ciudad: json['ciudad'],
      pais: json['pais'],
      codigoPostal: json['codigoPostal'],
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'ciudad': ciudad,
      'pais': pais,
      'codigoPostal': codigoPostal,
    };
  }

  /// Crea un modelo a partir de una entidad de dominio
  factory UbicacionModel.fromEntity(Ubicacion ubicacion) {
    return UbicacionModel(
      latitud: ubicacion.latitud,
      longitud: ubicacion.longitud,
      direccion: ubicacion.direccion,
      ciudad: ubicacion.ciudad,
      pais: ubicacion.pais,
      codigoPostal: ubicacion.codigoPostal,
    );
  }
}
