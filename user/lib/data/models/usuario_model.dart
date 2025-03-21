import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    super.telefono,
    super.fotoPerfil,
    super.cuentaVerificada,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      fotoPerfil: json['fotoPerfil'],
      cuentaVerificada: json['cuentaVerificada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fotoPerfil': fotoPerfil,
      'cuentaVerificada': cuentaVerificada,
    };
  }
}
