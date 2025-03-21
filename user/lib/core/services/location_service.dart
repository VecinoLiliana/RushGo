import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../errors/exceptions.dart';

/// Servicio para manejar la geolocalización
class LocationService {
  /// Singleton instance
  static final LocationService _instance = LocationService._internal();

  /// Factory constructor
  factory LocationService() => _instance;

  /// Private constructor
  LocationService._internal();

  /// Obtiene la ubicación actual del usuario
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Los servicios de ubicación están desactivados');
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Permisos de ubicación denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          'Los permisos de ubicación están permanentemente denegados, no se puede solicitar permisos');
    }

    // Obtener la ubicación actual
    return await Geolocator.getCurrentPosition();
  }

  /// Convierte una Position a LatLng para Google Maps
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Calcula la distancia entre dos coordenadas en metros
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Obtiene la última ubicación conocida
  Future<Position?> getLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Configura un stream para recibir actualizaciones de ubicación
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
