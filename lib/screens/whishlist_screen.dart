import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wishlist_service.dart';
import '../models/show_model.dart';
import '../widgets/show_card.dart';

class WishlistScreen extends StatelessWidget {
  final WishlistService wishlistService = WishlistService();

  WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Wishlist")),
        body: const Center(child: Text("Faça login para ver sua wishlist.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Minha Wishlist")),
      body: StreamBuilder<List<String>>(
        stream: wishlistService.getWishlist(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return const Center(child: Text("Sua wishlist está vazia 🎶"));
          }

          final wishlist = snapshot.data ?? [];

          return ListView(
            children: wishlist.map((showId) {
              return FutureBuilder<ShowModel?>(
                future: wishlistService.getShowById(showId),
                builder: (context, showSnapshot) {
                  if (showSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (!showSnapshot.hasData || showSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final show = showSnapshot.data!;
                  return ShowCard(show: show);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
