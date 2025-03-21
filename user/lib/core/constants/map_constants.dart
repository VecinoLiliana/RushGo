/// Constantes relacionadas con Google Maps
class MapConstants {
  MapConstants._();

  /// API Key para Google Maps
  static const String apiKey = "AIzaSyBHDoaqQSBglJT3q-suNoXtBgeOA8nbHms";

  /// Zoom inicial para el mapa
  static const double defaultZoom = 15.0;

  /// Duración de la animación de cámara
  static const Duration cameraDuration = Duration(milliseconds: 500);

  /// Radio de búsqueda en metros
  static const int searchRadius = 5000;

  /// Límite de resultados de búsqueda
  static const int searchLimit = 10;
}
