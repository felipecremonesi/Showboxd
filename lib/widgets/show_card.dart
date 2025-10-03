import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showboxd/screens/galeria_grid_screen.dart';
import 'package:showboxd/widgets/show_card_votes.dart';
import '../services/wishlist_service.dart';
import '../models/show_model.dart';
import '../screens/show_form_screen.dart';
import 'rating_stars.dart';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

class ShowCard extends StatelessWidget {
  final ShowModel show;
  final WishlistService wishlistService = WishlistService();

  ShowCard({super.key, required this.show});

  Future<void> _deleteShow(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Confirmar exclusão",
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          "Tem certeza que deseja excluir este evento?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.amber),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      for (var path in show.imagePaths) {
        await storage.ref(path).delete();
      }

      await firestore.collection("shows").doc(show.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Evento e fotos excluídos com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao excluir evento: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = show.userId == currentUser?.uid;

    return GestureDetector(
      onTap: () {},
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row com Wishlist e botões do dono (Editar e Deletar)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (currentUser != null)
                    StreamBuilder<List<String>>(
                      stream: wishlistService.getWishlist(currentUser.uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox(width: 40);

                        final wishlist = snapshot.data!;
                        final isInWishlist = wishlist.contains(show.id);

                        return IconButton(
                          icon: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            if (isInWishlist) {
                              wishlistService.removeShowFromWishlist(
                                currentUser.uid,
                                show.id,
                              );
                            } else {
                              wishlistService.addShowToWishlist(
                                currentUser.uid,
                                show.id,
                              );
                            }
                          },
                        );
                      },
                    ),
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.greenAccent),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShowFormScreen(show: show),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteShow(context),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              // Informações do Card
              Text(
                "🎤 ${show.artista}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "👤 Criado por: ${show.userName}",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "📍 Local: ${show.local} • 📅 ${formatDate(show.data.toLocal())}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.amber[200],
                ),
              ),
              const SizedBox(height: 4),

              if (isOwner) ...[
                Text(
                  "💵 Preço: R\$ ${show.valor / show.parcela} x ${show.parcela} (R\$ ${show.valor})",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),

                const SizedBox(height: 4),
              ],

              if (show.artistaAbertura.isNotEmpty == true) ...[
                Text(
                  "🎸 Artista de Abertura: ${show.artistaAbertura}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),
              ],

              if (show.duracao.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  "⏱️ Duração: ${show.duracao}h",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),
              ],

              if (isOwner && (show.setor.isNotEmpty)) ...[
                const SizedBox(height: 4),
                Text(
                  "📝 Setor: ${show.setor}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (isOwner && (show.musicaFav.isNotEmpty)) ...[
                Text(
                  "🎵 Música Favorita: ${show.musicaFav}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (isOwner && (show.setlist.isNotEmpty)) ...[
                Text(
                  "🎶 Setlist: ${show.setlist.isNotEmpty ? show.setlist.join(', ') : '—'}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[200],
                  ),
                ),

                const SizedBox(height: 4),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (show.copoPersonalizado)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange, // cor do site
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Copo Personalizado",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (show.cantaEDanca)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Canta e Dança",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (show.esforcouPortugues)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Esforçou Português",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              const Divider(height: 20, color: Colors.amber),

              // Presença de palco (Média dos Votos registrados)
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
                        .map(
                          (v) => ((v['presencaPalco'] ?? 0) as num).toDouble(),
                        )
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
                        "⭐ ${media.toStringAsFixed(1)} ($totalVotos votos)",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowDetailScreen(show: show),
                            ),
                          );
                        },
                        child: const Text(
                          'Avaliar',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),

              // Botão de Imagens
              if (show.imageUrls.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryGridScreen(
                            imageUrls: show.imageUrls,
                            docId: show.id,
                            imagePaths: show.imagePaths,
                            ownerId: show.userId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text("Ver fotos"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
