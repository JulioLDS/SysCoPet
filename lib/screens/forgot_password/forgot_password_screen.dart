import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/forgot_password/email_form_widget.dart';
import '../../widgets/forgot_password/code_verification_widget.dart';
import '../../widgets/forgot_password/reset_password_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0 = Email, 1 = Código, 2 = Nova Senha
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Controladores para os 6 dígitos do código
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // ✅ Etapa 1: Enviar email
  void _handleSendEmail() {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um e-mail válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _currentStep = 1);
  }

  // ✅ Etapa 2: Verificar código (simulado)
  void _handleVerifyCode() {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite o código de 6 dígitos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _currentStep = 2);
  }

  // ✅ Etapa 3: Redefinir senha
  void _handleResetPassword() {
    if (newPasswordController.text.isEmpty ||
        newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha redefinida com sucesso!'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Reenviar código
  void _handleResendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código reenviado!'),
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

        // 2. CONTEÚDO (Apenas Pets à direita)
        Row(
          children: [
            // LADO ESQUERDO (Vazio)
            Expanded(flex: 6, child: Container()),

            // LADO DIREITO (PETS)
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned(
                    top: screenHeight * 0.20,
                    left: 0,
                    right: -100,
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
          ],
        ),

        // 3. CARD CENTRALIZADO
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 40),
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
            child: IndexedStack(
              index: _currentStep,
              children: [
                EmailFormWidget(
                  key: const ValueKey('email-form'),
                  emailController: emailController,
                  onSendEmail: _handleSendEmail,
                ),
                CodeVerificationWidget(
                  key: const ValueKey('code-verification'),
                  controllers: _codeControllers,
                  focusNodes: _codeFocusNodes,
                  onVerify: _handleVerifyCode,
                  onResend: _handleResendCode,
                ),
                ResetPasswordWidget(
                  key: const ValueKey('reset-password'),
                  newPasswordController: newPasswordController,
                  confirmPasswordController: confirmPasswordController,
                  onReset: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== LAYOUT MOBILE - SEM ANIMAÇÃO =====
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              IndexedStack(
                index: _currentStep,
                children: [
                  EmailFormWidget(
                    key: const ValueKey('email-form-mobile'),
                    emailController: emailController,
                    onSendEmail: _handleSendEmail,
                  ),
                  CodeVerificationWidget(
                    key: const ValueKey('code-verification-mobile'),
                    controllers: _codeControllers,
                    focusNodes: _codeFocusNodes,
                    onVerify: _handleVerifyCode,
                    onResend: _handleResendCode,
                  ),
                  ResetPasswordWidget(
                    key: const ValueKey('reset-password-mobile'),
                    newPasswordController: newPasswordController,
                    confirmPasswordController: confirmPasswordController,
                    onReset: _handleResetPassword,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
