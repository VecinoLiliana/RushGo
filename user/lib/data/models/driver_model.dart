import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../../domain/entities/driver.dart';

/// Modelo para mapear datos de Firestore a la entidad Driver
class DriverModel extends Driver {
  const DriverModel({
    required super.name,
    required super.email,
    required super.carName,
    required super.carPlateNum,
    required super.carType,
    required super.driverLoc,
    required super.driverStatus,
  });

  /// Crea un modelo a partir de un mapa JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    // Crear un GeoFirePoint a partir de los datos de ubicación
    final GeoFlutterFire geo = GeoFlutterFire();
    final GeoFirePoint geoPoint =
        json['driverLoc'] != null
            ? geo.point(
              latitude: json['driverLoc']['geopoint'].latitude,
              longitude: json['driverLoc']['geopoint'].longitude,
            )
            : geo.point(latitude: 0, longitude: 0);

    return DriverModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      carName: json['carName'] ?? '',
      carPlateNum: json['carPlateNum'] ?? '',
      carType: json['carType'] ?? '',
      driverLoc: geoPoint,
      driverStatus: json['driverStatus'] ?? 'offline',
    );
  }

  /// Convierte el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'carName': carName,
      'carPlateNum': carPlateNum,
      'carType': carType,
      'driverLoc': driverLoc.data,
      'driverStatus': driverStatus,
    };
  }
}
