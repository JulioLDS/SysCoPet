import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/register_form_widget.dart';
import '../../widgets/auth/google_login_web_button.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;

  const RegisterScreen({super.key, required this.onGoToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final checkboxFocusNode = FocusNode();

  final GlobalKey<RegisterFormWidgetState> _formKey = GlobalKey();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    checkboxFocusNode.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _handleGoogleRegisterMobile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final errorMessage = await authProvider.loginComGoogleMobile();

    if (!mounted) return;

    if (errorMessage != null) {
      CustomSnackbar.showError(context, errorMessage);
      return;
    }

    _goToHome();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.isTermsAccepted == false) {
      CustomSnackbar.showWarning(
        context,
        'Você precisa aceitar os termos de uso',
      );
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      CustomSnackbar.showWarning(context, 'Preencha todos os campos');
      return;
    }
    if (passwordController.text.length < 6) {
      CustomSnackbar.showWarning(context, 'Senha mínima de 6 caracteres');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError(context, 'Senhas não coincidem');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.register(
      nome: nameController.text,
      email: emailController.text,
      senha: passwordController.text,
    );

    if (!mounted) return;

    if (result != null) {
      CustomSnackbar.showError(context, result);
      return;
    }

    CustomSnackbar.showSuccess(
      context,
      'Usuário criado com sucesso! Faça login para continuar.',
    );
    widget.onGoToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return RegisterFormWidget(
      key: _formKey,
      nameController: nameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      nameFocusNode: nameFocusNode,
      emailFocusNode: emailFocusNode,
      passwordFocusNode: passwordFocusNode,
      confirmPasswordFocusNode: confirmPasswordFocusNode,
      checkboxFocusNode: checkboxFocusNode,
      onRegister: _handleRegister,
      onGoogleRegister: _handleGoogleRegisterMobile,
      isLoading: authProvider.isLoading,
      googleButton: kIsWeb
          ? GoogleLoginWebButton(
              onSuccess: _goToHome,
              onError: (erro) {
                CustomSnackbar.showError(context, erro);
              },
            )
          : null,
    );
  }
}
