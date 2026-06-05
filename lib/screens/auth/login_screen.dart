import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../../widgets/auth/login_form_widget.dart';
import '../../widgets/common/custom_snackbar.dart'; // ✅ Adicione

class LoginScreen extends StatefulWidget {
  final VoidCallback onForgotPassword;
  final VoidCallback onGoToRegister;

  const LoginScreen({
    super.key,
    required this.onForgotPassword,
    required this.onGoToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final errorMessage = await authProvider.login(
      email: emailController.text,
      senha: passwordController.text,
    );
    if (!mounted) return;

    if (errorMessage != null) {
      // ✅ Substituído por CustomSnackbar
      CustomSnackbar.showError(context, errorMessage);
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return LoginFormWidget(
      emailController: emailController,
      passwordController: passwordController,
      emailFocusNode: emailFocusNode,
      passwordFocusNode: passwordFocusNode,
      onLogin: _handleLogin,
      onForgotPassword: widget.onForgotPassword,
      onGoToRegister: widget.onGoToRegister,
      onGoogleLogin: () {},
      isLoading: authProvider.isLoading,
    );
  }
}
