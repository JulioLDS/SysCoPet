import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onForgotPassword;

  const LoginScreen({super.key, required this.onForgotPassword});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Boas-vindas
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
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24), // ✅ Reduzido de 32 para 24
        // Campo E-mail
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF0D9488),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12), // ✅ Reduzido de 16 para 12
        // Campo Senha
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF0D9488),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () {}, // TODO: Toggle visibilidade
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          obscureText: true,
        ),
        const SizedBox(height: 4), // ✅ Reduzido de 8 para 4
        // Esqueci senha
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
        const SizedBox(height: 20), // ✅ Reduzido de 24 para 20
        // Botão Entrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final success = await authProvider.login(
                      email: emailController.text,
                      senha: passwordController.text,
                    );
                    if (!mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login inválido")),
                      );
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 20), // ✅ Reduzido de 24 para 20
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou', style: TextStyle(color: Colors.grey[500])),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 20), // ✅ Reduzido de 24 para 20
        // Botão Google (Apple removido)
        OutlinedButton.icon(
          onPressed: () {}, // TODO: Google Sign-In
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
        Center(
          child: Text(
            'Ainda não tem uma conta? Cadastre-se',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      ],
    );
  }
}
