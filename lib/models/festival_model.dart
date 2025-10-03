import 'package:cloud_firestore/cloud_firestore.dart';

class FestivalModel {
  final String id;
  final String nome;
  final String local;
  final DateTime data;
  final List<String> artistas;
  final String criadoPor;

  FestivalModel({
    required this.id,
    required this.nome,
    required this.local,
    required this.data,
    required this.artistas,
    required this.criadoPor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'local': local,
      'data': Timestamp.fromDate(data),
      'artistas': artistas,
      'criadoPor': criadoPor,
    };
  }

  factory FestivalModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FestivalModel(
      id: id ?? map['id'] ?? '',
      nome: map['nome'] ?? '',
      local: map['local'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
      artistas: List<String>.from(map['artistas'] ?? []),
      criadoPor: map['criadoPor'] ?? '',
    );
  }
}
