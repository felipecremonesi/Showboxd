import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const GalleryScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> downloadImage(String url) async {
    try {
      await GallerySaver.saveImage(url, albumName: "ShowBoxd");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem salva na galeria!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao baixar imagem: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1} / ${widget.imageUrls.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => downloadImage(widget.imageUrls[currentIndex]),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        builder: (context, index) {
          final url = widget.imageUrls[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(url),
            heroAttributes: PhotoViewHeroAttributes(tag: url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
