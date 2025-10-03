import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:showboxd/screens/festival_screen.dart';
import 'package:showboxd/screens/whishlist_screen.dart';
import '../services/firestore_service.dart';
import '../models/show_model.dart';
import 'show_form_screen.dart';
import '../widgets/show_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "Usuário",
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: ClipOval(
                child: Image.network(
                  FirebaseAuth.instance.currentUser?.photoURL ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 175, 131, 0),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.festival, color: Colors.amber),
              title: const Text(
                "Festivais",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Navegar para página de Festivais
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FestivalScreen(festival: null),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.amber),
              title: const Text(
                "Wishlist de Shows",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Navegar para página de Wishlist
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishlistScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.amber),
              title: const Text("Sair"),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      "Sair",
                      style: TextStyle(color: Colors.amber),
                    ),
                    content: const Text(
                      "Deseja realmente sair da sua conta?",
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Sair",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F1B24), Color(0xFF2A2A3B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar customizada
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.amber),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const Text(
                      "Painel de Shows",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  "Sair",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                content: const Text(
                                  "Deseja realmente sair da sua conta?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      "Sair",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await FirebaseAuth.instance.signOut();
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Card dos shows
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: StreamBuilder<List<ShowModel>>(
                    stream: firestoreService.getShows(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Erro ao carregar shows",
                            style: TextStyle(color: Colors.amber),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        );
                      }

                      final shows = snapshot.data!;
                      if (shows.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nenhum show cadastrado ainda 🎶",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.amberAccent,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: shows.length,
                        itemBuilder: (context, index) {
                          final show = shows[index];
                          return ShowCard(show: show);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[700],
        elevation: 6,
        child: const Icon(Icons.add, size: 32, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShowFormScreen()),
          );
        },
      ),
    );
  }
}
