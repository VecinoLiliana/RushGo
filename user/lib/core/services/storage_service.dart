import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el almacenamiento local de la aplicación
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Guarda un valor String en el almacenamiento local
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Obtiene un valor String del almacenamiento local
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Guarda un valor bool en el almacenamiento local
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Obtiene un valor bool del almacenamiento local
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Guarda un valor int en el almacenamiento local
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Obtiene un valor int del almacenamiento local
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Guarda un valor double en el almacenamiento local
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Obtiene un valor double del almacenamiento local
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Guarda una lista de String en el almacenamiento local
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Obtiene una lista de String del almacenamiento local
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Elimina un valor del almacenamiento local
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Elimina todos los valores del almacenamiento local
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Verifica si existe una clave en el almacenamiento local
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
