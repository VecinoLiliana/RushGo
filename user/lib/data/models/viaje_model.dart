import '../../data/models/ubicacion_model.dart';
import '../../domain/entities/viaje.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/pago_model.dart';

/// Modelo para mapear datos de Firestore a la entidad Viaje
class ViajeModel extends Viaje {
  ViajeModel({
    required super.id,
    required super.idUsuario,
    super.idConductor,
    required super.origen,
    required super.destino,
    required super.fechaSolicitud,
    super.fechaInicio,
    super.fechaFin,
    required super.distanciaEstimada,
    required super.tiempoEstimadoMinutos,
    required super.costoEstimado,
    super.costoFinal,
    required super.estado,
    super.pago,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory ViajeModel.fromJson(Map<String, dynamic> json) {
    return ViajeModel(
      id: json['id'] ?? '',
      idUsuario: json['idUsuario'] ?? '',
      idConductor: json['idConductor'],
      origen:
          json['origen'] != null
              ? UbicacionModel.fromJson(json['origen'])
              : UbicacionModel(latitud: 0, longitud: 0),
      destino:
          json['destino'] != null
              ? UbicacionModel.fromJson(json['destino'])
              : UbicacionModel(latitud: 0, longitud: 0),
      fechaSolicitud:
          json['fechaSolicitud'] != null
              ? (json['fechaSolicitud'] as Timestamp).toDate()
              : DateTime.now(),
      fechaInicio:
          json['fechaInicio'] != null
              ? (json['fechaInicio'] as Timestamp).toDate()
              : null,
      fechaFin:
          json['fechaFin'] != null
              ? (json['fechaFin'] as Timestamp).toDate()
              : null,
      distanciaEstimada: json['distanciaEstimada'] ?? 0.0,
      tiempoEstimadoMinutos: json['tiempoEstimadoMinutos'] ?? 0.0,
      costoEstimado: json['costoEstimado'] ?? 0.0,
      costoFinal: json['costoFinal'],
      estado: _mapEstadoViajeFromString(json['estado'] ?? 'solicitado'),
      pago: json['pago'] != null ? PagoModel.fromJson(json['pago']) : null,
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'idUsuario': idUsuario,
      'idConductor': idConductor,
      'origen':
          origen is UbicacionModel
              ? (origen as UbicacionModel).toJson()
              : UbicacionModel(
                latitud: origen.latitud,
                longitud: origen.longitud,
                direccion: origen.direccion,
                ciudad: origen.ciudad,
                pais: origen.pais,
                codigoPostal: origen.codigoPostal,
              ).toJson(),
      'destino':
          destino is UbicacionModel
              ? (destino as UbicacionModel).toJson()
              : UbicacionModel(
                latitud: destino.latitud,
                longitud: destino.longitud,
                direccion: destino.direccion,
                ciudad: destino.ciudad,
                pais: destino.pais,
                codigoPostal: destino.codigoPostal,
              ).toJson(),
      'fechaSolicitud': fechaSolicitud,
      'distanciaEstimada': distanciaEstimada,
      'tiempoEstimadoMinutos': tiempoEstimadoMinutos,
      'costoEstimado': costoEstimado,
      'estado': _mapEstadoViajeToString(estado),
    };

    // Agregar campos opcionales solo si no son nulos
    if (fechaInicio != null) data['fechaInicio'] = fechaInicio;
    if (fechaFin != null) data['fechaFin'] = fechaFin;
    if (costoFinal != null) data['costoFinal'] = costoFinal;

    return data;
  }

  /// Mapea un string a un enum EstadoViaje
  static EstadoViaje _mapEstadoViajeFromString(String estado) {
    switch (estado) {
      case 'solicitado':
        return EstadoViaje.solicitado;
      case 'aceptado':
        return EstadoViaje.aceptado;
      case 'enCamino':
        return EstadoViaje.enCamino;
      case 'enCurso':
        return EstadoViaje.enCurso;
      case 'completado':
        return EstadoViaje.completado;
      case 'cancelado':
        return EstadoViaje.cancelado;
      default:
        return EstadoViaje.solicitado;
    }
  }

  /// Mapea un enum EstadoViaje a un string
  static String _mapEstadoViajeToString(EstadoViaje estado) {
    switch (estado) {
      case EstadoViaje.solicitado:
        return 'solicitado';
      case EstadoViaje.aceptado:
        return 'aceptado';
      case EstadoViaje.enCamino:
        return 'enCamino';
      case EstadoViaje.enCurso:
        return 'enCurso';
      case EstadoViaje.completado:
        return 'completado';
      case EstadoViaje.cancelado:
        return 'cancelado';
      default:
        return 'solicitado';
    }
  }
}
