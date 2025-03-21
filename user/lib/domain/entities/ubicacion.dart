class Ubicacion {
  final double latitud;
  final double longitud;
  final String? direccion;
  final String? ciudad;
  final String? pais;
  final String? codigoPostal;

  Ubicacion({
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.ciudad,
    this.pais,
    this.codigoPostal,
  });
}
