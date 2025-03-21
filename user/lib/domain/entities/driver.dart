import 'package:equatable/equatable.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

/// Entidad que representa a un conductor en el sistema
class Driver extends Equatable {
  /// Nombre del conductor
  final String name;

  /// Email del conductor
  final String email;

  /// Nombre del vehículo
  final String carName;

  /// Número de placa del vehículo
  final String carPlateNum;

  /// Tipo de vehículo
  final String carType;

  /// Ubicación del conductor (GeoFirePoint)
  final GeoFirePoint driverLoc;

  /// Estado del conductor (online/offline)
  final String driverStatus;

  /// Constructor
  const Driver({
    required this.name,
    required this.email,
    required this.carName,
    required this.carPlateNum,
    required this.carType,
    required this.driverLoc,
    required this.driverStatus,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        carName,
        carPlateNum,
        carType,
        driverLoc,
        driverStatus,
      ];
}
