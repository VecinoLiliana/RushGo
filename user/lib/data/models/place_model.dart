import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modelo para representar un lugar buscado
class PlaceModel {
  final String placeId;
  final String name;
  final String address;
  final LatLng location;
  final String? photoReference;
  final double? rating;

  PlaceModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    this.photoReference,
    this.rating,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceModel(
      placeId: json['place_id'],
      name: json['name'],
      address: json['formatted_address'] ?? '',
      location: LatLng(
        location['lat'],
        location['lng'],
      ),
      photoReference: json['photos'] != null && json['photos'].isNotEmpty
          ? json['photos'][0]['photo_reference']
          : null,
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted_address': address,
      'geometry': {
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
      },
      'photo_reference': photoReference,
      'rating': rating,
    };
  }
}
