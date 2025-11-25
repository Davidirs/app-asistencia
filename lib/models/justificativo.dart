
class Justificativo {
  final String id;
  final String descripcion;
  final String profesor;
  final String fecha;
  final String imageUrl;

  Justificativo({
    required this.id,
    required this.descripcion,
    required this.profesor,
    required this.fecha,
    required this.imageUrl,
  });

  static Justificativo fromJson(Map<String, dynamic> json) {
    return Justificativo(
      id: json['id'],
      descripcion: json['descripcion'],
      profesor: json['profesor'],
      fecha: json['fecha'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'profesor': profesor,
      'fecha': fecha,
      'imageUrl': imageUrl,
    };
  }

  
} 