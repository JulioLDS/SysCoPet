import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'package:flutter/gestures.dart';

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

  // ✅ FocusNodes
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // ✅ Controle de visibilidade da senha
  bool _obscurePassword = true;

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
    final success = await authProvider.login(
      email: emailController.text,
      senha: passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login inválido")));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bem-vindo de volta! 🐾',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça login para continuar cuidando do seu pet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // ✅ Campo E-mail
          TextField(
            controller: emailController,
            focusNode: emailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocusNode),
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
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // ✅ Campo Senha com visibilidade
          TextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            obscureText: _obscurePassword, // ✅ Controlado pelo estado
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF0D9488),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: const Text(
                'Esqueci minha senha',
                style: TextStyle(color: Color(0xFF0D9488)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : () => _handleLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () {},
            icon: Image.asset(
              'assets/icons/google.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: Color(0xFF0D9488),
              ),
            ),
            label: const Text('Entrar com Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF0D9488)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Link para Cadastro (apenas "Cadastre-se" é clicável e verde)
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Ainda não tem uma conta? ',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Cadastre-se',
                    style: const TextStyle(
                      color: Color(0xFF0D9488), // ✅ Verde PetSaúde
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onGoToRegister,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
