import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/map_constants.dart';
import '../../core/services/location_service.dart';
import '../../core/services/maps_service.dart';
import '../../data/models/direction_model.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/maps_repository_impl.dart';
import '../../domain/repositories/maps_repository.dart';
import '../../presentation/themes/app_theme.dart';

/// Pantalla para solicitar un nuevo viaje
class SolicitarViajeScreen extends ConsumerStatefulWidget {
  const SolicitarViajeScreen({super.key});

  @override
  ConsumerState<SolicitarViajeScreen> createState() =>
      _SolicitarViajeScreenState();
}

class _SolicitarViajeScreenState extends ConsumerState<SolicitarViajeScreen> {
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  bool _isLoading = false;
  bool _mostrarMapa = false;
  bool _mostrarDetalles = false;
  // Used in UI to show loading indicator
  // ignore: unused_field
  bool _buscandoLugares = false;

  // Controlador del mapa
  GoogleMapController? _mapController;

  // Repositorio de mapas
  late final MapsRepository _mapsRepository;

  // Ubicación actual
  LatLng? _currentLocation;

  // Marcadores en el mapa
  final Map<String, Marker> _markers = {};

  // Polylines para la ruta
  final Map<PolylineId, Polyline> _polylines = {};

  // Lugares encontrados en la búsqueda
  // ignore: unused_field
  List<PlaceModel> _lugaresEncontrados = [];

  // Lugar seleccionado como origen y destino
  PlaceModel? _origenSeleccionado;
  PlaceModel? _destinoSeleccionado;

  // Información de la ruta
  // ignore: unused_field
  DirectionModel? _rutaInfo;

  // Valores para la interfaz
  double _distanciaEstimada = 0.0;
  double _tiempoEstimado = 0.0;
  double _costoEstimado = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicializar el repositorio de mapas
    _mapsRepository = MapsRepositoryImpl(
      mapsService: MapsService(),
      locationService: LocationService(),
    );

