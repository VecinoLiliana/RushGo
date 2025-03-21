import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/driver.dart';

/// Interfaz para el datasource de Firestore
abstract class FirestoreDataSource {
  /// Obtiene los conductores disponibles cerca de la posición del usuario
  Stream<List<Driver>> getAvailableDrivers(LatLng userPosition);

  /// Solicita un viaje con los datos proporcionados
  Future<bool> requestRide(Map<String, dynamic> rideData);

  /// Actualiza la ubicación del usuario en Firestore
  Future<void> updateUserLocation(LatLng position);

  /// Obtiene el estado de un viaje específico
  Stream<Map<String, dynamic>> getRideStatus(String rideId);

  /// Cancela un viaje solicitado
  Future<bool> cancelRide(String rideId);

  /// Califica a un conductor después de un viaje
  Future<bool> rateDriver(String rideId, int rating, String? comment);
}
