import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/exceptions.dart';

/// Servicio para manejar la autenticación con Firebase
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Singleton instance
  static final AuthService _instance = AuthService._internal(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );

  /// Factory constructor
  factory AuthService() => _instance;

  /// Private constructor
  AuthService._internal(this._auth, this._firestore);

  /// Obtiene el usuario actual
  User? get currentUser => _auth.currentUser;

  /// Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registra un nuevo usuario con email y contraseña
  Future<User?> registrarConEmailYPassword({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Actualizar el perfil del usuario
        await user.updateDisplayName(nombre);

        // Guardar datos adicionales en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'nombre': nombre,
          'email': email,
          'telefono': telefono,
          'createdAt': FieldValue.serverTimestamp(),
          'viajes': 0,
        });

        // Recargar el usuario para obtener los datos actualizados
        await user.reload();
        return _auth.currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('La contraseña proporcionada es demasiado débil');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Ya existe una cuenta con ese correo electrónico');
      } else if (e.code == 'invalid-email') {
        throw AuthException('El correo electrónico no es válido');
      } else {
        throw AuthException('Error al registrar usuario: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Error al registrar usuario: $e');
    }
  }

  /// Inicia sesión con email y contraseña
  Future<User?> iniciarSesionConEmailYPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('No existe un usuario con ese correo electrónico');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Contraseña incorrecta');
      } else {
        throw AuthException('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Error al iniciar sesión: $e');
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  /// Envía un correo para restablecer la contraseña
  Future<void> restablecerPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('No existe un usuario con ese correo electrónico');
      } else {
        throw AuthException(
            'Error al enviar correo de restablecimiento: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Error al restablecer contraseña: $e');
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> actualizarPerfil({
    String? nombre,
    String? telefono,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No hay usuario autenticado');
      }

      // Actualizar datos en Firebase Auth
      if (nombre != null) {
        await user.updateDisplayName(nombre);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Actualizar datos en Firestore
      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (telefono != null) updateData['telefono'] = telefono;
      if (photoURL != null) updateData['photoURL'] = photoURL;

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updateData);
      }

      // Recargar el usuario para obtener los datos actualizados
      await user.reload();
    } catch (e) {
      throw AuthException('Error al actualizar perfil: $e');
    }
  }
}
