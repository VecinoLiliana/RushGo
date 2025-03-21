class Pago {
  final String id;
  final String idViaje;
  final double monto;
  final DateTime fecha;
  final MetodoPago metodo;
  final EstadoPago estado;

  Pago({
    required this.id,
    required this.idViaje,
    required this.monto,
    required this.fecha,
    required this.metodo,
    required this.estado,
  });
}

enum MetodoPago {
  efectivo,
  tarjeta,
  paypal,
}

enum EstadoPago {
  pendiente,
  procesando,
  completado,
  fallido,
  reembolsado,
}
