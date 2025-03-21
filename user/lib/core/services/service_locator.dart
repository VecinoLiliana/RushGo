import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

import '../services/auth_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/location_service.dart';
import '../services/maps_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../../data/datasources/implementations/usuario_local_datasource_impl.dart';
import '../../data/datasources/implementations/usuario_remote_datasource_impl.dart';
import '../../data/datasources/implementations/firestore_datasource_impl.dart';
import '../../data/datasources/implementations/viaje_remote_datasource_impl.dart'
    as viaje_impl;
import '../../data/datasources/usuario_local_datasource.dart';
import '../../data/datasources/usuario_remote_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/datasources/viaje_remote_datasource.dart';
import '../../data/repositories/firestore_repository_impl.dart';
import '../../data/repositories/maps_repository_impl.dart';
import '../../data/repositories/viaje_repository_impl.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../domain/repositories/firestore_repository.dart';
import '../../domain/repositories/maps_repository.dart';
import '../../domain/repositories/viaje_repository.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/usecases/usuario/iniciar_sesion_usecase.dart';
import '../../domain/usecases/usuario/registrar_usuario_usecase.dart';
import '../../domain/usecases/viaje/solicitar_viaje_usecase.dart';
import '../../domain/usecases/viaje/cancelar_viaje_usecase.dart';
import '../../domain/usecases/viaje/get_viaje_usecase.dart';
import '../../domain/usecases/viaje/get_viajes_usuario_usecase.dart';
import '../../domain/usecases/viaje/get_viaje_activo_usecase.dart';
import '../../domain/usecases/viaje/calificar_viaje_usecase.dart';

final sl = GetIt.instance;

/// Configura la inyección de dependencias para la aplicación
Future<void> setupServiceLocator() async {
  // Servicios externos
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  sl.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin());
  sl.registerSingleton<GeoFlutterFire>(GeoFlutterFire());

  // Servicios core
  sl.registerSingleton<StorageService>(StorageService(sl<SharedPreferences>()));
  sl.registerSingleton<NotificationService>(
      NotificationService(sl<FlutterLocalNotificationsPlugin>()));
  sl.registerSingleton<FirebaseMessagingService>(
    FirebaseMessagingService(
      firebaseMessaging: sl<FirebaseMessaging>(),
      notificationService: sl<NotificationService>(),
    ),
  );
  sl.registerSingleton<LocationService>(LocationService());
  sl.registerSingleton<MapsService>(MapsService());
  sl.registerSingleton<AuthService>(AuthService());

  // Datasources
  sl.registerLazySingleton<UsuarioRemoteDataSource>(
    () => UsuarioRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<UsuarioLocalDataSource>(
    () => UsuarioLocalDataSourceImpl(
      storageService: sl<StorageService>(),
    ),
  );
  sl.registerLazySingleton<FirestoreDataSource>(
    () => FirestoreDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
      geo: sl<GeoFlutterFire>(),
    ),
  );
  sl.registerLazySingleton<ViajeRemoteDataSource>(
    () => viaje_impl.ViajeRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
      geo: sl<GeoFlutterFire>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<UsuarioRepository>(
    () => UsuarioRepositoryImpl(
      remoteDataSource: sl<UsuarioRemoteDataSource>(),
      localDataSource: sl<UsuarioLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<FirestoreRepository>(
    () => FirestoreRepositoryImpl(
      dataSource: sl<FirestoreDataSource>(),
    ),
  );
  sl.registerLazySingleton<MapsRepository>(
    () => MapsRepositoryImpl(
      mapsService: sl<MapsService>(),
      locationService: sl<LocationService>(),
    ),
  );
  sl.registerLazySingleton<ViajeRepository>(
    () => ViajeRepositoryImpl(
      remoteDataSource: sl<ViajeRemoteDataSource>(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(
      () => RegistrarUsuarioUseCase(sl<UsuarioRepository>()));
  sl.registerLazySingleton(() => IniciarSesionUseCase(sl<UsuarioRepository>()));

  // Viaje usecases
  sl.registerLazySingleton(() => SolicitarViajeUseCase(sl<ViajeRepository>()));
  sl.registerLazySingleton(() => CancelarViajeUseCase(sl<ViajeRepository>()));
  sl.registerLazySingleton(() => GetViajeUseCase(sl<ViajeRepository>()));
  sl.registerLazySingleton(
      () => GetViajesUsuarioUseCase(sl<ViajeRepository>()));
  sl.registerLazySingleton(() => GetViajeActivoUseCase(sl<ViajeRepository>()));
  sl.registerLazySingleton(() => CalificarViajeUseCase(sl<ViajeRepository>()));
}
