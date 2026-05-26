import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;

  void _toggleMode() {
    setState(() => _isLoginMode = !_isLoginMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 850;
          double screenHeight = constraints.maxHeight; // Altura da tela

          if (isDesktop) {
            return _buildDesktopLayout(screenHeight);
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // ===== LAYOUT DESKTOP =====
  Widget _buildDesktopLayout(double screenHeight) {
    return Stack(
      children: [
        // 1. BACKGROUND
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. CONTEÚDO
        Row(
          children: [
            // LADO ESQUERDO
            Expanded(
              child: Stack(
                children: [
                  // TEXTO (Posicionado no topo)
                  Positioned(
                    top: 60,
                    left: 120,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pets,
                              color: const Color(0xFF0D9488),
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'PetSaúde',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cuidar é amar',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 45),
                        Text.rich(
                          TextSpan(
                            text: 'A saúde do seu pet\n',
                            style: const TextStyle(
                              fontSize: 38, // Tamanho levemente aumentado
                              fontWeight: FontWeight.w800, // Bold Extra Forte
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(
                                text: 'em boas patas ',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D9488), // Verde
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Icon(
                                  Icons.favorite_border, // Contorno de coração
                                  color: const Color(0xFF0D9488),
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 420,
                          child: Text(
                            'Gerencie consultas, vacinas, medicamentos e muito mais. Tudo para o bem-estar do seu melhor amigo.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PETS (Position Absolute: Topo 50%, Altura 70%)
                  Positioned(
                    top:
                        screenHeight *
                        0.20, // Começa no meio da tela (empurrado pra baixo)
                    left: 100,
                    right: 0,
                    height:
                        screenHeight *
                        1.05, // Ocupa 70% da altura (sai para fora)
                    child: Image.asset(
                      'assets/images/pets.png',
                      fit: BoxFit.contain,
                      alignment:
                          Alignment.topCenter, // Alinha pelo topo do container
                    ),
                  ),
                ],
              ),
            ),

            // LADO DIREITO (Formulário)
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: _isLoginMode
                      ? LoginScreen(
                          onToggleRegister: _toggleMode,
                          onForgotPassword: () {},
                        )
                      : RegisterScreen(onToggle: _toggleMode),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== LAYOUT MOBILE =====
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_mobile.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          color: const Color(0xFF0D9488),
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PetSaúde',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoginMode
                        ? LoginScreen(
                            onToggleRegister: _toggleMode,
                            onForgotPassword: () {},
                          )
                        : RegisterScreen(onToggle: _toggleMode),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: ClipRect(
                clipBehavior: Clip.none,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 30),
                    child: Image.asset(
                      'assets/images/pets.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