    // Obtener la ubicación actual al iniciar
    _obtenerUbicacionActual();
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Método para obtener la ubicación actual
  Future<void> _obtenerUbicacionActual() async {
    try {
      final ubicacion = await _mapsRepository.getCurrentLocation();
      setState(() {
        _currentLocation = ubicacion;
        _mostrarMapa = true;

        // Agregar marcador de ubicación actual
        _agregarMarcador(
          'current_location',
          ubicacion,
          'Mi ubicación',
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );

        // Establecer origen como ubicación actual
        _origenSeleccionado = PlaceModel(
          placeId: 'current_location',
          name: 'Mi ubicación actual',
          address: 'Ubicación actual',
          location: ubicacion,
        );

        _origenController.text = 'Mi ubicación actual';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  // Método para buscar lugares
  Future<void> _buscarLugares(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _buscandoLugares = true;
    });

    try {
      final lugares = await _mapsRepository.searchPlaces(query);

      setState(() {
        _lugaresEncontrados = lugares;
        _buscandoLugares = false;
      });

      // Mostrar modal con resultados
      _mostrarResultadosBusqueda(lugares);
    } catch (e) {
      setState(() {
        _buscandoLugares = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar lugares: $e')),
        );
      }
    }
  }

  // Método para mostrar resultados de búsqueda
  void _mostrarResultadosBusqueda(List<PlaceModel> lugares) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: lugares.length,
          itemBuilder: (context, index) {
            final lugar = lugares[index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(lugar.name),
              subtitle: Text(lugar.address),
              onTap: () {
                Navigator.pop(context);
                _seleccionarLugar(lugar);
              },
            );
          },
        ),
      ),
    );
  }

  // Método para seleccionar un lugar
  void _seleccionarLugar(PlaceModel lugar) {
    setState(() {
      // Si estamos editando el origen
      if (_origenController.text.isEmpty ||
          _origenController.text == 'Mi ubicación actual') {
        _origenSeleccionado = lugar;
        _origenController.text = lugar.name;

        // Actualizar marcador de origen
        _agregarMarcador(
          'origen',
          lugar.location,
          lugar.name,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      } else {
        // Estamos editando el destino
        _destinoSeleccionado = lugar;
        _destinoController.text = lugar.name;

        // Actualizar marcador de destino
        _agregarMarcador(
          'destino',
          lugar.location,
          lugar.name,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }

      // Mover cámara al lugar seleccionado
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          lugar.location,
          MapConstants.defaultZoom,
        ),
      );

      // Si tenemos origen y destino, calcular ruta
      if (_origenSeleccionado != null && _destinoSeleccionado != null) {
        _calcularRuta(
          _origenSeleccionado!.location,
          _destinoSeleccionado!.location,
        );
      }
    });
  }

  // Método para agregar un marcador al mapa
  void _agregarMarcador(
      String id, LatLng position, String title, BitmapDescriptor icon) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: icon,
    );

    setState(() {
      _markers[id] = marker;
    });
  }

  // Método para calcular la ruta entre dos puntos
  Future<void> _calcularRuta(LatLng origen, LatLng destino) async {
    try {
      final direccion = await _mapsRepository.getDirections(origen, destino);

      // Calcular costo estimado (ejemplo: $20 por km)
      final costoBase = 30.0; // Tarifa base
      final costoPorKm = 15.0; // Costo por km
      final distanciaKm = direccion.distanceValue / 1000.0;
      final costoTotal = costoBase + (distanciaKm * costoPorKm);

      setState(() {
        _rutaInfo = direccion;
        _mostrarDetalles = true;

        // Actualizar información para la interfaz
        _distanciaEstimada = distanciaKm;
        _tiempoEstimado =
            direccion.durationValue / 60.0; // Convertir segundos a minutos
        _costoEstimado = costoTotal;

        // Agregar polyline
        final polylineId = PolylineId('ruta');
        final polyline = Polyline(
          polylineId: polylineId,
          color: AppTheme.primaryColor,
          width: 5,
          points: direccion.polylinePoints,
        );

        _polylines[polylineId] = polyline;

        // Ajustar cámara para mostrar toda la ruta
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: direccion.southwestBound,
              northeast: direccion.northeastBound,
            ),
            50, // padding
          ),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular ruta: $e')),
        );
      }
    }
  }

  // Método para buscar destino
  void _buscarDestino() {
    if (_destinoController.text.isEmpty) {
      return;
    }

    _buscarLugares(_destinoController.text);
  }

  Future<void> _solicitarViaje() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implementar lógica para solicitar viaje en Firebase
    await Future.delayed(const Duration(seconds: 2)); // Simulación

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Navegar a la pantalla de viaje activo con un ID simulado
      context.go('/viaje-activo/viaje-123');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Viaje'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Panel de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Campo de origen
                  TextField(
                    controller: _origenController,
                    decoration: InputDecoration(
                      labelText: 'Origen',
                      hintText: 'Tu ubicación actual',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo de destino
                  TextField(
                    controller: _destinoController,
                    decoration: InputDecoration(
                      labelText: 'Destino',
                      hintText: '¿A dónde vas?',
                      prefixIcon: const Icon(Icons.location_searching),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _buscarDestino,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mapa real de Google Maps
            if (_mostrarMapa)
              Expanded(
                child: Stack(
                  children: [
                    // Widget de Google Maps
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation ??
                            const LatLng(
                                19.4326, -99.1332), // Default: Ciudad de México
                        zoom: MapConstants.defaultZoom,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      markers: Set<Marker>.of(_markers.values),
                      polylines: Set<Polyline>.of(_polylines.values),
                      onMapCreated: (controller) {
                        setState(() {
                          _mapController = controller;
                          // Aplicar tema oscuro al mapa si es necesario
                        });
                      },
                    ),
                    // Panel de detalles y confirmación
                    if (_mostrarDetalles)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalles del viaje',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Información del viaje
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(
                                  context,
                                  Icons.straighten,
                                  '$_distanciaEstimada km',
                                  'Distancia',
                                ),
                                _buildInfoItem(
                                  context,
                                  Icons.access_time,
                                  '$_tiempoEstimado min',
                                  'Tiempo est.',
                                ),
                                _buildInfoItem(
                                  context,
                                  Icons.attach_money,
                                  '\$${_costoEstimado.toStringAsFixed(2)}',
                                  'Costo est.',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Botón de solicitar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _solicitarViaje,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'SOLICITAR AHORA',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Painter personalizado para simular una ruta en el mapa
class RutaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(100, 120); // Punto inicial (origen)
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      size.width - 100,
      size.height - 150,
    ); // Punto final (destino)

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
