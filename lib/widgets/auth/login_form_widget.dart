import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoToRegister;
  final VoidCallback onGoogleLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onGoToRegister,
    required this.onGoogleLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _obscurePassword = true;
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = widget.onGoToRegister;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bem-vindo de volta! ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset('assets/icons/patas.svg', height: 30, width: 30),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Faça login para continuar cuidando do seu pet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Campo E-mail
          TextField(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(widget.passwordFocusNode),
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

          // Campo Senha com visibilidade
          TextField(
            controller: widget.passwordController,
            focusNode: widget.passwordFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => widget.onLogin(),
            obscureText: _obscurePassword,
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
              onPressed: widget.isLoading ? null : widget.onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
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
            onPressed: widget.onGoogleLogin,
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
            child: Text.rich(
              TextSpan(
                text: 'Ainda não tem uma conta? ',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Cadastre-se',
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    recognizer: _tapRecognizer,
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
