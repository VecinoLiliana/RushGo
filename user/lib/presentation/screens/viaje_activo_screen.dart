import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/viaje.dart';
import '../../presentation/themes/app_theme.dart';

/// Pantalla que muestra el estado de un viaje activo
class ViajeActivoScreen extends ConsumerStatefulWidget {
  final String idViaje;

  const ViajeActivoScreen({super.key, required this.idViaje});

  @override
  ConsumerState<ViajeActivoScreen> createState() => _ViajeActivoScreenState();
}

class _ViajeActivoScreenState extends ConsumerState<ViajeActivoScreen> {
  // Estado simulado del viaje
  late EstadoViaje _estadoViaje;
  bool _isLoading = false;

  // Datos simulados del conductor
  final String _nombreConductor = "Juan Pérez";
  final String _placaVehiculo = "ABC-123";
  final String _modeloVehiculo = "Toyota Corolla";
  final double _calificacionConductor = 4.8;

  // Datos simulados del viaje
  final String _origenDireccion = "Av. Insurgentes Sur 1602";
  final String _destinoDireccion = "Plaza Universidad";
  final double _distanciaEstimada = 5.2;
  final double _tiempoEstimadoMinutos = 15;
  final double _costoEstimado = 120.0;

  @override
  void initState() {
    super.initState();
    // Iniciar con estado "aceptado" para simular que un conductor aceptó el viaje
    _estadoViaje = EstadoViaje.aceptado;

    // Simular cambios de estado del viaje
    _simularCambiosEstado();
  }

  // Método para simular cambios en el estado del viaje
  Future<void> _simularCambiosEstado() async {
    // Simular que el conductor está en camino después de 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _estadoViaje = EstadoViaje.enCamino;
      });
    }

    // Simular que el viaje está en curso después de 5 segundos más
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _estadoViaje = EstadoViaje.enCurso;
      });
    }
  }

  // Método para cancelar el viaje
  Future<void> _cancelarViaje() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implementar lógica para cancelar viaje en Firebase
    await Future.delayed(const Duration(seconds: 2)); // Simulación

    setState(() {
      _isLoading = false;
      _estadoViaje = EstadoViaje.cancelado;
    });

    if (mounted) {
      // Mostrar mensaje y volver a la pantalla principal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje cancelado')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/');
      });
    }
  }

  // Método para completar el viaje (simulación)
  Future<void> _completarViaje() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implementar lógica para marcar viaje como completado en Firebase
    await Future.delayed(const Duration(seconds: 2)); // Simulación

    setState(() {
      _isLoading = false;
      _estadoViaje = EstadoViaje.completado;
    });

    if (mounted) {
      // Mostrar mensaje y volver a la pantalla principal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Viaje completado!')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje en Curso'),
        leading: _estadoViaje != EstadoViaje.completado &&
                _estadoViaje != EstadoViaje.cancelado
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Mostrar diálogo de confirmación para cancelar el viaje
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancelar Viaje'),
                      content: const Text(
                          '¿Estás seguro de que deseas cancelar este viaje?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelarViaje();
                          },
                          child: const Text('Sí'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
        actions: [
          if (_estadoViaje != EstadoViaje.completado &&
              _estadoViaje != EstadoViaje.cancelado)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _isLoading ? null : _cancelarViaje,
              tooltip: 'Cancelar viaje',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mapa (simulado con un contenedor)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Simulación de mapa
                  Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: const Center(
                      child: Icon(
                        Icons.map,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Marcadores de origen y destino (simulados)
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 150,
                    right: 100,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Icono del vehículo (simulado)
                  if (_estadoViaje == EstadoViaje.enCamino ||
                      _estadoViaje == EstadoViaje.enCurso)
                    Positioned(
                      top: _estadoViaje == EstadoViaje.enCurso ? 200 : 300,
                      left: _estadoViaje == EstadoViaje.enCurso ? 200 : 150,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  // Línea que simula la ruta
                  CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: RutaPainter(),
                  ),
                  // Indicador de estado
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForEstado(_estadoViaje),
                              color: _getColorForEstado(_estadoViaje),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getTextForEstado(_estadoViaje),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Panel de información del viaje
            Expanded(
              flex: 2,
              child: Container(
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
                    // Información del conductor
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nombreConductor,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _calificacionConductor.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () {
                            // TODO: Implementar llamada al conductor
                          },
                          color: AppTheme.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // TODO: Implementar chat con el conductor
                          },
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Información del vehículo
                    Row(
                      children: [
                        const Icon(Icons.directions_car_outlined),
                        const SizedBox(width: 8),
                        Text(
                          '$_modeloVehiculo - $_placaVehiculo',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Información del viaje
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle,
                                      color: AppTheme.primaryColor, size: 12),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _origenDireccion,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                height: 20,
                                width: 2,
                                color: Colors.grey[300],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.red, size: 12),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _destinoDireccion,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$_distanciaEstimada km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${_tiempoEstimadoMinutos.toInt()} min',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Botón de acción según el estado
                    if (_estadoViaje == EstadoViaje.enCurso)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completarViaje,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'FINALIZAR VIAJE',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    // Mostrar costo estimado
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Costo estimado: \$${_costoEstimado.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para mostrar información según el estado del viaje
  IconData _getIconForEstado(EstadoViaje estado) {
    switch (estado) {
      case EstadoViaje.solicitado:
        return Icons.access_time;
      case EstadoViaje.aceptado:
        return Icons.check_circle;
      case EstadoViaje.enCamino:
        return Icons.directions_car;
      case EstadoViaje.enCurso:
        return Icons.navigation;
      case EstadoViaje.completado:
        return Icons.done_all;
      case EstadoViaje.cancelado:
        return Icons.cancel;
    }
  }

  Color _getColorForEstado(EstadoViaje estado) {
    switch (estado) {
      case EstadoViaje.solicitado:
        return Colors.orange;
      case EstadoViaje.aceptado:
        return Colors.green;
      case EstadoViaje.enCamino:
        return Colors.blue;
      case EstadoViaje.enCurso:
        return AppTheme.primaryColor;
      case EstadoViaje.completado:
        return Colors.green;
      case EstadoViaje.cancelado:
        return Colors.red;
    }
  }

  String _getTextForEstado(EstadoViaje estado) {
    switch (estado) {
      case EstadoViaje.solicitado:
        return 'Buscando conductor...';
      case EstadoViaje.aceptado:
        return 'Viaje aceptado';
      case EstadoViaje.enCamino:
        return 'Conductor en camino';
      case EstadoViaje.enCurso:
        return 'Viaje en curso';
      case EstadoViaje.completado:
        return 'Viaje completado';
      case EstadoViaje.cancelado:
        return 'Viaje cancelado';
    }
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
