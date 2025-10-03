class ShowModel {
  final String id;
  final String artista;
  final DateTime data;
  final String local;
  final String setor;
  final List<String> setlist;
  final String musicaFav;
  final String duracao;
  final String artistaAbertura;
  final double valor;
  final double valorParcela;
  final double parcela;
  final bool copoPersonalizado;
  final bool cantaEDanca;
  final double presencaPalco;
  final bool esforcouPortugues;
  final String userId;
  final String userName;
  final List<String> imageUrls;
  final List<String> imagePaths;

  ShowModel({
    required this.id,
    required this.artista,
    required this.data,
    required this.local,
    required this.setor,
    required this.setlist,
    required this.musicaFav,
    required this.duracao,
    required this.artistaAbertura,
    required this.valor,
    required this.valorParcela,
    required this.parcela,
    required this.copoPersonalizado,
    required this.cantaEDanca,
    required this.presencaPalco,
    required this.esforcouPortugues,
    required this.userId,
    required this.userName,
    required this.imageUrls,
    required this.imagePaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artista': artista,
      'data': data.toIso8601String(),
      'local': local,
      'setor': setor,
      'setlist': setlist,
      'musicaFav': musicaFav,
      'duracao': duracao,
      'artistaAbertura': artistaAbertura,
      'valor': valor,
      'valorParcela': valorParcela,
      'parcela': parcela,
      'copoPersonalizado': copoPersonalizado,
      'cantaEDanca': cantaEDanca,
      'presencaPalco': presencaPalco,
      'esforcouPortugues': esforcouPortugues,
      'userId': userId,
      'userName': userName,
      'imageUrls': imageUrls,
      'imagePaths': imagePaths,
    };
  }

  factory ShowModel.fromMap(Map<String, dynamic> map) {
    return ShowModel(
      id: map['id'] ?? '',
      artista: map['artista'] ?? '',
      data: DateTime.parse(map['data']),
      local: map['local'] ?? '',
      setor: map['setor'] ?? '',
      setlist: List<String>.from(map['setlist'] ?? []),
      musicaFav: map['musicaFav'] ?? '',
      duracao: map['duracao'] ?? '',
      artistaAbertura: map['artistaAbertura'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      valorParcela: (map['valorParcela'] ?? 0).toDouble(),
      parcela: (map['parcela'] ?? 0).toDouble(),
      copoPersonalizado: map['copoPersonalizado'] ?? false,
      cantaEDanca: map['cantaEDanca'] ?? false,
      presencaPalco: (map['presencaPalco'] ?? 0).toDouble(),
      esforcouPortugues: map['esforcouPortugues'] ?? false,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
    );
  }
}
