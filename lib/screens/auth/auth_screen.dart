import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// Enum para controlar qual tela está sendo exibida
enum AuthMode { login, register, forgotPassword }

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _currentMode = AuthMode.login;

  void _setMode(AuthMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Se largura > 600px = Desktop, senão = Mobile
          bool isDesktop = constraints.maxWidth > 600;

          if (isDesktop) {
            return _buildDesktopLayout(context, constraints);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // ===== LAYOUT DESKTOP =====
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        // Lado Esquerdo (Informações/Promotional)
        Expanded(
          child: Container(
            color: const Color(0xFF0D9488), // Verde Teal escuro
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PetSaúde',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Cuidar é amar',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'A saúde do seu pet em boas patas 🐾',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gerencie consultas, vacinas, medicamentos e muito mais. Tudo para o bem-estar do seu melhor amigo.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Placeholder para imagem dos pets
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🐕 🐈', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Lado Direito (Formulário)
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildCurrentScreen(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== LAYOUT MOBILE =====
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildCurrentScreen(),
        ),
      ),
    );
  }

  // ===== BUILD DA TELA ATUAL =====
  Widget _buildCurrentScreen() {
    switch (_currentMode) {
      case AuthMode.login:
        return LoginScreen(
          onToggleRegister: () => _setMode(AuthMode.register),
          onForgotPassword: () => _setMode(AuthMode.forgotPassword),
        );
      case AuthMode.register:
        return RegisterScreen(onToggle: () => _setMode(AuthMode.login));
      case AuthMode.forgotPassword:
        return ForgotPasswordScreen(
          onBackToLogin: () => _setMode(AuthMode.login),
        );
    }
  }
}
