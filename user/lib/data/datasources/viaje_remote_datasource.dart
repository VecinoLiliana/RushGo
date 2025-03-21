import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ubicacion.dart';
import '../../domain/entities/viaje.dart';

abstract class ViajeRemoteDataSource {
  /// Solicita un nuevo viaje
  Future<Viaje> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  });

  /// Cancela un viaje
  Future<void> cancelarViaje(String idViaje);

  /// Obtiene un viaje por su ID
  Future<Viaje> getViaje(String idViaje);

  /// Obtiene los viajes del usuario
  Future<List<Viaje>> getViajesUsuario(String idUsuario);

  /// Obtiene el viaje activo del usuario (si existe)
  Future<Viaje?> getViajeActivo(String idUsuario);

  /// Califica un viaje completado
  Future<void> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  });
}

class ViajeRemoteDataSourceImpl implements ViajeRemoteDataSource {
  final FirebaseFirestore firestore;

  ViajeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Viaje> solicitarViaje({
    required String idUsuario,
    required Ubicacion origen,
    required Ubicacion destino,
  }) async {
    try {
      // Calcular estimaciones (en una implementación real, esto podría usar
      // un servicio de mapas como Google Maps)
      final double distanciaEstimada = 5.0; // km
      final double tiempoEstimadoMinutos = 15.0;
      final double costoEstimado = 50.0; // pesos

      // Crear documento de viaje
      final viajeRef = firestore.collection('viajes').doc();

      final viajeData = {
        'idUsuario': idUsuario,
        'origen': {
          'latitud': origen.latitud,
          'longitud': origen.longitud,
          'direccion': origen.direccion,
          'ciudad': origen.ciudad,
          'pais': origen.pais,
          'codigoPostal': origen.codigoPostal,
        },
        'destino': {
          'latitud': destino.latitud,
          'longitud': destino.longitud,
          'direccion': destino.direccion,
          'ciudad': destino.ciudad,
          'pais': destino.pais,
          'codigoPostal': destino.codigoPostal,
        },
        'fechaSolicitud': FieldValue.serverTimestamp(),
        'distanciaEstimada': distanciaEstimada,
        'tiempoEstimadoMinutos': tiempoEstimadoMinutos,
        'costoEstimado': costoEstimado,
        'estado': 'solicitado',
      };

      await viajeRef.set(viajeData);

      // Obtener el documento recién creado
      final docSnapshot = await viajeRef.get();
      final data = docSnapshot.data()!;

      // Convertir Timestamp a DateTime
      final fechaSolicitud = (data['fechaSolicitud'] as Timestamp).toDate();

      return Viaje(
        id: viajeRef.id,
        idUsuario: idUsuario,
        origen: origen,
        destino: destino,
        fechaSolicitud: fechaSolicitud,
        distanciaEstimada: distanciaEstimada,
        tiempoEstimadoMinutos: tiempoEstimadoMinutos,
        costoEstimado: costoEstimado,
        estado: EstadoViaje.solicitado,
      );
    } catch (e) {
      throw Exception('Error al solicitar viaje: $e');
    }
  }

  @override
  Future<void> cancelarViaje(String idViaje) async {
    try {
      await firestore.collection('viajes').doc(idViaje).update({
        'estado': 'cancelado',
      });
    } catch (e) {
      throw Exception('Error al cancelar viaje: $e');
    }
  }

  @override
  Future<Viaje> getViaje(String idViaje) async {
    try {
      final docSnapshot =
          await firestore.collection('viajes').doc(idViaje).get();

      if (!docSnapshot.exists) {
        throw Exception('Viaje no encontrado');
      }

      return _viajeFromSnapshot(docSnapshot);
    } catch (e) {
      throw Exception('Error al obtener viaje: $e');
    }
  }

  @override
  Future<List<Viaje>> getViajesUsuario(String idUsuario) async {
    try {
      final querySnapshot = await firestore
          .collection('viajes')
          .where('idUsuario', isEqualTo: idUsuario)
          .orderBy('fechaSolicitud', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _viajeFromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Error al obtener viajes del usuario: $e');
    }
  }

  @override
  Future<Viaje?> getViajeActivo(String idUsuario) async {
    try {
      final querySnapshot = await firestore
          .collection('viajes')
          .where('idUsuario', isEqualTo: idUsuario)
          .where(
            'estado',
            whereIn: ['solicitado', 'aceptado', 'enCamino', 'enCurso'],
          )
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return _viajeFromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Error al obtener viaje activo: $e');
    }
  }

  @override
  Future<void> calificarViaje({
    required String idViaje,
    required double calificacion,
    String? comentario,
  }) async {
    try {
      // Explicitly declare map with dynamic values to allow mixed types
      final Map<String, dynamic> updateData = {'calificacion': calificacion};

      if (comentario != null) {
        // Add comentario as a separate field in the map
        updateData['comentario'] = comentario;
      }

      await firestore.collection('viajes').doc(idViaje).update(updateData);
    } catch (e) {
      throw Exception('Error al calificar viaje: $e');
    }
  }

  // Método auxiliar para convertir un snapshot a un objeto Viaje
  Viaje _viajeFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final origenData = data['origen'] as Map<String, dynamic>;
    final destinoData = data['destino'] as Map<String, dynamic>;

    final origen = Ubicacion(
      latitud: origenData['latitud'],
      longitud: origenData['longitud'],
      direccion: origenData['direccion'],
      ciudad: origenData['ciudad'],
      pais: origenData['pais'],
      codigoPostal: origenData['codigoPostal'],
    );

    final destino = Ubicacion(
      latitud: destinoData['latitud'],
      longitud: destinoData['longitud'],
      direccion: destinoData['direccion'],
      ciudad: destinoData['ciudad'],
      pais: destinoData['pais'],
      codigoPostal: destinoData['codigoPostal'],
    );

    // Convertir string de estado a enum
    final estadoString = data['estado'] as String;
    final estado = EstadoViaje.values.firstWhere(
      (e) => e.toString().split('.').last == estadoString,
    );

    return Viaje(
      id: doc.id,
      idUsuario: data['idUsuario'],
      idConductor: data['idConductor'],
      origen: origen,
      destino: destino,
      fechaSolicitud: (data['fechaSolicitud'] as Timestamp).toDate(),
      fechaInicio: data['fechaInicio'] != null
          ? (data['fechaInicio'] as Timestamp).toDate()
          : null,
      fechaFin: data['fechaFin'] != null
          ? (data['fechaFin'] as Timestamp).toDate()
          : null,
      distanciaEstimada: data['distanciaEstimada'],
      tiempoEstimadoMinutos: data['tiempoEstimadoMinutos'],
      costoEstimado: data['costoEstimado'],
      costoFinal: data['costoFinal'],
      estado: estado,
      pago:
          null, // En una implementación completa, aquí se cargaría el pago si existe
    );
  }
}
