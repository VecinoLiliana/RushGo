import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../../../core/errors/exceptions.dart';
import '../../../data/datasources/viaje_remote_datasource.dart';
import '../../../data/models/ubicacion_model.dart';
import '../../../data/models/viaje_model.dart';
import '../../../domain/entities/ubicacion.dart';
import '../../../domain/entities/viaje.dart';

/// Implementación del datasource remoto para viajes
class ViajeRemoteDataSourceImpl implements ViajeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GeoFlutterFire _geo;

  ViajeRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GeoFlutterFire geo,
  })  : _firestore = firestore,
        _auth = auth,
        _geo = geo;

  @override
  Future<Viaje> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  }) async {
    try {
      // Convertir ubicaciones a modelos
      final origenModel = UbicacionModel.fromEntity(origen);
      final destinoModel = UbicacionModel.fromEntity(destino);

      // Crear datos del viaje
      final viajeData = {
        'idUsuario': idUsuario,
        'origen': origenModel.toJson(),
        'destino': destinoModel.toJson(),
        'estado': 'solicitado',
        'fechaSolicitud': FieldValue.serverTimestamp(),
        'precio': 0.0, // Se calculará cuando un conductor acepte
        'distanciaEstimada': 0.0, // Se calculará cuando un conductor acepte
        'tiempoEstimado': 0, // Se calculará cuando un conductor acepte
      };

      // Guardar en Firestore
      final docRef = await _firestore.collection('viajes').add(viajeData);

      // Obtener el documento recién creado
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data()!;

      // Crear y devolver el modelo de viaje
      return ViajeModel.fromJson({...data, 'id': docRef.id});
    } catch (e) {
      throw ServerException('Error al solicitar viaje',
          code: 'solicitar-viaje-error', details: e.toString());
    }
  }

  @override
  Future<void> cancelarViaje(String idViaje) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw AuthException('Usuario no autenticado', code: 'auth-error');
      }

      // Verificar que el viaje pertenezca al usuario actual
      final viajeDoc = await _firestore.collection('viajes').doc(idViaje).get();

      if (!viajeDoc.exists) {
        throw ServerException('Viaje no encontrado', code: 'viaje-not-found');
      }

      final viajeData = viajeDoc.data();
      if (viajeData == null || viajeData['idUsuario'] != userId) {
        throw AuthException('No tienes permiso para cancelar este viaje',
            code: 'permission-denied');
      }

      // Verificar que el viaje esté en un estado que permita cancelación
      final estadoViaje = viajeData['estado'];
      if (estadoViaje != 'solicitado' && estadoViaje != 'aceptado') {
        throw ValidationException(
            'No se puede cancelar un viaje en estado $estadoViaje',
            code: 'invalid-state');
      }

      // Actualizar el estado del viaje a cancelado
      await _firestore.collection('viajes').doc(idViaje).update({
        'estado': 'cancelado',
        'fechaCancelacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Error al cancelar viaje',
          code: 'cancelar-viaje-error', details: e.toString());
    }
  }

  @override
  Future<Viaje> getViaje(String idViaje) async {
    try {
      final docSnapshot =
          await _firestore.collection('viajes').doc(idViaje).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw ServerException('Viaje no encontrado', code: 'viaje-not-found');
      }

      return ViajeModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });
    } catch (e) {
      throw ServerException('Error al obtener viaje',
          code: 'get-viaje-error', details: e.toString());
    }
  }

  @override
  Future<List<Viaje>> getViajesUsuario(String idUsuario) async {
    try {
      final querySnapshot = await _firestore
          .collection('viajes')
          .where('idUsuario', isEqualTo: idUsuario)
          .orderBy('fechaSolicitud', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return ViajeModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener viajes del usuario',
          code: 'get-viajes-usuario-error', details: e.toString());
    }
  }

  /// Obtiene un stream con actualizaciones en tiempo real del estado de un viaje
  Stream<Viaje> getViajeStream(String idViaje) {
    try {
      return _firestore.collection('viajes').doc(idViaje).snapshots().map((
        snapshot,
      ) {
        if (snapshot.exists && snapshot.data() != null) {
          return ViajeModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
        } else {
          throw ServerException('Viaje no encontrado', code: 'viaje-not-found');
        }
      });
    } catch (e) {
      throw ServerException('Error al obtener stream del viaje',
          code: 'get-viaje-stream-error', details: e.toString());
    }
  }

  /// Califica a un conductor después de un viaje
  Future<void> calificarConductor(
    String idViaje,
    int calificacion,
    String? comentario,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw AuthException('Usuario no autenticado', code: 'auth-error');
      }

      // Verificar que el viaje pertenezca al usuario actual y esté completado
      final viajeDoc = await _firestore.collection('viajes').doc(idViaje).get();

      if (!viajeDoc.exists || viajeDoc.data() == null) {
        throw ServerException('Viaje no encontrado', code: 'viaje-not-found');
      }

      final viajeData = viajeDoc.data()!;
      if (viajeData['idUsuario'] != userId) {
        throw AuthException('No tienes permiso para calificar este viaje',
            code: 'permission-denied');
      }

      if (viajeData['estado'] != 'completado') {
        throw ValidationException('Solo puedes calificar viajes completados',
            code: 'invalid-state');
      }

      // Actualizar el documento del viaje con la calificación
      await _firestore.collection('viajes').doc(idViaje).update({
        'calificacion': calificacion,
        'comentario': comentario,
        'fechaCalificacion': FieldValue.serverTimestamp(),
      });

      // Si el viaje tiene un idConductor, actualizar también las estadísticas del conductor
      if (viajeData.containsKey('idConductor')) {
        final idConductor = viajeData['idConductor'];
        final conductorRef =
            _firestore.collection('conductores').doc(idConductor);

        // Obtener datos actuales del conductor
        final conductorDoc = await conductorRef.get();
        if (conductorDoc.exists && conductorDoc.data() != null) {
          final conductorData = conductorDoc.data()!;

          // Calcular nueva calificación promedio
          final calificacionActual = conductorData['calificacion'] ?? 5.0;
          final totalCalificaciones = conductorData['totalCalificaciones'] ?? 0;

          final nuevoTotalCalificaciones = totalCalificaciones + 1;
          final nuevaCalificacion =
              ((calificacionActual * totalCalificaciones) + calificacion) /
                  nuevoTotalCalificaciones;

          // Actualizar calificación del conductor
          await conductorRef.update({
            'calificacion': nuevaCalificacion,
            'totalCalificaciones': nuevoTotalCalificaciones,
          });
        }
      }
    } catch (e) {
      throw ServerException('Error al calificar conductor',
          code: 'calificar-conductor-error', details: e.toString());
    }
  }

  @override
  Future<Viaje?> getViajeActivo(String idUsuario) async {
    try {
      final querySnapshot = await _firestore
          .collection('viajes')
          .where('idUsuario', isEqualTo: idUsuario)
          .where('estado', whereIn: ['solicitado', 'aceptado', 'en_curso'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No hay viaje activo
      }

      final doc = querySnapshot.docs.first;
      return ViajeModel.fromJson({...doc.data(), 'id': doc.id});
    } catch (e) {
      throw ServerException('Error al obtener viaje activo',
          code: 'get-viaje-activo-error', details: e.toString());
    }
  }

  @override
  Future<void> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw AuthException('Usuario no autenticado', code: 'auth-error');
      }

      // Verificar que el viaje pertenezca al usuario actual y esté completado
      final viajeDoc = await _firestore.collection('viajes').doc(idViaje).get();

      if (!viajeDoc.exists || viajeDoc.data() == null) {
        throw ServerException('Viaje no encontrado', code: 'viaje-not-found');
      }

      final viajeData = viajeDoc.data()!;
      if (viajeData['idUsuario'] != userId) {
        throw AuthException('No tienes permiso para calificar este viaje',
            code: 'permission-denied');
      }

      if (viajeData['estado'] != 'completado') {
        throw ValidationException('Solo puedes calificar viajes completados',
            code: 'invalid-state');
      }

      // Actualizar el documento del viaje con la calificación
      await _firestore.collection('viajes').doc(idViaje).update({
        'calificacion': calificacion,
        'comentario': comentario,
        'fechaCalificacion': FieldValue.serverTimestamp(),
      });

      // Si el viaje tiene un idConductor, actualizar también las estadísticas del conductor
      if (viajeData.containsKey('idConductor')) {
        final idConductor = viajeData['idConductor'];
        final conductorRef =
            _firestore.collection('conductores').doc(idConductor);

        // Obtener datos actuales del conductor
        final conductorDoc = await conductorRef.get();
        if (conductorDoc.exists && conductorDoc.data() != null) {
          final conductorData = conductorDoc.data()!;

          // Calcular nueva calificación promedio
          final calificacionActual = conductorData['calificacion'] ?? 5.0;
          final totalCalificaciones = conductorData['totalCalificaciones'] ?? 0;

          final nuevoTotalCalificaciones = totalCalificaciones + 1;
          final nuevaCalificacion =
              ((calificacionActual * totalCalificaciones) + calificacion) /
                  nuevoTotalCalificaciones;

          // Actualizar calificación del conductor
          await conductorRef.update({
            'calificacion': nuevaCalificacion,
            'totalCalificaciones': nuevoTotalCalificaciones,
          });
        }
      }
    } catch (e) {
      throw ServerException('Error al calificar viaje',
          code: 'calificar-viaje-error', details: e.toString());
    }
  }
}
