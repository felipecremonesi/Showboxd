import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final size = MediaQuery.of(context).size;

    double cardWidth;
    if (size.width < 500) {
      cardWidth = size.width * 0.9;
    } else if (size.width < 900) {
      cardWidth = size.width * 0.6;
    } else {
      cardWidth = size.width * 0.4;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Color(0xFF1A1A1A),
              Color(0xFF3A3A00),
              Color(0xFFFFD700),
              Color(0xFFFFC107),
            ],
            stops: [0.0, 0.3, 0.55, 0.8, 1.0],
            tileMode: TileMode.mirror,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo animado
                        RotationTransition(
                          turns: Tween(begin: -0.05, end: 0.05).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Curves.elasticInOut,
                            ),
                          ),
                          child: const Icon(
                            Icons.mic,
                            size: 60,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "Showboxd",
                          style: TextStyle(
                            fontSize: size.width < 500 ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Faça o login para continuar",
                          style: TextStyle(
                            fontSize: size.width < 500 ? 16 : 18,
                            color: Colors.amberAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.4),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width < 500 ? 14 : 16,
                                ),
                                textStyle: TextStyle(
                                  fontSize: size.width < 500 ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: Colors.amber.withOpacity(0.5),
                              ),
                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                height: size.width < 500 ? 20 : 24,
                                width: size.width < 500 ? 20 : 24,
                              ),
                              label: const Text("Entrar com Google"),
                              onPressed: () async {
                                await auth.signInWithGoogle();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
