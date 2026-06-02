import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite seu e-mail'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instruções enviadas para o e-mail!'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 850;
          double screenHeight = constraints.maxHeight;

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
            // LADO ESQUERDO (Apenas PETS, sem texto)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // PETS
                  Positioned(
                    top: screenHeight * 0.0,
                    left: 100,
                    right: 0,
                    height: screenHeight * 1.05,
                    child: Image.asset(
                      'assets/images/pets.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            ),

            // LADO DIREITO (Card com Formulário)
            Expanded(
              flex: 6,
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone
                        Container(
                          width: 120,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Transform.translate(
                            offset: const Offset(3, 3),
                            child: SvgPicture.asset(
                              'assets/icons/envelope.svg',
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Recuperar senha',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Descrição
                        Text(
                          'Digite seu e-mail para receber\ninstruções de como redefinir sua senha.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 32),

                        // Campo E-mail
                        TextField(
                          controller: emailController,
                          focusNode: emailFocusNode,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleForgotPassword(),
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF0D9488),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText: 'seu@email.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),

                        // Botão Enviar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleForgotPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Enviar instruções',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'ou',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botão Voltar
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.onBackToLogin,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar para o login'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: Color(0xFF0D9488)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ===== LAYOUT MOBILE =====
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Ícone
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'Recuperar senha',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // Descrição
              Text(
                'Digite seu e-mail para receber\ninstruções de como redefinir sua senha.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Campo E-mail
              TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleForgotPassword(),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF0D9488),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'seu@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Botão Enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleForgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enviar instruções',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Botão Voltar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onBackToLogin,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar para o login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
