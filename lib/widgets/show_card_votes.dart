import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showboxd/models/show_model.dart';
import 'package:showboxd/widgets/rating_stars.dart';

class ShowDetailScreen extends StatefulWidget {
  final ShowModel show;
  const ShowDetailScreen({super.key, required this.show});

  @override
  State<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends State<ShowDetailScreen> {
  double minhaNota = 0;
  TextEditingController comentarioController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarVotoAnterior();
  }

  Future<void> _carregarVotoAnterior() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('shows')
        .doc(widget.show.id)
        .collection('votos')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        minhaNota = (doc['presencaPalco'] ?? 0).toDouble();
        comentarioController.text = doc['comentario'] ?? '';
      });
    }
  }

  Future<void> salvarVoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance
        .collection('shows')
        .doc(widget.show.id)
        .collection('votos')
        .doc(user.uid)
        .set({
          'presencaPalco': minhaNota,
          'comentario': comentarioController.text,
          'userName': user.displayName ?? 'Usuário',
          'userId': user.uid,
        });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Voto salvo!')));

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final show = widget.show;

    return Scaffold(
      appBar: AppBar(title: Text(show.artista)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Média de votos:",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shows')
                  .doc(show.id)
                  .collection('votos')
                  .snapshots(),
              builder: (context, snapshot) {
                double media = 0;
                int totalVotos = 0;

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final votos = snapshot.data!.docs;
                  final notas = votos
                      .map((v) => ((v['presencaPalco'] ?? 0) as num).toDouble())
                      .toList();
                  if (notas.isNotEmpty) {
                    media = notas.reduce((a, b) => a + b) / notas.length;
                    totalVotos = notas.length;
                  }
                }

                return Row(
                  children: [
                    RatingStars(rating: media.round()),
                    const SizedBox(width: 8),
                    Text(
                      "${media.toStringAsFixed(1)} ($totalVotos votos)",
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Sua avaliação:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 4,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () => setState(() => minhaNota = index + 1.0),
                  child: Icon(
                    index < minhaNota ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : salvarVoto,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar voto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Comentários recentes:",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shows')
                  .doc(show.id)
                  .collection('votos')
                  .orderBy('presencaPalco', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    "Nenhum comentário ainda.",
                    style: TextStyle(color: Colors.white),
                  );
                }

                final votos = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: votos.length,
                  itemBuilder: (context, index) {
                    final voto = votos[index];
                    final comentario = voto['comentario'] ?? '';
                    final nota = (voto['presencaPalco'] ?? 0).toDouble();
                    final nome = voto['userName'] ?? 'Usuário';
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome,
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comentario,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            RatingStars(rating: nota.round()),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
