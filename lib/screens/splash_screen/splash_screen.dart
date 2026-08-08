import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Aguarda o load session terminar
    if (!authProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Decide se vai pra home ou pro onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.currentUser != null) {
        // ✅ Usuário logado → Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ✅ Usuário não logado → Onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
