import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../data/datasources/usuario_remote_datasource.dart';
import '../../../data/models/usuario_model.dart';

class UsuarioRemoteDataSourceImpl implements UsuarioRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UsuarioRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UsuarioModel> actualizarUsuario({
    required String id,
    String? nombre,
    String? telefono,
    String? fotoPerfil,
  }) async {
    try {
      final userDoc = _firestore.collection('usuarios').doc(id);

      final Map<String, dynamic> dataToUpdate = {};
      if (nombre != null) dataToUpdate['nombre'] = nombre;
      if (telefono != null) dataToUpdate['telefono'] = telefono;
      if (fotoPerfil != null) dataToUpdate['fotoPerfil'] = fotoPerfil;

      await userDoc.update(dataToUpdate);

      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        throw ServerException('Error al registrar usuario');
      }

      return UsuarioModel.fromJson({'id': id, ...docSnapshot.data()!});
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<bool> estaAutenticado() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UsuarioModel?> getUsuarioActual() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final docSnapshot =
          await _firestore.collection('usuarios').doc(firebaseUser.uid).get();

      if (!docSnapshot.exists) {
        return UsuarioModel(
          id: firebaseUser.uid,
          nombre: firebaseUser.displayName ?? '',
          email: firebaseUser.email!,
          telefono: firebaseUser.phoneNumber,
          fotoPerfil: firebaseUser.photoURL,
          cuentaVerificada: firebaseUser.emailVerified,
        );
      }

      return UsuarioModel.fromJson({
        'id': firebaseUser.uid,
        ...docSnapshot.data()!,
      });
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UsuarioModel> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException('Error al iniciar sesión: ${e.message}');
    } catch (e) {
      if (!e.toString().contains('List<Object?>')) {
        throw ServerException('Error al iniciar sesión: $e');
      }
    }
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw ServerException('Error al iniciar sesión: usuario no creado');
      }
      final docSnapshot =
          await _firestore.collection('usuarios').doc(firebaseUser.uid).get();

      if (!docSnapshot.exists) {
        return UsuarioModel(
          id: firebaseUser.uid,
          nombre: firebaseUser.displayName ?? '',
          email: firebaseUser.email!,
          telefono: firebaseUser.phoneNumber,
          fotoPerfil: firebaseUser.photoURL,
          cuentaVerificada: firebaseUser.emailVerified,
        );
      }

      return UsuarioModel.fromJson({
        'id': firebaseUser.uid,
        ...docSnapshot.data()!,
      });
    } catch (e) {
      throw ServerException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UsuarioModel> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException('Error al registrar usuario: ${e.message}');
    } catch (e) {
      if (!e.toString().contains('List<Object?>')) {
        throw ServerException('Error al registrar usuario: $e');
      }
    }
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw ServerException('Error al registrar usuario: usuario no creado');
      }

      await firebaseUser.updateDisplayName(nombre);

      final usuario = UsuarioModel(
        id: firebaseUser.uid,
        nombre: nombre,
        email: email,
        telefono: telefono,
        cuentaVerificada: false,
      );

      await _firestore
          .collection('usuarios')
          .doc(firebaseUser.uid)
          .set(usuario.toJson());

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException('Error al registrar usuario: ${e.message}');
    } catch (e) {
      throw ServerException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> restablecerContrasena({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException('Error al restablecer contraseña: ${e.message}');
    } catch (e) {
      throw ServerException('Error al restablecer contraseña: $e');
    }
  }
}
