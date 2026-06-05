import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/forgot_password/email_form_widget.dart';
import '../../widgets/forgot_password/code_verification_widget.dart';
import '../../widgets/forgot_password/reset_password_widget.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_snackbar.dart'; // ✅ Adicione

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0;
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 30;
  bool _canResend = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/background2.png'), context);
      precacheImage(const AssetImage('assets/images/pets.png'), context);
    });
  }

  void _startResendTimer() {
    _canResend = false;
    _secondsRemaining = 30;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _resendTimer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSendEmail() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      CustomSnackbar.showWarning(context, 'Por favor, digite um e-mail válido');
      return;
    }

    final result = await _authService.forgotPassword(
      email: emailController.text.trim(),
    );

    if (result['sucesso'] == true) {
      _startResendTimer();
      CustomSnackbar.showSuccess(context, result['mensagem']);
      setState(() => _currentStep = 1);
    } else {
      CustomSnackbar.showError(context, result['erro']);
    }
  }

  void _handleVerifyCode() {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      CustomSnackbar.showWarning(
        context,
        'Por favor, digite o código de 6 dígitos',
      );
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _handleResetPassword() async {
    if (newPasswordController.text.isEmpty ||
        newPasswordController.text.length < 6) {
      CustomSnackbar.showWarning(
        context,
        'A senha deve ter pelo menos 6 caracteres',
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError(context, 'As senhas não coincidem');
      return;
    }

    final codigo = _codeControllers.map((controller) => controller.text).join();

    final result = await _authService.resetPassword(
      email: emailController.text.trim(),
      codigo: codigo,
      novaSenha: newPasswordController.text,
    );

    if (result['sucesso'] == true) {
      CustomSnackbar.showSuccess(context, result['mensagem']);
      Navigator.pop(context);
    } else {
      CustomSnackbar.showError(context, result['erro']);
    }
  }

  Future<void> _handleResendCode() async {
    final result = await _authService.forgotPassword(
      email: emailController.text.trim(),
    );

    if (result['sucesso'] == true) {
      _startResendTimer();
      CustomSnackbar.showSuccess(context, 'Código reenviado com sucesso!');
    } else {
      CustomSnackbar.showError(context, result['erro']);
    }
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

  Widget _buildDesktopLayout(double screenHeight) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(flex: 6, child: Container()),
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
                  canResend: _canResend,
                  secondsRemaining: _secondsRemaining,
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
                    canResend: _canResend,
                    secondsRemaining: _secondsRemaining,
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
