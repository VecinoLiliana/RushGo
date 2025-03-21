import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modelo para representar direcciones entre dos puntos
class DirectionModel {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final int distanceValue; // en metros
  final String durationText;
  final int durationValue; // en segundos
  final LatLng northeastBound;
  final LatLng southwestBound;
  final String startAddress;
  final String endAddress;

  DirectionModel({
    required this.polylinePoints,
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
    required this.northeastBound,
    required this.southwestBound,
    required this.startAddress,
    required this.endAddress,
  });

  factory DirectionModel.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'];
    if (routes.isEmpty) {
      throw Exception('No se encontraron rutas');
    }

    final data = routes[0];
    final legs = data['legs'];
    final leg = legs[0];

    final polylinePoints = <LatLng>[];
    final decodedPolyline =
        _decodePolyline(data['overview_polyline']['points']);
    for (var point in decodedPolyline) {
      polylinePoints.add(LatLng(point[0], point[1]));
    }

    final bounds = data['bounds'];
    final northeast = bounds['northeast'];
    final southwest = bounds['southwest'];

    return DirectionModel(
      polylinePoints: polylinePoints,
      distanceText: leg['distance']['text'],
      distanceValue: leg['distance']['value'],
      durationText: leg['duration']['text'],
      durationValue: leg['duration']['value'],
      northeastBound: LatLng(northeast['lat'], northeast['lng']),
      southwestBound: LatLng(southwest['lat'], southwest['lng']),
      startAddress: leg['start_address'],
      endAddress: leg['end_address'],
    );
  }

  /// Decodifica un polyline para obtener una lista de coordenadas
  static List<List<double>> _decodePolyline(String encoded) {
    List<List<double>> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latDouble = lat / 1E5;
      double lngDouble = lng / 1E5;
      poly.add([latDouble, lngDouble]);
    }

    return poly;
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline_points': polylinePoints
          .map((point) => {
                'lat': point.latitude,
                'lng': point.longitude,
              })
          .toList(),
      'distance_text': distanceText,
      'distance_value': distanceValue,
      'duration_text': durationText,
      'duration_value': durationValue,
      'northeast_bound': {
        'lat': northeastBound.latitude,
        'lng': northeastBound.longitude,
      },
      'southwest_bound': {
        'lat': southwestBound.latitude,
        'lng': southwestBound.longitude,
      },
      'start_address': startAddress,
      'end_address': endAddress,
    };
  }
}
