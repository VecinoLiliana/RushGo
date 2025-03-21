import 'ubicacion.dart';
import 'pago.dart';

class Viaje {
  final String id;
  final String idUsuario;
  final String? idConductor;
  final Ubicacion origen;
  final Ubicacion destino;
  final DateTime fechaSolicitud;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final double distanciaEstimada;
  final double tiempoEstimadoMinutos;
  final double costoEstimado;
  final double? costoFinal;
  final EstadoViaje estado;
  final Pago? pago;

  Viaje({
    required this.id,
    required this.idUsuario,
    this.idConductor,
    required this.origen,
    required this.destino,
    required this.fechaSolicitud,
    this.fechaInicio,
    this.fechaFin,
    required this.distanciaEstimada,
    required this.tiempoEstimadoMinutos,
    required this.costoEstimado,
    this.costoFinal,
    required this.estado,
    this.pago,
  });
}

enum EstadoViaje {
  solicitado,
  aceptado,
  enCamino,
  enCurso,
  completado,
  cancelado,
}
