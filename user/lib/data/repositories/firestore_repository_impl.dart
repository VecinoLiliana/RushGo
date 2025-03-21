import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/firestore_repository.dart';

/// Implementación del repositorio para manejar operaciones relacionadas con Firestore
class FirestoreRepositoryImpl implements FirestoreRepository {
  final FirestoreDataSource _dataSource;

  FirestoreRepositoryImpl({required FirestoreDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Stream<List<Driver>> getAvailableDrivers(LatLng userPosition) {
    return _dataSource.getAvailableDrivers(userPosition);
  }

  @override
  Future<bool> requestRide(Map<String, dynamic> rideData) {
    return _dataSource.requestRide(rideData);
  }

  @override
  Future<void> updateUserLocation(LatLng position) {
    return _dataSource.updateUserLocation(position);
  }

  @override
  Stream<Map<String, dynamic>> getRideStatus(String rideId) {
    // Implementar la lógica para obtener el estado de un viaje específico
    return _dataSource.getRideStatus(rideId);
  }

  @override
  Future<bool> cancelRide(String rideId) {
    // Implementar la lógica para cancelar un viaje
    return _dataSource.cancelRide(rideId);
  }

  @override
  Future<bool> rateDriver(String rideId, int rating, String? comment) {
    // Implementar la lógica para calificar a un conductor
    return _dataSource.rateDriver(rideId, rating, comment);
  }
}
