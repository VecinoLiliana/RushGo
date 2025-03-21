import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/themes/app_theme.dart';

/// Pantalla de perfil de usuario
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController(text: 'Usuario Demo');
  final _emailController = TextEditingController(text: 'usuario@ejemplo.com');
  final _telefonoController = TextEditingController(text: '+52 123 456 7890');
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implementar lógica para guardar cambios en Firebase
      await Future.delayed(const Duration(seconds: 1)); // Simulación

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Foto de perfil
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Implementar cambio de foto de perfil
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                // Información del usuario
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  enabled: false, // El email no se puede editar
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Botón de guardar cambios
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'GUARDAR CAMBIOS',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                const SizedBox(height: 20),
                // Sección de opciones adicionales
                if (!_isEditing) ...[
                  const Divider(height: 40),
                  _buildOptionTile(
                    title: 'Métodos de pago',
                    icon: Icons.payment_outlined,
                    onTap: () {
                      // TODO: Implementar pantalla de métodos de pago
                    },
                  ),
                  _buildOptionTile(
                    title: 'Direcciones guardadas',
                    icon: Icons.location_on_outlined,
                    onTap: () {
                      // TODO: Implementar pantalla de direcciones
                    },
                  ),
                  _buildOptionTile(
                    title: 'Notificaciones',
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      // TODO: Implementar pantalla de notificaciones
                    },
                  ),
                  _buildOptionTile(
                    title: 'Ayuda y soporte',
                    icon: Icons.help_outline,
                    onTap: () {
                      // TODO: Implementar pantalla de ayuda
                    },
                  ),
                  _buildOptionTile(
                    title: 'Cerrar sesión',
                    icon: Icons.logout,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Implementar cierre de sesión
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
