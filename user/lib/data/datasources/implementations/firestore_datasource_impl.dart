import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../firestore_datasource.dart';
import '../../models/driver_model.dart';
import '../../../domain/entities/driver.dart';

/// Implementación del datasource para Firestore
class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GeoFlutterFire _geo;

  FirestoreDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GeoFlutterFire geo,
  })  : _firestore = firestore,
        _auth = auth,
        _geo = geo;

  @override
  Stream<List<Driver>> getAvailableDrivers(LatLng userPosition) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> driversStream =
          _firestore.collection("Drivers").snapshots();

      return driversStream.map((snapshot) {
        List<Driver> drivers = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();

          // Solo incluir conductores en línea
          if (data["driverStatus"] == "offline") continue;

          DriverModel model = DriverModel.fromJson(data);
          drivers.add(model);
        }

        return drivers;
      });
    } catch (e) {
      // En caso de error, devolver un stream vacío
      return Stream.value([]);
    }
  }

  @override
  Future<bool> requestRide(Map<String, dynamic> rideData) async {
    try {
      // Obtener el ID del usuario actual
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Agregar datos del viaje a Firestore
      await _firestore.collection("Rides").add({
        ...rideData,
        "userId": userId,
        "status": "requested",
        "timestamp": FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateUserLocation(LatLng position) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Crear un punto GeoFirePoint
      final geoPoint = _geo.point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Actualizar la ubicación del usuario en Firestore
      await _firestore.collection("Users").doc(userId).update({
        "location": geoPoint.data,
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Manejar errores silenciosamente
    }
  }

  @override
  Stream<Map<String, dynamic>> getRideStatus(String rideId) {
    try {
      // Obtener un stream del documento del viaje específico
      return _firestore.collection("Rides").doc(rideId).snapshots().map(
        (snapshot) {
          if (snapshot.exists) {
            return snapshot.data() ?? {};
          } else {
            return {};
          }
        },
      );
    } catch (e) {
      // En caso de error, devolver un stream con un mapa vacío
      return Stream.value({});
    }
  }

  @override
  Future<bool> cancelRide(String rideId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Verificar que el viaje pertenezca al usuario actual
      final rideDoc = await _firestore.collection("Rides").doc(rideId).get();

      if (!rideDoc.exists) return false;

      final rideData = rideDoc.data();
      if (rideData == null || rideData["userId"] != userId) return false;

      // Actualizar el estado del viaje a cancelado
      await _firestore.collection("Rides").doc(rideId).update({
        "status": "cancelled",
        "cancelledAt": FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> rateDriver(String rideId, int rating, String? comment) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Verificar que el viaje pertenezca al usuario actual y esté completado
      final rideDoc = await _firestore.collection("Rides").doc(rideId).get();

      if (!rideDoc.exists) return false;

      final rideData = rideDoc.data();
      if (rideData == null ||
          rideData["userId"] != userId ||
          rideData["status"] != "completed") {
        return false;
      }

      // Actualizar el documento del viaje con la calificación
      await _firestore.collection("Rides").doc(rideId).update({
        "rating": rating,
        "comment": comment,
        "ratedAt": FieldValue.serverTimestamp(),
      });

      // Si el viaje tiene un driverId, actualizar también las estadísticas del conductor
      if (rideData.containsKey("driverId")) {
        final driverId = rideData["driverId"];
        final driverRef = _firestore.collection("Drivers").doc(driverId);

        // Obtener datos actuales del conductor
        final driverDoc = await driverRef.get();
        if (driverDoc.exists && driverDoc.data() != null) {
          final driverData = driverDoc.data()!;

          // Calcular nueva calificación promedio
          final currentRating = driverData["rating"] ?? 5.0;
          final totalRatings = driverData["totalRatings"] ?? 0;

          final newTotalRatings = totalRatings + 1;
          final newRating =
              ((currentRating * totalRatings) + rating) / newTotalRatings;

          // Actualizar calificación del conductor
          await driverRef.update({
            "rating": newRating,
            "totalRatings": newTotalRatings,
          });
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
