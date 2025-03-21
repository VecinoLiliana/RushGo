class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? fotoPerfil;
  final bool cuentaVerificada;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.fotoPerfil,
    this.cuentaVerificada = false,
  });
}
