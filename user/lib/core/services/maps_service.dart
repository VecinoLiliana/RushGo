import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/map_constants.dart';
import '../errors/exceptions.dart';

/// Servicio para manejar la configuración y estilos de Google Maps
class MapsService {
  /// Singleton instance
  static final MapsService _instance = MapsService._internal();

  /// Factory constructor
  factory MapsService() => _instance;

  /// Private constructor
  MapsService._internal();

  /// Aplica el tema oscuro al mapa
  void setBlackMapTheme(GoogleMapController controller) {
    controller.setMapStyle('''
                   [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
]
    ''');
  }

  /// Busca lugares según un término de búsqueda
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=${MapConstants.apiKey}');

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw ServerException('Error al buscar lugares: ${data['status']}');
      }

      return List<Map<String, dynamic>>.from(data['results']);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al buscar lugares: $e');
    }
  }

  /// Obtiene detalles de un lugar por su ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${MapConstants.apiKey}');

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw ServerException(
            'Error al obtener detalles del lugar: ${data['status']}');
      }

      return data['result'];
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al obtener detalles del lugar: $e');
    }
  }

  /// Obtiene direcciones entre dos puntos
  Future<Map<String, dynamic>> getDirections(
      LatLng origin, LatLng destination) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${MapConstants.apiKey}');

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw ServerException(
            'Error al obtener direcciones: ${data['status']}');
      }

      return data;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error al obtener direcciones: $e');
    }
  }

  /// Decodifica un polyline para obtener una lista de coordenadas
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
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
      poly.add(LatLng(latDouble, lngDouble));
    }

    return poly;
  }
}
