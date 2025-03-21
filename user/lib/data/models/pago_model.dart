import '../../domain/entities/pago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para mapear datos de Firestore a la entidad Pago
class PagoModel extends Pago {
  PagoModel({
    required super.id,
    required super.idViaje,
    required super.monto,
    required super.fecha,
    required super.metodo,
    required super.estado,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] ?? '',
      idViaje: json['idViaje'] ?? '',
      monto: json['monto'] ?? 0.0,
      fecha:
          json['fecha'] != null
              ? (json['fecha'] as Timestamp).toDate()
              : DateTime.now(),
      metodo: _mapMetodoPagoFromString(json['metodo'] ?? 'efectivo'),
      estado: _mapEstadoPagoFromString(json['estado'] ?? 'pendiente'),
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idViaje': idViaje,
      'monto': monto,
      'fecha': fecha,
      'metodo': _mapMetodoPagoToString(metodo),
      'estado': _mapEstadoPagoToString(estado),
    };
  }

  /// Mapea un string a un enum MetodoPago
  static MetodoPago _mapMetodoPagoFromString(String metodo) {
    switch (metodo) {
      case 'efectivo':
        return MetodoPago.efectivo;
      case 'tarjeta':
        return MetodoPago.tarjeta;
      case 'paypal':
        return MetodoPago.paypal;
      default:
        return MetodoPago.efectivo;
    }
  }

  /// Mapea un enum MetodoPago a un string
  static String _mapMetodoPagoToString(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.efectivo:
        return 'efectivo';
      case MetodoPago.tarjeta:
        return 'tarjeta';
      case MetodoPago.paypal:
        return 'paypal';
      default:
        return 'efectivo';
    }
  }

  /// Mapea un string a un enum EstadoPago
  static EstadoPago _mapEstadoPagoFromString(String estado) {
    switch (estado) {
      case 'pendiente':
        return EstadoPago.pendiente;
      case 'procesando':
        return EstadoPago.procesando;
      case 'completado':
        return EstadoPago.completado;
      case 'fallido':
        return EstadoPago.fallido;
      case 'reembolsado':
        return EstadoPago.reembolsado;
      default:
        return EstadoPago.pendiente;
    }
  }

  /// Mapea un enum EstadoPago a un string
  static String _mapEstadoPagoToString(EstadoPago estado) {
    switch (estado) {
      case EstadoPago.pendiente:
        return 'pendiente';
      case EstadoPago.procesando:
        return 'procesando';
      case EstadoPago.completado:
        return 'completado';
      case EstadoPago.fallido:
        return 'fallido';
      case EstadoPago.reembolsado:
        return 'reembolsado';
      default:
        return 'pendiente';
    }
  }
}
