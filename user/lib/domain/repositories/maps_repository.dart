import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/direction_model.dart';
import '../../data/models/place_model.dart';

/// Repositorio para manejar operaciones relacionadas con mapas
abstract class MapsRepository {
  /// Busca lugares según un término de búsqueda
  Future<List<PlaceModel>> searchPlaces(String query);

  /// Obtiene detalles de un lugar por su ID
  Future<PlaceModel> getPlaceDetails(String placeId);

  /// Obtiene direcciones entre dos puntos
  Future<DirectionModel> getDirections(LatLng origin, LatLng destination);

  /// Obtiene la ubicación actual del usuario
  Future<LatLng> getCurrentLocation();

  /// Calcula la distancia entre dos coordenadas en metros
  double calculateDistance(LatLng start, LatLng end);
}
