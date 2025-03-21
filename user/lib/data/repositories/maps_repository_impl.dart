import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/location_service.dart';
import '../../core/services/maps_service.dart';
import '../../data/models/direction_model.dart';
import '../../data/models/place_model.dart';
import '../../domain/repositories/maps_repository.dart';

/// Implementación del repositorio para manejar operaciones relacionadas con mapas
class MapsRepositoryImpl implements MapsRepository {
  final MapsService _mapsService;
  final LocationService _locationService;

  MapsRepositoryImpl({
    required MapsService mapsService,
    required LocationService locationService,
  }) : _mapsService = mapsService,
       _locationService = locationService;

  @override
  Future<List<PlaceModel>> searchPlaces(String query) async {
    final results = await _mapsService.searchPlaces(query);
    return results.map((place) => PlaceModel.fromJson(place)).toList();
  }

  @override
  Future<PlaceModel> getPlaceDetails(String placeId) async {
    final result = await _mapsService.getPlaceDetails(placeId);
    return PlaceModel.fromJson(result);
  }

  @override
  Future<DirectionModel> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final result = await _mapsService.getDirections(origin, destination);
    return DirectionModel.fromJson(result);
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    return _locationService.positionToLatLng(position);
  }

  @override
  double calculateDistance(LatLng start, LatLng end) {
    return _locationService.calculateDistance(start, end);
  }
}
