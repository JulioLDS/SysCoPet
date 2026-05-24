import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import '../../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleRegister; // Callback para ir para Cadastro
  final VoidCallback onForgotPassword; // Callback para ir para Recuperação

  const LoginScreen({
    super.key,
    required this.onToggleRegister,
    required this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  
}


class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Text(
              'Entrar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.onToggleRegister,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
        const Divider(height: 32),

        const SizedBox(height: 24),

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
        const SizedBox(height: 32),

        // Campos de Input
        TextField(
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Senha',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_outlined),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),

        // Esqueci minha senha
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onForgotPassword,
            child: const Text('Esqueci minha senha'),
          ),
        ),
        const SizedBox(height: 24),

        // Botão Entrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                :() async {

                  final success = await authProvider.login(
                    email: emailController.text,
                    password: passwordController.text
                    );

                    if (!mounted) return;

                    if(!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login inválido"),
                        )
                      );
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                       MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                        )
                        );

              // TODO: Implementar login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou', style: TextStyle(color: Colors.grey[600])),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Botões Sociais
        OutlinedButton.icon(
          onPressed: () {},
          icon: Image.asset(
            'assets/icons/google.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, size: 24);
            },
          ),
          label: const Text('Entrar com Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.apple, size: 24),
          label: const Text('Entrar com Apple'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 32),

        // Link para Cadastro
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ainda não tem uma conta? ',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: widget.onToggleRegister,
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
