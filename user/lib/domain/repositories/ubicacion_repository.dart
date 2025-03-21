import '../entities/ubicacion.dart';

abstract class UbicacionRepository {
  /// Obtiene la ubicación actual del usuario
  Future<Ubicacion> getUbicacionActual();

  /// Busca lugares por nombre o dirección
  Future<List<Ubicacion>> buscarLugares(String query);

  /// Obtiene detalles de un lugar por sus coordenadas
  Future<Ubicacion> getDetallesLugar(double latitud, double longitud);

  /// Calcula la ruta entre dos ubicaciones
  Future<Map<String, dynamic>> calcularRuta(
      Ubicacion origen, Ubicacion destino);
}
