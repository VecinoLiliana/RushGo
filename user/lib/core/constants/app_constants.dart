/// Constantes generales de la aplicación
class AppConstants {
  AppConstants._();

  // Información de la aplicación
  static const String appName = 'RushGo';
  static const String appVersion = '1.0.0';

  // Preferencias
  static const String prefsKeyToken = 'auth_token';
  static const String prefsKeyUserId = 'user_id';
  static const String prefsKeyUserName = 'user_name';
  static const String prefsKeyUserEmail = 'user_email';
  static const String prefsKeyUserPhone = 'user_phone';
  static const String prefsKeyUserPhoto = 'user_photo';
  static const String prefsKeyIsLoggedIn = 'is_logged_in';
  static const String prefsKeyLanguage = 'app_language';
  static const String prefsKeyThemeMode = 'theme_mode';

  // Duración de animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Tamaños
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;

  // Límites
  static const int maxSearchResults = 10;
  static const int maxRecentLocations = 5;
  static const int maxNotifications = 50;
}
