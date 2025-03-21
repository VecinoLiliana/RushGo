import 'package:flutter/material.dart';
import '../../domain/entities/ubicacion.dart';
import '../../domain/entities/viaje.dart';
import '../../domain/usecases/viaje/calificar_viaje_usecase.dart';
import '../../domain/usecases/viaje/cancelar_viaje_usecase.dart';
import '../../domain/usecases/viaje/get_viaje_activo_usecase.dart';
import '../../domain/usecases/viaje/get_viaje_usecase.dart';
import '../../domain/usecases/viaje/get_viajes_usuario_usecase.dart';
import '../../domain/usecases/viaje/solicitar_viaje_usecase.dart';

enum ViajeStatus { initial, loading, loaded, error }

class ViajeProvider extends ChangeNotifier {
  final SolicitarViajeUseCase _solicitarViajeUseCase;
  final CancelarViajeUseCase _cancelarViajeUseCase;
  final GetViajeUseCase _getViajeUseCase;
  final GetViajesUsuarioUseCase _getViajesUsuarioUseCase;
  final GetViajeActivoUseCase _getViajeActivoUseCase;
  final CalificarViajeUseCase _calificarViajeUseCase;

  ViajeProvider({
    required SolicitarViajeUseCase solicitarViajeUseCase,
    required CancelarViajeUseCase cancelarViajeUseCase,
    required GetViajeUseCase getViajeUseCase,
    required GetViajesUsuarioUseCase getViajesUsuarioUseCase,
    required GetViajeActivoUseCase getViajeActivoUseCase,
    required CalificarViajeUseCase calificarViajeUseCase,
  })  : _solicitarViajeUseCase = solicitarViajeUseCase,
        _cancelarViajeUseCase = cancelarViajeUseCase,
        _getViajeUseCase = getViajeUseCase,
        _getViajesUsuarioUseCase = getViajesUsuarioUseCase,
        _getViajeActivoUseCase = getViajeActivoUseCase,
        _calificarViajeUseCase = calificarViajeUseCase;

  ViajeStatus _status = ViajeStatus.initial;
  ViajeStatus get status => _status;

  Viaje? _viajeActual;
  Viaje? get viajeActual => _viajeActual;

  List<Viaje> _historialViajes = [];
  List<Viaje> get historialViajes => _historialViajes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setStatus(ViajeStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(ViajeStatus.error);
  }

  Future<void> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  }) async {
    _setStatus(ViajeStatus.loading);
    try {
      final params = SolicitarViajeParams(
        idUsuario: idUsuario,
        origen: origen,
        destino: destino,
      );
      final result = await _solicitarViajeUseCase(params);
      result.fold(
        (failure) => _setError(failure.message),
        (viaje) {
          _viajeActual = viaje;
          _setStatus(ViajeStatus.loaded);
        },
      );
    } catch (e) {
      _setError('Error al solicitar viaje: $e');
    }
  }

  Future<void> cancelarViaje(String idViaje) async {
    _setStatus(ViajeStatus.loading);
    try {
      final result = await _cancelarViajeUseCase(idViaje);
      result.fold(
        (failure) => _setError(failure.message),
        (_) {
          _viajeActual = null;
          _setStatus(ViajeStatus.loaded);
        },
      );
    } catch (e) {
      _setError('Error al cancelar viaje: $e');
    }
  }

  Future<void> getViaje(String idViaje) async {
    _setStatus(ViajeStatus.loading);
    try {
      final result = await _getViajeUseCase(idViaje);
      result.fold(
        (failure) => _setError(failure.message),
        (viaje) {
          _viajeActual = viaje;
          _setStatus(ViajeStatus.loaded);
        },
      );
    } catch (e) {
      _setError('Error al obtener viaje: $e');
    }
  }

  Future<void> getViajesUsuario(String idUsuario) async {
    _setStatus(ViajeStatus.loading);
    try {
      final result = await _getViajesUsuarioUseCase(idUsuario);
      result.fold(
        (failure) => _setError(failure.message),
        (viajes) {
          _historialViajes = viajes;
          _setStatus(ViajeStatus.loaded);
        },
      );
    } catch (e) {
      _setError('Error al obtener viajes del usuario: $e');
    }
  }

  Future<void> getViajeActivo(String idUsuario) async {
    _setStatus(ViajeStatus.loading);
    try {
      final result = await _getViajeActivoUseCase(idUsuario);
      result.fold(
        (failure) => _setError(failure.message),
        (viaje) {
          _viajeActual = viaje;
          _setStatus(ViajeStatus.loaded);
        },
      );
    } catch (e) {
      _setError('Error al obtener viaje activo: $e');
    }
  }

  Future<void> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  }) async {
    _setStatus(ViajeStatus.loading);
    try {
      final params = CalificarViajeParams(
        idViaje: idViaje,
        calificacion: calificacion,
        comentario: comentario,
      );
      final result = await _calificarViajeUseCase(params);
      result.fold(
        (failure) => _setError(failure.message),
        (_) => _setStatus(ViajeStatus.loaded),
      );
    } catch (e) {
      _setError('Error al calificar viaje: $e');
    }
  }

  void resetStatus() {
    _status = ViajeStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
