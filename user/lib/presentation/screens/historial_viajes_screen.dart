import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/themes/app_theme.dart';

/// Pantalla que muestra el historial de viajes del usuario
class HistorialViajesScreen extends ConsumerStatefulWidget {
  const HistorialViajesScreen({super.key});

  @override
  ConsumerState<HistorialViajesScreen> createState() =>
      _HistorialViajesScreenState();
}

class _HistorialViajesScreenState extends ConsumerState<HistorialViajesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Datos simulados para la interfaz
  final List<Map<String, dynamic>> _viajesCompletados = [
    {
      'id': 'viaje-001',
      'origen': 'Av. Insurgentes Sur 1602',
      'destino': 'Plaza Universidad',
      'fecha': DateTime.now().subtract(const Duration(days: 2)),
      'costo': 120.0,
      'distancia': 5.2,
    },
    {
      'id': 'viaje-002',
      'origen': 'Parque México',
      'destino': 'Zócalo',
      'fecha': DateTime.now().subtract(const Duration(days: 5)),
      'costo': 180.0,
      'distancia': 8.5,
    },
    {
      'id': 'viaje-003',
      'origen': 'Aeropuerto Internacional',
      'destino': 'Hotel Zona Rosa',
      'fecha': DateTime.now().subtract(const Duration(days: 10)),
      'costo': 350.0,
      'distancia': 15.3,
    },
  ];

  final List<Map<String, dynamic>> _viajesCancelados = [
    {
      'id': 'viaje-004',
      'origen': 'Coyoacán',
      'destino': 'Santa Fe',
      'fecha': DateTime.now().subtract(const Duration(days: 3)),
      'motivo': 'Cancelado por el usuario',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Simular carga de datos
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Viajes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'COMPLETADOS'), Tab(text: 'CANCELADOS')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab de viajes completados
                _viajesCompletados.isEmpty
                    ? _buildEmptyState('No tienes viajes completados')
                    : _buildViajesCompletadosList(),

                // Tab de viajes cancelados
                _viajesCancelados.isEmpty
                    ? _buildEmptyState('No tienes viajes cancelados')
                    : _buildViajesCanceladosList(),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildViajesCompletadosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _viajesCompletados.length,
      itemBuilder: (context, index) {
        final viaje = _viajesCompletados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // TODO: Implementar vista detallada del viaje
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha del viaje
                  Text(
                    _formatDate(viaje['fecha']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Origen y destino
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: AppTheme.primaryColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viaje['origen'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viaje['destino'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
                            '\$${viaje['costo'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${viaje['distancia']} km',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botón para solicitar de nuevo
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implementar solicitud de viaje similar
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('REPETIR VIAJE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViajesCanceladosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _viajesCancelados.length,
      itemBuilder: (context, index) {
        final viaje = _viajesCancelados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha del viaje
                Text(
                  _formatDate(viaje['fecha']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                // Origen y destino
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: AppTheme.primaryColor,
                                size: 12,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viaje['origen'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 12,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viaje['destino'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Cancelado',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Motivo de cancelación
                Text(
                  viaje['motivo'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                // Botón para solicitar de nuevo
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar solicitud de viaje similar
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('INTENTAR DE NUEVO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
