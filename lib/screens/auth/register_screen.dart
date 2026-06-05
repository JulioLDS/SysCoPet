import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/register_form_widget.dart';
import '../../widgets/common/custom_snackbar.dart';

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

  // ✅ Use RegisterFormWidgetState (sem o _)
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

  Future<void> _handleRegister() async {
    // ✅ Validação dos termos
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
      key: _formKey, // ✅ Passa a key para o widget
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
      onGoogleRegister: () {},
      isLoading: authProvider.isLoading,
    );
  }
}
