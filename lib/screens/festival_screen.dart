import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showboxd/models/festival_model.dart';
import 'package:showboxd/screens/festival_form_screen.dart';
import 'package:showboxd/widgets/show_card.dart';
import '../services/festival_service.dart';

class FestivalScreen extends StatelessWidget {
  final FestivalService festivalService = FestivalService();

  final FestivalModel? festival;
  final currentUser = FirebaseAuth.instance.currentUser;

  FestivalScreen({super.key, required this.festival});

  Future<void> _deleteFestival(
    BuildContext context,
    FestivalModel festival,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Confirmar exclusão",
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          "Tem certeza que deseja excluir este festival?",
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

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection("festivais")
            .doc(festival.id)
            .delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Festival excluído!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao excluir festival: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Festivais")),
      body: StreamBuilder<List<FestivalModel>>(
        stream: festivalService.getFestivals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum festival disponível."));
          }

          final festivals = snapshot.data!;

          return ListView.builder(
            itemCount: festivals.length,
            itemBuilder: (context, index) {
              final festival = festivals[index];
              final isOwner = festival.criadoPor == currentUser?.uid;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(
                    Icons.festival,
                    color: Colors.orange,
                    size: 36,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          festival.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.greenAccent,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FestivalFormScreen(festival: festival),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _deleteFestival(context, festival),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 ${festival.local}"),
                      Text("📅 ${formatDate(festival.data)}"),
                      if (festival.artistas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "🎤 Artistas: ${festival.artistas.join(", ")}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FestivalFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
