import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:showboxd/screens/galeria_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryGridScreen extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> imagePaths;
  final String docId;
  final String ownerId;

  const GalleryGridScreen({
    super.key,
    required this.imageUrls,
    required this.imagePaths,
    required this.docId,
    required this.ownerId,
  });

  @override
  State<GalleryGridScreen> createState() => _GalleryGridScreenState();
}

class _GalleryGridScreenState extends State<GalleryGridScreen> {
  final Set<int> _selectedIndexes = {};
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool get isOwner => widget.ownerId == currentUserId;

  Future<void> _deleteImagesFromBackend(List<int> indexes) async {
    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;

    for (var i in indexes) {
      try {
        final path = widget.imagePaths[i];
        final url = widget.imageUrls[i];

        await storage.ref(path).delete();
        await firestore.collection('shows').doc(widget.docId).update({
          'imageUrls': FieldValue.arrayRemove([url]),
          'imagePaths': FieldValue.arrayRemove([path]),
        });
      } catch (e) {
        debugPrint("Erro ao deletar imagem: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao deletar imagem: $e')));
        }
      }
    }
  }

  void _confirmDelete() async {
    if (!isOwner) return;
    final count = _selectedIndexes.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Confirmar exclusão",
          style: TextStyle(color: Colors.amber),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              count == 1 ? Icons.image : Icons.collections,
              size: 64,
              color: count == 1 ? Colors.blueGrey : Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            Text(
              count == 1
                  ? "Deseja realmente deletar esta imagem?"
                  : "Deseja realmente deletar $count imagens?",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Deletar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final toRemoveIndexes = _selectedIndexes.toList()
        ..sort((a, b) => b.compareTo(a));
      await _deleteImagesFromBackend(toRemoveIndexes);

      setState(() {
        for (var i in toRemoveIndexes) {
          widget.imageUrls.removeAt(i);
          widget.imagePaths.removeAt(i);
        }
        _selectedIndexes.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$count imagem(ns) deletada(s) com sucesso")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = _selectedIndexes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text("${_selectedIndexes.length} selecionada(s)")
            : const Text("Galeria de Fotos"),
        actions: [
          if (isSelectionMode && isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          final url = widget.imageUrls[index];
          final isSelected = _selectedIndexes.contains(index);

          return GestureDetector(
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  isSelected
                      ? _selectedIndexes.remove(index)
                      : _selectedIndexes.add(index);
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryScreen(
                      imageUrls: widget.imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              }
            },
            onLongPress: isOwner
                ? () {
                    setState(() {
                      isSelected
                          ? _selectedIndexes.remove(index)
                          : _selectedIndexes.add(index);
                    });
                  }
                : null,
            child: Stack(
              children: [
                Hero(
                  tag: url,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
