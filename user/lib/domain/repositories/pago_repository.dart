import '../entities/pago.dart';

abstract class PagoRepository {
  /// Procesa un pago para un viaje
  Future<Pago> procesarPago({
    required String idViaje,
    required double monto,
    required MetodoPago metodo,
  });

  /// Obtiene el historial de pagos de un usuario
  Future<List<Pago>> getPagosUsuario(String idUsuario);

  /// Obtiene los detalles de un pago
  Future<Pago> getDetallePago(String idPago);
}
